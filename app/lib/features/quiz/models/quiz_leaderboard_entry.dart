import 'quiz_mode_type.dart';

class QuizLeaderboardEntry {
  const QuizLeaderboardEntry({
    required this.playerName,
    required this.score,
    required this.totalQuestions,
    required this.mode,
    required this.hintsUsed,
    required this.createdAt,
  });

  final String playerName;
  final int score;
  final int totalQuestions;
  final QuizModeType mode;
  final int hintsUsed;
  final DateTime createdAt;

  double get percentage => totalQuestions == 0 ? 0 : score / totalQuestions;
}
