import 'dart:math' show Point, Random;
// import 'dart:developer' show log;
import 'dart:async' show Timer;

import 'package:flutter/cupertino.dart';
import 'package:fpdart/fpdart.dart' show Some, None;
import 'package:flutter/material.dart';
import 'package:snake_game/domain/direction_enum.dart';
import 'package:snake_game/domain/entities/body_corner_entity.dart';
import 'package:snake_game/domain/resources/constants.dart';
import 'package:snake_game/ui/game/provider/game_provider_events.dart';
import 'package:snake_game/ui/game/view_models/snake_view_model.dart';
import 'package:snake_game/ui/game/widgets/snake_widget.dart';

enum GameState { loading, start, inGame, end }

abstract class IGameProvider extends ChangeNotifier {
  double get gameRunFraction;
  Point<int> get boardSize;
  Point<int> get foodPosition;
  GameState get gameState;
  SnakeViewModel get snake;
  int get score;
  SnakeType get snakeType;

  Future<void> notify(GameProviderEvent event);
}

class GameProvider extends IGameProvider {
  late final Stopwatch _stopwatch;
  Timer? _gameTimer;
  late int baseTimeInMillis; //may have level wise constants
  late Point<int> foodPosition;
  late final Point<int> boardSize;
  int score;
  GameState gameState;
  SnakeType snakeType;
  late SnakeViewModel snake;
  double get gameRunFraction {
    final elapsedMillis = _stopwatch.elapsedMilliseconds;
    final watchTick =
        (elapsedMillis - baseTimeInMillis / 2) ~/ baseTimeInMillis;
    if (hold || watchTick != (_gameTimer?.tick ?? 0)) return 0.499;
    return (elapsedMillis % baseTimeInMillis) / baseTimeInMillis; //0 - 0.9975
  }

  final _random = Random();
  static const _turnFraction = 0.3;

  bool hold = false; //holds runFrag till the calculations to avoid a glitch

  //initiate
  GameProvider()
      : gameState = GameState.loading,
        score = 0,
        snakeType = SnakeType.simple {
    baseTimeInMillis = 300;
    boardSize = Point(defaultColumns, defaultRows);
    _stopwatch = Stopwatch();
    _initSnake();
    _updateFoodPosition().then((_) {
      gameState = GameState.start;
      this.notifyListeners();
    });
  }

  Future<void> _updateFoodPosition() async {
    //may take time if snake covers lot of field
    do {
      foodPosition =
          Point(_random.nextInt(boardSize.x), _random.nextInt(boardSize.y));
    } while (snake.snakeBodyPoints.containsKey(foodPosition));
  }

  void _initSnake() {
    final start = Point(4, 7);
    final end = Point(2, 7);
    snake = SnakeViewModel(
      currentDirection: Direction.right,
      nextTurn: None(),
      snakeState: SnakeState.normal,
      snakeTailState: SnakeTailState.normal,
      snakeBodyPoints: {
        start: 1,
        Point(3, 7): 1,
        end: 1,
      },
      snakeJoints: [
        BodyCorner(turnDir: Direction.right, turnPoint: start),
        BodyCorner(turnDir: Direction.right, turnPoint: end),
      ],
      extraSnakeLength: 0,
    );
  }

  @override
  Future<void> notify(GameProviderEvent event) async {
    debugPrint(event.runtimeType.toString());
    switch (event.runtimeType) {
      case UserInteractionEvent:
        debugPrint((event as UserInteractionEvent).dir.toString() +
            snake.snakeJoints.toString() +
            snake.snakeState.toString());
        if (gameState == GameState.loading) return;
        if (gameState == GameState.start) {
          if (event.dir == Direction.left) return;
          //game on
          gameState = GameState.inGame;
          Future.delayed(
            Duration(milliseconds: baseTimeInMillis ~/ 2),
            () {
              _gameTimer = Timer.periodic(
                Duration(milliseconds: baseTimeInMillis),
                _onCellChange,
              );
              _onCellChange(_gameTimer);
            },
          );
        }
        _stopwatch.start();
        _onTurn(event.dir);
        notifyListeners();
        break;
      case RestartEvent:
        score = 0;
        _stopwatch.reset();
        _gameTimer = null;
        hold = false;
        _initSnake();
        _updateFoodPosition().then((_) {
          gameState = GameState.start;
          this.notifyListeners();
        });
        break;
      case ChangeSnakeEvent:
        if (gameState != GameState.inGame) {
          snakeType = snakeType == SnakeType.simple
              ? SnakeType.continuous
              : SnakeType.simple;
          notifyListeners();
        }
        break;
      default:
        throw UnimplementedError("some event case is missed in the cases");
    }
  }

  void _onTurn(Direction dir) {
    if (snake.nextTurn.isSome()) return;
    if (snake.snakeJoints.first.turnDir == dir ||
        oppositeDir(snake.snakeJoints.first.turnDir) == dir) return;
    final runFraction = gameRunFraction;
    if (runFraction > 0.5) {
      debugPrint("2st half $runFraction");
      snake = snake.copyWith(nextTurn: Some(dir));
      _delayedTurn(runFraction);
    } else {
      debugPrint("1st half $runFraction");
      if (snake.headInTurn) {
        //snake.nextTurn == null
        snake = snake.copyWith(nextTurn: Some(dir));
        _delayedTurn(runFraction);
      } else {
        final joints = List<BodyCorner>.from(snake.snakeJoints);
        joints.first = joints.first.copyWith(turnDir: dir);
        snake = snake.copyWith(
          snakeState: SnakeState.inTurn,
          currentDirection: runFraction >= _turnFraction ? dir : null,
          snakeJoints: joints,
        );
        notifyListeners();
        if (runFraction < _turnFraction) _delayedDir(runFraction, dir);
      }
    }
  }

  void _delayedDir(double runFraction, Direction dir) {
    //runFraction in 0 - _turnFraction (0.4)
    Future.delayed(
      Duration(
        milliseconds:
            (baseTimeInMillis * (_turnFraction - runFraction)).round(),
      ),
      () {
        snake = snake.copyWith(currentDirection: dir);
      },
    );
  }

  void _delayedTurn(double runFraction) {
    // puts the nextTurn in action
    Future.delayed(
      Duration(
        milliseconds: (baseTimeInMillis * (1 - runFraction)).round(),
      ),
      () {
        if (gameState == GameState.end) return;
        assert(snake.nextTurn.isSome());
        final Direction newDir = snake.nextTurn.getOrElse(() => Direction.left);
        final joints = List<BodyCorner>.from(snake.snakeJoints);
        joints.first = joints.first.copyWith(turnDir: newDir);
        snake = snake.copyWith(
          nextTurn: None(),
          snakeState: SnakeState.inTurn,
          snakeJoints: joints,
        );
        notifyListeners();
        _delayedDir(0, newDir);
      },
    );
  }

  void _onCellChange(_) {
    // debugPrint("onCellChange ${_gameTimer!.tick}");
    hold = true;
    final headJoint = snake.snakeJoints.first;
    final nextHeadPoint = _getNextPoint(
      headJoint.turnPoint,
      headJoint.turnDir,
      isRigidWall: snakeType == SnakeType.continuous,
    );

    // is hitting wall, snakeBody, food
    if (_checkIfHittingWall(nextHeadPoint) ||
        _checkIfHittingBody(nextHeadPoint)) {
      return;
    }
    _checkIfHittingFood(nextHeadPoint);

    // change bodyPoints and add extra length
    final lastJoint = snake.snakeJoints.last;
    final newLastPoint = _getNextPoint(
      lastJoint.turnPoint,
      lastJoint.turnDir,
      isRigidWall: snakeType == SnakeType.continuous,
    );
    final headInTurn = snake.headInTurn;
    final bool willTailTurn =
        snake.snakeJoints[snake.snakeJoints.length - 2].turnPoint ==
            newLastPoint;
    final newBodyPoints = Map<Point<int>, int>.from(snake.snakeBodyPoints);
    final newSnakeJoints = List<BodyCorner>.from(snake.snakeJoints);

    //changes from head side
    newBodyPoints[nextHeadPoint] = (newBodyPoints[nextHeadPoint] ?? 0) + 1;
    if (!headInTurn) newSnakeJoints.removeAt(0);
    newSnakeJoints.insert(
      0,
      BodyCorner(turnDir: headJoint.turnDir, turnPoint: nextHeadPoint),
    );

    //changes from tail side
    if (snake.extraSnakeLength == 0) {
      final tailPointCount = newBodyPoints[lastJoint.turnPoint]!;
      if (tailPointCount > 1) {
        newBodyPoints[lastJoint.turnPoint] = tailPointCount - 1;
      } else {
        newBodyPoints.remove(lastJoint.turnPoint);
      }
      if (willTailTurn) {
        _delayedTurnTail();
      } else {
        newSnakeJoints.last =
            newSnakeJoints.last.copyWith(turnPoint: newLastPoint);
      }
    }

    snake = snake.copyWith(
      snakeBodyPoints: newBodyPoints,
      snakeJoints: newSnakeJoints,
      snakeState: headInTurn ? SnakeState.normal : null,
      snakeTailState: willTailTurn ? SnakeTailState.inTurn : null,
    );
    hold = false;

    // debugPrint(snake.toString());
    notifyListeners();
  }

  Point<int> _getNextPoint(Point<int> cur, Direction dir,
      {required bool isRigidWall}) {
    switch (dir) {
      case Direction.left:
        return Point(
          (cur.x - 1) % (boardSize.x + (isRigidWall ? 1 : 0)),
          cur.y,
        );
      case Direction.up:
        return Point(
          cur.x,
          (cur.y - 1) % (boardSize.y + (isRigidWall ? 1 : 0)),
        );
      case Direction.right:
        return Point(
          (cur.x + 1) % (boardSize.x + (isRigidWall ? 1 : 0)),
          cur.y,
        );
      case Direction.down:
        return Point(
          cur.x,
          (cur.y + 1) % (boardSize.y + (isRigidWall ? 1 : 0)),
        );
      default:
        throw UnimplementedError();
    }
  }

  void _checkIfHittingFood(Point<int> nextPoint) {
    if (nextPoint == foodPosition) {
      Future.delayed(
        Duration(milliseconds: baseTimeInMillis ~/ 2),
        () {
          score++;
          _updateFoodPosition();
          final extraLen = snake.snakeBodyPoints.length > 10 ? 1 : 2;
          snake = snake.copyWith(
            extraSnakeLength: extraLen,
          );
          notifyListeners();
          _decreaseLength(extraLen);
        },
      );
    }
  }

  void _decreaseLength(int extraLen) {
    Future.delayed(
      Duration(milliseconds: baseTimeInMillis),
      () {
        snake = snake.copyWith(extraSnakeLength: extraLen - 1);
        if (extraLen > 1) _decreaseLength(extraLen - 1);
      },
    );
  }

  bool _checkIfHittingWall(Point<int> nextPoint) {
    final isWall = nextPoint.x < 0 ||
        nextPoint.x >= boardSize.x ||
        nextPoint.y < 0 ||
        nextPoint.y >= boardSize.y;
    if (isWall) _gameOver();
    debugPrint("hitWallCheck: $isWall, $nextPoint");
    return isWall;
  }

  bool _checkIfHittingBody(Point<int> nextPoint) {
    final bodyMinusTail = snake.snakeBodyPoints.keys.toList()
      ..removeAt(0); //removes tail
    if (bodyMinusTail.contains(nextPoint)) {
      _gameOver();
      return true;
    }
    return false;
  }

  void _gameOver() {
    gameState = GameState.end;
    _stopwatch.stop();
    _gameTimer!.cancel();
    notifyListeners();
  }

  void _delayedTurnTail() {
    // puts the tailTurn in action
    Future.delayed(
      Duration(
        milliseconds: (baseTimeInMillis * 0.2).round(),
      ),
      () {
        debugPrint("-------delayTailTurnCalled");
        if (gameState == GameState.end) return;
        final joints = List<BodyCorner>.from(snake.snakeJoints)..removeLast();
        snake = snake.copyWith(
          snakeTailState: SnakeTailState.normal,
          snakeJoints: joints,
        );
        notifyListeners();
      },
    );
  }
}
