import 'package:flutter/material.dart';

import 'package:app/features/quiz/models/quiz_language.dart';
import 'package:app/features/quiz/models/quiz_question.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_board.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_tile.dart';
import 'package:app/features/quiz/puzzle/presentation/widgets/periodic_puzzle_tile_widget.dart';

class PeriodicPuzzleBoardWidget extends StatelessWidget {
  const PeriodicPuzzleBoardWidget({
    super.key,
    required this.board,
    required this.language,
    required this.filledTileIds,
    required this.selectedTileId,
    required this.onTileTap,
    required this.localizedNameForTile,
    this.completedTileId,
  });

  final PeriodicPuzzleBoard board;
  final QuizLanguage language;
  final Set<String> filledTileIds;
  final String? selectedTileId;
  final String? completedTileId;
  final ValueChanged<PeriodicPuzzleTile> onTileTap;
  final String Function(PeriodicPuzzleTile tile) localizedNameForTile;

  @override
  Widget build(BuildContext context) {
    final tilesByPosition = <String, PeriodicPuzzleTile>{
      for (final tile in board.tiles) '${tile.row}-${tile.column}': tile,
    };

    final compressedColumns = _compressedColumnUnits();

    return LayoutBuilder(
      builder: (context, constraints) {
        final safeWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 820.0;
        final gap = safeWidth < 560 ? 4.0 : 5.0;
        final boardUnitWidth =
            compressedColumns.values.fold<double>(
              0,
              (max, value) => value > max ? value : max,
            ) +
            1;
        final maxBoardWidth = safeWidth.clamp(280.0, 900.0);
        final tileWidth =
            ((maxBoardWidth - ((boardUnitWidth - 1) * gap)) / boardUnitWidth)
                .clamp(48.0, 76.0);
        final tileHeight = (tileWidth * 1.08).clamp(52.0, 82.0);
        final rowGap = safeWidth < 560 ? 4.0 : 5.0;
        final step = tileWidth + gap;
        final boardWidth =
            (compressedColumns.values.fold<double>(
                  0,
                  (max, value) => value > max ? value : max,
                ) *
                step) +
            tileWidth;
        final boardHeight =
            ((board.maxRow + 1) * tileHeight) + (board.maxRow * rowGap);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: boardWidth,
            height: boardHeight,
            child: Stack(
              children: [
                for (var row = 0; row <= board.maxRow; row++)
                  for (var column = 0; column <= board.maxColumn; column++)
                    if (tilesByPosition['$row-$column'] case final tile?)
                      Positioned(
                        left: compressedColumns[column]! * step,
                        top: row * (tileHeight + rowGap),
                        width: tileWidth,
                        height: tileHeight,
                        child: _buildCell(
                          context,
                          tile,
                          tileWidth: tileWidth,
                          tileHeight: tileHeight,
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell(
    BuildContext context,
    PeriodicPuzzleTile tile, {
    required double tileWidth,
    required double tileHeight,
  }) {
    final categoryLabel = QuizAnswerOption(
      id: tile.element.sym,
      labelEnglish: tile.element.name,
      labelSpanish: tile.element.name,
      categoryKey: tile.element.cat,
    ).localizedCategory(language);
    final isFilled = !tile.isMissing || filledTileIds.contains(tile.id);

    return PeriodicPuzzleTileWidget(
      symbol: tile.element.sym,
      name: localizedNameForTile(tile),
      atomicNumber: tile.element.z,
      categoryKey: tile.element.cat,
      categoryLabel: categoryLabel,
      clueLabel: tile.clue?.labelFor(language),
      isMissing: tile.isMissing,
      isFilled: isFilled,
      isSelected: selectedTileId == tile.id && tile.isMissing && !isFilled,
      showSuccess: completedTileId == tile.id,
      tileWidth: tileWidth,
      tileHeight: tileHeight,
      onTap: tile.isMissing && !isFilled ? () => onTileTap(tile) : null,
    );
  }

  Map<int, double> _compressedColumnUnits() {
    final columns = board.tiles.map((tile) => tile.column).toSet().toList()
      ..sort();

    final positions = <int, double>{};
    double current = 0;
    int? previous;

    for (final column in columns) {
      if (previous != null) {
        final gap = column - previous;
        current += gap == 1 ? 1 : 1 + ((gap - 1) * 0.42);
      }
      positions[column] = current;
      previous = column;
    }

    return positions;
  }
}
