import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/router/app_navigation.dart';
import '../../../shared/widgets/pill_back_button.dart';
import '../data/story_quest_data.dart';
import '../data/story_progress_repository.dart';
import '../models/story_progress.dart';
import '../models/story_quest.dart';
import 'lab_experiment_screen.dart';
import 'quest_game_screen.dart';

// ─── Starfield background ─────────────────────────────────────────────────────

class _StarDot {
  final double x, y, r, phase;
  const _StarDot(this.x, this.y, this.r, this.phase);
}

class _StarfieldPainter extends CustomPainter {
  final double progress;
  final List<_StarDot> stars;

  _StarfieldPainter({required this.progress, required this.stars});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final twinkle = math.sin((progress + s.phase) * math.pi * 2);
      final alpha = (0.25 + 0.75 * (twinkle * 0.5 + 0.5)).clamp(0.1, 1.0);
      final radius = s.r * (0.6 + 0.4 * (twinkle * 0.5 + 0.5));
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        radius,
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) => old.progress != progress;
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class AdventureHomeScreen extends StatefulWidget {
  const AdventureHomeScreen({super.key});

  @override
  State<AdventureHomeScreen> createState() => _AdventureHomeScreenState();
}

class _AdventureHomeScreenState extends State<AdventureHomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _starCtrl;
  late final List<AnimationController> _cardCtrls;
  late final List<_StarDot> _stars;

  StoryProgress get _progress => StoryProgressRepository.instance.progress;

  @override
  void initState() {
    super.initState();

    // Deterministic starfield
    final rng = math.Random(31415);
    _stars = List.generate(
      90,
      (_) => _StarDot(
        rng.nextDouble(),
        rng.nextDouble(),
        rng.nextDouble() * 1.4 + 0.4,
        rng.nextDouble(),
      ),
    );

    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // +1 for the lab card at index 0
    _cardCtrls = List.generate(
      kStoryChapters.length + 1,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 550),
      ),
    );

    // Stagger card entrances
    for (int i = 0; i < _cardCtrls.length; i++) {
      Future.delayed(Duration(milliseconds: 80 + i * 160), () {
        if (mounted) _cardCtrls[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _starCtrl.dispose();
    for (final c in _cardCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _starCtrl,
        builder: (context, child) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF050B15), Color(0xFF0C1830)],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _StarfieldPainter(
                    progress: _starCtrl.value,
                    stars: _stars,
                  ),
                ),
              ),
              child!,
            ],
          ),
        ),
        child: SafeArea(child: LayoutBuilder(builder: _buildLayout)),
      ),
    );
  }

  Widget _buildLayout(BuildContext context, BoxConstraints bc) {
    final sw = bc.maxWidth;
    final w = math.min(sw, 720.0);
    final progress = _progress;
    final totalStars = progress.totalStars;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Header ──────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(sw * 0.04, 10, sw * 0.04, 0),
          child: Row(
            children: [
              PillBackButton(
                contentWidth: w,
                foreground: const Color(0xFF7C9AB8),
              ),
              const Spacer(),
              _StarPill(stars: totalStars),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Title ────────────────────────────────────────────────────
        Text(
          '⚔️  ADVENTURE MODE',
          style: TextStyle(
            fontSize: math.min(22.0, sw * 0.052),
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Explore chemistry through epic quests',
          style: TextStyle(
            fontSize: math.min(13.0, sw * 0.032),
            color: Colors.white.withValues(alpha: 0.5),
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 24),

        // ── Chapter cards ────────────────────────────────────────────
        Expanded(
          child: Center(
            child: SizedBox(
              width: w,
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(sw * 0.05, 0, sw * 0.05, 32),
                // +1 for the lab card, +1 for the "STORY QUESTS" section header
                itemCount: kStoryChapters.length + 2,
                separatorBuilder: (context, index) => const SizedBox(height: 18),
                itemBuilder: (context, i) {
                  // i == 0 → Lab card
                  if (i == 0) {
                    return AnimatedBuilder(
                      animation: _cardCtrls[0],
                      builder: (context, child) {
                        final curve = CurvedAnimation(
                          parent: _cardCtrls[0],
                          curve: Curves.easeOutCubic,
                        );
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.25),
                            end: Offset.zero,
                          ).animate(curve),
                          child: FadeTransition(opacity: curve, child: child),
                        );
                      },
                      child: _LabCard(
                        onTap: () => Navigator.push(
                          context,
                          slideRoute(const LabExperimentScreen()),
                        ),
                      ),
                    );
                  }

                  // i == 1 → Section header
                  if (i == 1) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Row(
                        children: [
                          Text(
                            'STORY QUESTS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withValues(alpha: 0.35),
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // i >= 2 → Chapter cards (offset by 2, ctrl offset by 1)
                  final ci = i - 2;
                  final ctrlIndex = ci + 1;
                  final chapter = kStoryChapters[ci];
                  final isUnlocked = totalStars >= chapter.unlockRequiredStars;
                  final chStars = progress.starsForChapter(
                    chapter.id,
                    chapter.quests.length,
                  );

                  return AnimatedBuilder(
                    animation: _cardCtrls[ctrlIndex],
                    builder: (context, child) {
                      final curve = CurvedAnimation(
                        parent: _cardCtrls[ctrlIndex],
                        curve: Curves.easeOutCubic,
                      );
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.25),
                          end: Offset.zero,
                        ).animate(curve),
                        child: FadeTransition(opacity: curve, child: child),
                      );
                    },
                    child: _ChapterCard(
                      chapter: chapter,
                      isUnlocked: isUnlocked,
                      starsEarned: chStars,
                      progress: progress,
                      onTap: isUnlocked ? () => _openChapter(chapter) : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openChapter(StoryChapter chapter) {
    final progress = _progress;
    // Find the first incomplete quest; fall back to quest 0
    int startIndex = 0;
    for (int i = 0; i < chapter.quests.length; i++) {
      if (!progress.isQuestCompleted(chapter.id, i)) {
        startIndex = i;
        break;
      }
      if (i == chapter.quests.length - 1) {
        startIndex = 0; // replay from start if all done
      }
    }

    Navigator.push(
      context,
      slideRoute(
        QuestGameScreen(chapter: chapter, initialQuestIndex: startIndex),
      ),
    ).then((_) => setState(() {}));
  }
}

// ─── Star pill (header) ───────────────────────────────────────────────────────

class _StarPill extends StatelessWidget {
  final int stars;
  const _StarPill({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Text(
            '$stars',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'stars',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Lab card ─────────────────────────────────────────────────────────────────

class _LabCard extends StatefulWidget {
  final VoidCallback onTap;
  const _LabCard({required this.onTap});

  @override
  State<_LabCard> createState() => _LabCardState();
}

class _LabCardState extends State<_LabCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF10B981);
    const bgDark = Color(0xFF021A0F);
    const bgLight = Color(0xFF053020);

    return GestureDetector(
      onTapDown: (details) => _pressCtrl.reverse(),
      onTapUp: (_) {
        _pressCtrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.forward(),
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (context, child) =>
            Transform.scale(scale: _pressCtrl.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [bgDark, bgLight],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: accent.withValues(alpha: 0.40),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative glow
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Flask icon badge
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: 0.12),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Text('⚗️', style: TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FREE PLAY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: accent,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Lab Experiment',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Mix any two elements and discover what they form',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.55),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: accent.withValues(alpha: 0.7),
                      size: 26,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Chapter card ─────────────────────────────────────────────────────────────

class _ChapterCard extends StatefulWidget {
  final StoryChapter chapter;
  final bool isUnlocked;
  final int starsEarned;
  final StoryProgress progress;
  final VoidCallback? onTap;

  const _ChapterCard({
    required this.chapter,
    required this.isUnlocked,
    required this.starsEarned,
    required this.progress,
    required this.onTap,
  });

  @override
  State<_ChapterCard> createState() => _ChapterCardState();
}

class _ChapterCardState extends State<_ChapterCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ch = widget.chapter;
    final unlocked = widget.isUnlocked;
    final completed = widget.progress.isChapterComplete(
      ch.id,
      ch.quests.length,
    );

    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (details) => _pressCtrl.reverse()
          : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _pressCtrl.forward();
              widget.onTap?.call();
            }
          : null,
      onTapCancel: () => _pressCtrl.forward(),
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (context, child) => Transform.scale(
          scale: _pressCtrl.value,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: unlocked
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [ch.bgDark, ch.bgLight],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF111827), Color(0xFF1C2533)],
                  ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: unlocked
                  ? ch.accentColor.withValues(alpha: completed ? 0.7 : 0.35)
                  : Colors.white.withValues(alpha: 0.08),
              width: completed ? 2.0 : 1.5,
            ),
            boxShadow: unlocked
                ? [
                    BoxShadow(
                      color: ch.accentColor.withValues(
                        alpha: completed ? 0.25 : 0.10,
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Decorative glow in bg corner
              if (unlocked)
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          ch.accentColor.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: unlocked
                    ? _UnlockedContent(
                        chapter: ch,
                        starsEarned: widget.starsEarned,
                        progress: widget.progress,
                        completed: completed,
                      )
                    : _LockedContent(chapter: ch),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Unlocked chapter content ─────────────────────────────────────────────────

class _UnlockedContent extends StatelessWidget {
  final StoryChapter chapter;
  final int starsEarned;
  final StoryProgress progress;
  final bool completed;

  const _UnlockedContent({
    required this.chapter,
    required this.starsEarned,
    required this.progress,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Emoji badge
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: chapter.accentColor.withValues(alpha: 0.15),
            border: Border.all(
              color: chapter.accentColor.withValues(alpha: 0.40),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              chapter.emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Info column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chapter number + completed badge
              Row(
                children: [
                  Text(
                    'Chapter ${chapter.id + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: chapter.accentColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                  if (completed) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: chapter.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'COMPLETE ✓',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: chapter.accentColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 3),

              Text(
                chapter.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                chapter.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.55),
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 10),

              // Quest completion dots
              Row(
                children: [
                  ...List.generate(chapter.quests.length, (i) {
                    final done = progress.isQuestCompleted(chapter.id, i);
                    final stars = progress.starsForQuest(chapter.id, i);
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done
                              ? chapter.accentColor
                              : Colors.white.withValues(alpha: 0.15),
                          boxShadow: done && stars == 3
                              ? [
                                  BoxShadow(
                                    color: chapter.accentColor
                                        .withValues(alpha: 0.6),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 10),
                  Text(
                    '$starsEarned / ${chapter.quests.length * 3} ⭐',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Chevron
        Icon(
          Icons.chevron_right_rounded,
          color: chapter.accentColor.withValues(alpha: 0.7),
          size: 26,
        ),
      ],
    );
  }
}

// ─── Locked chapter content ───────────────────────────────────────────────────

class _LockedContent extends StatelessWidget {
  final StoryChapter chapter;

  const _LockedContent({required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Greyed emoji
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Center(
            child: Text(
              chapter.emoji,
              style: TextStyle(
                fontSize: 28,
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chapter ${chapter.id + 1}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.3),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                chapter.title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: 13,
                    color: Colors.white.withValues(alpha: 0.30),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Unlock with ${chapter.unlockRequiredStars} ⭐',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.35),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
