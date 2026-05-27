import 'package:app/features/quiz/data/quiz_leaderboard_repository.dart';
import 'package:app/features/quiz/models/quiz_language.dart';
import 'package:app/features/quiz/models/quiz_mode_type.dart';
import 'package:app/features/quiz/models/quiz_question.dart';
import 'package:app/features/quiz/models/quiz_session_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  QuizSessionResult buildResult({
    required QuizModeType mode,
    required int score,
    required int total,
    int hintsUsed = 0,
    QuizLanguage language = QuizLanguage.english,
  }) {
    final answeredQuestions = List<QuizAnsweredQuestion>.generate(total, (
      index,
    ) {
      final isCorrect = index < score;
      return QuizAnsweredQuestion(
        question: QuizQuestion(
          id: 'q$index',
          type: QuizQuestionType.symbol,
          promptEnglish: 'Prompt $index',
          promptSpanish: 'Pregunta $index',
          correctOptionId: 'correct-$index',
          options: [
            QuizAnswerOption(
              id: 'correct-$index',
              labelEnglish: 'Correct',
              labelSpanish: 'Correcto',
            ),
            QuizAnswerOption(
              id: 'wrong-$index',
              labelEnglish: 'Wrong',
              labelSpanish: 'Incorrecto',
            ),
            QuizAnswerOption(
              id: 'other-a-$index',
              labelEnglish: 'Other A',
              labelSpanish: 'Otra A',
            ),
            QuizAnswerOption(
              id: 'other-b-$index',
              labelEnglish: 'Other B',
              labelSpanish: 'Otra B',
            ),
          ],
          hintEnglish: 'Hint',
          hintSpanish: 'Pista',
        ),
        selectedOptionId: isCorrect ? 'correct-$index' : 'wrong-$index',
      );
    });

    return QuizSessionResult(
      mode: mode,
      language: language,
      answeredQuestions: answeredQuestions,
      hintsUsed: hintsUsed,
    );
  }

  test('Saves qualifying score and keeps only top 5', () {
    final repository = QuizLeaderboardRepository();

    for (var index = 0; index < 6; index++) {
      repository.saveResult(
        result: buildResult(
          mode: QuizModeType.quick,
          score: 5 - index,
          total: 5,
        ),
        playerName: 'P$index',
        createdAt: DateTime(2026, 5, 19, 12, index),
      );
    }

    final entries = repository.entriesFor(QuizModeType.quick);
    expect(entries, hasLength(5));
    expect(entries.first.score, 5);
    expect(entries.last.score, 1);
  });

  test('Keeps Quick and Challenge leaderboards separate', () {
    final repository = QuizLeaderboardRepository();

    repository.saveResult(
      result: buildResult(mode: QuizModeType.quick, score: 5, total: 5),
      playerName: 'Quick',
      createdAt: DateTime(2026, 5, 19),
    );
    repository.saveResult(
      result: buildResult(mode: QuizModeType.challenge, score: 9, total: 10),
      playerName: 'Challenge',
      createdAt: DateTime(2026, 5, 19, 1),
    );

    expect(repository.entriesFor(QuizModeType.quick), hasLength(1));
    expect(repository.entriesFor(QuizModeType.challenge), hasLength(1));
  });

  test('Sorts scores correctly and uses hints as tie-breaker', () {
    final repository = QuizLeaderboardRepository();

    repository.saveResult(
      result: buildResult(
        mode: QuizModeType.challenge,
        score: 8,
        total: 10,
        hintsUsed: 2,
      ),
      playerName: 'B',
      createdAt: DateTime(2026, 5, 19, 1),
    );
    repository.saveResult(
      result: buildResult(
        mode: QuizModeType.challenge,
        score: 8,
        total: 10,
        hintsUsed: 1,
      ),
      playerName: 'A',
      createdAt: DateTime(2026, 5, 19, 2),
    );

    final entries = repository.entriesFor(QuizModeType.challenge);
    expect(entries.first.playerName, 'A');
  });

  test('Empty name defaults safely', () {
    final repository = QuizLeaderboardRepository();

    repository.saveResult(
      result: buildResult(
        mode: QuizModeType.quick,
        score: 4,
        total: 5,
        language: QuizLanguage.spanish,
      ),
      playerName: '   ',
      createdAt: DateTime(2026, 5, 19),
    );

    final entry = repository.entriesFor(QuizModeType.quick).single;
    expect(entry.playerName, 'Jugador');
  });
}
