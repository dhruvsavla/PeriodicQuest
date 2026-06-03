import 'package:app/features/quiz/models/quiz_language.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_layer.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_tile.dart';

class PeriodicPuzzleBoard {
  const PeriodicPuzzleBoard({
    required this.id,
    required this.layer,
    required this.titleEnglish,
    required this.titleSpanish,
    required this.subtitleEnglish,
    required this.subtitleSpanish,
    required this.tiles,
    this.groupKey,
    this.groupLabelEnglish,
    this.groupLabelSpanish,
    this.maxHints = 3,
  });

  final String id;
  final PeriodicPuzzleLayer layer;
  final String titleEnglish;
  final String titleSpanish;
  final String subtitleEnglish;
  final String subtitleSpanish;
  final List<PeriodicPuzzleTile> tiles;
  final String? groupKey;
  final String? groupLabelEnglish;
  final String? groupLabelSpanish;
  final int maxHints;

  String titleFor(QuizLanguage language) {
    return language == QuizLanguage.spanish ? titleSpanish : titleEnglish;
  }

  String subtitleFor(QuizLanguage language) {
    return language == QuizLanguage.spanish ? subtitleSpanish : subtitleEnglish;
  }

  String? groupLabelFor(QuizLanguage language) {
    if (groupLabelEnglish == null || groupLabelSpanish == null) {
      return null;
    }
    return language == QuizLanguage.spanish
        ? groupLabelSpanish
        : groupLabelEnglish;
  }

  List<PeriodicPuzzleTile> get missingTiles =>
      tiles.where((tile) => tile.isMissing).toList(growable: false);

  int get maxRow =>
      tiles.fold(0, (max, tile) => tile.row > max ? tile.row : max);

  int get maxColumn =>
      tiles.fold(0, (max, tile) => tile.column > max ? tile.column : max);
}
