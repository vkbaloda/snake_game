import 'package:equatable/equatable.dart';
import 'package:snake_game/domain/direction_enum.dart';

abstract class GameProviderEvent extends Equatable {}

class UserInteractionEvent extends GameProviderEvent {
  final Direction dir;
  UserInteractionEvent(this.dir);

  @override
  List<Object?> get props => [dir];
}

class RestartEvent extends GameProviderEvent{
  @override
  List<Object?> get props => [];
}

class ChangeSnakeEvent extends GameProviderEvent{
  @override
  List<Object?> get props => [];
}