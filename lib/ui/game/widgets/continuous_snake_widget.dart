import 'dart:async' show Timer;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snake_game/domain/direction_enum.dart';
import 'package:snake_game/domain/entities/body_corner_entity.dart';
import 'package:snake_game/ui/game/provider/game_provider.dart'
    show IGameProvider, GameState;
import 'package:snake_game/ui/game/widgets/snake_widget.dart';

class ContinuousSnakeWidget extends StatefulWidget implements SnakeWidget {
  final Point<int> boardSize;
  final double cellSize;
  const ContinuousSnakeWidget({
    Key? key,
    required this.boardSize,
    required this.cellSize,
  }) : super(key: key);

  @override
  _ContinuousSnakeWidgetState createState() => _ContinuousSnakeWidgetState();
}

class _ContinuousSnakeWidgetState extends State<ContinuousSnakeWidget> {
  static const _gameFrameDuration = Duration(milliseconds: 1000 ~/ 30);
  static const _bodyWidth = 0.2;
  Color get _bodyColor => Colors.amber;
  Color get _headColor => Colors.blue;
  Timer? _snakeTimer;

  @override
  void dispose() {
    _snakeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.boardSize.x * widget.cellSize,
      height: widget.boardSize.y * widget.cellSize,
      child: Consumer<IGameProvider>(
        builder: (context, provider, _) {
          if (provider.gameState == GameState.inGame && _snakeTimer == null) {
            _startTimer();
          } else if (provider.gameState == GameState.end) {
            _snakeTimer?.cancel();
            _snakeTimer = null;
          }
          final cellFraction = (provider.gameRunFraction + 0.5) % 1;
          final snake = provider.snake;
          final joints = List<BodyCorner>.from(snake.snakeJoints);
          final tailJoint = joints.last;
          final headJoint = joints.first;
          if (snake.tailInTurn) {
            joints.removeLast();
          } else {
            joints.last = tailJoint.copyWith(
              turnPoint: _getNextPoint(
                tailJoint.turnPoint,
                tailJoint.turnDir,
              ),
            );
          }
          if (!snake.headInTurn) {
            joints.first = headJoint.copyWith(
              turnPoint: _getNextPoint(
                headJoint.turnPoint,
                oppositeDir(headJoint.turnDir),
              ),
            );
          } else {
            if (cellFraction < 0.8) {
              joints.first = headJoint.copyWith(
                turnPoint: _getNextPoint(
                  headJoint.turnPoint,
                  oppositeDir(snake.currentDirection),
                ),
              );
            }
          }
          //dir of first joint not right in else case; its not used anywhere
          // debugPrint(joints.toString() + " $cellFraction");

          return Stack(
            children: [
              //tail
              _getTail(tailJoint, cellFraction,
                  inTurn: snake.tailInTurn, extraLen: snake.extraSnakeLength),

              //trunks; todo: tail trunk may not be right
              ...List.generate(
                joints.length - 1,
                (i) => _getTrunk(i, joints),
                growable: false,
              ),

              //head
              ..._getHead(headJoint, cellFraction, snake.currentDirection,
                  inTurn: snake.headInTurn),
            ],
          );
        },
      ),
    );
  }

  void _startTimer() {
    _snakeTimer = Timer.periodic(_gameFrameDuration, (timer) {
      setState(() {});
    });
  }

  List<Positioned> _getHead(
      BodyCorner headJoint, double cellFraction, Direction snakeDir,
      {required bool inTurn}) {
    final isHeadTopLeft = !_isDirRightDown(snakeDir);
    final isVert = isVertical(snakeDir);
    final padding = inTurn && cellFraction > 0.8 ? 1.2 : 0.8;
    return [
      //trunk
      Positioned(
        left: (headJoint.turnPoint.x + (isVert || isHeadTopLeft ? 0 : -1)) *
            widget.cellSize,
        top: (headJoint.turnPoint.y + (!isVert || isHeadTopLeft ? 0 : -1)) *
            widget.cellSize,
        child: Container(
          width: (isVert ? 1 : 2) * widget.cellSize,
          height: (!isVert ? 1 : 2) * widget.cellSize,
          padding: EdgeInsets.fromLTRB(
            (isVert
                    ? _bodyWidth
                    : isHeadTopLeft
                        ? (1 - cellFraction)
                        : padding) *
                widget.cellSize,
            (!isVert
                    ? _bodyWidth
                    : isHeadTopLeft
                        ? (1 - cellFraction)
                        : padding) *
                widget.cellSize,
            (isVert
                    ? _bodyWidth
                    : !isHeadTopLeft
                        ? (1 - cellFraction)
                        : padding) *
                widget.cellSize,
            (!isVert
                    ? _bodyWidth
                    : !isHeadTopLeft
                        ? (1 - cellFraction)
                        : padding) *
                widget.cellSize,
          ),
          child: Ink(color: _bodyColor),
        ),
      ),
      //face
      Positioned(
        left: (headJoint.turnPoint.x +
                (isVert ? 0 : (1 - cellFraction) * (isHeadTopLeft ? 1 : -1))) *
            widget.cellSize,
        top: (headJoint.turnPoint.y +
                (!isVert ? 0 : (1 - cellFraction) * (isHeadTopLeft ? 1 : -1))) *
            widget.cellSize,
        child: Container(
          key: ValueKey("head"),
          width: widget.cellSize,
          height: widget.cellSize,
          padding: EdgeInsets.all(0.05 * widget.cellSize),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: CircleBorder(),
              color: _headColor,
            ),
          ),
        ),
      ),
    ];
  }

  Positioned _getTail(BodyCorner tailJoint, double cellFraction,
      {required bool inTurn, required int extraLen}) {
    final isTailTopLeft = _isDirRightDown(tailJoint.turnDir);
    final isVert = isVertical(tailJoint.turnDir);
    final mainPadding = extraLen > 0 ? 0.5 : (cellFraction + (inTurn ? 1 : 0));
    return Positioned(
      left: (tailJoint.turnPoint.x + (isVert || isTailTopLeft ? 0 : -1)) *
          widget.cellSize,
      top: (tailJoint.turnPoint.y + (!isVert || isTailTopLeft ? 0 : -1)) *
          widget.cellSize,
      child: Container(
        width: (isVert ? 1 : 2) * widget.cellSize,
        height: (!isVert ? 1 : 2) * widget.cellSize,
        padding: EdgeInsets.fromLTRB(
          (isVert
                  ? _bodyWidth
                  : isTailTopLeft
                      ? mainPadding
                      : 0.5) *
              widget.cellSize,
          (!isVert
                  ? _bodyWidth
                  : isTailTopLeft
                      ? mainPadding
                      : 0.5) *
              widget.cellSize,
          (isVert
                  ? _bodyWidth
                  : !isTailTopLeft
                      ? mainPadding
                      : 0.5) *
              widget.cellSize,
          (!isVert
                  ? _bodyWidth
                  : !isTailTopLeft
                      ? mainPadding
                      : 0.5) *
              widget.cellSize,
        ),
        child: Ink(color: _bodyColor),
      ),
    );
  }

  Positioned _getTrunk(int i, List<BodyCorner> joints) {
    final curJoint = joints[i];
    // debugPrint(curJoint.toString());
    final nextJoint = joints[i + 1];
    final isCurFirst = !_isDirRightDown(nextJoint.turnDir);
    final isVert = isVertical(nextJoint.turnDir);
    return Positioned(
      left: (isCurFirst ? curJoint.turnPoint.x : nextJoint.turnPoint.x) *
          widget.cellSize,
      top: (isCurFirst ? curJoint.turnPoint.y : nextJoint.turnPoint.y) *
          widget.cellSize,
      child: Container(
        width: (isVert
                ? 1
                : (curJoint.turnPoint.x - nextJoint.turnPoint.x) *
                        (isCurFirst ? -1 : 1) +
                    1) *
            widget.cellSize,
        height: (isVert
                ? (curJoint.turnPoint.y - nextJoint.turnPoint.y) *
                        (isCurFirst ? -1 : 1) +
                    1
                : 1) *
            widget.cellSize,
        padding: EdgeInsets.all(_bodyWidth * widget.cellSize),
        child: Ink(color: _bodyColor),
      ),
    );
  }

  bool _isDirRightDown(Direction dir) {
    return dir == Direction.right || dir == Direction.down;
  }

  Matrix4 _getRotation(Direction dir) {
    switch (dir) {
      case Direction.left:
        return Matrix4.rotationZ(-pi);
      case Direction.down:
        return Matrix4.rotationZ(pi / 2);
      case Direction.right:
        return Matrix4.identity();
      case Direction.up:
        return Matrix4.rotationZ(-pi / 2);
      default:
        throw UnimplementedError();
    }
  }

  Point<int> _getNextPoint(Point<int> cur, Direction dir) {
    switch (dir) {
      case Direction.left:
        return Point(cur.x - 1, cur.y);
      case Direction.up:
        return Point(cur.x, cur.y - 1);
      case Direction.right:
        return Point(cur.x + 1, cur.y);
      case Direction.down:
        return Point(cur.x, cur.y + 1);
      default:
        throw UnimplementedError();
    }
  }
}
