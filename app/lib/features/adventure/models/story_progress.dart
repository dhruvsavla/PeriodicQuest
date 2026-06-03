class StoryProgress {
  final Map<String, int> _starsMap;

  const StoryProgress._(this._starsMap);

  factory StoryProgress.initial() => const StoryProgress._({});

  static String _key(int chapterId, int questId) => '${chapterId}_$questId';

  bool isQuestCompleted(int chapterId, int questId) =>
      _starsMap.containsKey(_key(chapterId, questId));

  int starsForQuest(int chapterId, int questId) =>
      _starsMap[_key(chapterId, questId)] ?? 0;

  int starsForChapter(int chapterId, int questCount) {
    int total = 0;
    for (int i = 0; i < questCount; i++) {
      total += starsForQuest(chapterId, i);
    }
    return total;
  }

  bool isChapterComplete(int chapterId, int questCount) =>
      List.generate(questCount, (i) => i)
          .every((i) => isQuestCompleted(chapterId, i));

  int get totalStars => _starsMap.values.fold(0, (a, b) => a + b);

  StoryProgress withRecord(int chapterId, int questId, int stars) {
    final key = _key(chapterId, questId);
    final existing = _starsMap[key] ?? 0;
    if (stars <= existing) return this;
    return StoryProgress._({..._starsMap, key: stars});
  }
}
