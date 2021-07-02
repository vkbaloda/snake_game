import 'package:flutter/material.dart';

class SimpleFieldCell extends StatelessWidget {
  final int row, column;
  const SimpleFieldCell({Key? key, required this.column, required this.row})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Ink(
      color: (row + column).isEven ? Colors.green : Colors.lightGreen,
      // decoration: BoxDecoration(border: Border.all()),
    );
  }
}
