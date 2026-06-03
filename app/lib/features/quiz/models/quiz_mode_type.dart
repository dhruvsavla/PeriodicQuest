enum QuizModeType { quick, challenge }

extension QuizModeTypeX on QuizModeType {
  int get questionCount => this == QuizModeType.quick ? 5 : 10;

  int get totalHints => this == QuizModeType.challenge ? 3 : 0;
}
