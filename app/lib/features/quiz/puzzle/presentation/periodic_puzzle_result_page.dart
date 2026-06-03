import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:app/core/router/app_navigation.dart';
import 'package:app/core/responsive/app_radius.dart';
import 'package:app/features/quiz/models/quiz_language.dart';
import 'package:app/features/quiz/presentation/widgets/quiz_language_toggle.dart';
import 'package:app/features/quiz/presentation/widgets/quiz_responsive_layout.dart';
import 'package:app/features/quiz/puzzle/data/periodic_puzzle_best_times_repository.dart';
import 'package:app/features/quiz/puzzle/data/periodic_puzzle_generator.dart';
import 'package:app/features/quiz/puzzle/data/periodic_puzzle_progress_repository.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_board.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_best_time_entry.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_layer.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_strings.dart';
import 'package:app/features/quiz/puzzle/presentation/periodic_puzzle_game_page.dart';
import 'package:app/features/quiz/puzzle/presentation/periodic_puzzle_home_page.dart';
import 'package:app/shared/decorations/app_gradients.dart';
import 'package:app/shared/widgets/pill_back_button.dart';

class PeriodicPuzzleResultPage extends StatefulWidget {
  const PeriodicPuzzleResultPage({
    super.key,
    required this.board,
    this.generator = const PeriodicPuzzleGenerator(),
    this.progressRepository,
    this.bestTimesRepository,
    this.initialLanguage = QuizLanguage.english,
  });

  final PeriodicPuzzleBoard board;
  final PeriodicPuzzleGenerator generator;
  final PeriodicPuzzleProgressRepository? progressRepository;
  final PeriodicPuzzleBestTimesRepository? bestTimesRepository;
  final QuizLanguage initialLanguage;

  @override
  State<PeriodicPuzzleResultPage> createState() =>
      _PeriodicPuzzleResultPageState();
}

class _PeriodicPuzzleResultPageState extends State<PeriodicPuzzleResultPage> {
  Timer? _ticker;
  late QuizLanguage _language;
  late final TextEditingController _nameController;
  late Duration _elapsedTime;
  bool _timeSaved = false;

  PeriodicPuzzleProgressRepository get _progressRepository =>
      widget.progressRepository ?? PeriodicPuzzleProgressRepository.instance;

  PeriodicPuzzleBestTimesRepository get _bestTimesRepository =>
      widget.bestTimesRepository ?? PeriodicPuzzleBestTimesRepository.instance;

  PeriodicPuzzleStrings get _strings => PeriodicPuzzleStrings.of(_language);

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _nameController = TextEditingController();
    _elapsedTime = _progressRepository.elapsedTime;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _elapsedTime = _progressRepository.elapsedTime;
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boardProgress = _progressRepository.progressForBoard(widget.board);
    final nextGroupBoard = _nextIncompleteGroupBoard();
    final isFinalBoard = widget.board.layer == PeriodicPuzzleLayer.mixed;
    final aggregatedProgress = widget.generator
        .buildBoards()
        .where((board) => _progressRepository.isBoardCompleted(board.id))
        .map(_progressRepository.progressForBoard)
        .toList(growable: false);
    final totalStars = _progressRepository.totalStars(aggregatedProgress);
    final totalMistakes = _progressRepository.totalMistakes(aggregatedProgress);
    final totalHintsUsed = _progressRepository.totalHintsUsed(
      aggregatedProgress,
    );
    final bestTimeEntries = _bestTimesRepository.entries;
    final qualifiesForBestTimes =
        isFinalBoard &&
        !_timeSaved &&
        _bestTimesRepository.qualifies(
          totalElapsedTime: _elapsedTime,
          totalStars: totalStars,
          totalMistakes: totalMistakes,
          totalHintsUsed: totalHintsUsed,
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
                                    onTap: () =>
                                        Navigator.pop(context, _language),
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
                              children: [
                                PillBackButton(
                                  contentWidth: layout.contentWidth,
                                  foreground: const Color(0xFF3D6B80),
                                  label: _strings.backToQuizMenuLabel,
                                  onTap: () =>
                                      Navigator.pop(context, _language),
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
                        SizedBox(height: 12.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(18.w),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFF0A6), Color(0xFFCFF3FF)],
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _strings.puzzleCompleteLabel,
                                style: TextStyle(
                                  color: Color(0xFF17334A),
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                widget.board.titleFor(_language),
                                style: TextStyle(
                                  color: Color(0xFF35566F),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              TweenAnimationBuilder<int>(
                                tween: IntTween(
                                  begin: 0,
                                  end: boardProgress.stars,
                                ),
                                duration: const Duration(milliseconds: 650),
                                builder: (context, value, child) {
                                  return Text(
                                    '⭐' * value,
                                    style: TextStyle(fontSize: 30.sp),
                                  );
                                },
                              ),
                              SizedBox(height: 12.h),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  _ResultChip(
                                    label: _strings.totalTimeText(_elapsedTime),
                                  ),
                                  _ResultChip(
                                    label: _strings.mistakesText(
                                      boardProgress.mistakes,
                                    ),
                                  ),
                                  _ResultChip(
                                    label:
                                        '${_strings.hintsUsedLabel}: ${boardProgress.hintsUsed}',
                                  ),
                                  _ResultChip(
                                    label: _strings.starsText(
                                      boardProgress.stars,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 14.h),
                              Text(
                                isFinalBoard
                                    ? _strings.greatJobLabel
                                    : _strings.unlockedNextLayerLabel,
                                style: const TextStyle(
                                  color: Color(0xFF2C4E6E),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isFinalBoard) ...[
                          SizedBox(height: 18.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _strings.greatJobLabel,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: const Color(0xFF17334A),
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                                SizedBox(height: 12.h),
                                _ResultChip(
                                  label: _strings.totalTimeText(_elapsedTime),
                                ),
                                SizedBox(height: 8.h),
                                _ResultChip(
                                  label:
                                      '${_strings.mistakesLabel}: $totalMistakes',
                                ),
                                SizedBox(height: 8.h),
                                _ResultChip(
                                  label:
                                      '${_strings.hintsUsedLabel}: $totalHintsUsed',
                                ),
                                SizedBox(height: 8.h),
                                _ResultChip(
                                  label:
                                      '${_strings.starsSummaryLabel}: $totalStars',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 18.h),
                          if (qualifiesForBestTimes) ...[
                            _buildBestTimeEntryPanel(
                              totalStars: totalStars,
                              totalMistakes: totalMistakes,
                              totalHintsUsed: totalHintsUsed,
                            ),
                            SizedBox(height: 18.h),
                          ],
                          _buildBestTimesCard(bestTimeEntries),
                        ],
                        SizedBox(height: 20.h),
                        if (widget.board.layer == PeriodicPuzzleLayer.groups &&
                            nextGroupBoard != null)
                          _PrimaryButton(
                            key: const Key('puzzle-next-group'),
                            label: _strings.nextGroupLabel,
                            onTap: () => _openBoard(nextGroupBoard),
                          )
                        else if (!isFinalBoard)
                          _PrimaryButton(
                            key: const Key('puzzle-next-layer'),
                            label: _strings.nextLayerLabel,
                            onTap: () => _openNextLayer(),
                          )
                        else
                          _PrimaryButton(
                            label: _strings.playAgainLabel,
                            onTap: _playAgain,
                          ),
                        SizedBox(height: 12.h),
                        _SecondaryButton(
                          label: _strings.backToQuizMenuLabel,
                          onTap: () => Navigator.pushReplacement(
                            context,
                            slideRoute(
                              PeriodicPuzzleHomePage(
                                generator: widget.generator,
                                progressRepository: _progressRepository,
                                bestTimesRepository: _bestTimesRepository,
                                initialLanguage: _language,
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

  PeriodicPuzzleBoard? _nextIncompleteGroupBoard() {
    if (widget.board.layer != PeriodicPuzzleLayer.groups) {
      return null;
    }
    for (final board in widget.generator.boardsForLayer(
      PeriodicPuzzleLayer.groups,
    )) {
      if (!_progressRepository.isBoardCompleted(board.id)) {
        return board;
      }
    }
    return null;
  }

  void _openBoard(PeriodicPuzzleBoard board) {
    Navigator.pushReplacement(
      context,
      slideRoute(
        PeriodicPuzzleGamePage(
          board: board,
          generator: widget.generator,
          progressRepository: _progressRepository,
          bestTimesRepository: _bestTimesRepository,
          initialLanguage: _language,
        ),
      ),
    );
  }

  void _openNextLayer() {
    final nextLayer = switch (widget.board.layer) {
      PeriodicPuzzleLayer.starter => PeriodicPuzzleLayer.groups,
      PeriodicPuzzleLayer.groups => PeriodicPuzzleLayer.mixed,
      PeriodicPuzzleLayer.mixed => PeriodicPuzzleLayer.mixed,
    };
    final nextBoard = widget.generator.boardsForLayer(nextLayer).first;
    _openBoard(nextBoard);
  }

  void _playAgain() {
    _progressRepository.resetAll();
    Navigator.pushReplacement(
      context,
      slideRoute(
        PeriodicPuzzleHomePage(
          generator: widget.generator,
          progressRepository: _progressRepository,
          bestTimesRepository: _bestTimesRepository,
          initialLanguage: _language,
        ),
      ),
    );
  }

  Widget _buildBestTimeEntryPanel({
    required int totalStars,
    required int totalMistakes,
    required int totalHintsUsed,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF1C7), Color(0xFFFFD68F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(color: const Color(0xFFE2B83D), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('⏱️', style: TextStyle(fontSize: 28.sp)),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  _strings.newBestTimeLabel,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF6B5200),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          TextField(
            controller: _nameController,
            maxLength: 12,
            decoration: InputDecoration(
              labelText: _strings.enterYourNameLabel,
              hintText: _strings.playerPlaceholder,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.95),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _saveBestTime(
                totalStars: totalStars,
                totalMistakes: totalMistakes,
                totalHintsUsed: totalHintsUsed,
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: Text(
                _strings.saveTimeLabel,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestTimesCard(List<PeriodicPuzzleBestTimeEntry> entries) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _strings.bestTimesLabel,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF17334A),
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 16.h),
          if (entries.isEmpty)
            const SizedBox.shrink()
          else
            Column(
              children: [
                for (var index = 0; index < entries.length; index++)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(
                      bottom: index == entries.length - 1 ? 0 : 10.h,
                    ),
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6FBFF),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: const Color(0xFFD9EAF8),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        _PuzzleRankBadge(rank: index + 1),
                        SizedBox(width: 12.w),
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
                          '${formatPuzzleDuration(entries[index].totalElapsedTime)} — ${entries[index].totalStars}★',
                          style: const TextStyle(
                            color: Color(0xFF2C4E6E),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  void _saveBestTime({
    required int totalStars,
    required int totalMistakes,
    required int totalHintsUsed,
  }) {
    _bestTimesRepository.save(
      playerName: _nameController.text,
      totalElapsedTime: _elapsedTime,
      totalStars: totalStars,
      totalMistakes: totalMistakes,
      totalHintsUsed: totalHintsUsed,
      language: _language,
    );
    setState(() {
      _timeSaved = true;
    });
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(54.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          minimumSize: Size.fromHeight(54.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _ResultChip extends StatelessWidget {
  const _ResultChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF2C4E6E),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PuzzleRankBadge extends StatelessWidget {
  const _PuzzleRankBadge({required this.rank});

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
      width: 40.w,
      height: 40.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE7F3FF),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900),
      ),
    );
  }
}
