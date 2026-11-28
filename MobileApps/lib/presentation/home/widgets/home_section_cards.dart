import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/pressable_scale.dart';

/// Tombol aksi bulat dengan tooltip di AppBar Beranda.
class HomeIconCircleAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const HomeIconCircleAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.bgSurface,
        shape: const CircleBorder(),
        elevation: 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderSubtle, width: 1),
              boxShadow: [AppShadows.softSm()],
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 21),
          ),
        ),
      ),
    );
  }
}

/// Kartu pintasan 2 kolom pada bagian Aksi Cepat Beranda.
class QuickFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bannerColor;
  final Color iconBgColor;
  final Color iconColor;
  final Color accentDotColor;
  final VoidCallback onTap;

  const QuickFeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bannerColor,
    required this.iconBgColor,
    required this.iconColor,
    required this.accentDotColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderSubtle, width: 1),
          boxShadow: [AppShadows.softSm()],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 62,
              width: double.infinity,
              decoration: BoxDecoration(
                color: bannerColor,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -12,
                    bottom: -14,
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentDotColor.withValues(alpha: 0.16),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 11,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: [AppShadows.glow(iconBgColor, alpha: 0.25)],
                      ),
                      child: Icon(
                        icon,
                        size: 21,
                        color: iconColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTextStyles.labelLg.copyWith(
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu rekomendasi penyimpanan chiller/freezer di Beranda.
class StorageRecommendationCard extends StatelessWidget {
  const StorageRecommendationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
        boxShadow: [AppShadows.softSm()],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.tertiaryFixed,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.kitchen_rounded,
              color: AppColors.tertiaryDark,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REKOMENDASI PENYIMPANAN',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Daging sapi segar? Simpan di chiller < 4°C (1-2 hari). Bekukan di freezer untuk penyimpanan lebih lama (4-12 bulan).',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _TempChip(
                      icon: Icons.ac_unit_rounded,
                      label: 'Chiller < 4°C',
                      bgColor: AppColors.secondaryFixed,
                      fgColor: AppColors.secondaryDark,
                    ),
                    _TempChip(
                      icon: Icons.severe_cold_rounded,
                      label: 'Freezer -18°C',
                      bgColor: AppColors.tertiaryFixed,
                      fgColor: AppColors.tertiaryDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TempChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color fgColor;

  const _TempChip({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.fgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fgColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
