import 'package:app/features/quiz/models/quiz_language.dart';

class PeriodicPuzzleStrings {
  const PeriodicPuzzleStrings._(this.language);

  final QuizLanguage language;

  static PeriodicPuzzleStrings of(QuizLanguage language) {
    return PeriodicPuzzleStrings._(language);
  }

  bool get isSpanish => language == QuizLanguage.spanish;

  String get puzzleTitle =>
      isSpanish ? 'Rompecabezas periódico' : 'Periodic Puzzle';
  String get puzzleSubtitle =>
      isSpanish ? 'Completa las casillas faltantes' : 'Fill the missing tiles';
  String get timeLabel => isSpanish ? 'Tiempo' : 'Time';
  String get layerLabel => isSpanish ? 'Nivel' : 'Layer';
  String get startLabel => isSpanish ? 'Comenzar' : 'Start';
  String get continueLabel => isSpanish ? 'Continuar' : 'Continue';
  String get lockedLabel => isSpanish ? 'Bloqueado' : 'Locked';
  String get unlockedLabel => isSpanish ? 'Desbloqueado' : 'Unlocked';
  String get completedLabel => isSpanish ? 'Completado' : 'Completed';
  String get nextLayerLabel => isSpanish ? 'Siguiente nivel' : 'Next layer';
  String get nextGroupLabel => isSpanish ? 'Siguiente grupo' : 'Next group';
  String get tryAgainLabel => isSpanish ? 'Intentar de nuevo' : 'Try again';
  String get mistakesLabel => isSpanish ? 'Errores' : 'Mistakes';
  String get hintsLabel => isSpanish ? 'Pistas' : 'Hints';
  String get useHintLabel => isSpanish ? 'Usar pista' : 'Use hint';
  String get puzzleCompleteLabel =>
      isSpanish ? '¡Rompecabezas completo!' : 'Puzzle complete!';
  String get greatJobLabel => isSpanish ? '¡Buen trabajo!' : 'Great job!';
  String get bestTimesLabel => isSpanish ? 'Mejores tiempos' : 'Best Times';
  String get newBestTimeLabel =>
      isSpanish ? '¡Nuevo mejor tiempo!' : 'New best time!';
  String get enterYourNameLabel =>
      isSpanish ? 'Escribe tu nombre' : 'Enter your name';
  String get saveTimeLabel => isSpanish ? 'Guardar tiempo' : 'Save time';
  String get totalTimeLabel => isSpanish ? 'Tiempo total' : 'Total time';
  String get starsSummaryLabel => isSpanish ? 'Estrellas' : 'Stars';
  String get hintsUsedLabel => isSpanish ? 'Pistas usadas' : 'Hints used';
  String get playerPlaceholder => isSpanish ? 'Jugador' : 'Player';
  String get unlockedNextLayerLabel => isSpanish
      ? '¡Desbloqueaste el siguiente nivel!'
      : 'You unlocked the next layer!';
  String get backToQuizMenuLabel =>
      isSpanish ? 'Volver al menú del quiz' : 'Back to quiz menu';
  String get chooseCorrectElementLabel =>
      isSpanish ? 'Elige el elemento correcto' : 'Choose the correct element';
  String get fillThisTileLabel =>
      isSpanish ? 'Completa esta casilla' : 'Fill this tile';
  String get correctLabel => isSpanish ? '¡Correcto!' : 'Correct!';
  String get almostTryAgainLabel =>
      isSpanish ? 'Casi — inténtalo de nuevo' : 'Almost — try again!';
  String get boardReadyLabel =>
      isSpanish ? 'Listo para completar' : 'Ready to fill';
  String get boardClearedLabel =>
      isSpanish ? 'Tablero completado' : 'Board cleared';
  String get playAgainLabel => isSpanish ? 'Jugar de nuevo' : 'Play again';
  String get starterLayerTitle =>
      isSpanish ? 'Nivel 1: Elementos iniciales' : 'Layer 1: Starter Elements';
  String get groupsLayerTitle =>
      isSpanish ? 'Nivel 2: Grupos de elementos' : 'Layer 2: Element Groups';
  String get mixedLayerTitle =>
      isSpanish ? 'Nivel 3: Desafío mixto' : 'Layer 3: Mixed Challenge';
  String get starterLayerSubtitle => isSpanish
      ? 'Aprende los primeros 20 elementos'
      : 'Learn the first 20 elements';
  String get groupsLayerSubtitle => isSpanish
      ? 'Completa familias y grupos'
      : 'Complete element families and groups';
  String get mixedLayerSubtitle => isSpanish
      ? 'Combina nombres, símbolos y pistas del mundo real'
      : 'Mix names, symbols, and real-world clues';
  String get puzzleCardSubtitle => puzzleSubtitle;
  String get layerBadgeOne => isSpanish ? '3 niveles' : '3 layers';
  String get layerBadgeTwo => isSpanish ? 'Desbloquea grupos' : 'Unlock groups';
  String get layerBadgeThree =>
      isSpanish ? 'Práctica de tabla' : 'Table practice';

  String layerStatusText({required bool locked, required bool completed}) {
    if (completed) {
      return completedLabel;
    }
    return locked ? lockedLabel : unlockedLabel;
  }

  String progressText(int completed, int total) {
    return isSpanish
        ? '$completed de $total completados'
        : '$completed of $total completed';
  }

  String starsText(int stars) {
    return isSpanish ? '$stars estrellas' : '$stars stars';
  }

  String groupLabel(String english, String spanish) {
    return isSpanish ? spanish : english;
  }

  String timeText(Duration duration) {
    return '$timeLabel: ${formatPuzzleDuration(duration)}';
  }

  String totalTimeText(Duration duration) {
    return '$totalTimeLabel: ${formatPuzzleDuration(duration)}';
  }

  String hintsRemainingText(int hints) {
    return isSpanish ? 'Pistas: $hints' : 'Hints: $hints';
  }

  String mistakesText(int mistakes) {
    return isSpanish ? 'Errores: $mistakes' : 'Mistakes: $mistakes';
  }
}

String formatPuzzleDuration(Duration duration) {
  final totalSeconds = duration.inSeconds;
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;

  String twoDigits(int value) => value.toString().padLeft(2, '0');

  if (hours > 0) {
    return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
  return '${twoDigits(minutes)}:${twoDigits(seconds)}';
}
