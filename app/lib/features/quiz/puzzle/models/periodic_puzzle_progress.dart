import 'package:app/features/quiz/puzzle/models/periodic_puzzle_answer.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_layer.dart';

class PeriodicPuzzleBoardProgress {
  const PeriodicPuzzleBoardProgress({
    required this.boardId,
    required this.totalMissingTiles,
    required this.filledTileIds,
    required this.mistakes,
    required this.hintsRemaining,
    required this.hintsUsed,
    required this.attempts,
  });

  final String boardId;
  final int totalMissingTiles;
  final Set<String> filledTileIds;
  final int mistakes;
  final int hintsRemaining;
  final int hintsUsed;
  final List<PeriodicPuzzleAnswer> attempts;

  factory PeriodicPuzzleBoardProgress.initial({
    required String boardId,
    required int totalMissingTiles,
    required int maxHints,
  }) {
    return PeriodicPuzzleBoardProgress(
      boardId: boardId,
      totalMissingTiles: totalMissingTiles,
      filledTileIds: <String>{},
      mistakes: 0,
      hintsRemaining: maxHints,
      hintsUsed: 0,
      attempts: const <PeriodicPuzzleAnswer>[],
    );
  }

  bool get isComplete => filledTileIds.length >= totalMissingTiles;

  int get stars {
    if (mistakes == 0) {
      return 3;
    }
    if (mistakes <= 2) {
      return 2;
    }
    return 1;
  }

  bool isFilled(String tileId) => filledTileIds.contains(tileId);

  PeriodicPuzzleBoardProgress copyWith({
    Set<String>? filledTileIds,
    int? mistakes,
    int? hintsRemaining,
    int? hintsUsed,
    List<PeriodicPuzzleAnswer>? attempts,
  }) {
    return PeriodicPuzzleBoardProgress(
      boardId: boardId,
      totalMissingTiles: totalMissingTiles,
      filledTileIds: filledTileIds ?? this.filledTileIds,
      mistakes: mistakes ?? this.mistakes,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      attempts: attempts ?? this.attempts,
    );
  }
}

class PeriodicPuzzleProgress {
  const PeriodicPuzzleProgress({
    required this.unlockedLayers,
    required this.completedLayers,
    required this.completedBoardIds,
    required this.boardProgressById,
    required this.runStartedAt,
    required this.completedElapsed,
  });

  final Set<PeriodicPuzzleLayer> unlockedLayers;
  final Set<PeriodicPuzzleLayer> completedLayers;
  final Set<String> completedBoardIds;
  final Map<String, PeriodicPuzzleBoardProgress> boardProgressById;
  final DateTime? runStartedAt;
  final Duration? completedElapsed;

  factory PeriodicPuzzleProgress.initial() {
    return const PeriodicPuzzleProgress(
      unlockedLayers: {PeriodicPuzzleLayer.starter},
      completedLayers: <PeriodicPuzzleLayer>{},
      completedBoardIds: <String>{},
      boardProgressById: <String, PeriodicPuzzleBoardProgress>{},
      runStartedAt: null,
      completedElapsed: null,
    );
  }

  bool isLayerUnlocked(PeriodicPuzzleLayer layer) {
    return unlockedLayers.contains(layer);
  }

  bool isLayerCompleted(PeriodicPuzzleLayer layer) {
    return completedLayers.contains(layer);
  }

  bool isBoardCompleted(String boardId) {
    return completedBoardIds.contains(boardId);
  }

  PeriodicPuzzleProgress copyWith({
    Set<PeriodicPuzzleLayer>? unlockedLayers,
    Set<PeriodicPuzzleLayer>? completedLayers,
    Set<String>? completedBoardIds,
    Map<String, PeriodicPuzzleBoardProgress>? boardProgressById,
    DateTime? runStartedAt,
    Duration? completedElapsed,
  }) {
    return PeriodicPuzzleProgress(
      unlockedLayers: unlockedLayers ?? this.unlockedLayers,
      completedLayers: completedLayers ?? this.completedLayers,
      completedBoardIds: completedBoardIds ?? this.completedBoardIds,
      boardProgressById: boardProgressById ?? this.boardProgressById,
      runStartedAt: runStartedAt ?? this.runStartedAt,
      completedElapsed: completedElapsed ?? this.completedElapsed,
    );
  }
}
