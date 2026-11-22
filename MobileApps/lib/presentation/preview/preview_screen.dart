import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../domain/models/prediction_model_type.dart';
import '../providers/scan_provider.dart';
import '../theme/result_ui_ext.dart';
import '../theme/theme.dart';

class PreviewScreen extends StatefulWidget {
  final String imagePath;
  final VoidCallback onAnalyze;

  const PreviewScreen({
    super.key,
    required this.imagePath,
    required this.onAnalyze,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  @override
  Widget build(BuildContext context) {
    final scanProvider = context.watch<ScanProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bgCanvas,
        body: Column(
          children: [
            _buildTopBar(),
            // Ruang gambar yang bersih & luas
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  AppSpacing.md,
                  AppSpacing.margin,
                  AppSpacing.md,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: [AppShadows.softCard()],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(widget.imagePath),
                          fit: BoxFit.cover,
                          width: double.infinity,
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
                        // Frosted bottom photo guidance pill
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.textPrimary.withValues(alpha: 0.72),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 16,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Pastikan daging terlihat jelas dan pencahayaan cukup.',
                                    style: AppTextStyles.bodySm.copyWith(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Floating bottom control sheet (Terinspirasi Screen 3 Design Guide)
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
                border: const Border(
                  top: BorderSide(color: AppColors.borderSubtle, width: 1),
                ),
                boxShadow: [AppShadows.navBar()],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.margin,
                    18,
                    AppSpacing.margin,
                    16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildModelSelector(scanProvider),
                      const SizedBox(height: 16),
                      _GoldenPrimaryButton(
                        text:
                            'ANALISIS (${scanProvider.selectedModel.shortName})',
                        icon: Icons.science_rounded,
                        onPressed: widget.onAnalyze,
                      ),
                      const SizedBox(height: 10),
                      _SecondaryGhostButton(
                        text: 'PILIH FOTO LAIN',
                        icon: Icons.photo_library_outlined,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
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
                  onTap: () => Navigator.of(context).pop(),
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
                  'PRATINJAU FOTO',
                  style: AppTextStyles.headlineSm.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'SIAP PINDAI',
                  style: AppTextStyles.labelSm.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModelSelector(ScanProvider scanProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PILIH MODEL AI',
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: PredictionModelType.values.map((model) {
            final isSelected = scanProvider.selectedModel == model;
            final isLast = model == PredictionModelType.values.last;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 10),
                child: _ModelOptionCard(
                  title: model.displayName,
                  subtitle: model.description,
                  icon: model == PredictionModelType.netv2
                      ? Icons.hub_rounded
                      : Icons.tune_rounded,
                  isSelected: isSelected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    scanProvider.selectModel(model);
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ModelOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModelOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft : AppColors.bgCanvas,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderSubtle,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.tertiaryDark,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMd.copyWith(
                      color: isSelected
                          ? AppColors.primaryDark
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoldenPrimaryButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _GoldenPrimaryButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_GoldenPrimaryButton> createState() => _GoldenPrimaryButtonState();
}

class _GoldenPrimaryButtonState extends State<_GoldenPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.mediumImpact();
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [AppShadows.glow(AppColors.accent, alpha: 0.35)],
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, size: 20, color: AppColors.onAccent),
                  const SizedBox(width: 8),
                  Text(
                    widget.text,
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.onAccent,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.onAccent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryGhostButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _SecondaryGhostButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 19, color: AppColors.textPrimary),
        label: Text(
          text,
          style: AppTextStyles.labelMd.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.bgCanvas,
          side: const BorderSide(color: AppColors.borderDefault, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }
}
