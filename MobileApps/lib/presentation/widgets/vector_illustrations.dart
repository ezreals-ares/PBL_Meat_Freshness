import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Ilustrasi flat-vector modern untuk Hero HomeScreen
/// terinspirasi dari visual layering pada Design Guide (#FDC323, #00785D, #32BFDB, #539BA9).
class HeroFreshnessIllustration extends StatelessWidget {
  final double height;

  const HeroFreshnessIllustration({super.key, this.height = 148});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _HeroFreshnessPainter(),
      ),
    );
  }
}

class _HeroFreshnessPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Soft atmospheric sky backdrop circles
    final skyGlow = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.14);
    canvas.drawCircle(Offset(w * 0.78, h * 0.32), h * 0.36, skyGlow);

    final sunGlow = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.22);
    canvas.drawCircle(Offset(w * 0.26, h * 0.34), h * 0.28, sunGlow);

    // 2. Warm Golden Sun (#FDC323)
    final sunPaint = Paint()..color = AppColors.accent;
    canvas.drawCircle(Offset(w * 0.26, h * 0.36), h * 0.17, sunPaint);

    // 3. Back mountain / organic wave in Slate Teal (#539BA9)
    final backHill = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.72)
      ..quadraticBezierTo(w * 0.18, h * 0.42, w * 0.40, h * 0.64)
      ..quadraticBezierTo(w * 0.65, h * 0.30, w * 0.88, h * 0.54)
      ..quadraticBezierTo(w * 0.95, h * 0.60, w, h * 0.56)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(backHill, Paint()..color = AppColors.tertiary.withValues(alpha: 0.55));

    // 4. Mid wave in Bright Aqua (#32BFDB)
    final midHill = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.80)
      ..quadraticBezierTo(w * 0.28, h * 0.52, w * 0.56, h * 0.75)
      ..quadraticBezierTo(w * 0.80, h * 0.55, w, h * 0.72)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(midHill, Paint()..color = AppColors.secondary.withValues(alpha: 0.80));

    // 5. Stylized geometric freshness trees/leaves on left & right (like the guide!)
    _drawStylizedTree(canvas, Offset(w * 0.14, h * 0.82), h * 0.26, AppColors.primary);
    _drawStylizedTree(canvas, Offset(w * 0.86, h * 0.80), h * 0.30, AppColors.primaryDark);
    _drawStylizedTree(canvas, Offset(w * 0.77, h * 0.84), h * 0.20, AppColors.primary);

    // 6. Central AI Freshness Lens / Dome emblem (echoing the tent focal point!)
    final centerX = w * 0.50;
    final baseY = h * 0.92;
    final cardW = math.min(w * 0.38, 126.0);
    final cardH = h * 0.56;

    // Soft white card shield behind lens
    final shieldRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, baseY - cardH * 0.52),
        width: cardW,
        height: cardH,
      ),
      const Radius.circular(18),
    );
    canvas.drawRRect(
      shieldRect.shift(const Offset(0, 6)),
      Paint()..color = AppColors.primaryDark.withValues(alpha: 0.16),
    );
    canvas.drawRRect(shieldRect, Paint()..color = AppColors.bgSurface);

    // Golden top ribbon inside shield
    final topStripe = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        centerX - cardW * 0.34,
        baseY - cardH * 0.84,
        cardW * 0.68,
        8,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(topStripe, Paint()..color = AppColors.accent);

    // Emerald scanner ring inside shield
    final ringCenter = Offset(centerX, baseY - cardH * 0.42);
    canvas.drawCircle(ringCenter, cardH * 0.24, Paint()..color = AppColors.primarySoft);
    canvas.drawCircle(
      ringCenter,
      cardH * 0.16,
      Paint()..color = AppColors.primary,
    );
    // Crisp check stroke inside circle
    final checkPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final r = cardH * 0.08;
    final checkPath = Path()
      ..moveTo(ringCenter.dx - r, ringCenter.dy + r * 0.05)
      ..lineTo(ringCenter.dx - r * 0.2, ringCenter.dy + r * 0.8)
      ..lineTo(ringCenter.dx + r * 1.05, ringCenter.dy - r * 0.65);
    canvas.drawPath(checkPath, checkPaint);

    // 7. Foreground Deep Emerald base curve seamlessly connecting to CTA card
    final frontWave = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.88)
      ..quadraticBezierTo(w * 0.26, h * 0.76, w * 0.52, h * 0.88)
      ..quadraticBezierTo(w * 0.78, h * 0.96, w, h * 0.84)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(frontWave, Paint()..color = AppColors.primary);

    // 8. Floating vector sparkles
    _drawSparkle(canvas, Offset(w * 0.66, h * 0.22), 6, AppColors.accent);
    _drawSparkle(canvas, Offset(w * 0.34, h * 0.18), 4.5, AppColors.secondary);
    canvas.drawCircle(
      Offset(w * 0.72, h * 0.38),
      3.5,
      Paint()..color = AppColors.primary.withValues(alpha: 0.45),
    );
  }

  void _drawStylizedTree(Canvas canvas, Offset base, double height, Color color) {
    final trunkPaint = Paint()
      ..color = AppColors.amberInk.withValues(alpha: 0.55)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(base, Offset(base.dx, base.dy - height * 0.35), trunkPaint);

    final canopyPaint = Paint()..color = color;
    final path = Path()
      ..moveTo(base.dx, base.dy - height)
      ..lineTo(base.dx - height * 0.34, base.dy - height * 0.24)
      ..quadraticBezierTo(
        base.dx,
        base.dy - height * 0.16,
        base.dx + height * 0.34,
        base.dy - height * 0.24,
      )
      ..close();
    canvas.drawPath(path, canopyPaint);
  }

  void _drawSparkle(Canvas canvas, Offset c, double r, Color color) {
    final p = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(p, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Latar geometris flat-vector untuk Viewfinder CaptureScreen
/// terinspirasi dari visual peta/blok warna Screen 3 pada Design Guide.
class ScannerBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Base rich burgundy-to-ruby meat scanner gradient
    final bgRect = Rect.fromLTWH(0, 0, w, h);
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF3E1218),
          Color(0xFF6B1822),
          Color(0xFF96222D),
        ],
      ).createShader(bgRect);
    canvas.drawRect(bgRect, bgPaint);

    // Subtle geometric color blocks echoing Screen 3 vector art
    final aquaBlob = Path()
      ..moveTo(w * 0.62, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.58)
      ..quadraticBezierTo(w * 0.74, h * 0.50, w * 0.62, 0)
      ..close();
    canvas.drawPath(
      aquaBlob,
      Paint()..color = AppColors.secondary.withValues(alpha: 0.22),
    );

    final tealBlob = Path()
      ..moveTo(0, h * 0.56)
      ..quadraticBezierTo(w * 0.26, h * 0.44, w * 0.46, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      tealBlob,
      Paint()..color = AppColors.tertiary.withValues(alpha: 0.28),
    );

    // Crisp subtle camera rule-of-thirds grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(w / 3, 0), Offset(w / 3, h), gridPaint);
    canvas.drawLine(Offset(2 * w / 3, 0), Offset(2 * w / 3, h), gridPaint);
    canvas.drawLine(Offset(0, h / 3), Offset(w, h / 3), gridPaint);
    canvas.drawLine(Offset(0, 2 * h / 3), Offset(w, 2 * h / 3), gridPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ilustrasi empty state modern untuk HistoryScreen.
class EmptyHistoryIllustration extends StatelessWidget {
  const EmptyHistoryIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 100,
      child: CustomPaint(
        painter: _EmptyHistoryPainter(),
      ),
    );
  }
}

class _EmptyHistoryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft mint circle base
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.52),
      h * 0.42,
      Paint()..color = AppColors.primarySoft,
    );

    // Decorative aqua dot & golden sun
    canvas.drawCircle(
      Offset(w * 0.20, h * 0.26),
      8,
      Paint()..color = AppColors.accent,
    );
    canvas.drawCircle(
      Offset(w * 0.84, h * 0.34),
      6,
      Paint()..color = AppColors.secondary,
    );

    // Document card icon
    final docRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.48, h * 0.54),
        width: 48,
        height: 58,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(docRect, Paint()..color = Colors.white);
    canvas.drawRRect(
      docRect,
      Paint()
        ..color = AppColors.tertiary.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Document lines
    final linePaint = Paint()
      ..color = AppColors.surfaceContainerHighest
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.36, h * 0.40), Offset(w * 0.58, h * 0.40), linePaint);
    canvas.drawLine(Offset(w * 0.36, h * 0.52), Offset(w * 0.54, h * 0.52), linePaint);
    canvas.drawLine(Offset(w * 0.36, h * 0.64), Offset(w * 0.48, h * 0.64), linePaint);

    // Emerald badge lens bottom-right
    final lensCenter = Offset(w * 0.66, h * 0.68);
    canvas.drawCircle(lensCenter, 14, Paint()..color = AppColors.primary);
    canvas.drawCircle(
      lensCenter,
      6,
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
