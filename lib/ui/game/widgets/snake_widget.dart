import 'package:flutter/material.dart';
import 'dart:math';
import 'simple_snake_widget.dart';
import 'continuous_snake_widget.dart';

enum SnakeType { simple, continuous }

abstract class SnakeWidget extends Widget {
  factory SnakeWidget({
    SnakeType type = SnakeType.simple,
    Key? key,
    required Point<int> boardSize,
    required double cellSize,
  }) {
    switch(type){
      case SnakeType.simple:
        return SimpleSnakeWidget(boardSize: boardSize, cellSize: cellSize);
      case SnakeType.continuous:
        return ContinuousSnakeWidget(boardSize: boardSize, cellSize: cellSize);
      default:
        throw UnimplementedError();
    }
  }
}

