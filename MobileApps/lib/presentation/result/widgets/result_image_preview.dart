import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// Kartu preview foto spesimen yang dipakai pada tampilan hasil maupun penolakan non-daging.
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

  @override
  Widget build(BuildContext context) {
    return Container(
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
                      specimenText ??
                          meatType?.toUpperCase() ??
                          'SAMPEL DAGING',
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
    );
  }
}
