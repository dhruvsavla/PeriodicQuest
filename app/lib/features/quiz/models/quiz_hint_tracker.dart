import 'quiz_mode_type.dart';

class QuizHintTracker {
  QuizHintTracker._({
    required this.mode,
    required int remainingGlobalHints,
    Set<String>? hintedQuestionIds,
  }) : _remainingGlobalHints = remainingGlobalHints,
       _hintedQuestionIds = hintedQuestionIds ?? <String>{};

  factory QuizHintTracker.forMode(QuizModeType mode) {
    return QuizHintTracker._(mode: mode, remainingGlobalHints: mode.totalHints);
  }

  final QuizModeType mode;
  final Set<String> _hintedQuestionIds;
  int _remainingGlobalHints;

  int get remainingGlobalHints => _remainingGlobalHints;

  bool hasUsedHint(String questionId) {
    return _hintedQuestionIds.contains(questionId);
  }

  bool canUseHint(String questionId) {
    if (_hintedQuestionIds.contains(questionId)) {
      return false;
    }
    if (mode == QuizModeType.quick) {
      return true;
    }
    return _remainingGlobalHints > 0;
  }

  bool useHint(String questionId) {
    if (!canUseHint(questionId)) {
      return false;
    }

    _hintedQuestionIds.add(questionId);
    if (mode == QuizModeType.challenge) {
      _remainingGlobalHints--;
    }
    return true;
  }

  int hintsRemainingForQuestion(String questionId) {
    if (mode == QuizModeType.challenge) {
      return _remainingGlobalHints;
    }
    return _hintedQuestionIds.contains(questionId) ? 0 : 1;
  }

  int get hintsUsed {
    if (mode == QuizModeType.quick) {
      return _hintedQuestionIds.length;
    }
    return mode.totalHints - _remainingGlobalHints;
  }
}
