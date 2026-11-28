import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/pressable_scale.dart';

/// Hero banner Beranda dengan foto daging segar penuh dan gradasi merah daging.
class HomeHeroCard extends StatelessWidget {
  final VoidCallback onStartCheck;

  const HomeHeroCard({super.key, required this.onStartCheck});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.meatRedLight,
            AppColors.meatRed,
            AppColors.meatRedDark,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [AppShadows.glow(AppColors.meatRed, alpha: 0.30)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 178,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/hero_fresh_meat.jpg',
                    fit: BoxFit.cover,
                    cacheWidth: 1080,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.meatRedLight,
                            AppColors.meatRedDark,
                          ],
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
                            Colors.black.withValues(alpha: 0.22),
                            Colors.transparent,
                            AppColors.meatRed.withValues(alpha: 0.65),
                            AppColors.meatRed,
                          ],
                          stops: const [0.0, 0.40, 0.80, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.42),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'AI VISION READY',
                            style: AppTextStyles.labelSm.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.meatRed,
                    AppColors.meatRedDark,
                  ],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CEK KESEGARAN\nDAGING KAMU',
                    style: AppTextStyles.headlineLgMobile.copyWith(
                      color: AppColors.onPrimary,
                      fontSize: 22,
                      height: 1.22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Analisis visual kesegaran daging secara instan langsung dari kamera.',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.88),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MeatRedStartCta(onTap: onStartCheck),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeatRedStartCta extends StatelessWidget {
  final VoidCallback onTap;

  const _MeatRedStartCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      pressedScale: 0.98,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.meatRedDark,
              AppColors.meatRedDeep,
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(
                Icons.photo_camera_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MULAI CEK',
                    style: AppTextStyles.labelLg.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'PINDAI DENGAN KAMERA',
                    style: AppTextStyles.labelSm.copyWith(
                      color: Colors.white.withValues(alpha: 0.80),
                      fontSize: 10.5,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                boxShadow: [AppShadows.glow(AppColors.accent, alpha: 0.35)],
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.onAccent,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
