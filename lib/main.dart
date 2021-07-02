import 'package:flutter/material.dart';
import 'package:snake_game/ui/game/game_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      home: GamePage(),
    );
  }
}
