import 'dart:math' show Point;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:provider/provider.dart';
import 'package:snake_game/ui/game/provider/game_provider.dart';
import 'package:snake_game/ui/game/widgets/continuous_snake_widget.dart';
import 'package:snake_game/ui/game/widgets/snake_widget.dart';

class SimpleSnakeWidget extends StatefulWidget implements SnakeWidget {
  final Point<int> boardSize;
  final double cellSize;
  const SimpleSnakeWidget({
    Key? key,
    required this.boardSize,
    required this.cellSize,
  }) : super(key: key);

  @override
  _SimpleSnakeWidgetState createState() => _SimpleSnakeWidgetState();
}

class _SimpleSnakeWidgetState extends State<SimpleSnakeWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.boardSize.x * widget.cellSize,
      height: widget.boardSize.y * widget.cellSize,
      child: Consumer<IGameProvider>(
        builder: (context, provider, _) {
          final body = provider.snake.snakeBodyPoints.keys.toList();
          return Stack(
            children: List.generate(
              body.length,
              (index) {
                final unit = body[index];
                return Positioned(
                  key: ValueKey(unit),
                  top: unit.y * widget.cellSize,
                  left: unit.x * widget.cellSize,
                  child: SnakeUnitWidget(
                    cellSize: widget.cellSize,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class SnakeUnitWidget extends StatelessWidget {
  final double cellSize;
  const SnakeUnitWidget({Key? key, required this.cellSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cellSize,
      width: cellSize,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: DecoratedBox(
          decoration: const ShapeDecoration(
            shape: CircleBorder(),
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
