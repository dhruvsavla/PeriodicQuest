import 'package:app/features/quiz/puzzle/data/periodic_puzzle_generator.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_layer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const generator = PeriodicPuzzleGenerator();

  test('Layer 1 board uses the first 20 elements and has missing tiles', () {
    final board = generator.boardsForLayer(PeriodicPuzzleLayer.starter).single;
    final symbols = board.tiles.map((tile) => tile.element.sym).toList();

    expect(
      symbols,
      equals([
        'H',
        'He',
        'Li',
        'Be',
        'B',
        'C',
        'N',
        'O',
        'F',
        'Ne',
        'Na',
        'Mg',
        'Al',
        'Si',
        'P',
        'S',
        'Cl',
        'Ar',
        'K',
        'Ca',
      ]),
    );
    expect(board.missingTiles, isNotEmpty);
  });

  test(
    'Every missing tile has four unique options with the correct answer',
    () {
      final board = generator
          .boardsForLayer(PeriodicPuzzleLayer.starter)
          .single;

      for (final tile in board.missingTiles) {
        final optionIds = tile.options.map((option) => option.id).toList();
        expect(tile.options.length, 4);
        expect(optionIds.toSet().length, 4);
        expect(optionIds, contains(tile.id));
      }
    },
  );

  test('No duplicate missing tile ids exist on a board', () {
    final board = generator.boardsForLayer(PeriodicPuzzleLayer.starter).single;
    final missingIds = board.missingTiles.map((tile) => tile.id).toList();

    expect(missingIds.toSet().length, missingIds.length);
  });

  test('Layer 2 group boards generate with intended group symbols', () {
    final boards = generator.boardsForLayer(PeriodicPuzzleLayer.groups);

    expect(boards.length, 5);
    expect(boards.first.groupKey, 'noble-gases');
    expect(
      boards.first.tiles.map((tile) => tile.element.sym).toList(),
      equals(['He', 'Ne', 'Ar', 'Kr', 'Xe']),
    );
  });

  test('Layer 3 mixed board has more missing tiles than Layer 1', () {
    final starter = generator
        .boardsForLayer(PeriodicPuzzleLayer.starter)
        .single;
    final mixed = generator.boardsForLayer(PeriodicPuzzleLayer.mixed).single;

    expect(mixed.missingTiles.length, greaterThan(starter.missingTiles.length));
  });

  test(
    'Spanish clues work and missing translation fallback does not crash',
    () {
      final starter = generator
          .boardsForLayer(PeriodicPuzzleLayer.starter)
          .single;
      final spanishClue = starter.missingTiles.firstWhere(
        (tile) => tile.id == 'H',
      );

      expect(spanishClue.clue!.spanish, contains('Hidrógeno'));

      const fallbackGenerator = PeriodicPuzzleGenerator(
        spanishTranslations: {},
      );
      final fallbackBoard = fallbackGenerator
          .boardsForLayer(PeriodicPuzzleLayer.starter)
          .single;
      final fallbackClue = fallbackBoard.missingTiles.firstWhere(
        (tile) => tile.id == 'H',
      );

      expect(fallbackClue.clue!.spanish, contains('Hydrogen'));
    },
  );

  test('Generated option ids stay stable and symbol-based', () {
    final board = generator.boardsForLayer(PeriodicPuzzleLayer.mixed).single;
    final tile = board.missingTiles.firstWhere((item) => item.id == 'Au');

    expect(tile.options.map((option) => option.id), contains('Au'));
    expect(tile.options.every((option) => option.id.isNotEmpty), isTrue);
  });
}
