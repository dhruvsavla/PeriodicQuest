import 'package:app/features/quiz/models/quiz_language.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_best_time_entry.dart';

class PeriodicPuzzleBestTimesRepository {
  PeriodicPuzzleBestTimesRepository({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static final PeriodicPuzzleBestTimesRepository instance =
      PeriodicPuzzleBestTimesRepository();

  final DateTime Function() _clock;
  final List<PeriodicPuzzleBestTimeEntry> _entries =
      <PeriodicPuzzleBestTimeEntry>[];

  List<PeriodicPuzzleBestTimeEntry> get entries =>
      List<PeriodicPuzzleBestTimeEntry>.unmodifiable(_entries);

  bool qualifies({
    required Duration totalElapsedTime,
    required int totalStars,
    required int totalMistakes,
    required int totalHintsUsed,
  }) {
    if (_entries.length < 5) {
      return true;
    }

    final candidate = PeriodicPuzzleBestTimeEntry(
      playerName: '',
      totalElapsedTime: totalElapsedTime,
      totalStars: totalStars,
      totalMistakes: totalMistakes,
      totalHintsUsed: totalHintsUsed,
      completedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );

    final ranked = [..._entries, candidate]..sort(_compareEntries);
    return ranked.take(5).contains(candidate);
  }

  PeriodicPuzzleBestTimeEntry save({
    required String playerName,
    required Duration totalElapsedTime,
    required int totalStars,
    required int totalMistakes,
    required int totalHintsUsed,
    required QuizLanguage language,
    DateTime? completedAt,
  }) {
    final entry = PeriodicPuzzleBestTimeEntry(
      playerName: _normalizeName(playerName, language),
      totalElapsedTime: totalElapsedTime,
      totalStars: totalStars,
      totalMistakes: totalMistakes,
      totalHintsUsed: totalHintsUsed,
      completedAt: completedAt ?? _clock(),
    );

    _entries.add(entry);
    _entries.sort(_compareEntries);
    if (_entries.length > 5) {
      _entries.removeRange(5, _entries.length);
    }
    return entry;
  }

  void clear() {
    _entries.clear();
  }

  int _compareEntries(
    PeriodicPuzzleBestTimeEntry a,
    PeriodicPuzzleBestTimeEntry b,
  ) {
    final starsCompare = b.totalStars.compareTo(a.totalStars);
    if (starsCompare != 0) {
      return starsCompare;
    }

    final timeCompare = a.totalElapsedTime.compareTo(b.totalElapsedTime);
    if (timeCompare != 0) {
      return timeCompare;
    }

    final mistakesCompare = a.totalMistakes.compareTo(b.totalMistakes);
    if (mistakesCompare != 0) {
      return mistakesCompare;
    }

    final hintsCompare = a.totalHintsUsed.compareTo(b.totalHintsUsed);
    if (hintsCompare != 0) {
      return hintsCompare;
    }

    return a.completedAt.compareTo(b.completedAt);
  }

  String _normalizeName(String rawName, QuizLanguage language) {
    final trimmed = rawName.trim();
    if (trimmed.isEmpty) {
      return language == QuizLanguage.spanish ? 'Jugador' : 'Player';
    }
    return trimmed.length > 12 ? trimmed.substring(0, 12) : trimmed;
  }
}
