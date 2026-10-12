import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Status badge for freshness results — FRESH / HALF-FRESH / SPOILED.
class NeoBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const NeoBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    this.textColor = AppColors.textPrimary,
    this.icon,
  });

  factory NeoBadge.fresh() => const NeoBadge(
        label: 'FRESH',
        backgroundColor: AppColors.statusFresh,
        icon: Icons.check_circle,
      );

  factory NeoBadge.halfFresh() => const NeoBadge(
        label: 'HALF-FRESH',
        backgroundColor: AppColors.statusHalf,
        icon: Icons.warning,
      );

  factory NeoBadge.spoiled() => const NeoBadge(
        label: 'SPOILED',
        backgroundColor: AppColors.statusSpoiled,
        textColor: AppColors.onPrimary,
        icon: Icons.block,
      );

  factory NeoBadge.fromResult(String result) {
    switch (result) {
      case 'fresh':
        return NeoBadge.fresh();
      case 'half_fresh':
        return NeoBadge.halfFresh();
      case 'spoiled':
        return NeoBadge.spoiled();
      default:
        return NeoBadge.fresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.borderDefault, width: 2),
        boxShadow: [AppShadows.hardSmall()],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
