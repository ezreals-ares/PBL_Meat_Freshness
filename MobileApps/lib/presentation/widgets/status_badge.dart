import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Status badge pill modern untuk hasil kesegaran — FRESH / HALF-FRESH / SPOILED.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    this.textColor = AppColors.textPrimary,
    this.icon,
  });

  factory StatusBadge.fresh() => const StatusBadge(
        label: 'FRESH',
        backgroundColor: AppColors.statusFreshSoft,
        textColor: AppColors.statusFreshInk,
        icon: Icons.verified_rounded,
      );

  factory StatusBadge.halfFresh() => const StatusBadge(
        label: 'HALF-FRESH',
        backgroundColor: AppColors.statusHalfSoft,
        textColor: AppColors.amberInk,
        icon: Icons.warning_amber_rounded,
      );

  factory StatusBadge.spoiled() => const StatusBadge(
        label: 'SPOILED',
        backgroundColor: AppColors.statusSpoiledSoft,
        textColor: AppColors.statusSpoiledInk,
        icon: Icons.dangerous_rounded,
      );

  factory StatusBadge.fromResult(String result) {
    switch (result) {
      case 'fresh':
        return StatusBadge.fresh();
      case 'half_fresh':
        return StatusBadge.halfFresh();
      case 'spoiled':
        return StatusBadge.spoiled();
      default:
        return StatusBadge.fresh();
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
