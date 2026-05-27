import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:app/core/router/app_navigation.dart';
import 'package:app/features/quiz/data/quiz_leaderboard_repository.dart';
import 'package:app/features/quiz/data/quiz_question_generator.dart';
import 'package:app/features/quiz/models/quiz_hint_tracker.dart';
import 'package:app/features/quiz/models/quiz_language.dart';
import 'package:app/features/quiz/models/quiz_mode_type.dart';
import 'package:app/features/quiz/models/quiz_question.dart';
import 'package:app/features/quiz/models/quiz_session_result.dart';
import 'package:app/features/quiz/presentation/quiz_result_page.dart';
import 'package:app/features/quiz/presentation/widgets/quiz_language_toggle.dart';
import 'package:app/features/quiz/presentation/widgets/quiz_option_button.dart';
import 'package:app/shared/decorations/app_gradients.dart';
import 'package:app/shared/widgets/pill_back_button.dart';

class QuizGamePage extends StatefulWidget {
  const QuizGamePage({
    super.key,
    required this.mode,
    required this.initialLanguage,
    this.questionGenerator = const QuizQuestionGenerator(),
    this.leaderboardRepository,
    this.randomSeed,
  });

  final QuizModeType mode;
  final QuizLanguage initialLanguage;
  final QuizQuestionGenerator questionGenerator;
  final QuizLeaderboardRepository? leaderboardRepository;
  final int? randomSeed;

  @override
  State<QuizGamePage> createState() => _QuizGamePageState();
}

class _QuizGamePageState extends State<QuizGamePage> {
  late final List<QuizQuestion> _questions;
  late final QuizHintTracker _hintTracker;

  final Map<String, String> _submittedAnswerIds = <String, String>{};
  int _currentIndex = 0;
  String? _selectedOptionId;
  bool _feedbackVisible = false;
  late QuizLanguage _language;

  QuizQuestion get _currentQuestion => _questions[_currentIndex];

  QuizStrings get _strings => QuizStrings.of(_language);

  QuizLeaderboardRepository get _leaderboardRepository =>
      widget.leaderboardRepository ?? QuizLeaderboardRepository.instance;

  bool get _isQuickQuiz => widget.mode == QuizModeType.quick;

  bool get _isLastQuestion => _currentIndex == _questions.length - 1;

  bool get _canAdvance =>
      _isQuickQuiz ? _feedbackVisible : _selectedOptionId != null;

  bool get _hasHintForCurrentQuestion =>
      _hintTracker.hasUsedHint(_currentQuestion.id);

  int get _currentScore {
    var score = 0;
    for (final entry in _submittedAnswerIds.entries) {
      final question = _questions.firstWhere((item) => item.id == entry.key);
      if (question.correctOptionId == entry.value) {
        score++;
      }
    }
    return score;
  }

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _questions = widget.questionGenerator.generateQuestions(
      mode: widget.mode,
      random: widget.randomSeed == null ? null : math.Random(widget.randomSeed),
    );
    _hintTracker = QuizHintTracker.forMode(widget.mode);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.skyBlue),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(context),
                    const SizedBox(height: 18),
                    _buildHeroHeader(progress),
                    const SizedBox(height: 18),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.03, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: _buildQuestionPanel(
                        context,
                        key: ValueKey(
                          '${_currentQuestion.id}-${_language.name}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, -0.05),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: _hasHintForCurrentQuestion
                          ? _buildHintBox(
                              key: ValueKey('hint-${_currentQuestion.id}'),
                            )
                          : const SizedBox.shrink(key: ValueKey('no-hint')),
                    ),
                    if (_hasHintForCurrentQuestion) const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.03),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: _buildOptionsPanel(
                        context,
                        key: ValueKey(
                          'options-${_currentQuestion.id}-${_language.name}',
                        ),
                      ),
                    ),
                    if (_isQuickQuiz && _feedbackVisible) ...[
                      const SizedBox(height: 16),
                      _buildFeedbackBox(),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canAdvance ? _advanceQuiz : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          _isLastQuestion
                              ? _strings.finishLabel
                              : _strings.nextLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PillBackButton(
                contentWidth: constraints.maxWidth,
                foreground: const Color(0xFF3D6B80),
                label: _strings.backToQuizMenuLabel,
                onTap: () => Navigator.pop(context, _language),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: QuizLanguageToggle(
                  selectedLanguage: _language,
                  onChanged: (value) {
                    setState(() {
                      _language = value;
                    });
                  },
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PillBackButton(
              contentWidth: constraints.maxWidth,
              foreground: const Color(0xFF3D6B80),
              label: _strings.backToQuizMenuLabel,
              onTap: () => Navigator.pop(context, _language),
            ),
            const Spacer(),
            QuizLanguageToggle(
              selectedLanguage: _language,
              onChanged: (value) {
                setState(() {
                  _language = value;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeroHeader(double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.mode == QuizModeType.quick
              ? const [Color(0xFFFFD873), Color(0xFFFFA9A1)]
              : const [Color(0xFFDCC8FF), Color(0xFF9FD9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A9AC8).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mode == QuizModeType.quick
                          ? _strings.quickQuizTitle
                          : _strings.challengeModeTitle,
                      style: const TextStyle(
                        color: Color(0xFF17334A),
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _StatusChip(
                          icon: Icons.route_rounded,
                          label: _strings.progressText(
                            _currentIndex + 1,
                            _questions.length,
                          ),
                        ),
                        _StatusChip(
                          icon: Icons.lightbulb_outline,
                          label: _isQuickQuiz
                              ? _strings.questionHintStatusText(
                                  _hintTracker.hintsRemainingForQuestion(
                                    _currentQuestion.id,
                                  ),
                                )
                              : _strings.hintsLeftText(
                                  _hintTracker.remainingGlobalHints,
                                ),
                        ),
                        _StatusChip(
                          icon: Icons.emoji_events_outlined,
                          label: '${_strings.scoreLabel}: $_currentScore',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  widget.mode == QuizModeType.quick ? '⚡' : '🏆',
                  style: const TextStyle(fontSize: 34),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPanel(BuildContext context, {required Key key}) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F0FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _strings.questionLabel,
                  style: const TextStyle(
                    color: Color(0xFF28567E),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (_currentQuestion.visualCueEmoji != null)
                Container(
                  key: const Key('quiz-real-world-cue'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0C8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _currentQuestion.visualCueEmoji!,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _currentQuestion.promptFor(_language),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF17334A),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.tonalIcon(
                onPressed: _hintTracker.canUseHint(_currentQuestion.id)
                    ? _showHint
                    : null,
                icon: const Icon(Icons.lightbulb_outline),
                label: Text(
                  _hintTracker.canUseHint(_currentQuestion.id)
                      ? _strings.useHintLabel
                      : _strings.noHintsLeftLabel,
                ),
              ),
              Text(
                _isQuickQuiz
                    ? _strings.questionHintStatusText(
                        _hintTracker.hintsRemainingForQuestion(
                          _currentQuestion.id,
                        ),
                      )
                    : _strings.hintsLeftText(_hintTracker.remainingGlobalHints),
                style: const TextStyle(
                  color: Color(0xFF45657D),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHintBox({required Key key}) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF5D9), Color(0xFFFFE8B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5C04F), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: const Text('💡', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _strings.friendlyHintIntro,
                  style: const TextStyle(
                    color: Color(0xFF6B5200),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _currentQuestion.hintFor(_language),
                  style: const TextStyle(
                    color: Color(0xFF6B5200),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsPanel(BuildContext context, {required Key key}) {
    return LayoutBuilder(
      key: key,
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 760;
        final cardWidth = twoColumns
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (
              var index = 0;
              index < _currentQuestion.options.length;
              index++
            )
              SizedBox(
                width: cardWidth,
                child: QuizOptionButton(
                  key: Key('quiz-option-${_currentQuestion.options[index].id}'),
                  option: _currentQuestion.options[index],
                  questionType: _currentQuestion.type,
                  language: _language,
                  prefix: String.fromCharCode(65 + index),
                  isSelected:
                      _selectedOptionId == _currentQuestion.options[index].id,
                  isCorrect:
                      _isQuickQuiz &&
                      _feedbackVisible &&
                      _currentQuestion.options[index].id ==
                          _currentQuestion.correctOptionId,
                  isIncorrect:
                      _isQuickQuiz &&
                      _feedbackVisible &&
                      _selectedOptionId == _currentQuestion.options[index].id &&
                      _selectedOptionId != _currentQuestion.correctOptionId,
                  isDisabled: _isQuickQuiz && _feedbackVisible,
                  onTap: () =>
                      _handleOptionTap(_currentQuestion.options[index].id),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFeedbackBox() {
    final isCorrect = _selectedOptionId == _currentQuestion.correctOptionId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: isCorrect
            ? const LinearGradient(
                colors: [Color(0xFFDDF7E8), Color(0xFFC7F0D7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFFFE8E8), Color(0xFFFFD4D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCorrect ? const Color(0xFF2F9C5C) : const Color(0xFFC95A5A),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect
                ? Icons.celebration_rounded
                : Icons.psychology_alt_rounded,
            color: isCorrect
                ? const Color(0xFF14613B)
                : const Color(0xFF8A2020),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? _strings.niceWorkLabel : _strings.incorrectLabel,
                  style: TextStyle(
                    color: isCorrect
                        ? const Color(0xFF14613B)
                        : const Color(0xFF8A2020),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isCorrect
                      ? _strings.correctLabel
                      : '${_strings.almostThereLabel} ${_currentQuestion.correctOption.labelFor(_language)}',
                  style: TextStyle(
                    color: isCorrect
                        ? const Color(0xFF14613B)
                        : const Color(0xFF8A2020),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleOptionTap(String optionId) {
    if (_isQuickQuiz) {
      if (_feedbackVisible) {
        return;
      }
      setState(() {
        _selectedOptionId = optionId;
        _submittedAnswerIds[_currentQuestion.id] = optionId;
        _feedbackVisible = true;
      });
      return;
    }

    setState(() {
      _selectedOptionId = optionId;
    });
  }

  void _showHint() {
    final usedHint = _hintTracker.useHint(_currentQuestion.id);
    if (!usedHint) {
      return;
    }
    setState(() {});
  }

  void _advanceQuiz() {
    if (!_isQuickQuiz && _selectedOptionId != null) {
      _submittedAnswerIds[_currentQuestion.id] = _selectedOptionId!;
    }

    if (_isLastQuestion) {
      final answeredQuestions = _questions
          .map(
            (question) => QuizAnsweredQuestion(
              question: question,
              selectedOptionId: _submittedAnswerIds[question.id] ?? '',
            ),
          )
          .toList(growable: false);

      Navigator.pushReplacement(
        context,
        slideRoute(
          QuizResultPage(
            result: QuizSessionResult(
              mode: widget.mode,
              language: _language,
              answeredQuestions: answeredQuestions,
              hintsUsed: _hintTracker.hintsUsed,
            ),
            questionGenerator: widget.questionGenerator,
            leaderboardRepository: _leaderboardRepository,
            randomSeed: widget.randomSeed,
          ),
        ),
      );
      return;
    }

    setState(() {
      _currentIndex++;
      _selectedOptionId = null;
      _feedbackVisible = false;
    });
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2C4E6E)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF2C4E6E),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
