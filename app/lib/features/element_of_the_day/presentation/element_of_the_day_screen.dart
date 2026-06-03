import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/audio/element_audio_service.dart';
import '../../../core/responsive/app_radius.dart';
import '../../../core/responsive/app_sizes.dart';
import '../../../core/responsive/app_spacing.dart';
import '../../../core/responsive/responsive.dart';
import '../../../shared/decorations/app_gradients.dart';
import '../../../shared/widgets/pill_back_button.dart';
import '../models/element_of_the_day_model.dart';

class ElementOfTheDayScreen extends StatefulWidget {
  const ElementOfTheDayScreen({
    super.key,
    required this.featuredElement,
    this.onAudioTap,
    this.title = 'Element of the Day',
    this.subtitle = 'A new element to learn every day!',
    this.reminderMessage = 'Come back tomorrow for a new Element of the Day!',
  });

  final ElementOfTheDayModel featuredElement;
  final VoidCallback? onAudioTap;

  final String title;
  final String subtitle;
  final String reminderMessage;

  @override
  State<ElementOfTheDayScreen> createState() => _ElementOfTheDayScreenState();
}

class _ElementOfTheDayScreenState extends State<ElementOfTheDayScreen> {
  final ElementAudioService _audio = ElementAudioService.instance;
  bool _showSpanish = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _speakCurrentContent();
    });
  }

  @override
  void dispose() {
    _audio.stop();
    super.dispose();
  }

  String get _displayName => _showSpanish
      ? (widget.featuredElement.nameEs ?? widget.featuredElement.name)
      : widget.featuredElement.name;

  String get _displayCategory => _showSpanish
      ? (widget.featuredElement.categoryEs ?? widget.featuredElement.category)
      : widget.featuredElement.category;

  String get _displayDescription => _showSpanish
      ? (widget.featuredElement.descriptionEs ??
            widget.featuredElement.description)
      : widget.featuredElement.description;

  String get _displayFunFact => _showSpanish
      ? (widget.featuredElement.funFactEs ?? widget.featuredElement.funFact)
      : widget.featuredElement.funFact;

  Future<void> _speakCurrentContent() async {
    if (widget.onAudioTap != null) {
      widget.onAudioTap!.call();
      return;
    }

    final languageCode = _showSpanish ? 'es-ES' : 'en-US';
    final text = _showSpanish
        ? 'Elemento del día: $_displayName. $_displayDescription. Dato curioso: $_displayFunFact.'
        : 'Element of the day: $_displayName. $_displayDescription. Fun fact: $_displayFunFact.';

    await _audio.speakText(text: text, languageCode: languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final contentWidth = Responsive.contentMaxWidth(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.explorePurple),
        child: SafeArea(
          child: Stack(
            children: [
              const _FloatingBlobs(),
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.horizontalPadding(context),
                    AppSpacing.md,
                    Responsive.horizontalPadding(context),
                    AppSpacing.lg,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _HeaderRow(),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppSizes.titleFont,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1A1A4A),
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          widget.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppSizes.subtitleFont,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4A4A7A),
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg),
                        _MainInfoCard(
                          featuredElement: widget.featuredElement,
                          displayName: _displayName,
                          displayCategory: _displayCategory,
                          displayDescription: _displayDescription,
                          displayFunFact: _displayFunFact,
                          showSpanish: _showSpanish,
                          onToggleLanguage: () =>
                              setState(() => _showSpanish = !_showSpanish),
                          onAudioTap: _speakCurrentContent,
                        ),
                        SizedBox(height: AppSpacing.md),
                        _ReminderBanner(message: widget.reminderMessage),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final contentWidth = Responsive.contentMaxWidth(context);

    return Row(
      children: [
        PillBackButton(
          contentWidth: contentWidth,
          foreground: const Color(0xFF3D3070),
        ),
      ],
    );
  }
}

class _MainInfoCard extends StatelessWidget {
  const _MainInfoCard({
    required this.featuredElement,
    required this.displayName,
    required this.displayCategory,
    required this.displayDescription,
    required this.displayFunFact,
    required this.showSpanish,
    required this.onToggleLanguage,
    required this.onAudioTap,
  });

  final ElementOfTheDayModel featuredElement;
  final String displayName;
  final String displayCategory;
  final String displayDescription;
  final String displayFunFact;
  final bool showSpanish;
  final VoidCallback onToggleLanguage;
  final Future<void> Function() onAudioTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wideLayout =
            constraints.maxWidth > 760.w || Responsive.isLandscape(context);

        return Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 20.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: wideLayout
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 235.w,
                      child: _ElementShowcase(
                        featuredElement: featuredElement,
                        displayName: displayName,
                        displayCategory: displayCategory,
                      ),
                    ),
                    SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: _ElementDetailsPanel(
                        featuredElement: featuredElement,
                        displayName: displayName,
                        displayDescription: displayDescription,
                        displayFunFact: displayFunFact,
                        showSpanish: showSpanish,
                        onToggleLanguage: onToggleLanguage,
                        onAudioTap: onAudioTap,
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: math.min(constraints.maxWidth, 265.w),
                        child: _ElementShowcase(
                          featuredElement: featuredElement,
                          displayName: displayName,
                          displayCategory: displayCategory,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    _ElementDetailsPanel(
                      featuredElement: featuredElement,
                      displayName: displayName,
                      displayDescription: displayDescription,
                      displayFunFact: displayFunFact,
                      showSpanish: showSpanish,
                      onToggleLanguage: onToggleLanguage,
                      onAudioTap: onAudioTap,
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _ElementShowcase extends StatelessWidget {
  const _ElementShowcase({
    required this.featuredElement,
    required this.displayName,
    required this.displayCategory,
  });

  final ElementOfTheDayModel featuredElement;
  final String displayName;
  final String displayCategory;

  String get _dateLabel {
    final d = featuredElement.date;
    const monthNames = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${monthNames[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDDEBFF), Color(0xFFF0E8FF)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD66E),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                _dateLabel,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6A4A00),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 140.w,
              height: 170.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: const Color(0xFFA6C6EE), width: 2.w),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x33829CD8),
                    blurRadius: 12.r,
                    offset: Offset(0, 6.h),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    featuredElement.symbol,
                    style: TextStyle(
                      fontSize: 52.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF264A70),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1F3654),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F6EA),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                displayCategory,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2A6A3F),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ElementDetailsPanel extends StatelessWidget {
  const _ElementDetailsPanel({
    required this.featuredElement,
    required this.displayName,
    required this.displayDescription,
    required this.displayFunFact,
    required this.showSpanish,
    required this.onToggleLanguage,
    required this.onAudioTap,
  });

  final ElementOfTheDayModel featuredElement;
  final String displayName;
  final String displayDescription;
  final String displayFunFact;
  final bool showSpanish;
  final VoidCallback onToggleLanguage;
  final Future<void> Function() onAudioTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About $displayName',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1F3654),
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          displayDescription,
          style: TextStyle(
            fontSize: AppSizes.bodyFont,
            height: 1.45,
            color: const Color(0xFF3E4A62),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            SizedBox(
              height: AppSizes.largeButtonHeight,
              child: ElevatedButton.icon(
                onPressed: onAudioTap,
                icon: Icon(Icons.volume_up_rounded, size: AppSizes.iconSize),
                label: Text(
                  showSpanish ? 'Reproducir audio' : 'Play Audio',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7D8CFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                ),
              ),
            ),
            SizedBox(
              height: AppSizes.largeButtonHeight,
              child: OutlinedButton.icon(
                onPressed: onToggleLanguage,
                icon: Icon(Icons.translate_rounded, size: AppSizes.iconSize),
                label: Text(
                  showSpanish ? 'English' : 'Español',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4A5CC9),
                  side: const BorderSide(color: Color(0xFFB7C6F7)),
                  backgroundColor: Colors.white.withValues(alpha: 0.85),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6D8),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                showSpanish ? 'Dato Curioso' : 'Fun Fact',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF7A5B00),
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                displayFunFact,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.4,
                  color: const Color(0xFF6A5600),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _MascotBubble(assetPath: featuredElement.mascotAsset),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _InfoPill(
                    label: showSpanish ? 'Atómico #' : 'Atomic #',
                    value: '${featuredElement.atomicNumber}',
                  ),
                  _InfoPill(
                    label: showSpanish ? 'Peso' : 'Weight',
                    value: featuredElement.atomicWeight.toStringAsFixed(3),
                  ),
                  _InfoPill(
                    label: showSpanish ? 'Grupo' : 'Group',
                    value: featuredElement.group,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MascotBubble extends StatelessWidget {
  const _MascotBubble({required this.assetPath});

  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        color: const Color(0xFFE9F3FF),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Center(
        child: assetPath == null
            ? Text('🫧', style: TextStyle(fontSize: 24.sp))
            : Padding(
                padding: EdgeInsets.all(AppSpacing.xs),
                child: Image.asset(assetPath!, fit: BoxFit.contain),
              ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4FF),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: const Color(0xFF33445E), fontSize: 12.sp),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _ReminderBanner extends StatelessWidget {
  const _ReminderBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF3F4F6A),
        ),
      ),
    );
  }
}

class _FloatingBlobs extends StatelessWidget {
  const _FloatingBlobs();

  @override
  Widget build(BuildContext context) {
    final width = Responsive.screenWidth(context);
    final height = Responsive.screenHeight(context);

    Widget blob({
      required double size,
      required double left,
      required double top,
      required Color color,
    }) {
      return Positioned(
        left: left,
        top: top,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size / 2),
          ),
        ),
      );
    }

    return IgnorePointer(
      child: Stack(
        children: [
          blob(
            size: math.min(220.w, width * 0.35),
            left: -30.w,
            top: height * 0.10,
            color: const Color(0x22FFFFFF),
          ),
          blob(
            size: math.min(180.w, width * 0.28),
            left: width * 0.78,
            top: height * 0.18,
            color: const Color(0x26FFFFFF),
          ),
          blob(
            size: math.min(200.w, width * 0.31),
            left: width * 0.72,
            top: height * 0.72,
            color: const Color(0x20FFFFFF),
          ),
        ],
      ),
    );
  }
}
