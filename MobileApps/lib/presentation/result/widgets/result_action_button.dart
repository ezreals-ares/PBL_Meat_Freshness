import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/pressable_scale.dart';

/// Tombol aksi bawah pada ResultScreen dengan perlindungan teks anti-overflow.
class ResultActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool iconFirst;
  final Color color;
  final Color textColor;
  final bool outlined;
  final VoidCallback onTap;

  const ResultActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.iconFirst,
    required this.color,
    required this.textColor,
    required this.outlined,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: outlined
              ? Border.all(color: AppColors.borderDefault, width: 1.2)
              : null,
          boxShadow: [
            outlined
                ? AppShadows.softSm()
                : AppShadows.glow(color, alpha: 0.34),
          ],
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: iconFirst
                  ? [
                      Icon(icon, size: 19, color: textColor),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: AppTextStyles.labelLg.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ]
                  : [
                      Text(
                        label,
                        style: AppTextStyles.labelLg.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(icon, size: 19, color: textColor),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
