import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../domain/models/classification_result.dart';

/// Layar Hasil — menampilkan hasil klasifikasi setelah analisis.
///
/// Menerima [ClassificationResult] dengan data asli dari alur pindai.
class ResultScreen extends StatelessWidget {
  final ClassificationResult result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.margin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildScanIdBar(),
                    const SizedBox(height: AppSpacing.md),
                    _buildImagePreview(),
                    const SizedBox(height: AppSpacing.md),
                    _buildVerdictCard(),
                    const SizedBox(height: AppSpacing.md),
                    _buildConfidenceCard(),
                    if (result.isLowConfidence) ...[
                      const SizedBox(height: AppSpacing.md),
                      _buildLowConfidenceWarning(),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    _buildSafetyNotice(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildActionButtons(context),
                    const SizedBox(height: AppSpacing.lg),
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
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.margin, vertical: AppSpacing.sm),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(Icons.arrow_back,
                  color: AppColors.textPrimary, size: 24),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.borderDefault, width: 2),
            ),
            child:
                const Icon(Icons.restaurant, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Text('HASIL PINDAI', style: AppTextStyles.headlineSm),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: const Icon(Icons.person,
                color: AppColors.onPrimary, size: 18),
          ),
        ],
      ),
    );
  }

  // ─── SCAN ID BAR ──────────────────────────────────────────
  Widget _buildScanIdBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: AppColors.borderDefault, width: 2),
            boxShadow: [AppShadows.hardSmall()],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: result.statusColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'PINDAI #MF-${result.id ?? 0}',
                style: AppTextStyles.labelMd,
              ),
            ],
          ),
        ),
        Text('BARU SAJA',
            style: AppTextStyles.labelMd
                .copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  // ─── IMAGE PREVIEW ────────────────────────────────────────
  Widget _buildImagePreview() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderDefault, width: 3),
        boxShadow: [AppShadows.hard()],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg - 3),
        child: SizedBox(
          height: 210,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Gambar
              Image.file(
                File(result.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => Container(
                  color: AppColors.surfaceContainerHigh,
                  child: const Center(
                    child: Icon(Icons.broken_image,
                        size: 64, color: AppColors.surfaceContainer),
                  ),
                ),
              ),
              // Gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.borderDefault.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
              ),
              // Badge kiri atas
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(6),
                    border:
                        Border.all(color: AppColors.borderDefault, width: 2),
                    boxShadow: [AppShadows.hardSmall()],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.center_focus_strong,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text('PINDAI PERMUKAAN SELESAI',
                          style: AppTextStyles.labelSm
                              .copyWith(letterSpacing: 0.8)),
                    ],
                  ),
                ),
              ),
              // Teks kiri bawah
              Positioned(
                bottom: 12,
                left: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SPESIMEN TERIDENTIFIKASI',
                        style: AppTextStyles.labelSm.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 2)),
                    Text(
                      result.meatType?.toUpperCase() ?? 'SAMPEL DAGING',
                      style: AppTextStyles.headlineSm
                          .copyWith(color: Colors.white),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: result.statusColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderDefault, width: 3.5),
        boxShadow: [AppShadows.hardLarge()],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border:
                  Border.all(color: AppColors.borderDefault, width: 2.5),
              boxShadow: [AppShadows.hardSmall()],
            ),
            child: Icon(result.statusIcon,
                color: AppColors.textPrimary, size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HASIL ANALISIS',
                    style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.textPrimary.withValues(alpha: 0.8),
                        letterSpacing: 1.5)),
                Text(
                  '${result.statusEmoji} ${result.displayName}',
                  style: AppTextStyles.headlineLgMobile.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderDefault, width: 2.5),
        boxShadow: [AppShadows.hard()],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.analytics,
                  color: AppColors.textPrimary, size: 20),
              const SizedBox(width: 8),
              Text('KEPERCAYAAN: ${result.confidencePercent}',
                  style: AppTextStyles.labelLg
                      .copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: result.statusColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                  border:
                      Border.all(color: AppColors.borderDefault, width: 1.5),
                ),
                child: Text(confLabel,
                    style: AppTextStyles.labelSm
                        .copyWith(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          Container(
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(6),
              border:
                  Border.all(color: AppColors.borderDefault, width: 2.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: result.confidence,
                    child: Container(
                      decoration: BoxDecoration(
                        color: result.statusColor,
                        border: const Border(
                          right: BorderSide(
                              color: AppColors.borderDefault, width: 2.5),
                        ),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(result.confidencePercent,
                          style: AppTextStyles.labelSm
                              .copyWith(fontWeight: FontWeight.w900)),
                    ),
                  ),
                  // Pembagi segmen
                  Row(
                    children: List.generate(
                      4,
                      (i) => Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: i < 3
                                ? Border(
                                    right: BorderSide(
                                      color: AppColors.borderDefault
                                          .withValues(alpha: 0.4),
                                      width: 1.5,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0% TIDAK PASTI',
                  style: AppTextStyles.labelSm
                      .copyWith(color: AppColors.textSecondary)),
              Text('50% SEDANG',
                  style: AppTextStyles.labelSm
                      .copyWith(color: AppColors.textSecondary)),
              Text('100% PASTI',
                  style: AppTextStyles.labelSm
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── LOW CONFIDENCE WARNING ───────────────────────────────
  Widget _buildLowConfidenceWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderDefault, width: 2),
        boxShadow: [AppShadows.hardSmall()],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber,
              color: AppColors.textPrimary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '⚠️ KEPERCAYAAN RENDAH — Coba ambil ulang foto dengan pencahayaan yang lebih baik.',
              style: AppTextStyles.labelMd
                  .copyWith(fontWeight: FontWeight.w700, height: 1.4),
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
        border: Border.all(color: AppColors.borderDefault, width: 2),
        boxShadow: [AppShadows.hardMedium()],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.borderDefault,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.warning,
                color: AppColors.bgSurface, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CATATAN KEAMANAN',
                    style: AppTextStyles.labelSm.copyWith(
                        fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                const SizedBox(height: 2),
                Text(AppConstants.disclaimer,
                    style: AppTextStyles.bodySm),
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
            icon: Icons.photo_camera,
            iconFirst: true,
            color: AppColors.bgSurface,
            onTap: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ResultButton(
            label: 'SELESAI',
            icon: Icons.check_circle,
            iconFirst: false,
            color: AppColors.primaryContainer,
            textColor: AppColors.onPrimary,
            onTap: () {
              // Kembali ke shell (beranda)
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ),
      ],
    );
  }
}

// ─── RESULT BUTTON ──────────────────────────────────────────
class _ResultButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool iconFirst;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _ResultButton({
    required this.label,
    required this.icon,
    required this.iconFirst,
    required this.color,
    this.textColor = AppColors.textPrimary,
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
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
            _pressed ? 2 : 0, _pressed ? 2 : 0, 0),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border:
              Border.all(color: AppColors.borderDefault, width: 2.5),
          boxShadow: [
            _pressed ? AppShadows.hardSmall() : AppShadows.hardMedium()
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.iconFirst
              ? [
                  Icon(widget.icon, size: 20, color: widget.textColor),
                  const SizedBox(width: 6),
                  Text(widget.label,
                      style: AppTextStyles.labelLg.copyWith(
                          color: widget.textColor, letterSpacing: 1)),
                ]
              : [
                  Text(widget.label,
                      style: AppTextStyles.labelLg.copyWith(
                          color: widget.textColor, letterSpacing: 1)),
                  const SizedBox(width: 6),
                  Icon(widget.icon, size: 20, color: widget.textColor),
                ],
        ),
      ),
    );
  }
}
