import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Progress bar kepercayaan modern dengan sudut membulat lembut.
class ConfidenceBar extends StatelessWidget {
  final double confidence; // 0.0 - 1.0
  final String result; // fresh, half_fresh, spoiled
  final bool showLabel;
  final double height;

  const ConfidenceBar({
    super.key,
    required this.confidence,
    required this.result,
    this.showLabel = true,
    this.height = 10,
  });

  Color get _statusColor {
    switch (result) {
      case 'fresh':
        return AppColors.statusFresh;
      case 'half_fresh':
        return AppColors.statusHalf;
      case 'spoiled':
        return AppColors.statusSpoiled;
      default:
        return AppColors.statusFresh;
    }
  }

  @override
  Widget build(BuildContext context) {
    final clamped = confidence.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KEPERCAYAAN',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${(clamped * 100).toStringAsFixed(1)}%',
                  style: AppTextStyles.labelSm.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Container(
            height: height,
            color: AppColors.surfaceContainer,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: clamped,
              child: Container(
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
