import '../models/story_progress.dart';

class StoryProgressRepository {
  StoryProgressRepository();

  static final StoryProgressRepository instance = StoryProgressRepository();

  StoryProgress _progress = StoryProgress.initial();

  StoryProgress get progress => _progress;

  void record(int chapterId, int questId, int stars) {
    _progress = _progress.withRecord(chapterId, questId, stars);
  }

  void reset() => _progress = StoryProgress.initial();
}
