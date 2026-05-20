import 'package:app/features/quiz/models/quiz_language.dart';
import 'package:app/features/quiz/models/quiz_leaderboard_entry.dart';
import 'package:app/features/quiz/models/quiz_mode_type.dart';
import 'package:app/features/quiz/models/quiz_session_result.dart';

class QuizLeaderboardRepository {
  QuizLeaderboardRepository();

  static final QuizLeaderboardRepository instance = QuizLeaderboardRepository();

  final Map<QuizModeType, List<QuizLeaderboardEntry>> _entriesByMode = {
    QuizModeType.quick: <QuizLeaderboardEntry>[],
    QuizModeType.challenge: <QuizLeaderboardEntry>[],
  };

  List<QuizLeaderboardEntry> entriesFor(QuizModeType mode) {
    return List<QuizLeaderboardEntry>.unmodifiable(_entriesByMode[mode]!);
  }

  bool qualifiesForLeaderboard(QuizSessionResult result) {
    final entries = _entriesByMode[result.mode]!;
    if (entries.length < 5) {
      return true;
    }

    final candidate = QuizLeaderboardEntry(
      playerName: '',
      score: result.score,
      totalQuestions: result.totalQuestions,
      mode: result.mode,
      hintsUsed: result.hintsUsed,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    );

    final ranked = [...entries, candidate]..sort(_compareEntries);
    return ranked.take(5).contains(candidate);
  }

  QuizLeaderboardEntry saveResult({
    required QuizSessionResult result,
    required String playerName,
    DateTime? createdAt,
  }) {
    final normalizedName = _normalizeName(playerName, result.language);
    final entry = QuizLeaderboardEntry(
      playerName: normalizedName,
      score: result.score,
      totalQuestions: result.totalQuestions,
      mode: result.mode,
      hintsUsed: result.hintsUsed,
      createdAt: createdAt ?? DateTime.now(),
    );

    final entries = _entriesByMode[result.mode]!;
    entries.add(entry);
    entries.sort(_compareEntries);
    if (entries.length > 5) {
      entries.removeRange(5, entries.length);
    }
    return entry;
  }

  void clearAll() {
    for (final entries in _entriesByMode.values) {
      entries.clear();
    }
  }

  int _compareEntries(QuizLeaderboardEntry a, QuizLeaderboardEntry b) {
    final scoreCompare = b.score.compareTo(a.score);
    if (scoreCompare != 0) {
      return scoreCompare;
    }

    final percentageCompare = b.percentage.compareTo(a.percentage);
    if (percentageCompare != 0) {
      return percentageCompare;
    }

    final hintsCompare = a.hintsUsed.compareTo(b.hintsUsed);
    if (hintsCompare != 0) {
      return hintsCompare;
    }

    return a.createdAt.compareTo(b.createdAt);
  }

  String _normalizeName(String rawName, QuizLanguage language) {
    final trimmed = rawName.trim();
    if (trimmed.isEmpty) {
      return language == QuizLanguage.spanish ? 'Jugador' : 'Player';
    }
    return trimmed.length > 12 ? trimmed.substring(0, 12) : trimmed;
  }
}
