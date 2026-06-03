import 'package:flutter/material.dart';

import 'package:app/features/quiz/models/quiz_language.dart';
import 'package:app/features/quiz/models/quiz_question.dart';
import 'package:app/features/quiz/presentation/widgets/quiz_option_button.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_tile.dart';

class PeriodicPuzzleOptionCard extends StatelessWidget {
  const PeriodicPuzzleOptionCard({
    super.key,
    required this.option,
    required this.clueType,
    required this.language,
    required this.prefix,
    required this.onTap,
    this.isSelected = false,
    this.isIncorrect = false,
    this.forceTight = false,
  });

  final QuizAnswerOption option;
  final PeriodicPuzzleClueType clueType;
  final QuizLanguage language;
  final String prefix;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isIncorrect;
  final bool forceTight;

  @override
  Widget build(BuildContext context) {
    return QuizOptionButton(
      option: option,
      questionType: _displayQuestionType(clueType),
      language: language,
      prefix: prefix,
      onTap: onTap,
      isSelected: isSelected,
      isIncorrect: isIncorrect,
      density: QuizOptionButtonDensity.compact,
      forceTight: forceTight,
    );
  }

  QuizQuestionType _displayQuestionType(PeriodicPuzzleClueType clueType) {
    switch (clueType) {
      case PeriodicPuzzleClueType.name:
        return QuizQuestionType.symbol;
      case PeriodicPuzzleClueType.symbol:
        return QuizQuestionType.nameFromSymbol;
      case PeriodicPuzzleClueType.atomicNumber:
      case PeriodicPuzzleClueType.position:
        return QuizQuestionType.atomicNumber;
      case PeriodicPuzzleClueType.realWorld:
        return QuizQuestionType.realWorldUse;
    }
  }
}
