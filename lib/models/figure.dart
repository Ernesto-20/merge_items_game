import 'package:equatable/equatable.dart';

class FigureInfo extends Equatable {
  FigureInfo(
      {required this.id,
      required this.rowIndex,
      required this.columnIndex,
      required this.steps,
      required this.lvl,
      this.levelUp = false});

  int id;
  int rowIndex;
  int columnIndex;
  int steps;
  int lvl;

  bool levelUp;

  @override
  List<Object?> get props => [id, rowIndex, columnIndex, steps, levelUp];

  FigureInfo copyWidth(
    {final int? id,
    final int? rowIndex,
    final int? columnIndex,
    final int? steps,
    final int? lvl,
    final bool? levelUp,}
  ) {
    return FigureInfo(
        id: id ?? this.id,
        rowIndex: rowIndex ?? this.rowIndex,
        columnIndex: columnIndex ?? this.columnIndex,
        steps: steps ?? this.steps,
        lvl: lvl ?? this.lvl);
  }
}
