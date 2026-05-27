class PeriodicPuzzleBestTimeEntry {
  const PeriodicPuzzleBestTimeEntry({
    required this.playerName,
    required this.totalElapsedTime,
    required this.totalStars,
    required this.totalMistakes,
    required this.totalHintsUsed,
    required this.completedAt,
  });

  final String playerName;
  final Duration totalElapsedTime;
  final int totalStars;
  final int totalMistakes;
  final int totalHintsUsed;
  final DateTime completedAt;
}
