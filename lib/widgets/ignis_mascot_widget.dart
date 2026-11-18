import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/strive_models.dart';
import 'strive_theme.dart';

class IgnisMascotWidget extends StatefulWidget {
  final IgnisMood mood;
  final String? speechText;
  final String equippedAccessory;
  final double size;
  final bool showSpeechBubble;
  final bool interactiveMoodCycle;
  final VoidCallback? onTap;

  const IgnisMascotWidget({
    super.key,
    required this.mood,
    this.speechText,
    this.equippedAccessory = 'none',
    this.size = 110,
    this.showSpeechBubble = true,
    this.interactiveMoodCycle = false,
    this.onTap,
  });

  @override
  State<IgnisMascotWidget> createState() => _IgnisMascotWidgetState();
}

class _IgnisMascotWidgetState extends State<IgnisMascotWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _moodLabel(IgnisMood mood) {
    switch (mood) {
      case IgnisMood.happyHype:
        return '🔥 HYPE MODE';
      case IgnisMood.angryGuilt:
        return '💢 RAGE DUOLINGO MODE';
      case IgnisMood.cryingFrozen:
        return '❄️ FROZEN STREAK MODE';
      case IgnisMood.coachSpartan:
        return '🎽 SPARTAN COACH MODE';
      case IgnisMood.burnoutDoctor:
        return '🩺 BURNOUT DOCTOR MODE';
    }
  }

  Color _moodPrimaryColor(IgnisMood mood) {
    switch (mood) {
      case IgnisMood.happyHype:
        return StriveColors.amber;
      case IgnisMood.angryGuilt:
        return StriveColors.rose;
      case IgnisMood.cryingFrozen:
        return StriveColors.sky;
      case IgnisMood.coachSpartan:
        return StriveColors.emerald;
      case IgnisMood.burnoutDoctor:
        return const Color(0xFF14B8A6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodColor = _moodPrimaryColor(widget.mood);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final mascotAvatar = GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final dy = widget.mood == IgnisMood.happyHype
              ? -8.0 * math.sin(t * math.pi)
              : (widget.mood == IgnisMood.angryGuilt
                  ? 2.5 * math.sin(t * math.pi * 6)
                  : -4.0 * math.sin(t * math.pi));

          return Transform.translate(
            offset: Offset(0, dy),
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _IgnisPhoenixTigerPainter(
                  mood: widget.mood,
                  accessory: widget.equippedAccessory,
                  animValue: t,
                ),
              ),
            ),
          );
        },
      ),
    );

    if (!widget.showSpeechBubble || widget.speechText == null) {
      return mascotAvatar;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: moodColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? StriveColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: moodColor.withValues(alpha: 0.85),
            width: 2.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            mascotAvatar,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: moodColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: moodColor.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Text(
                            _moodLabel(widget.mood),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: moodColor,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                      if (widget.interactiveMoodCycle &&
                          widget.onTap != null) ...[
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            widget.onTap?.call();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.touch_app_rounded,
                                  size: 13,
                                  color: StriveColors.textSecondary(context),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Ubah Mood',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: StriveColors.textSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<double>(
                    key: ValueKey(widget.speechText),
                    tween: Tween(begin: 0.85, end: 1.0),
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        alignment: Alignment.centerLeft,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? StriveColors.darkSurface
                            : const Color(0xFFF1F5F9),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                          topLeft: Radius.circular(4),
                        ),
                        border: Border.all(
                          color: moodColor.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '"${widget.speechText!}"',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                          color: StriveColors.textPrimary(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IgnisPhoenixTigerPainter extends CustomPainter {
  final IgnisMood mood;
  final String accessory;
  final double animValue;

  _IgnisPhoenixTigerPainter({
    required this.mood,
    required this.accessory,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 4;
    final r = size.width * 0.34;

    // Color scheme per Mascot State
    Color bodyTop;
    Color bodyBottom;
    Color auraColor;
    Color stripeColor;

    switch (mood) {
      case IgnisMood.happyHype:
        bodyTop = const Color(0xFFFFB703);
        bodyBottom = const Color(0xFFFB8500);
        auraColor = const Color(0xFFFFD166);
        stripeColor = const Color(0xFF9B2226);
        break;
      case IgnisMood.angryGuilt:
        bodyTop = const Color(0xFFFF2A2A);
        bodyBottom = const Color(0xFF990000);
        auraColor = const Color(0xFFFF4B4B);
        stripeColor = const Color(0xFF2B0000);
        break;
      case IgnisMood.cryingFrozen:
        bodyTop = const Color(0xFF56CFE1);
        bodyBottom = const Color(0xFF0077B6);
        auraColor = const Color(0xFF90E0EF);
        stripeColor = const Color(0xFF03045E);
        break;
      case IgnisMood.coachSpartan:
        bodyTop = const Color(0xFFFF9F1C);
        bodyBottom = const Color(0xFFE76F51);
        auraColor = const Color(0xFF58CC02);
        stripeColor = const Color(0xFF5F0F40);
        break;
      case IgnisMood.burnoutDoctor:
        bodyTop = const Color(0xFF2EC4B6);
        bodyBottom = const Color(0xFF0F766E);
        auraColor = const Color(0xFF5EEAD4);
        stripeColor = const Color(0xFF134E4A);
        break;
    }

    // 1. Glowing Outer Aura Circle
    final auraPaint = Paint()
      ..color = auraColor.withValues(alpha: 0.22 + 0.1 * animValue)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(cx, cy),
      r * (1.28 + 0.06 * animValue),
      auraPaint,
    );

    // 2. Phoenix Wings (Left & Right)
    final wingPaint = Paint()
      ..shader = LinearGradient(
        colors: [bodyTop, bodyBottom],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r * 1.4));

    final wingFlap = (animValue - 0.5) * 8.0;
    final leftWing = Path()
      ..moveTo(cx - r * 0.75, cy)
      ..quadraticBezierTo(
        cx - r * 1.45,
        cy - r * 0.6 + wingFlap,
        cx - r * 1.15,
        cy + r * 0.45,
      )
      ..quadraticBezierTo(cx - r * 0.9, cy + r * 0.5, cx - r * 0.65, cy + r * 0.2)
      ..close();
    canvas.drawPath(leftWing, wingPaint);

    final rightWing = Path()
      ..moveTo(cx + r * 0.75, cy)
      ..quadraticBezierTo(
        cx + r * 1.45,
        cy - r * 0.6 + wingFlap,
        cx + r * 1.15,
        cy + r * 0.45,
      )
      ..quadraticBezierTo(cx + r * 0.9, cy + r * 0.5, cx + r * 0.65, cy + r * 0.2)
      ..close();
    canvas.drawPath(rightWing, wingPaint);

    // 3. Tiger Rounded Ears
    final earPaint = Paint()..color = bodyBottom;
    final innerEarPaint = Paint()..color = const Color(0xFFFFE5B4);
    canvas.drawCircle(Offset(cx - r * 0.7, cy - r * 0.72), r * 0.30, earPaint);
    canvas.drawCircle(Offset(cx + r * 0.7, cy - r * 0.72), r * 0.30, earPaint);
    canvas.drawCircle(
        Offset(cx - r * 0.7, cy - r * 0.72), r * 0.16, innerEarPaint);
    canvas.drawCircle(
        Offset(cx + r * 0.7, cy - r * 0.72), r * 0.16, innerEarPaint);

    // 4. Phoenix Flame Crest on top of head
    final crestPaint = Paint()
      ..color = mood == IgnisMood.cryingFrozen
          ? const Color(0xFFCAF0F8)
          : const Color(0xFFFFD166);
    final crestPath = Path()
      ..moveTo(cx - r * 0.28, cy - r * 0.85)
      ..quadraticBezierTo(
          cx - r * 0.15, cy - r * 1.45, cx, cy - r * (1.28 + 0.1 * animValue))
      ..quadraticBezierTo(
          cx + r * 0.15, cy - r * 1.45, cx + r * 0.28, cy - r * 0.85)
      ..close();
    canvas.drawPath(crestPath, crestPaint);

    // 5. Main Head / Body Sphere with 3D Tactile Shading
    final bodyRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: r * 2.05,
      height: r * 1.92,
    );
    final bodyRRect =
        RRect.fromRectAndRadius(bodyRect, Radius.circular(r * 0.88));

    // Bottom 3D lip shadow
    final lipRect = bodyRect.shift(const Offset(0, 4));
    canvas.drawRRect(
      RRect.fromRectAndRadius(lipRect, Radius.circular(r * 0.88)),
      Paint()..color = stripeColor.withValues(alpha: 0.75),
    );

    final headPaint = Paint()
      ..shader = LinearGradient(
        colors: [bodyTop, bodyBottom],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bodyRect);
    canvas.drawRRect(bodyRRect, headPaint);

    // 6. Tiger Cheek & Belly Patch
    final muzzleRect = Rect.fromCenter(
      center: Offset(cx, cy + r * 0.24),
      width: r * 1.25,
      height: r * 0.88,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(muzzleRect, Radius.circular(r * 0.45)),
      Paint()
        ..color = mood == IgnisMood.cryingFrozen
            ? const Color(0xFFE0FBFC)
            : const Color(0xFFFFF3D6),
    );

    // 7. Tiger Forehead & Cheek Stripes
    final stripePaint = Paint()
      ..color = stripeColor
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    // Left cheek stripes
    canvas.drawLine(
      Offset(cx - r * 0.92, cy - r * 0.05),
      Offset(cx - r * 0.65, cy - r * 0.02),
      stripePaint,
    );
    canvas.drawLine(
      Offset(cx - r * 0.90, cy + r * 0.14),
      Offset(cx - r * 0.66, cy + r * 0.11),
      stripePaint,
    );
    // Right cheek stripes
    canvas.drawLine(
      Offset(cx + r * 0.92, cy - r * 0.05),
      Offset(cx + r * 0.65, cy - r * 0.02),
      stripePaint,
    );
    canvas.drawLine(
      Offset(cx + r * 0.90, cy + r * 0.14),
      Offset(cx + r * 0.66, cy + r * 0.11),
      stripePaint,
    );

    // 8. Eyes & Expression per State
    final eyeY = cy - r * 0.12;
    final leftEyeX = cx - r * 0.36;
    final rightEyeX = cx + r * 0.36;

    if (mood == IgnisMood.angryGuilt) {
      // Glowing Fierce Eyes + Angry V-Brows
      final eyeWhite = Paint()..color = const Color(0xFFFFF0F0);
      canvas.drawCircle(Offset(leftEyeX, eyeY), r * 0.20, eyeWhite);
      canvas.drawCircle(Offset(rightEyeX, eyeY), r * 0.20, eyeWhite);

      final pupilPaint = Paint()..color = const Color(0xFF990000);
      canvas.drawCircle(Offset(leftEyeX, eyeY), r * 0.11, pupilPaint);
      canvas.drawCircle(Offset(rightEyeX, eyeY), r * 0.11, pupilPaint);

      final browPaint = Paint()
        ..color = const Color(0xFF2B0000)
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(leftEyeX - r * 0.22, eyeY - r * 0.24),
        Offset(leftEyeX + r * 0.20, eyeY - r * 0.08),
        browPaint,
      );
      canvas.drawLine(
        Offset(rightEyeX + r * 0.22, eyeY - r * 0.24),
        Offset(rightEyeX - r * 0.20, eyeY - r * 0.08),
        browPaint,
      );
    } else if (mood == IgnisMood.cryingFrozen) {
      // Waterfall Tear Streams + Shivering Eyes
      final tearPaint = Paint()
        ..color = const Color(0xFF00B4D8).withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(leftEyeX - r * 0.10, eyeY, r * 0.20, r * 0.65),
          const Radius.circular(6),
        ),
        tearPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(rightEyeX - r * 0.10, eyeY, r * 0.20, r * 0.65),
          const Radius.circular(6),
        ),
        tearPaint,
      );

      final eyePaint = Paint()
        ..color = const Color(0xFF03045E)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(leftEyeX, eyeY), radius: r * 0.16),
        0.2,
        math.pi - 0.4,
        false,
        eyePaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: Offset(rightEyeX, eyeY), radius: r * 0.16),
        0.2,
        math.pi - 0.4,
        false,
        eyePaint,
      );
    } else {
      // Bright Expressive Eyes with Sparkle Highlights
      final eyeBg = Paint()..color = const Color(0xFF1E293B);
      canvas.drawCircle(Offset(leftEyeX, eyeY), r * 0.19, eyeBg);
      canvas.drawCircle(Offset(rightEyeX, eyeY), r * 0.19, eyeBg);

      final sparkle = Paint()..color = Colors.white;
      canvas.drawCircle(
          Offset(leftEyeX - r * 0.06, eyeY - r * 0.06), r * 0.07, sparkle);
      canvas.drawCircle(
          Offset(rightEyeX - r * 0.06, eyeY - r * 0.06), r * 0.07, sparkle);
      canvas.drawCircle(
          Offset(leftEyeX + r * 0.06, eyeY + r * 0.05), r * 0.035, sparkle);
      canvas.drawCircle(
          Offset(rightEyeX + r * 0.06, eyeY + r * 0.05), r * 0.035, sparkle);
    }

    // 9. Cute Tiger Nose & Mouth / Beak-Grin
    final nosePaint = Paint()..color = const Color(0xFFD90429);
    final nosePath = Path()
      ..moveTo(cx - r * 0.12, cy + r * 0.10)
      ..lineTo(cx + r * 0.12, cy + r * 0.10)
      ..lineTo(cx, cy + r * 0.22)
      ..close();
    canvas.drawPath(nosePath, nosePaint);

    final mouthPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (mood == IgnisMood.angryGuilt || mood == IgnisMood.cryingFrozen) {
      // Frown
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx, cy + r * 0.42),
          width: r * 0.45,
          height: r * 0.26,
        ),
        math.pi + 0.3,
        math.pi - 0.6,
        false,
        mouthPaint,
      );
    } else {
      // Determined / Happy Tiger Cat-Smile ("w")
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx - r * 0.12, cy + r * 0.27),
          width: r * 0.24,
          height: r * 0.20,
        ),
        0,
        math.pi,
        false,
        mouthPaint,
      );
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx + r * 0.12, cy + r * 0.27),
          width: r * 0.24,
          height: r * 0.20,
        ),
        0,
        math.pi,
        false,
        mouthPaint,
      );
    }

    // 10. Mode-Specific & Shop Accessories
    final showSpartanHeadband =
        mood == IgnisMood.coachSpartan || accessory == 'headband_spartan';
    if (showSpartanHeadband) {
      final bandPaint = Paint()..color = const Color(0xFFD90429);
      final bandRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy - r * 0.56),
          width: r * 1.92,
          height: r * 0.26,
        ),
        const Radius.circular(6),
      );
      canvas.drawRRect(bandRect, bandPaint);
      // Gold stripe in middle of headband
      canvas.drawLine(
        Offset(cx - r * 0.85, cy - r * 0.56),
        Offset(cx + r * 0.85, cy - r * 0.56),
        Paint()
          ..color = const Color(0xFFFFD166)
          ..strokeWidth = 3,
      );
    }

    if (mood == IgnisMood.burnoutDoctor) {
      // Doctor Headband & Medical Cross Mirror
      canvas.drawLine(
        Offset(cx - r * 0.88, cy - r * 0.55),
        Offset(cx + r * 0.88, cy - r * 0.55),
        Paint()
          ..color = const Color(0xFF0F172A)
          ..strokeWidth = 5,
      );
      canvas.drawCircle(
        Offset(cx, cy - r * 0.55),
        r * 0.24,
        Paint()..color = Colors.white,
      );
      final crossPaint = Paint()
        ..color = StriveColors.rose
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cx - r * 0.11, cy - r * 0.55),
        Offset(cx + r * 0.11, cy - r * 0.55),
        crossPaint,
      );
      canvas.drawLine(
        Offset(cx, cy - r * 0.66),
        Offset(cx, cy - r * 0.44),
        crossPaint,
      );
    }

    if (accessory == 'kacamata_ambis') {
      final glassPaint = Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = 3.2
        ..style = PaintingStyle.stroke;
      final lensTint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.28);
      final leftLens = Rect.fromCenter(
        center: Offset(leftEyeX, eyeY),
        width: r * 0.54,
        height: r * 0.42,
      );
      final rightLens = Rect.fromCenter(
        center: Offset(rightEyeX, eyeY),
        width: r * 0.54,
        height: r * 0.42,
      );
      canvas.drawRRect(
          RRect.fromRectAndRadius(leftLens, const Radius.circular(6)), lensTint);
      canvas.drawRRect(
          RRect.fromRectAndRadius(rightLens, const Radius.circular(6)), lensTint);
      canvas.drawRRect(
          RRect.fromRectAndRadius(leftLens, const Radius.circular(6)),
          glassPaint);
      canvas.drawRRect(
          RRect.fromRectAndRadius(rightLens, const Radius.circular(6)),
          glassPaint);
      canvas.drawLine(
        Offset(leftEyeX + r * 0.27, eyeY),
        Offset(rightEyeX - r * 0.27, eyeY),
        glassPaint,
      );
    } else if (accessory == 'baret_taruna') {
      final beretPaint = Paint()..color = const Color(0xFFB91C1C);
      final beretPath = Path()
        ..moveTo(cx - r * 0.85, cy - r * 0.62)
        ..quadraticBezierTo(
            cx - r * 0.3, cy - r * 1.38, cx + r * 0.92, cy - r * 0.85)
        ..quadraticBezierTo(
            cx + r * 1.0, cy - r * 0.55, cx - r * 0.85, cy - r * 0.62)
        ..close();
      canvas.drawPath(beretPath, beretPaint);
      // Gold Taruna Emblem
      canvas.drawCircle(
        Offset(cx - r * 0.25, cy - r * 0.82),
        r * 0.14,
        Paint()..color = const Color(0xFFFFD166),
      );
    } else if (accessory == 'mahkota_sepuh') {
      final crownPaint = Paint()..color = const Color(0xFFFFD700);
      final crownPath = Path()
        ..moveTo(cx - r * 0.55, cy - r * 0.72)
        ..lineTo(cx - r * 0.65, cy - r * 1.25)
        ..lineTo(cx - r * 0.25, cy - r * 0.95)
        ..lineTo(cx, cy - r * 1.38)
        ..lineTo(cx + r * 0.25, cy - r * 0.95)
        ..lineTo(cx + r * 0.65, cy - r * 1.25)
        ..lineTo(cx + r * 0.55, cy - r * 0.72)
        ..close();
      canvas.drawPath(crownPath, crownPaint);
      canvas.drawCircle(
        Offset(cx, cy - r * 0.92),
        r * 0.09,
        Paint()..color = StriveColors.rose,
      );
    }

    // 11. Floating Sparkles / Fire / Ice Particles
    final particlePaint = Paint()
      ..color = mood == IgnisMood.angryGuilt
          ? const Color(0xFFFF4B4B)
          : (mood == IgnisMood.cryingFrozen
              ? const Color(0xFFCAF0F8)
              : const Color(0xFFFFD166));
    final angles = [0.4, 1.3, 2.5, 3.8, 4.9, 5.8];
    for (int i = 0; i < angles.length; i++) {
      final a = angles[i] + animValue * 0.7;
      final dist = r * (1.18 + (i % 2) * 0.15);
      final px = cx + math.cos(a) * dist;
      final py = cy + math.sin(a) * dist;
      canvas.drawCircle(Offset(px, py), 3.0 + (i % 2) * 1.5, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _IgnisPhoenixTigerPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.accessory != accessory ||
        oldDelegate.animValue != animValue;
  }
}
