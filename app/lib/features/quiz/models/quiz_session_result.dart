import 'quiz_language.dart';
import 'quiz_mode_type.dart';
import 'quiz_question.dart';

class QuizAnsweredQuestion {
  const QuizAnsweredQuestion({
    required this.question,
    required this.selectedOptionId,
  });

  final QuizQuestion question;
  final String selectedOptionId;

  bool get isCorrect => selectedOptionId == question.correctOptionId;

  QuizAnswerOption get selectedOption => question.optionById(selectedOptionId);
}

class QuizSessionResult {
  const QuizSessionResult({
    required this.mode,
    required this.language,
    required this.answeredQuestions,
    required this.hintsUsed,
  });

  final QuizModeType mode;
  final QuizLanguage language;
  final List<QuizAnsweredQuestion> answeredQuestions;
  final int hintsUsed;

  int get score => answeredQuestions.where((answer) => answer.isCorrect).length;

  int get totalQuestions => answeredQuestions.length;
}
