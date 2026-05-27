import 'package:app/features/quiz/puzzle/models/periodic_puzzle_answer.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_board.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_layer.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_progress.dart';

class PeriodicPuzzleProgressRepository {
  PeriodicPuzzleProgressRepository({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static final PeriodicPuzzleProgressRepository instance =
      PeriodicPuzzleProgressRepository();

  final DateTime Function() _clock;
  PeriodicPuzzleProgress _progress = PeriodicPuzzleProgress.initial();

  PeriodicPuzzleProgress get progress => _progress;

  Duration get elapsedTime {
    final completedElapsed = _progress.completedElapsed;
    if (completedElapsed != null) {
      return completedElapsed;
    }

    final startedAt = _progress.runStartedAt;
    if (startedAt == null) {
      return Duration.zero;
    }

    final duration = _clock().difference(startedAt);
    return duration.isNegative ? Duration.zero : duration;
  }

  void startRunIfNeeded() {
    if (_progress.runStartedAt != null) {
      return;
    }
    _progress = _progress.copyWith(runStartedAt: _clock());
  }

  PeriodicPuzzleBoardProgress progressForBoard(PeriodicPuzzleBoard board) {
    final existing = _progress.boardProgressById[board.id];
    if (existing != null) {
      return existing;
    }

    final created = PeriodicPuzzleBoardProgress.initial(
      boardId: board.id,
      totalMissingTiles: board.missingTiles.length,
      maxHints: board.maxHints,
    );
    _progress = _progress.copyWith(
      boardProgressById: {..._progress.boardProgressById, board.id: created},
    );
    return created;
  }

  bool isLayerUnlocked(PeriodicPuzzleLayer layer) {
    return _progress.isLayerUnlocked(layer);
  }

  bool isLayerCompleted(PeriodicPuzzleLayer layer) {
    return _progress.isLayerCompleted(layer);
  }

  bool isBoardCompleted(String boardId) {
    return _progress.isBoardCompleted(boardId);
  }

  PeriodicPuzzleBoardProgress submitAnswer({
    required PeriodicPuzzleBoard board,
    required String tileSymbol,
    required String selectedOptionId,
  }) {
    final current = progressForBoard(board);
    final isCorrect = tileSymbol == selectedOptionId;
    final nextAttempts = [
      ...current.attempts,
      PeriodicPuzzleAnswer(
        tileSymbol: tileSymbol,
        selectedOptionId: selectedOptionId,
        isCorrect: isCorrect,
      ),
    ];

    final nextProgress = current.copyWith(
      filledTileIds: isCorrect
          ? {...current.filledTileIds, tileSymbol}
          : current.filledTileIds,
      mistakes: isCorrect ? current.mistakes : current.mistakes + 1,
      attempts: nextAttempts,
    );
    _storeBoardProgress(nextProgress);
    return nextProgress;
  }

  PeriodicPuzzleBoardProgress? useHint(PeriodicPuzzleBoard board) {
    final current = progressForBoard(board);
    if (current.hintsRemaining <= 0) {
      return null;
    }

    final nextProgress = current.copyWith(
      hintsRemaining: current.hintsRemaining - 1,
      hintsUsed: current.hintsUsed + 1,
    );
    _storeBoardProgress(nextProgress);
    return nextProgress;
  }

  void completeBoard({
    required PeriodicPuzzleBoard board,
    required List<String> siblingBoardIds,
  }) {
    final completedBoardIds = {..._progress.completedBoardIds, board.id};
    final completedLayers = {..._progress.completedLayers};
    final unlockedLayers = {..._progress.unlockedLayers};
    var completedElapsed = _progress.completedElapsed;

    if (siblingBoardIds.every(completedBoardIds.contains)) {
      completedLayers.add(board.layer);
      switch (board.layer) {
        case PeriodicPuzzleLayer.starter:
          unlockedLayers.add(PeriodicPuzzleLayer.groups);
        case PeriodicPuzzleLayer.groups:
          unlockedLayers.add(PeriodicPuzzleLayer.mixed);
        case PeriodicPuzzleLayer.mixed:
          completedElapsed ??= elapsedTime;
          break;
      }
    }

    _progress = _progress.copyWith(
      completedBoardIds: completedBoardIds,
      completedLayers: completedLayers,
      unlockedLayers: unlockedLayers,
      completedElapsed: completedElapsed,
    );
  }

  int totalStars(Iterable<PeriodicPuzzleBoardProgress> boardProgresses) {
    return boardProgresses.fold(0, (sum, progress) => sum + progress.stars);
  }

  int totalMistakes(Iterable<PeriodicPuzzleBoardProgress> boardProgresses) {
    return boardProgresses.fold(0, (sum, progress) => sum + progress.mistakes);
  }

  int totalHintsUsed(Iterable<PeriodicPuzzleBoardProgress> boardProgresses) {
    return boardProgresses.fold(0, (sum, progress) => sum + progress.hintsUsed);
  }

  void resetAll() {
    _progress = PeriodicPuzzleProgress.initial();
  }

  void _storeBoardProgress(PeriodicPuzzleBoardProgress boardProgress) {
    _progress = _progress.copyWith(
      boardProgressById: {
        ..._progress.boardProgressById,
        boardProgress.boardId: boardProgress,
      },
    );
  }
}
