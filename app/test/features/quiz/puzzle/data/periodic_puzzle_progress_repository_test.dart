import 'package:app/features/quiz/puzzle/data/periodic_puzzle_generator.dart';
import 'package:app/features/quiz/puzzle/data/periodic_puzzle_progress_repository.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_layer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const generator = PeriodicPuzzleGenerator();
  late PeriodicPuzzleProgressRepository repository;

  setUp(() {
    repository = PeriodicPuzzleProgressRepository();
  });

  test('Correct answer fills tile and wrong answer does not', () {
    final board = generator.boardsForLayer(PeriodicPuzzleLayer.starter).single;
    final tile = board.missingTiles.first;

    final wrong = repository.submitAnswer(
      board: board,
      tileSymbol: tile.id,
      selectedOptionId: tile.options
          .firstWhere((option) => option.id != tile.id)
          .id,
    );
    expect(wrong.isFilled(tile.id), isFalse);
    expect(wrong.mistakes, 1);

    final correct = repository.submitAnswer(
      board: board,
      tileSymbol: tile.id,
      selectedOptionId: tile.id,
    );
    expect(correct.isFilled(tile.id), isTrue);
  });

  test('Board completes only when all missing tiles are filled', () {
    final board = generator.boardsForLayer(PeriodicPuzzleLayer.starter).single;

    for (final tile in board.missingTiles.take(board.missingTiles.length - 1)) {
      repository.submitAnswer(
        board: board,
        tileSymbol: tile.id,
        selectedOptionId: tile.id,
      );
    }

    expect(repository.progressForBoard(board).isComplete, isFalse);

    final lastTile = board.missingTiles.last;
    repository.submitAnswer(
      board: board,
      tileSymbol: lastTile.id,
      selectedOptionId: lastTile.id,
    );

    expect(repository.progressForBoard(board).isComplete, isTrue);
  });

  test('Completing Layer 1 unlocks Layer 2', () {
    final board = generator.boardsForLayer(PeriodicPuzzleLayer.starter).single;

    _completeBoard(repository, board);
    repository.completeBoard(board: board, siblingBoardIds: [board.id]);

    expect(repository.isLayerUnlocked(PeriodicPuzzleLayer.groups), isTrue);
  });

  test('Completing all Layer 2 groups unlocks Layer 3', () {
    final boards = generator.boardsForLayer(PeriodicPuzzleLayer.groups);

    for (final board in boards) {
      _completeBoard(repository, board);
      repository.completeBoard(
        board: board,
        siblingBoardIds: boards.map((item) => item.id).toList(),
      );
    }

    expect(repository.isLayerUnlocked(PeriodicPuzzleLayer.mixed), isTrue);
  });

  test('Completing Layer 3 marks puzzle complete for that layer', () {
    final board = generator.boardsForLayer(PeriodicPuzzleLayer.mixed).single;

    _completeBoard(repository, board);
    repository.completeBoard(board: board, siblingBoardIds: [board.id]);

    expect(repository.isLayerCompleted(PeriodicPuzzleLayer.mixed), isTrue);
  });

  test('Stars are calculated from mistakes', () {
    final board = generator.boardsForLayer(PeriodicPuzzleLayer.starter).single;
    final tile = board.missingTiles.first;

    repository.submitAnswer(
      board: board,
      tileSymbol: tile.id,
      selectedOptionId: tile.options
          .firstWhere((option) => option.id != tile.id)
          .id,
    );
    repository.submitAnswer(
      board: board,
      tileSymbol: tile.id,
      selectedOptionId: tile.id,
    );

    expect(repository.progressForBoard(board).stars, 2);
  });

  test('Hints decrement, do not go below zero, and reset per board', () {
    final starter = generator
        .boardsForLayer(PeriodicPuzzleLayer.starter)
        .single;
    final mixed = generator.boardsForLayer(PeriodicPuzzleLayer.mixed).single;

    repository.useHint(starter);
    repository.useHint(starter);
    repository.useHint(starter);
    repository.useHint(starter);

    expect(repository.progressForBoard(starter).hintsRemaining, 0);
    expect(repository.progressForBoard(mixed).hintsRemaining, 3);
  });

  test('Timer starts with the run and resets for a new full puzzle run', () {
    var now = DateTime(2026, 5, 20, 12, 0, 0);
    repository = PeriodicPuzzleProgressRepository(clock: () => now);

    repository.startRunIfNeeded();
    expect(repository.elapsedTime, Duration.zero);

    now = now.add(const Duration(minutes: 2, seconds: 34));
    expect(repository.elapsedTime, const Duration(minutes: 2, seconds: 34));

    repository.resetAll();
    expect(repository.elapsedTime, Duration.zero);

    now = now.add(const Duration(seconds: 5));
    repository.startRunIfNeeded();
    now = now.add(const Duration(seconds: 5));
    expect(repository.elapsedTime, const Duration(seconds: 5));
  });

  test('Final completion freezes the elapsed time', () {
    var now = DateTime(2026, 5, 20, 12, 0, 0);
    repository = PeriodicPuzzleProgressRepository(clock: () => now);
    final board = generator.boardsForLayer(PeriodicPuzzleLayer.mixed).single;

    repository.startRunIfNeeded();
    _completeBoard(repository, board);
    now = now.add(const Duration(minutes: 4, seconds: 10));
    repository.completeBoard(board: board, siblingBoardIds: [board.id]);

    expect(repository.elapsedTime, const Duration(minutes: 4, seconds: 10));

    now = now.add(const Duration(minutes: 1));
    expect(repository.elapsedTime, const Duration(minutes: 4, seconds: 10));
  });
}

void _completeBoard(
  PeriodicPuzzleProgressRepository repository,
  dynamic board,
) {
  for (final tile in board.missingTiles) {
    repository.submitAnswer(
      board: board,
      tileSymbol: tile.id,
      selectedOptionId: tile.id,
    );
  }
}
