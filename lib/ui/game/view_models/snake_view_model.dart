import 'dart:math' show Point;

import 'package:fpdart/fpdart.dart' show Option;
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;
import 'package:snake_game/domain/direction_enum.dart';
import 'package:snake_game/domain/entities/body_corner_entity.dart';

enum SnakeState { inTurn, normal }
enum SnakeTailState { inTurn, normal }

@immutable
class SnakeViewModel extends Equatable {
  final Direction currentDirection;
  final Option<Direction> nextTurn;
  final SnakeState snakeState;
  final Map<Point<int>, int> snakeBodyPoints;
  final List<BodyCorner> snakeJoints;
  final SnakeTailState snakeTailState;
  final int extraSnakeLength;

  SnakeViewModel({
    required this.currentDirection,
    required this.nextTurn,
    required this.snakeState,
    required Map<Point<int>, int> snakeBodyPoints,
    required this.snakeTailState,
    required List<BodyCorner> snakeJoints,
    required this.extraSnakeLength,
  })  : this.snakeJoints = List<BodyCorner>.unmodifiable(snakeJoints),
        this.snakeBodyPoints =
            Map<Point<int>, int>.unmodifiable(snakeBodyPoints);

  bool get tailInTurn => snakeTailState == SnakeTailState.inTurn;
  bool get headInTurn => snakeState == SnakeState.inTurn;

  SnakeViewModel copyWith({
    Direction? currentDirection,
    Option<Direction>? nextTurn,
    SnakeState? snakeState,
    SnakeTailState? snakeTailState,
    Map<Point<int>, int>? snakeBodyPoints,
    List<BodyCorner>? snakeJoints,
    int? extraSnakeLength,
  }) {
    return SnakeViewModel(
      currentDirection: currentDirection ?? this.currentDirection,
      nextTurn: nextTurn ?? this.nextTurn,
      snakeState: snakeState ?? this.snakeState,
      snakeTailState: snakeTailState ?? this.snakeTailState,
      snakeBodyPoints: snakeBodyPoints ?? this.snakeBodyPoints,
      snakeJoints: snakeJoints ?? this.snakeJoints,
      extraSnakeLength: extraSnakeLength ?? this.extraSnakeLength,
    );
  }

  @override
  List<Object?> get props => [
        currentDirection,
        nextTurn,
        snakeState,
        snakeBodyPoints,
        snakeJoints,
        snakeTailState,
        extraSnakeLength,
      ];
}
