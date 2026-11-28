import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Kartu peringatan keamanan pangan dengan gaya hangat yang dipakai di Beranda dan Hasil.
class SafetyNoticeCard extends StatelessWidget {
  final String title;
  final String message;
  final bool uppercaseTitle;
  final double borderRadius;

  const SafetyNoticeCard({
    super.key,
    required this.title,
    required this.message,
    this.uppercaseTitle = false,
    this.borderRadius = AppRadius.lg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.onAccent,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: (uppercaseTitle
                          ? AppTextStyles.labelSm.copyWith(letterSpacing: 0.9)
                          : AppTextStyles.labelMd)
                      .copyWith(
                    color: AppColors.amberInk,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.amberInk,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
