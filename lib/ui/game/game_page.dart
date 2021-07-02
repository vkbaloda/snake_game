import 'dart:math' show min, Point, pi;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snake_game/domain/direction_enum.dart';
import 'package:snake_game/ui/game/provider/game_provider.dart';
import 'package:snake_game/ui/game/provider/game_provider_events.dart';
import 'package:snake_game/ui/game/widgets/snake_widget.dart';
import 'package:snake_game/ui/widgets/food_widget.dart';
import 'package:snake_game/ui/widgets/game_field.dart';
import 'package:snake_game/domain/resources/constants.dart';
import 'package:snake_game/ui/widgets/repeated_bounce_animation.dart';

class GamePage extends StatelessWidget {
  const GamePage({Key? key}) : super(key: key);

  IGameProvider  _getGameProvider(BuildContext c) =>
      Provider.of<IGameProvider>(c, listen: false);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 16;
    final height = MediaQuery.of(context).size.height - 16;
    final cellSizeByWidth = min(width / defaultColumns, maxCellSize);
    final cellSizeByHeight = min(height / defaultRows, maxCellSize);
    final cellSize = min(cellSizeByHeight, cellSizeByWidth);

    return ChangeNotifierProvider<IGameProvider>(
      create: (context) => GameProvider(),
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Selector<IGameProvider, int>(
            selector: (_, pro) => pro.score,
            builder: (_, score, __) => Text("Score: $score"),
          ),
          actions: [
            IconButton(
              onPressed: () =>
                  _getGameProvider(context).notify(ChangeSnakeEvent()),
              icon: Icon(Icons.change_circle),
            ),
          ],
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanEnd: (details) => _onPanEnd(context, details),
          // onTap: () => debugPrint("tapped"),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Stack(
              children: [
                GameField(
                  rows: defaultRows,
                  columns: defaultColumns,
                  cellSize: cellSize,
                ),
                Selector<IGameProvider, Point<int>>(
                  selector: (_, pro) => pro.foodPosition,
                  builder: (_, loc, __) => Positioned(
                    top: loc.y * cellSize,
                    left: loc.x * cellSize,
                    child: RepeatedBounceAnimation(
                      child: SimpleFoodWidget(),
                      cellSize: cellSize,
                    ),
                  ),
                ),
                Selector<IGameProvider, SnakeType>(
                  selector: (_, pro) => pro.snakeType,
                  builder: (_, type, __) => SnakeWidget(
                    type: type,
                    cellSize: cellSize,
                    boardSize: _getGameProvider(context).boardSize,
                  ),
                ),
                Selector<IGameProvider, GameState>(
                  selector: (_, provider) => provider.gameState,
                  builder: (_, gs, __) => gs == GameState.end
                      ? Center(
                          child: InkWell(
                            onTap: () => _restart(context),
                            child: Container(
                              alignment: Alignment.center,
                              height: 200,
                              width: 300,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              child: Text(
                                "Game Over!\nclick here to restart",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _restart(BuildContext context) {
    _getGameProvider(context).notify(RestartEvent());
  }

  void _onPanEnd(BuildContext context, DragEndDetails details) {
    final provider = _getGameProvider(context);
    final swipeDir = _getDir(details.velocity.pixelsPerSecond.direction);
    if (details.velocity.pixelsPerSecond.distance > 400) {
      provider.notify(UserInteractionEvent(swipeDir));
    }
  }

  Direction _getDir(double dir) {
    if (dir < -0.75 * pi || dir > 0.75 * pi) return Direction.left;
    if (dir > 0.25 * pi) return Direction.down;
    if (dir > -0.25 * pi) return Direction.right;
    return Direction.up;
  }
}
