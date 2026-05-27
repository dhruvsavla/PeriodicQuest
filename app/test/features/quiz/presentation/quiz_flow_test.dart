import 'dart:math';

import 'package:app/features/game_mode/presentation/game_mode_screen.dart';
import 'package:app/features/quiz/data/quiz_leaderboard_repository.dart';
import 'package:app/features/quiz/data/quiz_question_generator.dart';
import 'package:app/features/quiz/models/quiz_language.dart';
import 'package:app/features/quiz/models/quiz_mode_type.dart';
import 'package:app/features/quiz/models/quiz_question.dart';
import 'package:app/features/quiz/models/quiz_session_result.dart';
import 'package:app/features/quiz/presentation/quiz_game_page.dart';
import 'package:app/features/quiz/presentation/quiz_home_page.dart';
import 'package:app/features/quiz/presentation/quiz_result_page.dart';
import 'package:app/features/quiz/presentation/widgets/quiz_option_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const generator = QuizQuestionGenerator();

  testWidgets('Tapping Quiz Mode from GameModePage opens Quiz Home page', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GameModePage(quizQuestionGenerator: generator, quizRandomSeed: 3),
      ),
    );

    await tester.tap(find.text('Quiz Mode').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Quick Quiz'), findsOneWidget);
    expect(find.text('Challenge Mode'), findsOneWidget);
  });

  testWidgets('Language toggle appears on QuizHomePage', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: QuizHomePage(questionGenerator: generator, randomSeed: 4),
      ),
    );

    expect(find.text('English'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);
  });

  testWidgets('QuizHomePage no longer shows the favorite challenge subtitle', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: QuizHomePage(questionGenerator: generator, randomSeed: 4),
      ),
    );

    expect(find.text('Choose your favorite challenge'), findsNothing);
    expect(find.text('Choose your favourite challenge'), findsNothing);
  });

  testWidgets(
    'User can switch to Spanish during quiz without losing progress',
    (tester) async {
      final firstQuestion = generator
          .generateQuestions(mode: QuizModeType.challenge, random: Random(9))
          .first;
      final firstOption = firstQuestion.options.first;

      await tester.pumpWidget(
        const MaterialApp(
          home: QuizGamePage(
            mode: QuizModeType.challenge,
            initialLanguage: QuizLanguage.english,
            questionGenerator: generator,
            randomSeed: 9,
          ),
        ),
      );

      final optionFinder = find.byKey(Key('quiz-option-${firstOption.id}'));
      await tester.ensureVisible(optionFinder);
      await tester.tap(optionFinder);
      await tester.pumpAndSettle();
      expect(find.text('Next'), findsOneWidget);

      final spanishToggle = find.text('Español');
      await tester.ensureVisible(spanishToggle);
      await tester.tap(spanishToggle);
      await tester.pumpAndSettle();

      expect(find.text('Pregunta 1 / 10'), findsWidgets);
      expect(
        find.text(firstOption.labelFor(QuizLanguage.spanish)),
        findsWidgets,
      );
      expect(find.text('Siguiente'), findsOneWidget);
    },
  );

  testWidgets('Quick Quiz hint can be used once and resets on next question', (
    tester,
  ) async {
    final questions = generator.generateQuestions(
      mode: QuizModeType.quick,
      random: Random(12),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: QuizGamePage(
          mode: QuizModeType.quick,
          initialLanguage: QuizLanguage.english,
          questionGenerator: generator,
          randomSeed: 12,
        ),
      ),
    );

    expect(find.text('Hints for this question: 1'), findsWidgets);
    await tester.tap(find.text('Use hint'));
    await tester.pumpAndSettle();
    expect(
      find.text(questions.first.hintFor(QuizLanguage.english)),
      findsOneWidget,
    );
    expect(find.text('Hints for this question: 0'), findsWidgets);

    final optionFinder = find.byKey(
      Key('quiz-option-${questions.first.correctOptionId}'),
    );
    await tester.ensureVisible(optionFinder);
    await tester.tap(optionFinder);
    await tester.pumpAndSettle();
    final nextFinder = find.text('Next');
    await tester.ensureVisible(nextFinder);
    await tester.tap(nextFinder);
    await tester.pumpAndSettle();

    expect(find.text('Hints for this question: 1'), findsWidgets);
  });

  testWidgets('Quick Quiz shows immediate feedback', (tester) async {
    final firstQuestion = generator
        .generateQuestions(mode: QuizModeType.quick, random: Random(8))
        .first;

    await tester.pumpWidget(
      const MaterialApp(
        home: QuizGamePage(
          mode: QuizModeType.quick,
          initialLanguage: QuizLanguage.english,
          questionGenerator: generator,
          randomSeed: 8,
        ),
      ),
    );

    final optionFinder = find.byKey(
      Key('quiz-option-${firstQuestion.correctOptionId}'),
    );
    await tester.ensureVisible(optionFinder);
    await tester.tap(optionFinder);
    await tester.pumpAndSettle();

    expect(find.text('Correct'), findsOneWidget);
  });

  testWidgets('Challenge Mode has 3 total hints and no immediate correctness', (
    tester,
  ) async {
    final firstQuestion = generator
        .generateQuestions(mode: QuizModeType.challenge, random: Random(10))
        .first;

    await tester.pumpWidget(
      const MaterialApp(
        home: QuizGamePage(
          mode: QuizModeType.challenge,
          initialLanguage: QuizLanguage.english,
          questionGenerator: generator,
          randomSeed: 10,
        ),
      ),
    );

    expect(find.text('Hints left: 3'), findsWidgets);
    await tester.tap(find.text('Use hint'));
    await tester.pumpAndSettle();
    expect(find.text('Hints left: 2'), findsWidgets);

    final optionFinder = find.byKey(
      Key('quiz-option-${firstQuestion.options.first.id}'),
    );
    await tester.ensureVisible(optionFinder);
    await tester.tap(optionFinder);
    await tester.pumpAndSettle();
    expect(find.text('Correct'), findsNothing);
    expect(find.text('Incorrect'), findsNothing);
  });

  testWidgets('Quick Quiz result hides leaderboard and name entry UI', (
    tester,
  ) async {
    final leaderboardRepository = QuizLeaderboardRepository();
    final result = QuizSessionResult(
      mode: QuizModeType.quick,
      language: QuizLanguage.english,
      answeredQuestions: const [
        QuizAnsweredQuestion(
          question: QuizQuestion(
            id: 'q1',
            type: QuizQuestionType.symbol,
            promptEnglish: 'What is the symbol for Oxygen?',
            promptSpanish: '¿Cuál es el símbolo de Oxígeno?',
            correctOptionId: 'O',
            options: [
              QuizAnswerOption(id: 'O', labelEnglish: 'O', labelSpanish: 'O'),
              QuizAnswerOption(id: 'N', labelEnglish: 'N', labelSpanish: 'N'),
              QuizAnswerOption(id: 'H', labelEnglish: 'H', labelSpanish: 'H'),
              QuizAnswerOption(id: 'C', labelEnglish: 'C', labelSpanish: 'C'),
            ],
            hintEnglish: 'This element helps us breathe.',
            hintSpanish: 'Este elemento nos ayuda a respirar.',
          ),
          selectedOptionId: 'O',
        ),
      ],
      hintsUsed: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: QuizResultPage(
          result: result,
          leaderboardRepository: leaderboardRepository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('You scored 1 / 1'), findsOneWidget);
    expect(find.text('Leaderboard'), findsNothing);
    expect(find.text('New high score!'), findsNothing);
    expect(find.text('Enter your name'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Play again'), findsOneWidget);
    expect(find.text('Back to quiz menu'), findsWidgets);
  });

  testWidgets(
    'Challenge Mode result still shows leaderboard input for qualifying score',
    (tester) async {
      final leaderboardRepository = QuizLeaderboardRepository();
      final result = QuizSessionResult(
        mode: QuizModeType.challenge,
        language: QuizLanguage.english,
        answeredQuestions: const [
          QuizAnsweredQuestion(
            question: QuizQuestion(
              id: 'real-world-Au',
              type: QuizQuestionType.realWorldUse,
              promptEnglish:
                  'Which element is used in jewelry because it is shiny and does not rust easily?',
              promptSpanish:
                  '¿Qué elemento se usa en joyería porque es brillante y no se oxida fácilmente?',
              correctOptionId: 'Au',
              options: [
                QuizAnswerOption(
                  id: 'Au',
                  labelEnglish: 'Gold',
                  labelSpanish: 'Oro',
                  elementSymbol: 'Au',
                  categoryKey: 'transition',
                ),
                QuizAnswerOption(
                  id: 'Ag',
                  labelEnglish: 'Silver',
                  labelSpanish: 'Plata',
                  elementSymbol: 'Ag',
                  categoryKey: 'transition',
                ),
                QuizAnswerOption(
                  id: 'Cu',
                  labelEnglish: 'Copper',
                  labelSpanish: 'Cobre',
                  elementSymbol: 'Cu',
                  categoryKey: 'transition',
                ),
                QuizAnswerOption(
                  id: 'Fe',
                  labelEnglish: 'Iron',
                  labelSpanish: 'Hierro',
                  elementSymbol: 'Fe',
                  categoryKey: 'transition',
                ),
              ],
              hintEnglish: 'It is a precious yellow metal.',
              hintSpanish: 'Es un metal precioso de color amarillo.',
            ),
            selectedOptionId: 'Au',
          ),
        ],
        hintsUsed: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: QuizResultPage(
            result: result,
            leaderboardRepository: leaderboardRepository,
          ),
        ),
      );

      expect(find.text('English'), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);
      expect(find.text('Leaderboard'), findsOneWidget);
      expect(find.text('New high score!'), findsWidgets);
      expect(find.text('Enter your name'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'HARSH');
      await tester.tap(find.text('Save score'));
      await tester.pumpAndSettle();

      expect(find.text('HARSH'), findsOneWidget);

      await tester.tap(find.text('Español'));
      await tester.pumpAndSettle();
      expect(find.text('Tabla de posiciones'), findsOneWidget);
    },
  );

  testWidgets('Real-world question visual cue appears on the question card', (
    tester,
  ) async {
    final generator = FixedQuizQuestionGenerator([
      _realWorldQuestion,
      _realWorldQuestionTwo,
      _symbolQuestion,
      _atomicNumberQuestion,
      _nameFromSymbolQuestion,
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: QuizGamePage(
          mode: QuizModeType.quick,
          initialLanguage: QuizLanguage.english,
          questionGenerator: generator,
        ),
      ),
    );

    expect(find.byKey(const Key('quiz-real-world-cue')), findsOneWidget);
    expect(find.text('💍'), findsOneWidget);
  });

  testWidgets('Atomic number answer cards do not show atomic number metadata', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QuizOptionButton(
            option: QuizAnswerOption(
              id: 'O',
              labelEnglish: 'Oxygen',
              labelSpanish: 'Oxígeno',
              elementSymbol: 'O',
              atomicNumber: 8,
              categoryKey: 'nonmetal',
            ),
            questionType: QuizQuestionType.atomicNumber,
            language: QuizLanguage.english,
            prefix: 'A',
            onTap: null,
          ),
        ),
      ),
    );

    expect(find.text('Oxygen'), findsOneWidget);
    expect(find.text('Nonmetal'), findsOneWidget);
    expect(find.text('Atomic 8'), findsNothing);
  });

  testWidgets('Symbol answer cards stay minimal and hide extra metadata', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QuizOptionButton(
            option: QuizAnswerOption(
              id: 'O',
              labelEnglish: 'O',
              labelSpanish: 'O',
              elementSymbol: 'O',
              atomicNumber: 8,
              categoryKey: 'nonmetal',
            ),
            questionType: QuizQuestionType.symbol,
            language: QuizLanguage.english,
            prefix: 'A',
            onTap: null,
          ),
        ),
      ),
    );

    expect(find.text('O'), findsOneWidget);
    expect(find.text('Nonmetal'), findsNothing);
    expect(find.text('Atomic 8'), findsNothing);
  });

  testWidgets('Name-from-symbol answer cards do not show the symbol', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QuizOptionButton(
            option: QuizAnswerOption(
              id: 'O',
              labelEnglish: 'Oxygen',
              labelSpanish: 'Oxígeno',
              elementSymbol: 'O',
              atomicNumber: 8,
              categoryKey: 'nonmetal',
            ),
            questionType: QuizQuestionType.nameFromSymbol,
            language: QuizLanguage.english,
            prefix: 'A',
            onTap: null,
          ),
        ),
      ),
    );

    expect(find.text('Oxygen'), findsOneWidget);
    expect(find.text('Nonmetal'), findsOneWidget);
    expect(find.text('O'), findsNothing);
  });
}

class FixedQuizQuestionGenerator extends QuizQuestionGenerator {
  FixedQuizQuestionGenerator(this.questions);

  final List<QuizQuestion> questions;

  @override
  List<QuizQuestion> generateQuestions({
    required QuizModeType mode,
    Random? random,
  }) {
    return questions.take(mode.questionCount).toList(growable: false);
  }
}

const _realWorldQuestion = QuizQuestion(
  id: 'real-world-Au',
  type: QuizQuestionType.realWorldUse,
  promptEnglish:
      'Which element is used in jewelry because it is shiny and does not rust easily?',
  promptSpanish:
      '¿Qué elemento se usa en joyería porque es brillante y no se oxida fácilmente?',
  correctOptionId: 'Au',
  options: [
    QuizAnswerOption(
      id: 'Au',
      labelEnglish: 'Gold',
      labelSpanish: 'Oro',
      elementSymbol: 'Au',
      atomicNumber: 79,
      categoryKey: 'transition',
    ),
    QuizAnswerOption(
      id: 'Ag',
      labelEnglish: 'Silver',
      labelSpanish: 'Plata',
      elementSymbol: 'Ag',
      atomicNumber: 47,
      categoryKey: 'transition',
    ),
    QuizAnswerOption(
      id: 'Cu',
      labelEnglish: 'Copper',
      labelSpanish: 'Cobre',
      elementSymbol: 'Cu',
      atomicNumber: 29,
      categoryKey: 'transition',
    ),
    QuizAnswerOption(
      id: 'Fe',
      labelEnglish: 'Iron',
      labelSpanish: 'Hierro',
      elementSymbol: 'Fe',
      atomicNumber: 26,
      categoryKey: 'transition',
    ),
  ],
  hintEnglish: 'It is a precious yellow metal.',
  hintSpanish: 'Es un metal precioso de color amarillo.',
  visualCueEmoji: '💍',
);

const _realWorldQuestionTwo = QuizQuestion(
  id: 'real-world-He',
  type: QuizQuestionType.realWorldUse,
  promptEnglish:
      'Which gas is used in party balloons because it is lighter than air?',
  promptSpanish:
      '¿Qué gas se usa en globos de fiesta porque es más ligero que el aire?',
  correctOptionId: 'He',
  options: [
    QuizAnswerOption(
      id: 'He',
      labelEnglish: 'Helium',
      labelSpanish: 'Helio',
      elementSymbol: 'He',
      atomicNumber: 2,
      categoryKey: 'noble',
    ),
    QuizAnswerOption(
      id: 'Ne',
      labelEnglish: 'Neon',
      labelSpanish: 'Neón',
      elementSymbol: 'Ne',
      atomicNumber: 10,
      categoryKey: 'noble',
    ),
    QuizAnswerOption(
      id: 'N',
      labelEnglish: 'Nitrogen',
      labelSpanish: 'Nitrógeno',
      elementSymbol: 'N',
      atomicNumber: 7,
      categoryKey: 'nonmetal',
    ),
    QuizAnswerOption(
      id: 'O',
      labelEnglish: 'Oxygen',
      labelSpanish: 'Oxígeno',
      elementSymbol: 'O',
      atomicNumber: 8,
      categoryKey: 'nonmetal',
    ),
  ],
  hintEnglish: 'It is a noble gas.',
  hintSpanish: 'Es un gas noble.',
  visualCueEmoji: '🎈',
);

const _symbolQuestion = QuizQuestion(
  id: 'symbol-8',
  type: QuizQuestionType.symbol,
  promptEnglish: 'What is the symbol for Oxygen?',
  promptSpanish: '¿Cuál es el símbolo de Oxígeno?',
  correctOptionId: 'O',
  options: [
    QuizAnswerOption(id: 'O', labelEnglish: 'O', labelSpanish: 'O'),
    QuizAnswerOption(id: 'N', labelEnglish: 'N', labelSpanish: 'N'),
    QuizAnswerOption(id: 'H', labelEnglish: 'H', labelSpanish: 'H'),
    QuizAnswerOption(id: 'C', labelEnglish: 'C', labelSpanish: 'C'),
  ],
  hintEnglish: 'This element helps us breathe.',
  hintSpanish: 'Este elemento nos ayuda a respirar.',
);

const _atomicNumberQuestion = QuizQuestion(
  id: 'atomic-number-8',
  type: QuizQuestionType.atomicNumber,
  promptEnglish: 'Which element has atomic number 8?',
  promptSpanish: '¿Qué elemento tiene el número atómico 8?',
  correctOptionId: 'O',
  options: [
    QuizAnswerOption(
      id: 'O',
      labelEnglish: 'Oxygen',
      labelSpanish: 'Oxígeno',
      elementSymbol: 'O',
      atomicNumber: 8,
      categoryKey: 'nonmetal',
    ),
    QuizAnswerOption(
      id: 'N',
      labelEnglish: 'Nitrogen',
      labelSpanish: 'Nitrógeno',
      elementSymbol: 'N',
      atomicNumber: 7,
      categoryKey: 'nonmetal',
    ),
    QuizAnswerOption(
      id: 'Ne',
      labelEnglish: 'Neon',
      labelSpanish: 'Neón',
      elementSymbol: 'Ne',
      atomicNumber: 10,
      categoryKey: 'noble',
    ),
    QuizAnswerOption(
      id: 'C',
      labelEnglish: 'Carbon',
      labelSpanish: 'Carbono',
      elementSymbol: 'C',
      atomicNumber: 6,
      categoryKey: 'nonmetal',
    ),
  ],
  hintEnglish: 'This element helps us breathe.',
  hintSpanish: 'Este elemento nos ayuda a respirar.',
);

const _nameFromSymbolQuestion = QuizQuestion(
  id: 'name-from-symbol-8',
  type: QuizQuestionType.nameFromSymbol,
  promptEnglish: 'What is the name of the element with symbol O?',
  promptSpanish: '¿Cuál es el nombre del elemento con el símbolo O?',
  correctOptionId: 'O',
  options: [
    QuizAnswerOption(
      id: 'O',
      labelEnglish: 'Oxygen',
      labelSpanish: 'Oxígeno',
      elementSymbol: 'O',
      atomicNumber: 8,
      categoryKey: 'nonmetal',
    ),
    QuizAnswerOption(
      id: 'N',
      labelEnglish: 'Nitrogen',
      labelSpanish: 'Nitrógeno',
      elementSymbol: 'N',
      atomicNumber: 7,
      categoryKey: 'nonmetal',
    ),
    QuizAnswerOption(
      id: 'Ne',
      labelEnglish: 'Neon',
      labelSpanish: 'Neón',
      elementSymbol: 'Ne',
      atomicNumber: 10,
      categoryKey: 'noble',
    ),
    QuizAnswerOption(
      id: 'C',
      labelEnglish: 'Carbon',
      labelSpanish: 'Carbono',
      elementSymbol: 'C',
      atomicNumber: 6,
      categoryKey: 'nonmetal',
    ),
  ],
  hintEnglish: 'This element helps us breathe.',
  hintSpanish: 'Este elemento nos ayuda a respirar.',
);
