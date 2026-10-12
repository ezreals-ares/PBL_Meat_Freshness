import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Segmented confidence bar matching the neobrutalist reference design.
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
    this.height = 12,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('CONFIDENCE',
                    style: AppTextStyles.labelSm
                        .copyWith(color: AppColors.textSecondary)),
                Text('${(confidence * 100).toStringAsFixed(1)}%',
                    style: AppTextStyles.labelSm
                        .copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: AppColors.borderDefault, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: Row(
              children: List.generate(4, (i) {
                final segmentFill =
                    ((confidence * 4) - i).clamp(0.0, 1.0);
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < 3 ? 2 : 0),
                    decoration: BoxDecoration(
                      color: segmentFill > 0.5
                          ? _statusColor
                          : AppColors.surfaceContainerHighest,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
