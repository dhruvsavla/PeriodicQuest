import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/audio/element_audio_service.dart';
import '../../../core/responsive/app_radius.dart';
import '../../../core/responsive/app_spacing.dart';
import '../../../domain/elements/chemical_element.dart';
import '../../../domain/elements/periodic_table_data.dart';
import '../data/story_progress_repository.dart';
import '../models/story_quest.dart';

// ─── Particle / Confetti data ─────────────────────────────────────────────────

class _Particle {
  final double x, y, r, phase, speed, maxAlpha;
  const _Particle(this.x, this.y, this.r, this.phase, this.speed, this.maxAlpha);
}

class _ConfettiPiece {
  final double x, startY, w, h, phase, rotSpeed;
  final Color color;
  const _ConfettiPiece(
      this.x, this.startY, this.w, this.h, this.phase, this.rotSpeed, this.color);
}

// ─── Particle painter ─────────────────────────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final List<_Particle> particles;

  _ParticlePainter({required this.progress, required this.color, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      final y = ((p.y - progress * p.speed) % 1.0 + 1.0) % 1.0;
      final xPx = p.x * size.width + math.sin((progress + p.phase) * math.pi * 2) * 10;
      final alpha = ((math.sin((progress + p.phase) * math.pi * 2) * 0.5 + 0.5) * p.maxAlpha)
          .clamp(0.0, 1.0);
      paint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(xPx, y * size.height), p.r, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

// ─── Confetti painter ─────────────────────────────────────────────────────────

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiPiece> pieces;

  _ConfettiPainter({required this.progress, required this.pieces});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in pieces) {
      final x = p.x * size.width + math.sin((progress * 3 + p.phase) * math.pi) * 28;
      final y = (p.startY + progress * 0.9) * size.height;
      if (y > size.height + 20) continue;
      paint.color = p.color.withValues(alpha: (1.0 - progress * 0.55).clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * math.pi * 4 * p.rotSpeed);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.w, height: p.h),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class QuestGameScreen extends StatefulWidget {
  final StoryChapter chapter;
  final int initialQuestIndex;

  const QuestGameScreen({
    super.key,
    required this.chapter,
    required this.initialQuestIndex,
  });

  @override
  State<QuestGameScreen> createState() => _QuestGameScreenState();
}

class _QuestGameScreenState extends State<QuestGameScreen>
    with TickerProviderStateMixin {
  late int _questIndex;
  StoryQuest get _quest => widget.chapter.quests[_questIndex];

  // Language
  bool _showSpanish = false;
  final _audio = ElementAudioService.instance;

  // Typewriter
  int _revealedChars = 0;
  bool _textDone = false;
  Timer? _typeTimer;

  // Answer state
  int _attempts = 0;
  bool? _answered;

  // Identify
  final Set<int> _wrongTaps = {};
  int? _correctTapZ;

  // Combine
  int? _slotA, _slotB;
  bool _combineWrong = false;

  // MultiChoice
  int? _selectedOptionIdx;
  bool _mcWrong = false;

  // Overlays
  bool _showResult = false;
  bool _chapterDone = false;
  int _awardedStars = 0;

  // Animation controllers
  late final AnimationController _shakeCtrl;
  late final AnimationController _resultCtrl;
  late final AnimationController _starsCtrl;
  late final AnimationController _bgCtrl;
  late final AnimationController _sceneCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _confettiCtrl;

  late final List<_Particle> _particles;
  late final List<_ConfettiPiece> _confetti;
  late List<ChemicalElement> _shuffledTiles;

  static const _confettiColors = [
    Color(0xFFFF6B6B), Color(0xFFFFD93D), Color(0xFF6BCB77),
    Color(0xFF4D96FF), Color(0xFFFF922B), Color(0xFFCC5DE8),
  ];

  @override
  void initState() {
    super.initState();
    _questIndex = widget.initialQuestIndex;

    _shakeCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _resultCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _starsCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _bgCtrl     = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _sceneCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _confettiCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

    final pRng = math.Random(12345);
    _particles = List.generate(22, (_) => _Particle(
      pRng.nextDouble(), pRng.nextDouble(),
      pRng.nextDouble() * 2.2 + 0.8, pRng.nextDouble(),
      pRng.nextDouble() * 0.12 + 0.04, pRng.nextDouble() * 0.09 + 0.02,
    ));

    final cRng = math.Random(99887);
    _confetti = List.generate(48, (_) => _ConfettiPiece(
      cRng.nextDouble(), cRng.nextDouble() * 0.4 - 0.45,
      cRng.nextDouble() * 8 + 4, cRng.nextDouble() * 5 + 3,
      cRng.nextDouble(), cRng.nextDouble() * 2 + 0.5,
      _confettiColors[cRng.nextInt(_confettiColors.length)],
    ));

    _initQuest();
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _audio.stop();
    _shakeCtrl.dispose();
    _resultCtrl.dispose();
    _starsCtrl.dispose();
    _bgCtrl.dispose();
    _sceneCtrl.dispose();
    _particleCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  void _initQuest() {
    _typeTimer?.cancel();
    _revealedChars = 0;
    _textDone = false;
    _attempts = 0;
    _answered = null;
    _wrongTaps.clear();
    _correctTapZ = null;
    _slotA = null;
    _slotB = null;
    _combineWrong = false;
    _selectedOptionIdx = null;
    _mcWrong = false;
    _showResult = false;
    _chapterDone = false;
    _awardedStars = 0;
    _shakeCtrl.reset();
    _resultCtrl.reset();
    _starsCtrl.reset();
    _confettiCtrl.reset();

    _buildShuffledTiles();
    _startTypewriter();
    _speakStory();
  }

  void _speakStory() {
    final q = _quest;
    final langCode = _showSpanish ? 'es-ES' : 'en-US';
    final text = _showSpanish ? (q.storyEs ?? q.story) : q.story;
    _audio.speakText(text: text, languageCode: langCode);
  }

  void _buildShuffledTiles() {
    final quest = _quest;
    List<int> zList;
    if (quest.type == QuestType.identify) {
      zList = [quest.targetZ!, ...?quest.distractorZs];
    } else if (quest.type == QuestType.combine) {
      zList = quest.combineZs ?? [quest.combineZA!, quest.combineZB!];
    } else {
      zList = [];
    }
    final allElements = {for (final e in kPeriodicElements) e.z: e};
    final elems = zList.map((z) => allElements[z]).whereType<ChemicalElement>().toList();
    elems.shuffle(math.Random(widget.chapter.id * 100 + _questIndex));
    _shuffledTiles = elems;
  }

  void _startTypewriter() {
    final text = _showSpanish ? (_quest.storyEs ?? _quest.story) : _quest.story;
    _typeTimer = Timer.periodic(const Duration(milliseconds: 16), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_revealedChars >= text.length) {
        t.cancel();
        if (mounted) setState(() => _textDone = true);
      } else {
        setState(() => _revealedChars++);
      }
    });
  }

  void _skipTypewriter() {
    _typeTimer?.cancel();
    final text = _showSpanish ? (_quest.storyEs ?? _quest.story) : _quest.story;
    setState(() { _revealedChars = text.length; _textDone = true; });
  }

  void _toggleLanguage() {
    setState(() {
      _showSpanish = !_showSpanish;
      // Restart typewriter in new language
      _typeTimer?.cancel();
      _revealedChars = 0;
      _textDone = false;
    });
    _startTypewriter();
    _speakStory();
  }

  // ── Answer handlers ──────────────────────────────────────────────────────────

  void _handleIdentifyTap(int z) {
    if (_answered != null) return;
    if (_wrongTaps.contains(z)) return;
    if (z == _quest.targetZ) {
      setState(() { _correctTapZ = z; _answered = true; });
      _onCorrect();
    } else {
      setState(() { _wrongTaps.add(z); _attempts++; });
      _shakeCtrl.forward(from: 0);
    }
  }

  void _handleCombineTap(int z) {
    if (_answered != null) return;
    if (_combineWrong) return;
    if (_slotA == null) {
      setState(() => _slotA = z);
    } else if (_slotB == null && z != _slotA) {
      setState(() => _slotB = z);
      _checkCombine();
    }
  }

  void _checkCombine() {
    final za = _quest.combineZA!;
    final zb = _quest.combineZB!;
    final correct = (_slotA == za && _slotB == zb) || (_slotA == zb && _slotB == za);
    if (correct) {
      setState(() => _answered = true);
      _onCorrect();
    } else {
      setState(() { _combineWrong = true; _attempts++; });
      _shakeCtrl.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          setState(() { _slotA = null; _slotB = null; _combineWrong = false; });
        }
      });
    }
  }

  void _handleMultiChoice(int index) {
    if (_answered != null) return;
    if (_mcWrong) return;
    setState(() => _selectedOptionIdx = index);
    if (_quest.options![index].isCorrect) {
      setState(() => _answered = true);
      _onCorrect();
    } else {
      setState(() { _mcWrong = true; _attempts++; });
      _shakeCtrl.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() { _selectedOptionIdx = null; _mcWrong = false; });
        }
      });
    }
  }

  void _onCorrect() {
    final stars = _attempts == 0 ? 3 : (_attempts == 1 ? 2 : 1);
    _awardedStars = stars;
    StoryProgressRepository.instance.record(widget.chapter.id, _questIndex, stars);
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() => _showResult = true);
      _resultCtrl.forward(from: 0);
      _starsCtrl.forward(from: 0);
      _confettiCtrl.forward(from: 0);
    });
  }

  void _nextQuestOrFinish() {
    final nextIndex = _questIndex + 1;
    if (nextIndex < widget.chapter.quests.length) {
      setState(() { _questIndex = nextIndex; _initQuest(); });
    } else {
      setState(() => _chapterDone = true);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final ch = widget.chapter;
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_bgCtrl, _particleCtrl]),
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [ch.bgDark, ch.bgLight],
              transform: GradientRotation(_bgCtrl.value * 0.5),
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _ParticlePainter(
                    progress: _particleCtrl.value,
                    color: ch.accentColor,
                    particles: _particles,
                  ),
                ),
              ),
              child!,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              LayoutBuilder(builder: _buildLayout),
              if (_showResult && !_chapterDone)
                _QuestResultOverlay(
                  quest: _quest,
                  stars: _awardedStars,
                  accentColor: ch.accentColor,
                  resultCtrl: _resultCtrl,
                  starsCtrl: _starsCtrl,
                  confettiCtrl: _confettiCtrl,
                  confetti: _confetti,
                  isLastQuest: _questIndex == widget.chapter.quests.length - 1,
                  onNext: _nextQuestOrFinish,
                ),
              if (_chapterDone)
                _ChapterCompleteOverlay(
                  chapter: ch,
                  resultCtrl: _resultCtrl,
                  starsCtrl: _starsCtrl,
                  confetti: _confetti,
                  totalStars: StoryProgressRepository.instance.progress
                      .starsForChapter(ch.id, ch.quests.length),
                  onHome: () => Navigator.pop(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLayout(BuildContext context, BoxConstraints bc) {
    final w = bc.maxWidth;
    final h = bc.maxHeight;
    final ch = widget.chapter;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.md, 10.h, AppSpacing.md, 0),
          child: _QuestHeader(
            chapter: ch,
            questIndex: _questIndex,
            totalQuests: ch.quests.length,
            showSpanish: _showSpanish,
            onToggleLanguage: _toggleLanguage,
          ),
        ),

        SizedBox(height: h * 0.014),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: GestureDetector(
            onTap: _textDone ? null : _skipTypewriter,
            child: AnimatedBuilder(
              animation: _sceneCtrl,
              builder: (context, child) => _SceneCard(
                quest: _quest,
                revealedChars: _revealedChars,
                textDone: _textDone,
                accentColor: ch.accentColor,
                sceneFloat: _sceneCtrl.value,
                showSpanish: _showSpanish,
              ),
            ),
          ),
        ),

        SizedBox(height: h * 0.016),

        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, h * 0.018),
            child: _buildChallengePanel(w, h),
          ),
        ),
      ],
    );
  }

  Widget _buildChallengePanel(double w, double h) {
    return AnimatedBuilder(
      animation: _shakeCtrl,
      builder: (context, child) {
        final shakeX =
            math.sin(_shakeCtrl.value * math.pi * 5) * 10.0 * (1 - _shakeCtrl.value);
        return Transform.translate(offset: Offset(shakeX, 0), child: child);
      },
      child: switch (_quest.type) {
        QuestType.identify   => _buildIdentifyPanel(w),
        QuestType.combine    => _buildCombinePanel(w),
        QuestType.multiChoice => _buildMultiChoicePanel(w, h),
      },
    );
  }

  // ── Identify ─────────────────────────────────────────────────────────────────

  Widget _buildIdentifyPanel(double w) {
    final tileSize = math.min(88.w, (w - 60.w) / 3 - 10.w).clamp(60.0, 90.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ChallengeLabel(
          text: _showSpanish
              ? (_quest.challengeEs ?? _quest.challenge)
              : _quest.challenge,
          accentColor: widget.chapter.accentColor,
          icon: '🔍',
        ),
        SizedBox(height: 14.h),
        Expanded(
          child: Center(
            child: Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              alignment: WrapAlignment.center,
              children: _shuffledTiles.map((elem) {
                final isWrong   = _wrongTaps.contains(elem.z);
                final isCorrect = _correctTapZ == elem.z;
                return _ElementTile(
                  elem: elem,
                  size: tileSize,
                  state: isCorrect
                      ? _TileState.correct
                      : isWrong ? _TileState.wrong : _TileState.idle,
                  onTap: () => _handleIdentifyTap(elem.z),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ── Combine ──────────────────────────────────────────────────────────────────

  Widget _buildCombinePanel(double w) {
    final allElements = {for (final e in kPeriodicElements) e.z: e};
    final elemA = _slotA != null ? allElements[_slotA] : null;
    final elemB = _slotB != null ? allElements[_slotB] : null;
    final tileSize = math.min(64.w, (w - 60.w) / 4 - 10.w).clamp(44.0, 66.0);
    final bothFilled = elemA != null && elemB != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ChallengeLabel(
          text: _showSpanish
              ? (_quest.challengeEs ?? _quest.challenge)
              : _quest.challenge,
          accentColor: widget.chapter.accentColor,
          icon: '⚗️',
        ),
        SizedBox(height: 14.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CombineSlot(elem: elemA, label: 'A',
                accentColor: widget.chapter.accentColor, isWrong: _combineWrong),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bothFilled && !_combineWrong
                      ? widget.chapter.accentColor.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.06),
                  border: Border.all(
                    color: bothFilled && !_combineWrong
                        ? widget.chapter.accentColor.withValues(alpha: 0.60)
                        : Colors.white.withValues(alpha: 0.14),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      color: bothFilled && !_combineWrong
                          ? widget.chapter.accentColor
                          : Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),
            ),
            _CombineSlot(elem: elemB, label: 'B',
                accentColor: widget.chapter.accentColor, isWrong: _combineWrong),
          ],
        ),
        SizedBox(height: 14.h),
        Expanded(
          child: Center(
            child: Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              alignment: WrapAlignment.center,
              children: _shuffledTiles.map((elem) {
                final inSlot = elem.z == _slotA || elem.z == _slotB;
                return _ElementTile(
                  elem: elem, size: tileSize,
                  state: inSlot ? _TileState.selected : _TileState.idle,
                  onTap: () => _handleCombineTap(elem.z),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ── MultiChoice ──────────────────────────────────────────────────────────────

  Widget _buildMultiChoicePanel(double w, double h) {
    final allElements = {for (final e in kPeriodicElements) e.z: e};
    final cardSize = math.min((w - 44.w) / 2, (h * 0.55) / 2).clamp(90.0, 160.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ChallengeLabel(
          text: _showSpanish
              ? (_quest.challengeEs ?? _quest.challenge)
              : _quest.challenge,
          accentColor: widget.chapter.accentColor,
          icon: '💡',
        ),
        SizedBox(height: 14.h),
        Expanded(
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 1.0,
            children: List.generate(_quest.options!.length, (i) {
              final opt      = _quest.options![i];
              final elem     = allElements[opt.elementZ];
              final selected = _selectedOptionIdx == i;
              final isWrong  = selected && _mcWrong;
              return _McElementCard(
                elem: elem,
                label: opt.label,
                cardSize: cardSize,
                state: isWrong ? _McState.wrong : selected ? _McState.selected : _McState.idle,
                accentColor: widget.chapter.accentColor,
                onTap: () => _handleMultiChoice(i),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ─── Scene card ───────────────────────────────────────────────────────────────

class _SceneCard extends StatelessWidget {
  final StoryQuest quest;
  final int revealedChars;
  final bool textDone;
  final Color accentColor;
  final double sceneFloat;
  final bool showSpanish;

  const _SceneCard({
    required this.quest,
    required this.revealedChars,
    required this.textDone,
    required this.accentColor,
    required this.sceneFloat,
    required this.showSpanish,
  });

  @override
  Widget build(BuildContext context) {
    final floatY   = math.sin(sceneFloat * math.pi * 2) * 5.0;
    final fullText = showSpanish ? (quest.storyEs ?? quest.story) : quest.story;
    final title    = showSpanish ? (quest.titleEs ?? quest.title) : quest.title;
    final displayText = fullText.substring(0, revealedChars.clamp(0, fullText.length));

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: accentColor.withValues(alpha: 0.30), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.translate(
            offset: Offset(0, floatY),
            child: Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.13),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.35),
                    blurRadius: 22.r,
                    spreadRadius: 2.r,
                  ),
                ],
              ),
              child: Center(
                child: Text(quest.sceneEmoji, style: TextStyle(fontSize: 28.sp)),
              ),
            ),
          ),

          SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w900,
                          color: accentColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    if (!textDone)
                      Text(
                        showSpanish ? 'omitir ▶' : 'skip ▶',
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: Colors.white.withValues(alpha: 0.30),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 5.h),
                Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white.withValues(alpha: 0.80),
                    height: 1.50,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!textDone)
                  Text('▌', style: TextStyle(fontSize: 11.sp, color: accentColor.withValues(alpha: 0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quest header ─────────────────────────────────────────────────────────────

class _QuestHeader extends StatelessWidget {
  final StoryChapter chapter;
  final int questIndex;
  final int totalQuests;
  final bool showSpanish;
  final VoidCallback onToggleLanguage;

  const _QuestHeader({
    required this.chapter,
    required this.questIndex,
    required this.totalQuests,
    required this.showSpanish,
    required this.onToggleLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Back
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              size: 14.sp,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ),

        SizedBox(width: AppSpacing.sm),

        // Chapter + progress bar
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(chapter.emoji, style: TextStyle(fontSize: 12.sp)),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(
                      chapter.title,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: chapter.accentColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: (questIndex + 1) / totalQuests,
                  backgroundColor: Colors.white.withValues(alpha: 0.10),
                  valueColor: AlwaysStoppedAnimation(chapter.accentColor),
                  minHeight: 5.h,
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: AppSpacing.xs),

        // EN / ES language toggle
        GestureDetector(
          onTap: onToggleLanguage,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: chapter.accentColor.withValues(alpha: 0.45)),
            ),
            child: Text(
              showSpanish ? 'ES' : 'EN',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w900,
                color: chapter.accentColor,
              ),
            ),
          ),
        ),

        SizedBox(width: AppSpacing.xs),

        // Quest counter
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Text(
            '${questIndex + 1}/$totalQuests',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Challenge label ──────────────────────────────────────────────────────────

class _ChallengeLabel extends StatelessWidget {
  final String text;
  final Color accentColor;
  final String icon;

  const _ChallengeLabel({required this.text, required this.accentColor, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10.h),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: accentColor.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: 15.sp)),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white.withValues(alpha: 0.92),
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Element tile ─────────────────────────────────────────────────────────────

enum _TileState { idle, wrong, correct, selected }

class _ElementTile extends StatefulWidget {
  final ChemicalElement elem;
  final double size;
  final _TileState state;
  final VoidCallback onTap;

  const _ElementTile({required this.elem, required this.size, required this.state, required this.onTap});

  @override
  State<_ElementTile> createState() => _ElementTileState();
}

class _ElementTileState extends State<_ElementTile> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 100),
      lowerBound: 0.88, upperBound: 1.0, value: 1.0,
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final elem  = widget.elem;
    final color = periodicCategoryColor(elem.cat);
    final sz    = widget.size;
    final state = widget.state;

    Color bg, border; Color textColor; List<BoxShadow>? shadows;
    switch (state) {
      case _TileState.idle:
        bg = color; border = color.withValues(alpha: 0.6); textColor = Colors.white;
        shadows = [BoxShadow(color: color.withValues(alpha: 0.40), blurRadius: 8.r, offset: Offset(0, 3.h))];
      case _TileState.wrong:
        bg = const Color(0xFF7F1D1D); border = const Color(0xFFEF4444); textColor = Colors.white;
        shadows = [BoxShadow(color: const Color(0x66EF4444), blurRadius: 12.r)];
      case _TileState.correct:
        bg = const Color(0xFF14532D); border = const Color(0xFF22C55E); textColor = Colors.white;
        shadows = [BoxShadow(color: const Color(0x8822C55E), blurRadius: 18.r, spreadRadius: 2.r)];
      case _TileState.selected:
        bg = color.withValues(alpha: 0.55); border = Colors.white.withValues(alpha: 0.7); textColor = Colors.white;
        shadows = [BoxShadow(color: Colors.white.withValues(alpha: 0.25), blurRadius: 8.r)];
    }

    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) { _ctrl.forward(); widget.onTap(); },
      onTapCancel: () => _ctrl.forward(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) => Transform.scale(scale: _ctrl.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: sz, height: sz * 1.18,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: border, width: 2),
            boxShadow: shadows,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${elem.z}', style: TextStyle(fontSize: sz * 0.13, color: textColor.withValues(alpha: 0.70), fontWeight: FontWeight.w700, height: 1.0)),
              Text(elem.sym,    style: TextStyle(fontSize: sz * 0.38, fontWeight: FontWeight.w900, color: textColor, height: 1.0)),
              Text(elem.name,   style: TextStyle(fontSize: sz * 0.11, color: textColor.withValues(alpha: 0.80), fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Combine slot ─────────────────────────────────────────────────────────────

class _CombineSlot extends StatelessWidget {
  final ChemicalElement? elem;
  final String label;
  final Color accentColor;
  final bool isWrong;

  const _CombineSlot({required this.elem, required this.label, required this.accentColor, required this.isWrong});

  @override
  Widget build(BuildContext context) {
    final filled    = elem != null;
    final elemColor = filled ? periodicCategoryColor(elem!.cat) : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 88.w, height: 104.h,
      decoration: BoxDecoration(
        color: isWrong
            ? const Color(0xFF7F1D1D).withValues(alpha: 0.7)
            : filled ? elemColor.withValues(alpha: 0.80) : Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isWrong ? const Color(0xFFEF4444) : filled ? accentColor.withValues(alpha: 0.65) : Colors.white.withValues(alpha: 0.18),
          width: 2,
        ),
        boxShadow: filled && !isWrong
            ? [BoxShadow(color: accentColor.withValues(alpha: 0.30), blurRadius: 16.r, spreadRadius: 1.r)]
            : null,
      ),
      child: filled
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${elem!.z}', style: TextStyle(fontSize: 11.sp, color: Colors.white.withValues(alpha: 0.70), fontWeight: FontWeight.w700, height: 1.0)),
                Text(elem!.sym,   style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: Colors.white, height: 1.0)),
                Text(elem!.name,  style: TextStyle(fontSize: 10.sp, color: Colors.white.withValues(alpha: 0.75), fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('?', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: Colors.white.withValues(alpha: 0.15))),
                SizedBox(height: 4.h),
                Text('Slot $label', style: TextStyle(fontSize: 10.sp, color: Colors.white.withValues(alpha: 0.25), fontWeight: FontWeight.w600)),
              ],
            ),
    );
  }
}

// ─── MultiChoice element card ─────────────────────────────────────────────────

enum _McState { idle, selected, wrong }

class _McElementCard extends StatefulWidget {
  final ChemicalElement? elem;
  final String label;
  final double cardSize;
  final _McState state;
  final Color accentColor;
  final VoidCallback onTap;

  const _McElementCard({
    required this.elem, required this.label, required this.cardSize,
    required this.state, required this.accentColor, required this.onTap,
  });

  @override
  State<_McElementCard> createState() => _McElementCardState();
}

class _McElementCardState extends State<_McElementCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 90), lowerBound: 0.93, upperBound: 1.0, value: 1.0);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final elem      = widget.elem;
    final state     = widget.state;
    final elemColor = elem != null ? periodicCategoryColor(elem.cat) : const Color(0xFF374151);
    final sz        = widget.cardSize;

    Color bg, border; List<BoxShadow>? shadows;
    switch (state) {
      case _McState.idle:
        bg = elemColor.withValues(alpha: 0.85); border = elemColor;
        shadows = [BoxShadow(color: elemColor.withValues(alpha: 0.35), blurRadius: 10.r, offset: Offset(0, 4.h))];
      case _McState.selected:
        bg = const Color(0xFF14532D); border = const Color(0xFF22C55E);
        shadows = [BoxShadow(color: const Color(0x8822C55E), blurRadius: 20.r, spreadRadius: 2.r)];
      case _McState.wrong:
        bg = const Color(0xFF7F1D1D); border = const Color(0xFFEF4444);
        shadows = [BoxShadow(color: const Color(0x66EF4444), blurRadius: 14.r)];
    }

    return GestureDetector(
      onTapDown: state == _McState.idle ? (_) => _ctrl.reverse() : null,
      onTapUp:   state == _McState.idle ? (_) { _ctrl.forward(); widget.onTap(); } : null,
      onTapCancel: () => _ctrl.forward(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) => Transform.scale(scale: _ctrl.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: border, width: 2),
            boxShadow: shadows,
          ),
          child: elem != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${elem.z}', style: TextStyle(fontSize: sz * 0.10, color: Colors.white.withValues(alpha: 0.65), fontWeight: FontWeight.w700, height: 1.0)),
                    Text(elem.sym,   style: TextStyle(fontSize: sz * 0.38, fontWeight: FontWeight.w900, color: Colors.white, height: 1.0)),
                    Text(elem.name,  style: TextStyle(fontSize: sz * 0.11, color: Colors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                )
              : Center(child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Text(widget.label, textAlign: TextAlign.center, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                )),
        ),
      ),
    );
  }
}

// ─── Quest result overlay ─────────────────────────────────────────────────────

class _QuestResultOverlay extends StatelessWidget {
  final StoryQuest quest;
  final int stars;
  final Color accentColor;
  final AnimationController resultCtrl;
  final AnimationController starsCtrl;
  final AnimationController confettiCtrl;
  final List<_ConfettiPiece> confetti;
  final bool isLastQuest;
  final VoidCallback onNext;

  const _QuestResultOverlay({
    required this.quest, required this.stars, required this.accentColor,
    required this.resultCtrl, required this.starsCtrl, required this.confettiCtrl,
    required this.confetti, required this.isLastQuest, required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: resultCtrl, curve: Curves.easeIn),
      child: Stack(
        children: [
          Container(color: Colors.black.withValues(alpha: 0.70)),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: confettiCtrl,
              builder: (context, _) => CustomPaint(
                painter: _ConfettiPainter(progress: confettiCtrl.value, pieces: confetti),
              ),
            ),
          ),
          Center(
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                CurvedAnimation(parent: resultCtrl, curve: Curves.easeOutBack),
              ),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 32.w),
                padding: EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: accentColor.withValues(alpha: 0.55), width: 2),
                  boxShadow: [BoxShadow(color: accentColor.withValues(alpha: 0.28), blurRadius: 40.r, spreadRadius: 4.r)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 76.w, height: 76.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor.withValues(alpha: 0.12),
                            boxShadow: [BoxShadow(color: accentColor.withValues(alpha: 0.30), blurRadius: 24.r, spreadRadius: 2.r)],
                          ),
                          child: Center(child: Text(quest.sceneEmoji, style: TextStyle(fontSize: 34.sp))),
                        ),
                        Positioned(
                          bottom: -4, right: -4,
                          child: Container(
                            width: 28.w, height: 28.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF14532D),
                              border: Border.all(color: const Color(0xFF22C55E), width: 2),
                            ),
                            child: Icon(Icons.check_rounded, color: const Color(0xFF22C55E), size: 14.sp),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Text('CORRECT! 🎉', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2)),
                    SizedBox(height: 16.h),
                    _StarRow(stars: stars, accentColor: accentColor, ctrl: starsCtrl),
                    SizedBox(height: 18.h),
                    Text('"${quest.title}"', style: TextStyle(fontSize: 13.sp, color: accentColor, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
                    SizedBox(height: 22.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onNext,
                        icon: Icon(isLastQuest ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded, size: 16.sp),
                        label: Text(isLastQuest ? 'Chapter Complete!' : 'Next Quest',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor, foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 13.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                          elevation: 4, shadowColor: accentColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Star row ─────────────────────────────────────────────────────────────────

class _StarRow extends StatelessWidget {
  final int stars;
  final Color accentColor;
  final AnimationController ctrl;

  const _StarRow({required this.stars, required this.accentColor, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, child) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final filled = i < stars;
          final delay  = i * 0.28;
          final localP = ((ctrl.value - delay) / (1.0 - delay)).clamp(0.0, 1.0);
          final scale  = CurvedAnimation(
            parent: AlwaysStoppedAnimation(localP),
            curve: Curves.easeOutBack,
          ).value;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Transform.scale(
              scale: scale,
              child: Text(
                filled ? '⭐' : '☆',
                style: TextStyle(fontSize: 40.sp, color: filled ? null : Colors.white.withValues(alpha: 0.20)),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Chapter complete overlay ─────────────────────────────────────────────────

class _ChapterCompleteOverlay extends StatefulWidget {
  final StoryChapter chapter;
  final AnimationController resultCtrl;
  final AnimationController starsCtrl;
  final List<_ConfettiPiece> confetti;
  final int totalStars;
  final VoidCallback onHome;

  const _ChapterCompleteOverlay({
    required this.chapter, required this.resultCtrl, required this.starsCtrl,
    required this.confetti, required this.totalStars, required this.onHome,
  });

  @override
  State<_ChapterCompleteOverlay> createState() => _ChapterCompleteOverlayState();
}

// FIX: was SingleTickerProviderStateMixin — needs two controllers so use TickerProviderStateMixin
class _ChapterCompleteOverlayState extends State<_ChapterCompleteOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final AnimationController _confettiCtrl;

  @override
  void initState() {
    super.initState();
    _enterCtrl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
    _confettiCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ch       = widget.chapter;
    final maxStars = ch.quests.length * 3;

    return FadeTransition(
      opacity: CurvedAnimation(parent: _enterCtrl, curve: Curves.easeIn),
      child: Stack(
        children: [
          Container(color: Colors.black.withValues(alpha: 0.85)),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _confettiCtrl,
              builder: (context, _) => CustomPaint(
                painter: _ConfettiPainter(progress: _confettiCtrl.value, pieces: widget.confetti),
              ),
            ),
          ),
          Center(
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.6, end: 1.0).animate(
                CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutBack),
              ),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 28.w),
                padding: EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0F1E),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: ch.accentColor.withValues(alpha: 0.6), width: 2),
                  boxShadow: [BoxShadow(color: ch.accentColor.withValues(alpha: 0.30), blurRadius: 50.r, spreadRadius: 6.r)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 90.w, height: 90.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(colors: [ch.accentColor.withValues(alpha: 0.40), Colors.transparent]),
                          ),
                        ),
                        Text(ch.emoji, style: TextStyle(fontSize: 44.sp)),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text('CHAPTER COMPLETE! 🏆', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: ch.accentColor, letterSpacing: 1.2), textAlign: TextAlign.center),
                    SizedBox(height: 4.h),
                    Text(ch.title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                    SizedBox(height: 18.h),
                    _StarRow(stars: math.min(widget.totalStars, 3), accentColor: ch.accentColor, ctrl: widget.starsCtrl),
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: ch.accentColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: ch.accentColor.withValues(alpha: 0.30)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('⭐', style: TextStyle(fontSize: 20.sp)),
                          SizedBox(width: AppSpacing.sm),
                          Text('${widget.totalStars} / $maxStars', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: Colors.white)),
                          SizedBox(width: AppSpacing.sm),
                          Text('stars', style: TextStyle(fontSize: 12.sp, color: Colors.white.withValues(alpha: 0.5))),
                        ],
                      ),
                    ),
                    SizedBox(height: 22.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: widget.onHome,
                        icon: Icon(Icons.map_rounded, size: 16.sp),
                        label: Text('Back to Adventure Map', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ch.accentColor, foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 13.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                          elevation: 4, shadowColor: ch.accentColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
