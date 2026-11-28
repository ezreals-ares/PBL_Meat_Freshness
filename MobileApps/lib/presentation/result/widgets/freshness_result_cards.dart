import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../domain/models/classification_result.dart';
import '../../theme/result_ui_ext.dart';
import '../../theme/theme.dart';

/// Kartu vonis utama status kesegaran daging (FRESH / HALF-FRESH / SPOILED).
class VerdictCard extends StatelessWidget {
  final ClassificationResult result;

  const VerdictCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final bg = result.statusColor;
    final fg = result.statusOnColor;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [AppShadows.glow(bg, alpha: 0.28)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(result.statusIcon, color: fg, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HASIL ANALISIS',
                      style: AppTextStyles.labelSm.copyWith(
                        color: fg.withValues(alpha: 0.82),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${result.statusEmoji} ${result.displayName}',
                      style: AppTextStyles.headlineLgMobile.copyWith(
                        color: fg,
                        fontSize: 23,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              result.statusAdvice,
              style: AppTextStyles.bodySm.copyWith(
                color: fg,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu skor kepercayaan dengan progress bar animasi dan skala anti-overflow.
class ConfidenceCard extends StatelessWidget {
  final ClassificationResult result;

  const ConfidenceCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final confPercent = (result.confidence * 100).toInt();
    final confLabel = confPercent >= 85
        ? 'OPTIMAL'
        : confPercent >= 50
            ? 'SEDANG'
            : 'RENDAH';
    final clampedConf = result.confidence.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
        boxShadow: [AppShadows.softSm()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: result.statusSoftColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: result.statusInkColor,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'KEPERCAYAAN: ${result.confidencePercent}',
                  style: AppTextStyles.labelLg.copyWith(
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: result.statusSoftColor,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  confLabel,
                  style: AppTextStyles.labelSm.copyWith(
                    color: result.statusInkColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Container(
              height: 14,
              color: AppColors.surfaceContainer,
              alignment: Alignment.centerLeft,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: clampedConf),
                duration: const Duration(milliseconds: 550),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: result.statusColor,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '0% TIDAK PASTI',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '50% SEDANG',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '100% PASTI',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Kartu distribusi probabilitas per kelas (`fresh`, `half_fresh`, `spoiled`).
class ProbabilitiesCard extends StatelessWidget {
  final Map<String, double> probabilities;

  const ProbabilitiesCard({super.key, required this.probabilities});

  @override
  Widget build(BuildContext context) {
    const orderedKeys = ['fresh', 'half_fresh', 'spoiled'];
    final entries = <MapEntry<String, double>>[
      for (final key in orderedKeys)
        if (probabilities.containsKey(key)) MapEntry(key, probabilities[key]!),
      for (final entry in probabilities.entries)
        if (!orderedKeys.contains(entry.key)) entry,
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
        boxShadow: [AppShadows.softSm()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DISTRIBUSI PROBABILITAS',
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          ...entries.map((entry) {
            final label = AppConstants.labelDisplayNames[entry.key] ??
                entry.key.toUpperCase();
            final pct = (entry.value * 100).clamp(0.0, 100.0);
            final barColor = switch (entry.key) {
              'fresh' => AppColors.statusFresh,
              'half_fresh' => AppColors.statusHalf,
              'spoiled' => AppColors.statusSpoiled,
              _ => AppColors.tertiary,
            };

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${pct.toStringAsFixed(1)}%',
                        style: AppTextStyles.labelSm.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: Container(
                      height: 8,
                      color: AppColors.surfaceContainer,
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: entry.value.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
