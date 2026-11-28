import 'package:flutter/material.dart';
import '../../../domain/models/classification_result.dart';
import '../../theme/result_ui_ext.dart';
import '../../theme/theme.dart';
import 'result_action_button.dart';
import 'result_image_preview.dart';

/// Tampilan khusus saat backend menandai gambar sebagai objek non-daging (`isMeat == false`).
class NonMeatRejectionView extends StatelessWidget {
  final ClassificationResult result;

  const NonMeatRejectionView({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final reason = (result.rejectionReason?.trim().isNotEmpty ?? false)
        ? result.rejectionReason!.trim()
        : 'Objek daging tidak terdeteksi dengan jelas pada gambar. '
            'Arahkan kamera lebih dekat ke permukaan daging dengan pencahayaan cukup.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 8,
          spacing: 8,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.tertiaryFixed,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.history_toggle_off_rounded,
                    size: 14,
                    color: AppColors.tertiaryDark,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'TIDAK DISIMPAN KE RIWAYAT',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.tertiaryDark,
                        fontWeight: FontWeight.w800,
                      ),
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
                  Flexible(
                    child: Text(
                      'MODEL: ${result.modelDisplayName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ResultImagePreview(
          imagePath: result.imagePath,
          meatType: result.meatType,
          badgeText: 'OBJEK TIDAK VALID',
          captionTitle: 'STATUS VALIDASI',
          specimenText: 'BUKAN OBJEK DAGING',
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.tertiary,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [AppShadows.glow(AppColors.tertiary, alpha: 0.28)],
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
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.image_not_supported_rounded,
                      color: AppColors.onAccent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VALIDASI GAMBAR',
                          style: AppTextStyles.labelSm.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'OBJEK BUKAN DAGING',
                          style: AppTextStyles.headlineLgMobile.copyWith(
                            color: Colors.white,
                            fontSize: 21,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  reason,
                  style: AppTextStyles.bodySm.copyWith(
                    color: Colors.white,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
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
                'TIPS MENGAMBIL FOTO DAGING',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              const _RejectionTipRow(
                icon: Icons.center_focus_strong_rounded,
                text:
                    'Arahkan kamera dekat ke permukaan daging (jarak 15–30 cm).',
              ),
              const SizedBox(height: 8),
              const _RejectionTipRow(
                icon: Icons.wb_sunny_outlined,
                text:
                    'Pastikan pencahayaan terang & merata tanpa bayangan gelap.',
              ),
              const SizedBox(height: 8),
              const _RejectionTipRow(
                icon: Icons.crop_free_rounded,
                text:
                    'Hindari objek latar belakang mendominasi sebagian besar frame.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: ResultActionButton(
                label: 'SELESAI',
                icon: Icons.home_outlined,
                iconFirst: true,
                color: AppColors.bgSurface,
                textColor: AppColors.textPrimary,
                outlined: true,
                onTap: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ResultActionButton(
                label: 'AMBIL ULANG FOTO',
                icon: Icons.photo_camera_rounded,
                iconFirst: true,
                color: AppColors.accent,
                textColor: AppColors.onAccent,
                outlined: false,
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RejectionTipRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _RejectionTipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
