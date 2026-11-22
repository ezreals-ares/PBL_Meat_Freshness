import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Status badge pill modern untuk hasil kesegaran — FRESH / HALF-FRESH / SPOILED.
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
        backgroundColor: AppColors.statusFreshSoft,
        textColor: AppColors.statusFreshInk,
        icon: Icons.verified_rounded,
      );

  factory NeoBadge.halfFresh() => const NeoBadge(
        label: 'HALF-FRESH',
        backgroundColor: AppColors.statusHalfSoft,
        textColor: AppColors.amberInk,
        icon: Icons.warning_amber_rounded,
      );

  factory NeoBadge.spoiled() => const NeoBadge(
        label: 'SPOILED',
        backgroundColor: AppColors.statusSpoiledSoft,
        textColor: AppColors.statusSpoiledInk,
        icon: Icons.dangerous_rounded,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
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
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
