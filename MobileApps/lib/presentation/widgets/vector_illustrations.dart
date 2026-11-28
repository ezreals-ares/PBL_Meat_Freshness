import 'package:flutter/material.dart';
import '../theme/theme.dart';

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
