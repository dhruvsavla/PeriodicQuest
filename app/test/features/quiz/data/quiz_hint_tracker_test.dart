import 'package:app/features/quiz/models/quiz_hint_tracker.dart';
import 'package:app/features/quiz/models/quiz_mode_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Quick Quiz gives 1 hint per question and resets on next question', () {
    final tracker = QuizHintTracker.forMode(QuizModeType.quick);

    expect(tracker.canUseHint('q1'), isTrue);
    expect(tracker.hintsRemainingForQuestion('q1'), 1);

    tracker.useHint('q1');
    expect(tracker.canUseHint('q1'), isFalse);
    expect(tracker.hintsRemainingForQuestion('q1'), 0);

    expect(tracker.canUseHint('q2'), isTrue);
    expect(tracker.hintsRemainingForQuestion('q2'), 1);
  });

  test('Challenge Mode starts with 3 hints and cannot go below 0', () {
    final tracker = QuizHintTracker.forMode(QuizModeType.challenge);

    expect(tracker.remainingGlobalHints, 3);

    tracker.useHint('q1');
    tracker.useHint('q2');
    tracker.useHint('q3');
    expect(tracker.remainingGlobalHints, 0);
    expect(tracker.useHint('q4'), isFalse);
    expect(tracker.remainingGlobalHints, 0);
  });
}
