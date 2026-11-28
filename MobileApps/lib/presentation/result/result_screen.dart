import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants.dart';
import '../../domain/models/classification_result.dart';
import '../theme/result_ui_ext.dart';
import '../theme/theme.dart';
import '../widgets/curved_app_bar.dart';
import '../widgets/safety_notice_card.dart';
import 'widgets/freshness_result_cards.dart';
import 'widgets/non_meat_rejection_view.dart';
import 'widgets/result_action_button.dart';
import 'widgets/result_image_preview.dart';

/// Layar Hasil — orkestrator tampilan hasil klasifikasi atau penolakan non-daging.
class ResultScreen extends StatelessWidget {
  final ClassificationResult result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isNonMeat = result.isNonMeat;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bgCanvas,
        body: Column(
          children: [
            CurvedAppBar(
              title: 'HASIL PINDAI',
              onBack: () => Navigator.pop(context),
              trailing: Container(
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
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  AppSpacing.md,
                  AppSpacing.margin,
                  28,
                ),
                child: isNonMeat
                    ? NonMeatRejectionView(result: result)
                    : _buildMeatResultContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeatResultContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildScanIdBar(),
        const SizedBox(height: 12),
        ResultImagePreview(
          imagePath: result.imagePath,
          meatType: result.meatType,
        ),
        const SizedBox(height: 14),
        VerdictCard(result: result),
        const SizedBox(height: 14),
        ConfidenceCard(result: result),
        if (result.probabilities != null &&
            result.probabilities!.isNotEmpty) ...[
          const SizedBox(height: 14),
          ProbabilitiesCard(probabilities: result.probabilities!),
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
        const SafetyNoticeCard(
          title: 'CATATAN KEAMANAN',
          message: AppConstants.disclaimer,
          uppercaseTitle: true,
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: ResultActionButton(
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
              child: ResultActionButton(
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
        ),
      ],
    );
  }

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
}
