import 'dart:math';

import 'package:app/domain/elements/chemical_element.dart';
import 'package:app/domain/elements/element_translations_es.dart';
import 'package:app/domain/elements/periodic_table_data.dart';
import 'package:app/features/quiz/data/quiz_real_world_facts.dart';
import 'package:app/features/quiz/models/quiz_language.dart';
import 'package:app/features/quiz/models/quiz_mode_type.dart';
import 'package:app/features/quiz/models/quiz_question.dart';
import 'package:app/features/quiz/models/quiz_real_world_fact.dart';

class QuizQuestionGenerator {
  const QuizQuestionGenerator({
    this.elements = kPeriodicElements,
    this.spanishTranslations = kElementTranslationsEs,
    this.realWorldFacts = kQuizRealWorldFacts,
  });

  final List<ChemicalElement> elements;
  final Map<int, EsTranslation> spanishTranslations;
  final List<QuizRealWorldFact> realWorldFacts;

  List<QuizQuestion> generateQuestions({
    required QuizModeType mode,
    Random? random,
  }) {
    if (elements.length < 4) {
      throw StateError(
        'Quiz question generation requires at least 4 elements.',
      );
    }

    final effectiveRandom = random ?? Random();
    final baseQuestions = _buildElementQuestionPool(random: effectiveRandom);
    final realWorldQuestions = _buildRealWorldQuestionPool(
      random: effectiveRandom,
    );

    baseQuestions.shuffle(effectiveRandom);
    realWorldQuestions.shuffle(effectiveRandom);

    final targetRealWorldCount = mode == QuizModeType.quick ? 2 : 4;
    final selectedQuestions = <QuizQuestion>[];

    selectedQuestions.addAll(
      realWorldQuestions.take(
        min(targetRealWorldCount, realWorldQuestions.length),
      ),
    );

    final neededBaseQuestions = mode.questionCount - selectedQuestions.length;
    if (neededBaseQuestions > 0) {
      selectedQuestions.addAll(baseQuestions.take(neededBaseQuestions));
    }

    if (selectedQuestions.length < mode.questionCount) {
      final selectedIds = selectedQuestions
          .map((question) => question.id)
          .toSet();
      final fallbackPool = <QuizQuestion>[
        ...baseQuestions,
        ...realWorldQuestions,
      ].where((question) => !selectedIds.contains(question.id));

      for (final question in fallbackPool) {
        selectedQuestions.add(question);
        selectedIds.add(question.id);
        if (selectedQuestions.length == mode.questionCount) {
          break;
        }
      }
    }

    selectedQuestions.shuffle(effectiveRandom);
    return selectedQuestions.take(mode.questionCount).toList(growable: false);
  }

  List<QuizQuestion> _buildElementQuestionPool({required Random random}) {
    final questions = <QuizQuestion>[];

    for (final element in elements) {
      questions.add(
        QuizQuestion(
          id: 'symbol-${element.z}',
          type: QuizQuestionType.symbol,
          promptEnglish: 'What is the symbol for ${element.name}?',
          promptSpanish:
              '¿Cuál es el símbolo de ${_localizedElementName(element, QuizLanguage.spanish)}?',
          correctOptionId: element.sym,
          options: _buildSymbolOptions(element, random),
          hintEnglish: _localizedElementDescription(
            element,
            QuizLanguage.english,
          ),
          hintSpanish: _localizedElementDescription(
            element,
            QuizLanguage.spanish,
          ),
        ),
      );
      questions.add(
        QuizQuestion(
          id: 'atomic-number-${element.z}',
          type: QuizQuestionType.atomicNumber,
          promptEnglish: 'Which element has atomic number ${element.z}?',
          promptSpanish: '¿Qué elemento tiene el número atómico ${element.z}?',
          correctOptionId: element.sym,
          options: _buildElementNameOptions(element, random),
          hintEnglish: _localizedElementDescription(
            element,
            QuizLanguage.english,
          ),
          hintSpanish: _localizedElementDescription(
            element,
            QuizLanguage.spanish,
          ),
        ),
      );
      questions.add(
        QuizQuestion(
          id: 'name-from-symbol-${element.z}',
          type: QuizQuestionType.nameFromSymbol,
          promptEnglish:
              'What is the name of the element with symbol ${element.sym}?',
          promptSpanish:
              '¿Cuál es el nombre del elemento con el símbolo ${element.sym}?',
          correctOptionId: element.sym,
          options: _buildElementNameOptions(element, random),
          hintEnglish: _localizedElementDescription(
            element,
            QuizLanguage.english,
          ),
          hintSpanish: _localizedElementDescription(
            element,
            QuizLanguage.spanish,
          ),
        ),
      );
    }

    return questions;
  }

  List<QuizQuestion> _buildRealWorldQuestionPool({required Random random}) {
    final questions = <QuizQuestion>[];

    for (final fact in realWorldFacts) {
      final element = _findElementBySymbol(fact.elementSymbol);
      if (element == null) {
        continue;
      }

      questions.add(
        QuizQuestion(
          id: 'real-world-${element.sym}',
          type: QuizQuestionType.realWorldUse,
          promptEnglish: fact.clueEnglish,
          promptSpanish: fact.clueSpanish,
          correctOptionId: element.sym,
          options: _buildElementNameOptions(element, random),
          hintEnglish: fact.hintEnglish,
          hintSpanish: fact.hintSpanish,
          visualCueEmoji: fact.emoji,
        ),
      );
    }

    return questions;
  }

  ChemicalElement? _findElementBySymbol(String symbol) {
    for (final element in elements) {
      if (element.sym == symbol) {
        return element;
      }
    }
    return null;
  }

  List<QuizAnswerOption> _buildSymbolOptions(
    ChemicalElement element,
    Random random,
  ) {
    final candidates =
        elements
            .where((candidate) => candidate.z != element.z)
            .map((candidate) => candidate.sym)
            .toList(growable: false)
          ..shuffle(random);

    final options = <QuizAnswerOption>[
      QuizAnswerOption(
        id: element.sym,
        labelEnglish: element.sym,
        labelSpanish: element.sym,
        elementSymbol: element.sym,
      ),
    ];

    for (final candidateSymbol in candidates) {
      if (options.any((option) => option.id == candidateSymbol)) {
        continue;
      }
      options.add(
        QuizAnswerOption(
          id: candidateSymbol,
          labelEnglish: candidateSymbol,
          labelSpanish: candidateSymbol,
          elementSymbol: candidateSymbol,
        ),
      );
      if (options.length == 4) {
        break;
      }
    }

    options.shuffle(random);
    return options;
  }

  List<QuizAnswerOption> _buildElementNameOptions(
    ChemicalElement element,
    Random random,
  ) {
    final candidates =
        elements
            .where((candidate) => candidate.z != element.z)
            .toList(growable: false)
          ..shuffle(random);

    final options = <QuizAnswerOption>[_optionForElement(element)];
    for (final candidate in candidates) {
      if (options.any((option) => option.id == candidate.sym)) {
        continue;
      }
      options.add(_optionForElement(candidate));
      if (options.length == 4) {
        break;
      }
    }

    options.shuffle(random);
    return options;
  }

  QuizAnswerOption _optionForElement(ChemicalElement element) {
    return QuizAnswerOption(
      id: element.sym,
      labelEnglish: element.name,
      labelSpanish: _localizedElementName(element, QuizLanguage.spanish),
      elementSymbol: element.sym,
      atomicNumber: element.z,
      categoryKey: element.cat,
    );
  }

  String _localizedElementName(ChemicalElement element, QuizLanguage language) {
    if (language == QuizLanguage.english) {
      return element.name;
    }
    return spanishTranslations[element.z]?.name ?? element.name;
  }

  String _localizedElementDescription(
    ChemicalElement element,
    QuizLanguage language,
  ) {
    if (language == QuizLanguage.english) {
      return element.desc;
    }
    return spanishTranslations[element.z]?.desc ?? element.desc;
  }
}
