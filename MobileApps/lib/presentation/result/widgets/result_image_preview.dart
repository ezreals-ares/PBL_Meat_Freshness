import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';

/// Kartu preview foto spesimen yang dipakai pada tampilan hasil maupun penolakan non-daging.
/// Ketuk kartu untuk melihat foto secara penuh (*fullscreen*) dengan pinch-to-zoom.
class ResultImagePreview extends StatelessWidget {
  final String imagePath;
  final String? meatType;
  final String badgeText;
  final String captionTitle;
  final String? specimenText;

  const ResultImagePreview({
    super.key,
    required this.imagePath,
    this.meatType,
    this.badgeText = 'PINDAI PERMUKAAN SELESAI',
    this.captionTitle = 'SPESIMEN TERIDENTIFIKASI',
    this.specimenText,
  });

  String get _resolvedTitle =>
      specimenText ?? meatType?.toUpperCase() ?? 'SAMPEL DAGING';

  void _openFullScreenImage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, _, _) => _FullScreenImageViewer(
          imagePath: imagePath,
          title: _resolvedTitle,
        ),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openFullScreenImage(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [AppShadows.softCard()],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: SizedBox(
            height: 215,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                  cacheWidth: 1080,
                  errorBuilder: (ctx, err, st) => Container(
                    color: AppColors.surfaceContainer,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_rounded,
                        size: 56,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.08),
                          Colors.transparent,
                          AppColors.textPrimary.withValues(alpha: 0.72),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.center_focus_strong_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          badgeText,
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fullscreen_rounded,
                      size: 19,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 14,
                  left: 14,
                  right: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        captionTitle,
                        style: AppTextStyles.labelSm.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          letterSpacing: 1.4,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _resolvedTitle,
                        style: AppTextStyles.headlineSm.copyWith(
                          color: Colors.white,
                          fontSize: 19,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FullScreenImageViewer extends StatelessWidget {
  final String imagePath;
  final String title;

  const _FullScreenImageViewer({
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, st) => const Icon(
                      Icons.broken_image_rounded,
                      size: 72,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.headlineSm.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Material(
                        color: Colors.white.withValues(alpha: 0.16),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.of(context).pop(),
                          child: const Tooltip(
                            message: 'Tutup',
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        'Cubit untuk perbesar gambar',
                        style: AppTextStyles.labelSm.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
