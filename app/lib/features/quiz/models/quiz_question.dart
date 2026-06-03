import 'quiz_language.dart';

enum QuizQuestionType { symbol, atomicNumber, nameFromSymbol, realWorldUse }

class QuizAnswerOption {
  const QuizAnswerOption({
    required this.id,
    required this.labelEnglish,
    required this.labelSpanish,
    this.elementSymbol,
    this.atomicNumber,
    this.categoryKey,
  });

  final String id;
  final String labelEnglish;
  final String labelSpanish;
  final String? elementSymbol;
  final int? atomicNumber;
  final String? categoryKey;

  String labelFor(QuizLanguage language) {
    return language == QuizLanguage.spanish ? labelSpanish : labelEnglish;
  }

  String? localizedCategory(QuizLanguage language) {
    final category = categoryKey;
    if (category == null) {
      return null;
    }

    if (language == QuizLanguage.spanish) {
      switch (category) {
        case 'alkali':
          return 'Metal alcalino';
        case 'alkaline':
          return 'Metal alcalinotérreo';
        case 'transition':
          return 'Metal de transición';
        case 'post':
          return 'Postmetal';
        case 'metalloid':
          return 'Metaloide';
        case 'nonmetal':
          return 'No metal';
        case 'halogen':
          return 'Halógeno';
        case 'noble':
          return 'Gas noble';
        case 'lanthanide':
          return 'Lantánido';
        case 'actinide':
          return 'Actínido';
        default:
          return 'Elemento';
      }
    }

    switch (category) {
      case 'alkali':
        return 'Alkali metal';
      case 'alkaline':
        return 'Alkaline earth metal';
      case 'transition':
        return 'Transition metal';
      case 'post':
        return 'Post-transition metal';
      case 'metalloid':
        return 'Metalloid';
      case 'nonmetal':
        return 'Nonmetal';
      case 'halogen':
        return 'Halogen';
      case 'noble':
        return 'Noble gas';
      case 'lanthanide':
        return 'Lanthanide';
      case 'actinide':
        return 'Actinide';
      default:
        return 'Element';
    }
  }
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.type,
    required this.promptEnglish,
    required this.promptSpanish,
    required this.correctOptionId,
    required this.options,
    required this.hintEnglish,
    required this.hintSpanish,
    this.visualCueEmoji,
  });

  final String id;
  final QuizQuestionType type;
  final String promptEnglish;
  final String promptSpanish;
  final String correctOptionId;
  final List<QuizAnswerOption> options;
  final String hintEnglish;
  final String hintSpanish;
  final String? visualCueEmoji;

  String promptFor(QuizLanguage language) {
    return language == QuizLanguage.spanish ? promptSpanish : promptEnglish;
  }

  String hintFor(QuizLanguage language) {
    return language == QuizLanguage.spanish ? hintSpanish : hintEnglish;
  }

  QuizAnswerOption get correctOption =>
      options.firstWhere((option) => option.id == correctOptionId);

  QuizAnswerOption optionById(String optionId) {
    return options.firstWhere((option) => option.id == optionId);
  }
}
