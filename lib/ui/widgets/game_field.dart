import 'package:flutter/material.dart';
import 'package:snake_game/ui/widgets/field_cell.dart';

class GameField extends StatelessWidget {
  final int rows;
  final int columns;
  final double cellSize;
  const GameField({
    Key? key,
    required this.columns,
    required this.rows,
    required this.cellSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Table(
      defaultColumnWidth: FixedColumnWidth(cellSize),
      children: List.generate(
        rows,
        (row) => TableRow(
          children: List.generate(
            columns,
            (col) => SizedBox(
              height: cellSize,
              width: cellSize,
              child: SimpleFieldCell(row: row, column: col),
            ),
          ),
        ),
      ),
    );
  }
}
