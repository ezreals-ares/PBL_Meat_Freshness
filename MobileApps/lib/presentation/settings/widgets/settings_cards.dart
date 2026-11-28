import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants.dart';
import '../../../domain/models/prediction_model_type.dart';
import '../../theme/result_ui_ext.dart';
import '../../theme/theme.dart';
import '../../widgets/pressable_scale.dart';
import '../../widgets/safety_notice_card.dart';

/// Status pengecekan koneksi server FastAPI pada halaman Pengaturan.
enum ServerCheckStatus { idle, checking, connected, error }

/// Header seksi pada halaman Pengaturan dengan judul dan badge kategori.
class SettingsSectionHeader extends StatelessWidget {
  final String title;
  final String badgeText;

  const SettingsSectionHeader({
    super.key,
    required this.title,
    required this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            title,
            style: AppTextStyles.headlineSm.copyWith(fontSize: 17),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            badgeText,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.primaryDark,
              fontSize: 10,
              letterSpacing: 0.7,
            ),
          ),
        ),
      ],
    );
  }
}

/// Kartu pemilih model AI bawaan (`MobileNetV2` vs `SVM`).
class DefaultModelCard extends StatelessWidget {
  final PredictionModelType selectedModel;
  final ValueChanged<PredictionModelType> onSelectModel;

  const DefaultModelCard({
    super.key,
    required this.selectedModel,
    required this.onSelectModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
        boxShadow: [AppShadows.softCard()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Model yang dipilih akan otomatis aktif saat Anda membuka pratinjau foto.',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          ...PredictionModelType.values.map((model) {
            final isSelected = selectedModel == model;
            final isLast = model == PredictionModelType.values.last;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
              child: PressableScale(
                pressedScale: 0.985,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelectModel(model);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primarySoft.withValues(alpha: 0.55)
                        : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderSubtle,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          model == PredictionModelType.netv2
                              ? Icons.hub_rounded
                              : Icons.tune_rounded,
                          size: 20,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              model.displayName,
                              style: AppTextStyles.labelMd.copyWith(
                                color: isSelected
                                    ? AppColors.primaryDark
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              model.description,
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 22,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Kartu status & cek koneksi server inferensi FastAPI (`/health`).
class ServerStatusCard extends StatelessWidget {
  final ServerCheckStatus status;
  final int? latencyMs;
  final String? errorMessage;
  final VoidCallback onCheck;

  const ServerStatusCard({
    super.key,
    required this.status,
    this.latencyMs,
    this.errorMessage,
    required this.onCheck,
  });

  @override
  Widget build(BuildContext context) {
    final (badgeBg, badgeFg, badgeText, statusDesc, icon) = switch (status) {
      ServerCheckStatus.checking => (
          AppColors.accentSoft,
          AppColors.amberInk,
          'MEMERIKSA...',
          'Menghubungi layanan inferensi FastAPI...',
          Icons.sync_rounded,
        ),
      ServerCheckStatus.connected => (
          AppColors.statusFreshSoft,
          AppColors.statusFreshInk,
          'TERHUBUNG (${latencyMs ?? 0} MS)',
          'Server AI siap menerima permintaan klasifikasi.',
          Icons.cloud_done_rounded,
        ),
      ServerCheckStatus.error => (
          AppColors.statusSpoiledSoft,
          AppColors.statusSpoiledInk,
          'TIDAK TERJANGKAU',
          errorMessage ?? 'Server belum merespons. Periksa koneksi Anda.',
          Icons.cloud_off_rounded,
        ),
      ServerCheckStatus.idle => (
          AppColors.surfaceContainer,
          AppColors.textSecondary,
          'BELUM DICEK',
          'Tes koneksi ke endpoint /health untuk memastikan server aktif.',
          Icons.dns_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
        boxShadow: [AppShadows.softCard()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: badgeFg, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        badgeText,
                        style: AppTextStyles.labelSm.copyWith(
                          color: badgeFg,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      statusDesc,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PressableScale(
            onTap: status == ServerCheckStatus.checking ? () {} : onCheck,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (status == ServerCheckStatus.checking)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  else
                    const Icon(
                      Icons.wifi_tethering_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    'CEK KONEKSI SERVER',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu status izin kamera & galeri perangkat + pintasan buka pengaturan sistem.
class DevicePermissionsCard extends StatelessWidget {
  final bool cameraGranted;
  final bool galleryGranted;
  final VoidCallback onRequestCamera;
  final VoidCallback onRequestGallery;
  final VoidCallback onOpenSystemSettings;

  const DevicePermissionsCard({
    super.key,
    required this.cameraGranted,
    required this.galleryGranted,
    required this.onRequestCamera,
    required this.onRequestGallery,
    required this.onOpenSystemSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
        boxShadow: [AppShadows.softCard()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PermissionRow(
            icon: Icons.camera_alt_rounded,
            title: 'Izin Kamera',
            subtitle: 'Untuk memotret daging secara langsung',
            isGranted: cameraGranted,
            onRequest: onRequestCamera,
          ),
          const Divider(height: 20, color: AppColors.borderSubtle),
          _PermissionRow(
            icon: Icons.photo_library_rounded,
            title: 'Izin Galeri / Foto',
            subtitle: 'Untuk mengunggah foto dari penyimpanan',
            isGranted: galleryGranted,
            onRequest: onRequestGallery,
          ),
          const SizedBox(height: 14),
          PressableScale(
            onTap: onOpenSystemSettings,
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.open_in_new_rounded,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'BUKA PENGATURAN SISTEM',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isGranted;
  final VoidCallback onRequest;

  const _PermissionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isGranted,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isGranted
                ? AppColors.statusFreshSoft
                : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isGranted ? AppColors.statusFresh : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (isGranted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.statusFreshSoft,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              'DIIZINKAN',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.statusFreshInk,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          )
        else
          GestureDetector(
            onTap: onRequest,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                'IZINKAN',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.amberInk,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Kartu panduan pengambilan foto akurat agar model AI bekerja optimal.
class PhotoGuideCard extends StatelessWidget {
  const PhotoGuideCard({super.key});

  static const _tips = [
    (
      Icons.wb_sunny_outlined,
      'Gunakan cahaya putih/netral dan hindari lampu kuning hangat berlebih.',
    ),
    (
      Icons.center_focus_strong_rounded,
      'Arahkan kamera berjarak 15–30 cm tepat pada permukaan daging.',
    ),
    (
      Icons.blur_off_rounded,
      'Pastikan foto tajam, tidak buram, dan bebas bayangan tangan.',
    ),
    (
      Icons.layers_clear_rounded,
      'Gunakan alas polos agar segmentasi area daging lebih akurat.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
        boxShadow: [AppShadows.softCard()],
      ),
      child: Column(
        children: [
          for (var i = 0; i < _tips.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryFixed,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    _tips[i].$1,
                    size: 16,
                    color: AppColors.secondaryDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _tips[i].$2,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Kartu informasi versi aplikasi, deskripsi model, dan disclaimer keamanan pangan.
class AboutAppCard extends StatelessWidget {
  const AboutAppCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.borderSubtle, width: 1),
            boxShadow: [AppShadows.softCard()],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      color: AppColors.onAccent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.appName,
                          style: AppTextStyles.headlineSm.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Versi 1.0.0 • MobileNetV2 & SVM',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Sistem deteksi awal kesegaran daging berbasis citra dengan dua pilihan model AI: MobileNetV2 (Deep Learning CNN) dan Support Vector Machine (ekstraksi fitur warna & tekstur).',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const SafetyNoticeCard(
          title: 'Disclaimer Keamanan Pangan',
          message: AppConstants.disclaimer,
        ),
      ],
    );
  }
}
