import 'package:flutter/material.dart';

enum QuestType { identify, combine, multiChoice }

class MultiChoiceOption {
  final int elementZ;
  final String label;
  final bool isCorrect;

  const MultiChoiceOption({
    required this.elementZ,
    required this.label,
    required this.isCorrect,
  });
}

class StoryQuest {
  final int id;
  final String title;
  final String story;
  final String sceneEmoji;
  final QuestType type;
  final String challenge;

  // identify: targetZ + distractorZs (8 elements)
  final int? targetZ;
  final List<int>? distractorZs;

  // combine: the two correct elements + candidate pool
  final int? combineZA;
  final int? combineZB;
  final String? compoundName;
  // combineZs is the full pick-list (must include both combineZA and combineZB)
  final List<int>? combineZs;

  // multiChoice
  final List<MultiChoiceOption>? options;

  const StoryQuest({
    required this.id,
    required this.title,
    required this.story,
    required this.sceneEmoji,
    required this.type,
    required this.challenge,
    this.targetZ,
    this.distractorZs,
    this.combineZA,
    this.combineZB,
    this.compoundName,
    this.combineZs,
    this.options,
  });
}

class StoryChapter {
  final int id;
  final String title;
  final String description;
  final String emoji;
  final Color accentColor;
  final Color bgDark;
  final Color bgLight;
  final List<StoryQuest> quests;
  final int unlockRequiredStars;

  const StoryChapter({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.accentColor,
    required this.bgDark,
    required this.bgLight,
    required this.quests,
    required this.unlockRequiredStars,
  });

  int get maxStars => quests.length * 3;
}
