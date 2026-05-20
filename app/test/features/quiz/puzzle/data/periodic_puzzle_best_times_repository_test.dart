import 'package:app/features/quiz/models/quiz_language.dart';
import 'package:app/features/quiz/puzzle/data/periodic_puzzle_best_times_repository.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PeriodicPuzzleBestTimesRepository repository;
  var completedAt = DateTime(2026, 5, 20, 12, 0, 0);

  setUp(() {
    repository = PeriodicPuzzleBestTimesRepository(clock: () => completedAt);
    completedAt = DateTime(2026, 5, 20, 12, 0, 0);
  });

  test('Saves qualifying entry and keeps only top 5', () {
    for (var index = 0; index < 6; index++) {
      repository.save(
        playerName: 'P$index',
        totalElapsedTime: Duration(minutes: 3 + index),
        totalStars: 10 - index,
        totalMistakes: index,
        totalHintsUsed: index,
        language: QuizLanguage.english,
      );
      completedAt = completedAt.add(const Duration(minutes: 1));
    }

    expect(repository.entries, hasLength(5));
    expect(repository.entries.first.totalStars, 10);
    expect(repository.entries.last.totalStars, 6);
  });

  test('Sorts by stars first, then faster time, then mistakes, then hints', () {
    repository.save(
      playerName: 'Slow Star',
      totalElapsedTime: const Duration(minutes: 5),
      totalStars: 8,
      totalMistakes: 0,
      totalHintsUsed: 0,
      language: QuizLanguage.english,
    );
    completedAt = completedAt.add(const Duration(minutes: 1));
    repository.save(
      playerName: 'Fast Star',
      totalElapsedTime: const Duration(minutes: 4),
      totalStars: 8,
      totalMistakes: 1,
      totalHintsUsed: 0,
      language: QuizLanguage.english,
    );
    completedAt = completedAt.add(const Duration(minutes: 1));
    repository.save(
      playerName: 'More Stars',
      totalElapsedTime: const Duration(minutes: 6),
      totalStars: 9,
      totalMistakes: 3,
      totalHintsUsed: 2,
      language: QuizLanguage.english,
    );
    completedAt = completedAt.add(const Duration(minutes: 1));
    repository.save(
      playerName: 'Fewer Mistakes',
      totalElapsedTime: const Duration(minutes: 4),
      totalStars: 8,
      totalMistakes: 0,
      totalHintsUsed: 1,
      language: QuizLanguage.english,
    );
    completedAt = completedAt.add(const Duration(minutes: 1));
    repository.save(
      playerName: 'Fewer Hints',
      totalElapsedTime: const Duration(minutes: 4),
      totalStars: 8,
      totalMistakes: 0,
      totalHintsUsed: 0,
      language: QuizLanguage.english,
    );

    final names = repository.entries.map((entry) => entry.playerName).toList();
    expect(names, [
      'More Stars',
      'Fewer Hints',
      'Fewer Mistak',
      'Fast Star',
      'Slow Star',
    ]);
  });

  test('Empty name defaults safely based on language', () {
    repository.save(
      playerName: '   ',
      totalElapsedTime: const Duration(minutes: 3),
      totalStars: 5,
      totalMistakes: 1,
      totalHintsUsed: 1,
      language: QuizLanguage.spanish,
    );

    expect(repository.entries.single.playerName, 'Jugador');
  });

  test('Duration formatting supports short and long times', () {
    expect(formatPuzzleDuration(const Duration(seconds: 5)), '00:05');
    expect(
      formatPuzzleDuration(const Duration(minutes: 2, seconds: 34)),
      '02:34',
    );
    expect(
      formatPuzzleDuration(const Duration(hours: 1, minutes: 2, seconds: 3)),
      '1:02:03',
    );
  });
}
