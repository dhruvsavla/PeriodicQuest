import 'package:flutter/material.dart';

import 'package:app/core/router/app_navigation.dart';
import 'package:app/features/quiz/data/quiz_leaderboard_repository.dart';
import 'package:app/features/quiz/data/quiz_question_generator.dart';
import 'package:app/features/quiz/models/quiz_language.dart';
import 'package:app/features/quiz/models/quiz_leaderboard_entry.dart';
import 'package:app/features/quiz/models/quiz_mode_type.dart';
import 'package:app/features/quiz/models/quiz_session_result.dart';
import 'package:app/features/quiz/presentation/quiz_game_page.dart';
import 'package:app/features/quiz/presentation/widgets/quiz_language_toggle.dart';
import 'package:app/features/quiz/presentation/widgets/quiz_responsive_layout.dart';
import 'package:app/shared/decorations/app_gradients.dart';
import 'package:app/shared/widgets/pill_back_button.dart';

class QuizResultPage extends StatefulWidget {
  const QuizResultPage({
    super.key,
    required this.result,
    this.questionGenerator = const QuizQuestionGenerator(),
    this.leaderboardRepository,
    this.randomSeed,
  });

  final QuizSessionResult result;
  final QuizQuestionGenerator questionGenerator;
  final QuizLeaderboardRepository? leaderboardRepository;
  final int? randomSeed;

  @override
  State<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends State<QuizResultPage> {
  late QuizLanguage _language;
  late final TextEditingController _nameController;
  bool _scoreSaved = false;

  QuizStrings get _strings => QuizStrings.of(_language);

  QuizLeaderboardRepository get _leaderboardRepository =>
      widget.leaderboardRepository ?? QuizLeaderboardRepository.instance;

  bool get _showsLeaderboard => widget.result.mode == QuizModeType.challenge;

  bool get _qualifies =>
      _showsLeaderboard &&
      !_scoreSaved &&
      _leaderboardRepository.qualifiesForLeaderboard(widget.result);

  @override
  void initState() {
    super.initState();
    _language = widget.result.language;
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardEntries = _showsLeaderboard
        ? _leaderboardRepository.entriesFor(widget.result.mode)
        : const <QuizLeaderboardEntry>[];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.skyBlue),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final layout = QuizResponsiveLayout.resolve(
                context,
                constraints,
                maxContentWidth: 900,
              );

              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: layout.contentWidth,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      layout.horizontalPadding,
                      layout.topPadding,
                      layout.horizontalPadding,
                      layout.bottomPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(context),
                        const SizedBox(height: 18),
                        _buildScoreCard(),
                        const SizedBox(height: 20),
                        if (_qualifies) ...[
                          _buildHighScorePanel(),
                          const SizedBox(height: 20),
                        ],
                        if (_showsLeaderboard) ...[
                          _buildLeaderboardCard(leaderboardEntries),
                          const SizedBox(height: 20),
                        ],
                        _buildReviewHeader(),
                        const SizedBox(height: 14),
                        for (final answer
                            in widget.result.answeredQuestions) ...[
                          _buildAnswerReview(answer),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              slideRoute(
                                QuizGamePage(
                                  mode: widget.result.mode,
                                  initialLanguage: _language,
                                  questionGenerator: widget.questionGenerator,
                                  leaderboardRepository: _leaderboardRepository,
                                  randomSeed: widget.randomSeed,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size.fromHeight(
                                layout.compactCard ? 50 : 54,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: Text(
                              _strings.playAgainLabel,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, _language),
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size.fromHeight(
                                layout.compactCard ? 50 : 54,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: Text(
                              _strings.backToQuizMenuLabel,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = QuizResponsiveLayout.resolve(
          context,
          constraints,
          maxContentWidth: 900,
        );

        if (layout.stackTopBar) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PillBackButton(
                contentWidth: layout.contentWidth,
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
          children: [
            PillBackButton(
              contentWidth: layout.contentWidth,
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

  Widget _buildScoreCard() {
    final score = widget.result.score;
    final total = widget.result.totalQuestions;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 500;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? 16 : 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF0A6), Color(0xFFFFC8E0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(compact ? 24 : 30),
            border: Border.all(color: const Color(0xFFFFD06B), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB84D).withValues(alpha: 0.24),
                blurRadius: compact ? 18 : 24,
                offset: Offset(0, compact ? 8 : 12),
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
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _strings.scoreBurstLabel,
                      style: const TextStyle(
                        color: Color(0xFF6E4B1A),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    widget.result.mode == QuizModeType.quick ? '⚡' : '🏆',
                    style: TextStyle(fontSize: compact ? 24 : 30),
                  ),
                ],
              ),
              SizedBox(height: compact ? 12 : 16),
              Text(
                _strings.resultsLabel,
                style: TextStyle(
                  color: const Color(0xFF17334A),
                  fontSize: compact ? 28 : 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: compact ? 10 : 12),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: score),
                duration: const Duration(milliseconds: 700),
                builder: (context, value, child) {
                  return Text(
                    _strings.scoreText(value, total),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: const Color(0xFF17334A),
                      fontWeight: FontWeight.w900,
                    ),
                  );
                },
              ),
              SizedBox(height: compact ? 8 : 10),
              Text(
                _strings.encouragementText(score, total),
                style: TextStyle(
                  color: const Color(0xFF3E5F7B),
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 16 : 18,
                ),
              ),
              SizedBox(height: compact ? 12 : 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ScorePill(
                    icon: Icons.emoji_events_outlined,
                    label: '${_strings.scoreLabel}: $score/$total',
                  ),
                  _ScorePill(
                    icon: Icons.lightbulb_outline,
                    label: _strings.hintsLeftText(
                      widget.result.mode == QuizModeType.challenge
                          ? widget.result.mode.totalHints -
                                widget.result.hintsUsed
                          : 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHighScorePanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF1C7), Color(0xFFFFD68F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE2B83D), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌟', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _strings.newHighScoreLabel,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF6B5200),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _nameController,
            maxLength: 12,
            decoration: InputDecoration(
              labelText: _strings.enterYourNameLabel,
              hintText: _strings.playerPlaceholder,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.95),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveScore,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                _strings.saveScoreLabel,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardCard(List<QuizLeaderboardEntry> entries) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                _strings.leaderboardLabel,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF17334A),
                  fontWeight: FontWeight.w900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F3FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _strings.arcadeStarsLabel,
                  style: const TextStyle(
                    color: Color(0xFF2C4E6E),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            Text(
              _strings.newHighScoreLabel,
              style: const TextStyle(
                color: Color(0xFF45657D),
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Column(
              children: [
                for (var index = 0; index < entries.length; index++)
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 240 + (index * 80)),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, (1 - value) * 10),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        bottom: index == entries.length - 1 ? 0 : 10,
                      ),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6FBFF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFD9EAF8),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          _RankBadge(rank: index + 1),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entries[index].playerName,
                              style: const TextStyle(
                                color: Color(0xFF17334A),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            '${entries[index].score}/${entries[index].totalQuestions}',
                            style: const TextStyle(
                              color: Color(0xFF2C4E6E),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildReviewHeader() {
    return Text(
      _strings.resultsLabel,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: const Color(0xFF17334A),
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildAnswerReview(QuizAnsweredQuestion answer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: answer.isCorrect
              ? const Color(0xFF84D4A4)
              : const Color(0xFFFFB3B3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                answer.isCorrect ? Icons.check_circle : Icons.cancel,
                color: answer.isCorrect
                    ? const Color(0xFF2F9C5C)
                    : const Color(0xFFC95A5A),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  answer.question.promptFor(_language),
                  style: const TextStyle(
                    color: Color(0xFF17334A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${_strings.yourAnswerLabel}: ${answer.selectedOption.labelFor(_language)}',
            style: const TextStyle(
              color: Color(0xFF45657D),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (!answer.isCorrect) ...[
            const SizedBox(height: 6),
            Text(
              '${_strings.correctAnswerLabel}: ${answer.question.correctOption.labelFor(_language)}',
              style: const TextStyle(
                color: Color(0xFF8A2020),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _saveScore() {
    _leaderboardRepository.saveResult(
      result: QuizSessionResult(
        mode: widget.result.mode,
        language: _language,
        answeredQuestions: widget.result.answeredQuestions,
        hintsUsed: widget.result.hintsUsed,
      ),
      playerName: _nameController.text,
    );

    setState(() {
      _scoreSaved = true;
    });
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
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

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final label = switch (rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => '$rank',
    };

    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F3FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: rank <= 3 ? 22 : 16,
          fontWeight: FontWeight.w900,
          color: rank <= 3 ? null : const Color(0xFF2C4E6E),
        ),
      ),
    );
  }
}
