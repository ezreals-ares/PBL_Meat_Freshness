import 'package:flutter/material.dart';
import '../../core/theme.dart';

class HomeScreen extends StatelessWidget {
  /// Dipanggil oleh ShellScreen untuk navigasi ke tab lain (0=Beranda, 1=Pindai, 2=Riwayat).
  final void Function(int tabIndex)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              _buildAppBar(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    _buildHeroBanner(),
                    const SizedBox(height: AppSpacing.md),
                    _buildStartCheckButton(context),
                    const SizedBox(height: AppSpacing.md),
                    _buildQuickActions(),
                    const SizedBox(height: AppSpacing.md),
                    _buildSafetyDisclaimer(),
                    const SizedBox(height: AppSpacing.md),
                    _buildStorageRecommendation(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── APP BAR ──────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.margin, AppSpacing.sm, AppSpacing.margin, 0),
      child: Row(
        children: [
          // Logo placeholder
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.borderDefault, width: 2),
            ),
            child: const Icon(Icons.restaurant, color: Colors.white, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MEATFRESH AI',
                  style: AppTextStyles.headlineSm
                      .copyWith(letterSpacing: 0.5, fontSize: 18)),
              Text('BERANDA',
                  style: AppTextStyles.labelSm
                      .copyWith(color: AppColors.textSecondary, letterSpacing: 1.5)),
            ],
          ),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: const Icon(Icons.person, color: AppColors.onPrimary, size: 18),
          ),
        ],
      ),
    );
  }

  // ─── HERO BANNER ──────────────────────────────────────────
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderDefault, width: 2.5),
        boxShadow: [AppShadows.hard()],
      ),
      child: Stack(
        children: [
          // Lingkaran dekoratif
          Positioned(
            right: -24,
            bottom: -24,
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.statusFresh.withValues(alpha: 0.3),
                border: Border.all(color: AppColors.borderDefault, width: 2.5),
              ),
              child: Icon(Icons.verified, size: 64,
                  color: AppColors.borderDefault.withValues(alpha: 0.2)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text(
                'CEK KESEGARAN\nDAGING KAMU',
                style: AppTextStyles.headlineLgMobile.copyWith(
                  color: AppColors.onPrimary,
                  shadows: [
                    const Shadow(offset: Offset(1, 1), color: AppColors.borderDefault),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Analisis visual kesegaran daging secara instan langsung dari kamera.',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── TOMBOL MULAI CEK ─────────────────────────────────────
  Widget _buildStartCheckButton(BuildContext context) {
    return _PressableCard(
      color: AppColors.primaryContainer,
      borderWidth: 3,
      height: 64,
      onTap: () => onNavigateToTab?.call(1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.borderDefault, width: 2),
                boxShadow: [AppShadows.hardSmall()],
              ),
              child: const Icon(Icons.photo_camera, color: AppColors.textPrimary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MULAI CEK',
                      style: AppTextStyles.headlineSm.copyWith(
                          color: AppColors.onPrimary, fontSize: 18, letterSpacing: 0.8)),
                  Text('PINDAI DENGAN KAMERA',
                      style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onPrimary.withValues(alpha: 0.85),
                          letterSpacing: 1.0)),
                ],
              ),
            ),
            Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.borderDefault,
              ),
              child: const Icon(Icons.arrow_forward, color: AppColors.bgSurface, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  // ─── AKSI CEPAT ───────────────────────────────────────────
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _PressableCard(
            color: AppColors.bgSurface,
            height: 52,
            onTap: () => onNavigateToTab?.call(2),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryFixed,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderDefault, width: 1.5),
                    ),
                    child: const Icon(Icons.history, size: 16, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RIWAYAT', style: AppTextStyles.labelMd.copyWith(letterSpacing: 0.8)),
                      Text('SEMUA SCAN', style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PressableCard(
            color: AppColors.bgSurface,
            height: 52,
            onTap: () => onNavigateToTab?.call(1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryFixed,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderDefault, width: 1.5),
                    ),
                    child: const Icon(Icons.upload_file, size: 16, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('UNGGAH', style: AppTextStyles.labelMd.copyWith(letterSpacing: 0.8)),
                      Text('DARI GALERI', style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── PERINGATAN KEAMANAN ──────────────────────────────────
  Widget _buildSafetyDisclaimer() {
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
          const Icon(Icons.warning, color: AppColors.textPrimary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'APLIKASI INI MEMBANTU, NAMUN TIDAK MENGGANTIKAN INSPEKSI KEAMANAN PANGAN RESMI. SELALU CEK BAU, TEKSTUR, DAN SUHU PENYIMPANAN.',
              style: AppTextStyles.labelMd.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── REKOMENDASI PENYIMPANAN ──────────────────────────────────
  Widget _buildStorageRecommendation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderDefault, width: 2),
        boxShadow: [AppShadows.hardSmall()],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondaryFixed,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.borderDefault, width: 1.5),
            ),
            child: const Icon(Icons.kitchen, color: AppColors.textPrimary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('REKOMENDASI PENYIMPANAN',
                    style: AppTextStyles.labelMd.copyWith(letterSpacing: 0.8)),
                const SizedBox(height: 4),
                Text(
                  'Daging sapi segar? Simpan di chiller < 4°C (1-2 hari). Bekukan di freezer untuk penyimpanan lebih lama (4-12bulan).',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ─── PRESSABLE CARD HELPER ──────────────────────────────────
class _PressableCard extends StatefulWidget {
  final Color color;
  final double borderWidth;
  final double? height;
  final VoidCallback onTap;
  final Widget child;

  const _PressableCard({
    required this.color,
    this.borderWidth = 2.5,
    this.height,
    required this.onTap,
    required this.child,
  });

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
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
        height: widget.height,
        transform: _pressed
            ? Matrix4.translationValues(2.0, 2.0, 0.0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderDefault, width: widget.borderWidth),
          boxShadow: [_pressed ? AppShadows.hardSmall() : AppShadows.hard()],
        ),
        child: widget.child,
      ),
    );
  }
}
