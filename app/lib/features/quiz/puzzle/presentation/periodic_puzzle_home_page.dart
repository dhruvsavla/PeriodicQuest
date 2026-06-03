import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:app/core/router/app_navigation.dart';
import 'package:app/features/quiz/models/quiz_language.dart';
import 'package:app/features/quiz/presentation/widgets/quiz_language_toggle.dart';
import 'package:app/features/quiz/presentation/widgets/quiz_responsive_layout.dart';
import 'package:app/features/quiz/puzzle/data/periodic_puzzle_best_times_repository.dart';
import 'package:app/features/quiz/puzzle/data/periodic_puzzle_generator.dart';
import 'package:app/features/quiz/puzzle/data/periodic_puzzle_progress_repository.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_layer.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_strings.dart';
import 'package:app/features/quiz/puzzle/presentation/periodic_puzzle_game_page.dart';
import 'package:app/features/quiz/puzzle/presentation/widgets/periodic_puzzle_layer_card.dart';
import 'package:app/shared/decorations/app_gradients.dart';
import 'package:app/shared/widgets/pill_back_button.dart';

class PeriodicPuzzleHomePage extends StatefulWidget {
  const PeriodicPuzzleHomePage({
    super.key,
    this.generator = const PeriodicPuzzleGenerator(),
    this.progressRepository,
    this.bestTimesRepository,
    this.initialLanguage = QuizLanguage.english,
  });

  final PeriodicPuzzleGenerator generator;
  final PeriodicPuzzleProgressRepository? progressRepository;
  final PeriodicPuzzleBestTimesRepository? bestTimesRepository;
  final QuizLanguage initialLanguage;

  @override
  State<PeriodicPuzzleHomePage> createState() => _PeriodicPuzzleHomePageState();
}

class _PeriodicPuzzleHomePageState extends State<PeriodicPuzzleHomePage> {
  late QuizLanguage _language;

  PeriodicPuzzleProgressRepository get _progressRepository =>
      widget.progressRepository ?? PeriodicPuzzleProgressRepository.instance;

  PeriodicPuzzleBestTimesRepository get _bestTimesRepository =>
      widget.bestTimesRepository ?? PeriodicPuzzleBestTimesRepository.instance;

  PeriodicPuzzleStrings get _strings => PeriodicPuzzleStrings.of(_language);

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final starterBoards = widget.generator.boardsForLayer(
      PeriodicPuzzleLayer.starter,
    );
    final groupBoards = widget.generator.boardsForLayer(
      PeriodicPuzzleLayer.groups,
    );
    final mixedBoards = widget.generator.boardsForLayer(
      PeriodicPuzzleLayer.mixed,
    );

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
                maxContentWidth: 920,
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
                                    label: _strings.backToQuizMenuLabel,
                                  ),
                                  SizedBox(height: 12.h),
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
                                  contentWidth: layout.contentWidth,
                                  foreground: const Color(0xFF3D6B80),
                                  label: _strings.backToQuizMenuLabel,
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
                        ),
                        SizedBox(height: 16.h),
                        PeriodicPuzzleLayerCard(
                          title: _strings.starterLayerTitle,
                          subtitle: _strings.starterLayerSubtitle,
                          statusLabel: _strings.layerStatusText(
                            locked: !_progressRepository.isLayerUnlocked(
                              PeriodicPuzzleLayer.starter,
                            ),
                            completed: _progressRepository.isLayerCompleted(
                              PeriodicPuzzleLayer.starter,
                            ),
                          ),
                          badges: [
                            _strings.groupLabel(
                              '6 missing tiles',
                              '6 casillas',
                            ),
                            _strings.groupLabel(
                              'First 20 elements',
                              'Primeros 20 elementos',
                            ),
                          ],
                          emoji: '🌟',
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFE38B), Color(0xFFFFB89A)],
                          ),
                          borderColor: const Color(0xFFDF9A41),
                          glowColor: const Color(0xFFFFC24D),
                          trailingLabel: _strings.progressText(
                            _countCompleted(starterBoards),
                            starterBoards.length,
                          ),
                          stars: _layerStars(starterBoards),
                          onTap: () => _openLayer(PeriodicPuzzleLayer.starter),
                        ),
                        SizedBox(height: 18.h),
                        PeriodicPuzzleLayerCard(
                          title: _strings.groupsLayerTitle,
                          subtitle: _strings.groupsLayerSubtitle,
                          statusLabel: _strings.layerStatusText(
                            locked: !_progressRepository.isLayerUnlocked(
                              PeriodicPuzzleLayer.groups,
                            ),
                            completed: _progressRepository.isLayerCompleted(
                              PeriodicPuzzleLayer.groups,
                            ),
                          ),
                          badges: [
                            _strings.groupLabel('5 group boards', '5 grupos'),
                            _strings.groupLabel(
                              '3 hints each',
                              '3 pistas cada uno',
                            ),
                          ],
                          emoji: '🧪',
                          gradient: const LinearGradient(
                            colors: [Color(0xFFDCC8FF), Color(0xFFA8E2FF)],
                          ),
                          borderColor: const Color(0xFF8E72D9),
                          glowColor: const Color(0xFFA579FF),
                          trailingLabel: _strings.progressText(
                            _countCompleted(groupBoards),
                            groupBoards.length,
                          ),
                          stars: _layerStars(groupBoards),
                          locked: !_progressRepository.isLayerUnlocked(
                            PeriodicPuzzleLayer.groups,
                          ),
                          onTap: () => _openLayer(PeriodicPuzzleLayer.groups),
                        ),
                        SizedBox(height: 18.h),
                        PeriodicPuzzleLayerCard(
                          title: _strings.mixedLayerTitle,
                          subtitle: _strings.mixedLayerSubtitle,
                          statusLabel: _strings.layerStatusText(
                            locked: !_progressRepository.isLayerUnlocked(
                              PeriodicPuzzleLayer.mixed,
                            ),
                            completed: _progressRepository.isLayerCompleted(
                              PeriodicPuzzleLayer.mixed,
                            ),
                          ),
                          badges: [
                            _strings.groupLabel(
                              '9 missing tiles',
                              '9 casillas',
                            ),
                            _strings.groupLabel(
                              'Real-world clues',
                              'Pistas reales',
                            ),
                          ],
                          emoji: '🚀',
                          gradient: const LinearGradient(
                            colors: [Color(0xFFCFF1D2), Color(0xFFFFE29A)],
                          ),
                          borderColor: const Color(0xFF6BB685),
                          glowColor: const Color(0xFF94D16C),
                          trailingLabel: _strings.progressText(
                            _countCompleted(mixedBoards),
                            mixedBoards.length,
                          ),
                          stars: _layerStars(mixedBoards),
                          locked: !_progressRepository.isLayerUnlocked(
                            PeriodicPuzzleLayer.mixed,
                          ),
                          onTap: () => _openLayer(PeriodicPuzzleLayer.mixed),
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

  int _countCompleted(List boards) {
    return boards
        .where((board) => _progressRepository.isBoardCompleted(board.id))
        .length;
  }

  int? _layerStars(List boards) {
    final completedBoards = boards
        .where((board) => _progressRepository.isBoardCompleted(board.id))
        .toList();
    if (completedBoards.isEmpty) {
      return null;
    }
    return completedBoards.fold<int>(0, (sum, board) {
      final progress = _progressRepository.progressForBoard(board);
      return sum + progress.stars;
    });
  }

  Future<void> _openLayer(PeriodicPuzzleLayer layer) async {
    if (!_progressRepository.isLayerUnlocked(layer)) {
      return;
    }

    final layerBoards = widget.generator.boardsForLayer(layer);
    final targetBoard = layerBoards.firstWhere(
      (board) => !_progressRepository.isBoardCompleted(board.id),
      orElse: () => layerBoards.first,
    );

    final returnedLanguage = await Navigator.push<QuizLanguage>(
      context,
      slideRoute(
        PeriodicPuzzleGamePage(
          board: targetBoard,
          generator: widget.generator,
          progressRepository: _progressRepository,
          bestTimesRepository: _bestTimesRepository,
          initialLanguage: _language,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _language = returnedLanguage ?? _language;
    });
  }
}
