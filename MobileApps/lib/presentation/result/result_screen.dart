import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../../core/constants.dart';
import '../theme/result_ui_ext.dart';
import '../../domain/models/classification_result.dart';

/// Layar Hasil — menampilkan hasil klasifikasi setelah analisis dengan hierarki modern.
class ResultScreen extends StatelessWidget {
  final ClassificationResult result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bgCanvas,
        body: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  AppSpacing.md,
                  AppSpacing.margin,
                  28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildScanIdBar(),
                    const SizedBox(height: 12),
                    _buildImagePreview(),
                    const SizedBox(height: 14),
                    _buildVerdictCard(),
                    const SizedBox(height: 14),
                    _buildConfidenceCard(),
                    if (result.probabilities != null &&
                        result.probabilities!.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _buildProbabilitiesCard(),
                    ],
                    if (result.segmentationFallback == true) ...[
                      const SizedBox(height: 14),
                      _buildSegmentationFallbackNotice(),
                    ],
                    if (result.isLowConfidence) ...[
                      const SizedBox(height: 14),
                      _buildLowConfidenceWarning(),
                    ],
                    const SizedBox(height: 14),
                    _buildSafetyNotice(),
                    const SizedBox(height: 22),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── APP BAR ──────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.tertiary,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.lg),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, AppSpacing.margin, 14),
          child: Row(
            children: [
              Material(
                color: Colors.white.withValues(alpha: 0.18),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.pop(context),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'HASIL PINDAI',
                  style: AppTextStyles.headlineSm.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant_menu_rounded,
                  color: AppColors.onAccent,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── SCAN ID & MODEL BAR ──────────────────────────────────
  Widget _buildScanIdBar() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 8,
      spacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: AppColors.borderSubtle, width: 1),
            boxShadow: [AppShadows.softSm()],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: result.statusColor,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                'PINDAI #MF-${result.id ?? 0}',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondaryFixed,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.memory_rounded,
                size: 14,
                color: AppColors.secondaryDark,
              ),
              const SizedBox(width: 5),
              Text(
                'MODEL: ${result.modelDisplayName}',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── IMAGE PREVIEW ────────────────────────────────────────
  Widget _buildImagePreview() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [AppShadows.softCard()],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: SizedBox(
          height: 215,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(result.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => Container(
                  color: AppColors.surfaceContainer,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      size: 56,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.08),
                        Colors.transparent,
                        AppColors.textPrimary.withValues(alpha: 0.72),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
              // Frosted top-left status badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.center_focus_strong_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'PINDAI PERMUKAAN SELESAI',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom specimen label
              Positioned(
                bottom: 14,
                left: 14,
                right: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SPESIMEN TERIDENTIFIKASI',
                      style: AppTextStyles.labelSm.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 1.4,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      result.meatType?.toUpperCase() ?? 'SAMPEL DAGING',
                      style: AppTextStyles.headlineSm.copyWith(
                        color: Colors.white,
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── VERDICT CARD ─────────────────────────────────────────
  Widget _buildVerdictCard() {
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

  // ─── CONFIDENCE CARD ──────────────────────────────────────
  Widget _buildConfidenceCard() {
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

  // ─── PROBABILITIES BREAKDOWN ──────────────────────────────
  Widget _buildProbabilitiesCard() {
    final probs = result.probabilities!;
    const orderedKeys = ['fresh', 'half_fresh', 'spoiled'];
    final entries = <MapEntry<String, double>>[
      for (final key in orderedKeys)
        if (probs.containsKey(key)) MapEntry(key, probs[key]!),
      for (final entry in probs.entries)
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

  // ─── SEGMENTATION FALLBACK NOTICE ─────────────────────────
  Widget _buildSegmentationFallbackNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryFixed,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.secondaryDark,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'INFO SVM — Area daging sulit dipisahkan dari latar, analisis dilakukan pada seluruh frame gambar.',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.onSecondaryContainer,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── LOW CONFIDENCE WARNING ───────────────────────────────
  Widget _buildLowConfidenceWarning() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.amberInk,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'KEPERCAYAAN RENDAH — Coba ambil ulang foto dengan pencahayaan yang lebih baik.',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.amberInk,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SAFETY NOTICE ────────────────────────────────────────
  Widget _buildSafetyNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
                  'CATATAN KEAMANAN',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.amberInk,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  AppConstants.disclaimer,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.amberInk,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── ACTION BUTTONS ───────────────────────────────────────
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ResultButton(
            label: 'PINDAI LAGI',
            icon: Icons.photo_camera_outlined,
            iconFirst: true,
            color: AppColors.bgSurface,
            textColor: AppColors.textPrimary,
            outlined: true,
            onTap: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ResultButton(
            label: 'SELESAI',
            icon: Icons.check_circle_rounded,
            iconFirst: false,
            color: AppColors.accent,
            textColor: AppColors.onAccent,
            outlined: false,
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ),
      ],
    );
  }
}

class _ResultButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool iconFirst;
  final Color color;
  final Color textColor;
  final bool outlined;
  final VoidCallback onTap;

  const _ResultButton({
    required this.label,
    required this.icon,
    required this.iconFirst,
    required this.color,
    required this.textColor,
    required this.outlined,
    required this.onTap,
  });

  @override
  State<_ResultButton> createState() => _ResultButtonState();
}

class _ResultButtonState extends State<_ResultButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: widget.outlined
                ? Border.all(color: AppColors.borderDefault, width: 1.2)
                : null,
            boxShadow: [
              widget.outlined
                  ? AppShadows.softSm()
                  : AppShadows.glow(widget.color, alpha: 0.34),
            ],
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.iconFirst
                    ? [
                        Icon(widget.icon, size: 19, color: widget.textColor),
                        const SizedBox(width: 6),
                        Text(
                          widget.label,
                          style: AppTextStyles.labelLg.copyWith(
                            color: widget.textColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ]
                    : [
                        Text(
                          widget.label,
                          style: AppTextStyles.labelLg.copyWith(
                            color: widget.textColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(widget.icon, size: 19, color: widget.textColor),
                      ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
