import 'package:flutter/material.dart';
import 'dart:async';

import 'package:app/core/router/app_navigation.dart';
import 'package:app/features/quiz/models/quiz_language.dart';
import 'package:app/features/quiz/presentation/widgets/quiz_language_toggle.dart';
import 'package:app/core/audio/element_audio_service.dart';
import 'package:app/core/router/app_navigation.dart';
import 'package:app/features/quiz/models/quiz_language.dart';
import 'package:app/features/quiz/presentation/widgets/quiz_language_toggle.dart';
import 'package:app/features/quiz/presentation/widgets/quiz_responsive_layout.dart';
import 'package:app/features/quiz/puzzle/data/periodic_puzzle_best_times_repository.dart';
import 'package:app/features/quiz/puzzle/data/periodic_puzzle_generator.dart';
import 'package:app/features/quiz/puzzle/data/periodic_puzzle_progress_repository.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_board.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_layer.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_progress.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_strings.dart';
import 'package:app/features/quiz/puzzle/models/periodic_puzzle_tile.dart';
import 'package:app/features/quiz/puzzle/presentation/periodic_puzzle_result_page.dart';
import 'package:app/features/quiz/puzzle/presentation/widgets/periodic_puzzle_board_widget.dart';
import 'package:app/features/quiz/puzzle/presentation/widgets/periodic_puzzle_option_card.dart';
import 'package:app/shared/decorations/app_gradients.dart';
import 'package:app/shared/widgets/pill_back_button.dart';

class PeriodicPuzzleGamePage extends StatefulWidget {
  const PeriodicPuzzleGamePage({
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
  State<PeriodicPuzzleGamePage> createState() => _PeriodicPuzzleGamePageState();
}

class _PeriodicPuzzleGamePageState extends State<PeriodicPuzzleGamePage> {
  Timer? _ticker;
  late QuizLanguage _language;
  late PeriodicPuzzleBoardProgress _boardProgress;
  late Duration _elapsedTime;
  final ElementAudioService _audioService = ElementAudioService.instance;
  String? _selectedTileId;
  String? _completedTileId;
  String? _incorrectOptionId;
  String? _hintTileId;
  bool? _lastAnswerWasCorrect;
  String? _lastNarratedClueKey;

  PeriodicPuzzleProgressRepository get _progressRepository =>
      widget.progressRepository ?? PeriodicPuzzleProgressRepository.instance;

  PeriodicPuzzleBestTimesRepository get _bestTimesRepository =>
      widget.bestTimesRepository ?? PeriodicPuzzleBestTimesRepository.instance;

  PeriodicPuzzleStrings get _strings => PeriodicPuzzleStrings.of(_language);

  List<PeriodicPuzzleBoard> get _siblingBoards =>
      widget.generator.boardsForLayer(widget.board.layer);

  PeriodicPuzzleTile? get _selectedTile => widget.board.missingTiles
      .where((tile) => !_boardProgress.isFilled(tile.id))
      .cast<PeriodicPuzzleTile?>()
      .firstWhere(
        (tile) => tile?.id == _selectedTileId,
        orElse: () => _firstOpenTile,
      );

  PeriodicPuzzleTile? get _firstOpenTile {
    for (final tile in widget.board.missingTiles) {
      if (!_boardProgress.isFilled(tile.id)) {
        return tile;
      }
    }
    return null;
  }

  bool get _isComplete => _boardProgress.isComplete;

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _progressRepository.startRunIfNeeded();
    _boardProgress = _progressRepository.progressForBoard(widget.board);
    _elapsedTime = _progressRepository.elapsedTime;
    _selectedTileId = _firstOpenTile?.id;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _elapsedTime = _progressRepository.elapsedTime;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _speakSelectedTileClue();
    });
  }

  @override
  void dispose() {
    _audioService.stop();
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PillBackButton(
                          contentWidth: 980,
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
                    ),
                    const SizedBox(height: 12),
                    _buildHeader(),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PeriodicPuzzleBoardWidget(
                            board: widget.board,
                            language: _language,
                            filledTileIds: _boardProgress.filledTileIds,
                            selectedTileId: _selectedTileId,
                            completedTileId: _completedTileId,
                            onTileTap: (tile) {
                              setState(() {
                                _selectedTileId = tile.id;
                              });
                            },
                            localizedNameForTile: (tile) => widget.generator
                                .localizedElementName(tile.element, _language),
                          ),
                          if (_isComplete) ...[
                            const SizedBox(height: 18),
                            _buildCompleteBanner(),
                          ] else ...[
                            const SizedBox(height: 18),
                            _buildSelectionPanel(),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final layout = QuizResponsiveLayout.resolve(
                context,
                constraints,
                maxContentWidth: 980,
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
                                    onTap: () {
                                      _audioService.stop();
                                      Navigator.pop(context, _language);
                                    },
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
                                        _speakSelectedTileClue(force: true);
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
                                  onTap: () {
                                    _audioService.stop();
                                    Navigator.pop(context, _language);
                                  },
                                ),
                                const Spacer(),
                                QuizLanguageToggle(
                                  selectedLanguage: _language,
                                  onChanged: (value) {
                                    setState(() {
                                      _language = value;
                                    });
                                    _speakSelectedTileClue(force: true);
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildHeader(),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PeriodicPuzzleBoardWidget(
                                board: widget.board,
                                language: _language,
                                filledTileIds: _boardProgress.filledTileIds,
                                selectedTileId: _selectedTileId,
                                completedTileId: _completedTileId,
                                onTileTap: (tile) {
                                  setState(() {
                                    _selectedTileId = tile.id;
                                  });
                                  _speakSelectedTileClue(force: true);
                                },
                                localizedNameForTile: (tile) =>
                                    widget.generator.localizedElementName(
                                      tile.element,
                                      _language,
                                    ),
                              ),
                              if (_isComplete) ...[
                                const SizedBox(height: 18),
                                _buildCompleteBanner(),
                              ] else ...[
                                const SizedBox(height: 18),
                                _buildSelectionPanel(),
                              ],
                            ],
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFCFF4FF), Color(0xFFFFE0A8)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.board.titleFor(_language),
            style: const TextStyle(
              color: Color(0xFF17334A),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.board.groupLabelFor(_language) ??
                widget.board.subtitleFor(_language),
            style: const TextStyle(
              color: Color(0xFF35566F),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(label: _strings.timeText(_elapsedTime)),
              _StatusChip(
                label: _strings.mistakesText(_boardProgress.mistakes),
              ),
              _StatusChip(
                label: _strings.hintsRemainingText(
                  _boardProgress.hintsRemaining,
                ),
              ),
              _StatusChip(
                label:
                    '${_boardProgress.filledTileIds.length}/${widget.board.missingTiles.length}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionPanel() {
    final tile = _selectedTile ?? _firstOpenTile;
    if (tile == null) {
      return const SizedBox.shrink();
    }

    final options = tile.options;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF7FBFF), Color(0xFFEAF4FF)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFD1E5F6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _StatusChip(label: _strings.fillThisTileLabel),
                  if (tile.clue != null)
                    _StatusChip(label: tile.clue!.labelFor(_language)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                tile.clue!.textFor(_language),
                style: const TextStyle(
                  color: Color(0xFF17334A),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
              Wrap(
                spacing: 12,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: _audioService.isPlaying,
                    builder: (context, isPlaying, _) {
                      return FilledButton.tonalIcon(
                        onPressed: () {
                          if (isPlaying) {
                            _audioService.stop();
                            return;
                          }
                          _speakSelectedTileClue(force: true);
                        },
                        icon: Icon(
                          isPlaying
                              ? Icons.stop_circle_outlined
                              : Icons.volume_up,
                        ),
                        label: Text(
                          isPlaying
                              ? (_language == QuizLanguage.spanish
                                    ? 'Detener audio'
                                    : 'Stop audio')
                              : (_language == QuizLanguage.spanish
                                    ? 'Repetir pista'
                                    : 'Replay clue'),
                        ),
                      );
                    },
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _boardProgress.hintsRemaining > 0
                        ? _useHint
                        : null,
                    icon: const Icon(Icons.lightbulb_outline),
                    label: Text(_strings.useHintLabel),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _strings.hintsRemainingText(_boardProgress.hintsRemaining),
                    style: const TextStyle(
                      color: Color(0xFF35566F),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_hintTileId != null && _hintTileId == tile.id) ...[
          const SizedBox(height: 12),
          _buildHintBox(tile),
        ],
        if (_lastAnswerWasCorrect != null) ...[
          const SizedBox(height: 12),
          _buildFeedbackBanner(),
        ],
        const SizedBox(height: 16),
        Text(
          _strings.chooseCorrectElementLabel,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF17334A),
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth >= 760
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var index = 0; index < options.length; index++)
                  SizedBox(
                    width: cardWidth,
                    child: PeriodicPuzzleOptionCard(
                      key: Key('puzzle-option-${options[index].id}'),
                      option: options[index],
                      clueType: tile.clue!.type,
                      language: _language,
                      prefix: String.fromCharCode(65 + index),
                      isSelected: false,
                      isIncorrect: _incorrectOptionId == options[index].id,
                      onTap: () => _handleOptionTap(tile, options[index].id),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildHintBox(PeriodicPuzzleTile tile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF5D9), Color(0xFFFFE8B6)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white70,
              shape: BoxShape.circle,
            ),
            child: const Text('💡', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tile.clue!.hintFor(_language),
              style: const TextStyle(
                color: Color(0xFF6B5200),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackBanner() {
    final isCorrect = _lastAnswerWasCorrect == true;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isCorrect
            ? const LinearGradient(
                colors: [Color(0xFFDDF7E8), Color(0xFFC9F0D8)],
              )
            : const LinearGradient(
                colors: [Color(0xFFFFE7E7), Color(0xFFFFD6D6)],
              ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isCorrect ? _strings.correctLabel : _strings.almostTryAgainLabel,
        style: TextStyle(
          color: isCorrect ? const Color(0xFF14613B) : const Color(0xFF8A2020),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildCompleteBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE9FFF1), Color(0xFFD1F5DE)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF79C798), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✨', style: TextStyle(fontSize: 26)),
          const SizedBox(height: 8),
          Text(
            _strings.puzzleCompleteLabel,
            style: const TextStyle(
              color: Color(0xFF14613B),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _strings.greatJobLabel,
            style: const TextStyle(
              color: Color(0xFF14613B),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const Key('puzzle-finish-board'),
              onPressed: _openResult,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                widget.board.layer == PeriodicPuzzleLayer.mixed
                    ? _strings.puzzleCompleteLabel
                    : _strings.boardClearedLabel,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _useHint() {
    final targetTile = _selectedTile ?? _firstOpenTile;
    if (targetTile == null) {
      return;
    }
    final next = _progressRepository.useHint(widget.board);
    if (next == null) {
      return;
    }
    setState(() {
      _boardProgress = next;
      _hintTileId = targetTile.id;
      _selectedTileId = targetTile.id;
    });
  }

  void _handleOptionTap(PeriodicPuzzleTile tile, String selectedOptionId) {
    final next = _progressRepository.submitAnswer(
      board: widget.board,
      tileSymbol: tile.id,
      selectedOptionId: selectedOptionId,
    );

    if (tile.id == selectedOptionId && next.isComplete) {
      _progressRepository.completeBoard(
        board: widget.board,
        siblingBoardIds: _siblingBoards.map((board) => board.id).toList(),
      );
    }

    setState(() {
      _boardProgress = next;
      _lastAnswerWasCorrect = tile.id == selectedOptionId;
      _incorrectOptionId = tile.id == selectedOptionId
          ? null
          : selectedOptionId;
      _completedTileId = tile.id == selectedOptionId ? tile.id : null;
      if (tile.id == selectedOptionId) {
        final nextTile = _firstOpenTile;
        _selectedTileId = nextTile?.id;
      } else {
        _selectedTileId = tile.id;
      }
    });
  }

  void _openResult() {
    if (tile.id == selectedOptionId && next.isComplete) {
      _audioService.stop();
    } else {
      _speakSelectedTileClue();
    }
  }

  void _openResult() {
    _audioService.stop();
    Navigator.pushReplacement(
      context,
      slideRoute(
        PeriodicPuzzleResultPage(
          board: widget.board,
          generator: widget.generator,
          progressRepository: _progressRepository,
          bestTimesRepository: _bestTimesRepository,
          initialLanguage: _language,
        ),
      ),
    );
  }

  Future<void> _speakSelectedTileClue({bool force = false}) async {
    if (_isComplete) {
      return;
    }
    final tile = _selectedTile ?? _firstOpenTile;
    final clueText = tile?.clue?.textFor(_language);
    if (tile == null || clueText == null || clueText.isEmpty) {
      return;
    }
    final key = '${tile.id}-${_language.name}';
    if (!force && _lastNarratedClueKey == key) {
      return;
    }
    _lastNarratedClueKey = key;
    await _audioService.speakText(
      text: clueText,
      languageCode: _languageCodeFor(_language),
    );
  }

  String _languageCodeFor(QuizLanguage language) {
    return language == QuizLanguage.spanish ? 'es-ES' : 'en-US';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF2C4E6E),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
