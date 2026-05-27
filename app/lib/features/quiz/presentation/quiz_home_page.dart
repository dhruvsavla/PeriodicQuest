import 'package:flutter/material.dart';

import 'package:app/core/router/app_navigation.dart';
import 'package:app/features/quiz/data/quiz_leaderboard_repository.dart';
import 'package:app/features/quiz/data/quiz_question_generator.dart';
import 'package:app/features/quiz/models/quiz_language.dart';
import 'package:app/features/quiz/models/quiz_mode_type.dart';
import 'package:app/features/quiz/presentation/quiz_game_page.dart';
import 'package:app/features/quiz/puzzle/presentation/periodic_puzzle_home_page.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_strings.dart';
import 'package:app/features/quiz/presentation/widgets/quiz_language_toggle.dart';
import 'package:app/features/quiz/presentation/widgets/quiz_mode_card.dart';
import 'package:app/features/quiz/presentation/widgets/quiz_responsive_layout.dart';
import 'package:app/shared/decorations/app_gradients.dart';
import 'package:app/shared/widgets/pill_back_button.dart';

class QuizHomePage extends StatefulWidget {
  const QuizHomePage({
    super.key,
    this.questionGenerator = const QuizQuestionGenerator(),
    this.leaderboardRepository,
    this.initialLanguage = QuizLanguage.english,
    this.randomSeed,
  });

  final QuizQuestionGenerator questionGenerator;
  final QuizLeaderboardRepository? leaderboardRepository;
  final QuizLanguage initialLanguage;
  final int? randomSeed;

  @override
  State<QuizHomePage> createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  late QuizLanguage _selectedLanguage;

  QuizLeaderboardRepository get _leaderboardRepository =>
      widget.leaderboardRepository ?? QuizLeaderboardRepository.instance;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.initialLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final strings = QuizStrings.of(_selectedLanguage);
    final puzzleStrings = PeriodicPuzzleStrings.of(_selectedLanguage);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.skyBlue),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = constraints.maxWidth
                  .clamp(320.0, 860.0)
                  .toDouble();
              return Center(
                child: SizedBox(
                  width: contentWidth,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PillBackButton(
                              contentWidth: contentWidth,
                              foreground: const Color(0xFF3D6B80),
                              label: strings.backToGameModesLabel,
                            ),
                            const Spacer(),
                            QuizLanguageToggle(
                              selectedLanguage: _selectedLanguage,
                              onChanged: (value) {
                                setState(() {
                                  _selectedLanguage = value;
                                });
                              },
                            ),
                          ],
              final layout = QuizResponsiveLayout.resolve(
                context,
                constraints,
                maxContentWidth: 860,
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
                        LayoutBuilder(
                          builder: (context, _) {
                            if (layout.stackTopBar) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PillBackButton(
                                    contentWidth: layout.contentWidth,
                                    foreground: const Color(0xFF3D6B80),
                                    label: strings.backToGameModesLabel,
                                  ),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: QuizLanguageToggle(
                                      selectedLanguage: _selectedLanguage,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedLanguage = value;
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
                                  contentWidth: layout.contentWidth,
                                  foreground: const Color(0xFF3D6B80),
                                  label: strings.backToGameModesLabel,
                                ),
                                const Spacer(),
                                QuizLanguageToggle(
                                  selectedLanguage: _selectedLanguage,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedLanguage = value;
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        QuizModeCard(
                          title: strings.quickQuizTitle,
                          heroLabel: strings.quizReadyLabel,
                          badges: [
                            strings.quickQuizQuestionCount,
                            strings.instantFeedbackBadge,
                          ],
                          emoji: '⚡',
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD45A), Color(0xFFFFA66E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderColor: const Color(0xFFD8A300),
                          glowColor: const Color(0xFFFFC54D),
                          lines: [
                            strings.quickQuizDescription,
                            strings.quickHintSummary,
                            strings.answerChoicesLabel,
                          ],
                          onTap: () => _openQuizMode(QuizModeType.quick),
                        ),
                        const SizedBox(height: 18),
                        QuizModeCard(
                          title: strings.challengeModeTitle,
                          heroLabel: strings.quizReadyLabel,
                          badges: [
                            strings.challengeQuizQuestionCount,
                            strings.challengeHintsSummary,
                            strings.finalResultsBadge,
                          ],
                          emoji: '🏆',
                          gradient: const LinearGradient(
                            colors: [Color(0xFFDCC8FF), Color(0xFFA7D8FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderColor: const Color(0xFF9E78DA),
                          glowColor: const Color(0xFF9E78DA),
                          lines: [
                            strings.challengeResultsTiming,
                            strings.challengeHintsSummary,
                            strings.answerChoicesLabel,
                          ],
                          onTap: () => _openQuizMode(QuizModeType.challenge),
                        ),
                        const SizedBox(height: 18),
                        QuizModeCard(
                          title: puzzleStrings.puzzleTitle,
                          heroLabel: puzzleStrings.puzzleSubtitle,
                          badges: [
                            puzzleStrings.layerBadgeOne,
                            puzzleStrings.layerBadgeTwo,
                            puzzleStrings.layerBadgeThree,
                          ],
                          emoji: '🧩',
                          gradient: const LinearGradient(
                            colors: [Color(0xFFCFF4FF), Color(0xFFFFD6F0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderColor: const Color(0xFF73BDE2),
                          glowColor: const Color(0xFF8CCBFF),
                          lines: [
                            puzzleStrings.puzzleSubtitle,
                            puzzleStrings.groupLabel(
                              'Tap missing tiles to learn the table',
                              'Toca casillas faltantes para aprender la tabla',
                            ),
                            puzzleStrings.groupLabel(
                              'Names, symbols, and real-world clues',
                              'Nombres, símbolos y pistas del mundo real',
                            ),
                          ],
                          onTap: _openPuzzleMode,
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

  Future<void> _openQuizMode(QuizModeType mode) async {
    final returnedLanguage = await Navigator.push<QuizLanguage>(
      context,
      slideRoute(
        QuizGamePage(
          mode: mode,
          initialLanguage: _selectedLanguage,
          questionGenerator: widget.questionGenerator,
          leaderboardRepository: _leaderboardRepository,
          randomSeed: widget.randomSeed,
        ),
      ),
    );

    if (returnedLanguage != null && mounted) {
      setState(() {
        _selectedLanguage = returnedLanguage;
      });
    }
  }

  Future<void> _openPuzzleMode() async {
    final returnedLanguage = await Navigator.push<QuizLanguage>(
      context,
      slideRoute(PeriodicPuzzleHomePage(initialLanguage: _selectedLanguage)),
    );

    if (returnedLanguage != null && mounted) {
      setState(() {
        _selectedLanguage = returnedLanguage;
      });
    }
  }
}
