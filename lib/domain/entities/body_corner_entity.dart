import "dart:math" show Point;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;
import "package:snake_game/domain/direction_enum.dart";

@immutable
class BodyCorner extends Equatable {
  final Direction turnDir;
  final Point<int> turnPoint;

  BodyCorner({required this.turnDir, required this.turnPoint});

  BodyCorner copyWith({Direction? turnDir, Point<int>? turnPoint}) {
    return BodyCorner(
      turnDir: turnDir ?? this.turnDir,
      turnPoint: turnPoint ?? this.turnPoint,
    );
  }

  @override
  List<Object?> get props => [turnDir, turnPoint];
}
