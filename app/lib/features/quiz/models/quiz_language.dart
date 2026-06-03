enum QuizLanguage { english, spanish }

class QuizStrings {
  const QuizStrings._({required this.language});

  final QuizLanguage language;

  static QuizStrings of(QuizLanguage language) {
    return QuizStrings._(language: language);
  }

  bool get isSpanish => language == QuizLanguage.spanish;

  String get quizModeTitle => isSpanish ? 'Modo Quiz' : 'Quiz Mode';
  String get quickQuizTitle => isSpanish ? 'Quiz rápido' : 'Quick Quiz';
  String get challengeModeTitle =>
      isSpanish ? 'Modo desafío' : 'Challenge Mode';
  String get englishLabel => isSpanish ? 'Inglés' : 'English';
  String get spanishLabel => 'Español';
  String get questionLabel => isSpanish ? 'Pregunta' : 'Question';
  String get nextLabel => isSpanish ? 'Siguiente' : 'Next';
  String get finishLabel => isSpanish ? 'Finalizar' : 'Finish';
  String get correctLabel => isSpanish ? 'Correcto' : 'Correct';
  String get incorrectLabel => isSpanish ? 'Incorrecto' : 'Incorrect';
  String get hintLabel => isSpanish ? 'Pista' : 'Hint';
  String get scoreLabel => isSpanish ? 'Puntuación' : 'Score';
  String get playAgainLabel => isSpanish ? 'Jugar de nuevo' : 'Play again';
  String get backToQuizMenuLabel =>
      isSpanish ? 'Volver al menú del quiz' : 'Back to quiz menu';
  String get backToGameModesLabel =>
      isSpanish ? 'Volver a modos de juego' : 'Back to game modes';
  String get resultsLabel => isSpanish ? 'Resultados' : 'Results';
  String get yourAnswerLabel => isSpanish ? 'Tu respuesta' : 'Your answer';
  String get correctAnswerLabel =>
      isSpanish ? 'Respuesta correcta' : 'Correct answer';
  String get useHintLabel => isSpanish ? 'Usar pista' : 'Use hint';
  String get noHintsLeftLabel =>
      isSpanish ? 'No quedan pistas' : 'No hints left';
  String get leaderboardLabel =>
      isSpanish ? 'Tabla de posiciones' : 'Leaderboard';
  String get newHighScoreLabel =>
      isSpanish ? '¡Nuevo récord!' : 'New high score!';
  String get enterYourNameLabel =>
      isSpanish ? 'Escribe tu nombre' : 'Enter your name';
  String get saveScoreLabel => isSpanish ? 'Guardar puntaje' : 'Save score';
  String get quickHintSummary =>
      isSpanish ? '1 pista por pregunta' : '1 hint per question';
  String get feedbackAppearsLabel => isSpanish
      ? 'Retroalimentación inmediata'
      : 'Instant feedback after each answer';
  String get chooseQuizStyleLabel => isSpanish
      ? 'Elige una forma divertida de practicar los elementos.'
      : 'Choose a fun way to practice periodic-table questions.';
  String get quickQuizQuestionCount =>
      isSpanish ? '5 preguntas' : '5 questions';
  String get quickQuizDescription => isSpanish
      ? 'Retroalimentación inmediata después de cada respuesta'
      : 'Instant feedback after each answer';
  String get challengeQuizQuestionCount =>
      isSpanish ? '10 preguntas' : '10 questions';
  String get challengeResultsTiming =>
      isSpanish ? 'Resultados al final' : 'Results shown at the end';
  String get challengeHintsSummary =>
      isSpanish ? '3 pistas disponibles' : '3 hints available';
  String get quickQuizBadge =>
      isSpanish ? 'Retroalimentación rápida' : 'Fast feedback';
  String get challengeQuizBadge =>
      isSpanish ? 'Puntuación final' : 'Final score';
  String get playerPlaceholder => isSpanish ? 'Jugador' : 'Player';
  String get readySetQuizLabel =>
      isSpanish ? 'Elige tu reto favorito' : 'Choose your favorite challenge';
  String get quizCollectionLabel =>
      isSpanish ? 'Colección de ciencia' : 'Science card collection';
  String get friendlyHintIntro =>
      isSpanish ? 'Pista desbloqueada' : 'Hint unlocked';
  String get niceWorkLabel => isSpanish ? '¡Buen trabajo!' : 'Nice work!';
  String get almostThereLabel => isSpanish
      ? '¡Casi! La respuesta correcta es...'
      : 'Almost! The correct answer is...';
  String get arcadeStarsLabel =>
      isSpanish ? 'Ranking brillante' : 'Shining rankings';
  String get scoreBurstLabel => isSpanish ? 'Puntaje final' : 'Final score';
  String get instantFeedbackBadge =>
      isSpanish ? 'Respuesta inmediata' : 'Instant answer check';
  String get finalResultsBadge =>
      isSpanish ? 'Puntuación al final' : 'Results at the end';
  String get quizReadyLabel => isSpanish ? 'Listo para jugar' : 'Ready to play';
  String get answerChoicesLabel =>
      isSpanish ? 'Opciones sorpresa' : 'Pick your answer';

  String languageName(QuizLanguage value) {
    return value == QuizLanguage.english ? englishLabel : spanishLabel;
  }

  String progressText(int current, int total) {
    final label = questionLabel;
    return '$label $current / $total';
  }

  String hintsLeftText(int remaining) {
    return isSpanish
        ? 'Pistas restantes: $remaining'
        : 'Hints left: $remaining';
  }

  String questionHintStatusText(int remaining) {
    return isSpanish
        ? 'Pistas en esta pregunta: $remaining'
        : 'Hints for this question: $remaining';
  }

  String correctAnswerText(String answer) {
    return isSpanish
        ? 'La respuesta correcta es $answer'
        : 'The correct answer is $answer';
  }

  String scoreText(int score, int total) {
    return isSpanish
        ? 'Obtuviste $score / $total'
        : 'You scored $score / $total';
  }

  String leaderboardEntryText({
    required int rank,
    required String name,
    required int score,
    required int total,
  }) {
    return '$rank. $name — $score/$total';
  }

  String encouragementText(int score, int total) {
    final ratio = total == 0 ? 0.0 : score / total;
    if (ratio == 1.0) {
      return isSpanish ? '¡Maestro de la tabla periódica!' : 'Periodic Master!';
    }
    if (ratio >= 0.8) {
      return isSpanish
          ? '¡Grandes habilidades de química!'
          : 'Great chemistry skills!';
    }
    if (ratio >= 0.5) {
      return isSpanish
          ? '¡Buen trabajo — sigue practicando!'
          : 'Nice work — keep practicing!';
    }
    return isSpanish
        ? 'Buen comienzo — inténtalo de nuevo.'
        : 'Good start — try again!';
  }
}
