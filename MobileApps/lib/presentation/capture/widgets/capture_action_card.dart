import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/pressable_scale.dart';

/// Kartu tombol pemilihan sumber foto (Kamera / Galeri) pada CaptureScreen.
class CaptureActionCard extends StatelessWidget {
  final Color backgroundColor;
  final Color iconBgColor;
  final Color iconColor;
  final Color labelColor;
  final Color headlineColor;
  final IconData icon;
  final String label;
  final String headline;
  final bool hasGlow;
  final VoidCallback onTap;

  const CaptureActionCard({
    super.key,
    required this.backgroundColor,
    required this.iconBgColor,
    required this.iconColor,
    required this.labelColor,
    required this.headlineColor,
    required this.icon,
    required this.label,
    required this.headline,
    required this.hasGlow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: hasGlow
              ? null
              : Border.all(color: AppColors.borderSubtle, width: 1),
          boxShadow: [
            hasGlow
                ? AppShadows.glow(backgroundColor, alpha: 0.28)
                : AppShadows.softSm(),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 26, color: iconColor),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: labelColor,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              headline,
              style: AppTextStyles.headlineSm.copyWith(
                fontSize: 15.5,
                color: headlineColor,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
