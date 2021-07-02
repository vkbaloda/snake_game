enum Direction {left, up, right, down}

Direction oppositeDir(Direction dir){
  switch(dir){
    case Direction.up:
      return Direction.down;
    case Direction.down:
      return Direction.up;
    case Direction.right:
      return Direction.left;
    case Direction.left:
      return Direction.right;
    default:
      throw UnimplementedError();
  }
}

bool isVertical(Direction dir){
  return dir == Direction.up || dir == Direction.down;
}