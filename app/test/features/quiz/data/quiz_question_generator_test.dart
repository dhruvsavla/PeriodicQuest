import 'dart:math';

import 'package:app/domain/elements/chemical_element.dart';
import 'package:app/features/quiz/data/quiz_question_generator.dart';
import 'package:app/features/quiz/models/quiz_language.dart';
import 'package:app/features/quiz/models/quiz_mode_type.dart';
import 'package:app/features/quiz/models/quiz_question.dart';
import 'package:app/features/quiz/models/quiz_session_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const generator = QuizQuestionGenerator();

  test('Quick Quiz generates 5 questions with unique ids', () {
    final questions = generator.generateQuestions(
      mode: QuizModeType.quick,
      random: Random(7),
    );

    expect(questions, hasLength(5));
    expect(
      questions.map((question) => question.id).toSet(),
      hasLength(questions.length),
    );
  });

  test('Challenge Mode generates 10 questions with unique ids', () {
    final questions = generator.generateQuestions(
      mode: QuizModeType.challenge,
      random: Random(11),
    );

    expect(questions, hasLength(10));
    expect(
      questions.map((question) => question.id).toSet(),
      hasLength(questions.length),
    );
  });

  test(
    'Every question has 4 unique options and contains the correct answer',
    () {
      final questions = generator.generateQuestions(
        mode: QuizModeType.challenge,
        random: Random(17),
      );

      for (final question in questions) {
        expect(question.options, hasLength(4));
        expect(
          question.options.map((option) => option.id).toSet(),
          hasLength(4),
        );
        expect(
          question.options.any(
            (option) => option.id == question.correctOptionId,
          ),
          isTrue,
        );
      }
    },
  );

  test('Real-world question pool is included in generated quizzes', () {
    final quickQuestions = generator.generateQuestions(
      mode: QuizModeType.quick,
      random: Random(21),
    );
    final challengeQuestions = generator.generateQuestions(
      mode: QuizModeType.challenge,
      random: Random(22),
    );

    expect(
      quickQuestions
          .where((question) => question.type == QuizQuestionType.realWorldUse)
          .length,
      greaterThanOrEqualTo(2),
    );
    expect(
      challengeQuestions
          .where((question) => question.type == QuizQuestionType.realWorldUse)
          .length,
      greaterThanOrEqualTo(3),
    );
  });

  test('Spanish question text and labels are available when requested', () {
    final questions = generator.generateQuestions(
      mode: QuizModeType.quick,
      random: Random(13),
    );

    expect(
      questions.any(
        (question) =>
            question.promptFor(QuizLanguage.spanish).startsWith('¿') &&
            question.hintFor(QuizLanguage.spanish).isNotEmpty,
      ),
      isTrue,
    );
  });

  test('Spanish real-world questions return Spanish clue text', () {
    final questions = generator.generateQuestions(
      mode: QuizModeType.quick,
      random: Random(25),
    );

    final realWorldQuestion = questions.firstWhere(
      (question) => question.type == QuizQuestionType.realWorldUse,
    );

    expect(
      realWorldQuestion.promptFor(QuizLanguage.spanish).startsWith('¿'),
      isTrue,
    );
  });

  test('Missing Spanish element name fallback does not crash', () {
    final fallbackGenerator = QuizQuestionGenerator(
      elements: const [
        ChemicalElement(1, 'H', 'Hydrogen', 1.008, 'nonmetal', '', ''),
        ChemicalElement(8, 'O', 'Oxygen', 15.999, 'nonmetal', '', ''),
        ChemicalElement(10, 'Ne', 'Neon', 20.180, 'noble', '', ''),
        ChemicalElement(12, 'Mg', 'Magnesium', 24.305, 'alkaline', '', ''),
      ],
      spanishTranslations: const {},
    );

    final questions = fallbackGenerator.generateQuestions(
      mode: QuizModeType.challenge,
      random: Random(5),
    );

    expect(questions, hasLength(10));
    expect(
      questions.any(
        (question) =>
            question.promptFor(QuizLanguage.spanish).contains('Oxygen') ||
            question.correctOption.labelFor(QuizLanguage.spanish) == 'Oxygen',
      ),
      isTrue,
    );
  });

  test('Scoring uses stable answer ids instead of localized labels', () {
    const question = QuizQuestion(
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
        ),
        QuizAnswerOption(
          id: 'N',
          labelEnglish: 'Nitrogen',
          labelSpanish: 'Nitrógeno',
          elementSymbol: 'N',
        ),
        QuizAnswerOption(
          id: 'C',
          labelEnglish: 'Carbon',
          labelSpanish: 'Carbono',
          elementSymbol: 'C',
        ),
        QuizAnswerOption(
          id: 'He',
          labelEnglish: 'Helium',
          labelSpanish: 'Helio',
          elementSymbol: 'He',
        ),
      ],
      hintEnglish: 'It helps us breathe.',
      hintSpanish: 'Nos ayuda a respirar.',
    );

    const answered = QuizAnsweredQuestion(
      question: question,
      selectedOptionId: 'O',
    );

    expect(answered.isCorrect, isTrue);
    expect(answered.selectedOption.labelFor(QuizLanguage.spanish), 'Oxígeno');
  });
}
