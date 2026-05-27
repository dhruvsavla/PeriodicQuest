import 'package:app/domain/elements/chemical_element.dart';
import 'package:app/features/quiz/models/quiz_language.dart';
import 'package:app/features/quiz/models/quiz_question.dart';

enum PeriodicPuzzleClueType { name, symbol, atomicNumber, position, realWorld }

class PeriodicPuzzleClue {
  const PeriodicPuzzleClue({
    required this.type,
    required this.english,
    required this.spanish,
    required this.hintEnglish,
    required this.hintSpanish,
    this.labelEnglish,
    this.labelSpanish,
  });

  final PeriodicPuzzleClueType type;
  final String english;
  final String spanish;
  final String hintEnglish;
  final String hintSpanish;
  final String? labelEnglish;
  final String? labelSpanish;

  String textFor(QuizLanguage language) {
    return language == QuizLanguage.spanish ? spanish : english;
  }

  String hintFor(QuizLanguage language) {
    return language == QuizLanguage.spanish ? hintSpanish : hintEnglish;
  }

  String labelFor(QuizLanguage language) {
    return language == QuizLanguage.spanish
        ? (labelSpanish ?? spanish)
        : (labelEnglish ?? english);
  }
}

class PeriodicPuzzleTile {
  const PeriodicPuzzleTile({
    required this.element,
    required this.row,
    required this.column,
    this.clue,
    this.options = const <QuizAnswerOption>[],
  });

  final ChemicalElement element;
  final int row;
  final int column;
  final PeriodicPuzzleClue? clue;
  final List<QuizAnswerOption> options;

  String get id => element.sym;

  bool get isMissing => clue != null;

  QuizQuestionType get optionDisplayType {
    final clueType = clue?.type;
    switch (clueType) {
      case PeriodicPuzzleClueType.name:
        return QuizQuestionType.symbol;
      case PeriodicPuzzleClueType.symbol:
        return QuizQuestionType.nameFromSymbol;
      case PeriodicPuzzleClueType.atomicNumber:
      case PeriodicPuzzleClueType.position:
        return QuizQuestionType.atomicNumber;
      case PeriodicPuzzleClueType.realWorld:
      case null:
        return QuizQuestionType.realWorldUse;
    }
  }
}
