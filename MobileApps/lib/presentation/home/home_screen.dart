import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';

class HomeScreen extends StatelessWidget {
  /// Dipanggil oleh ShellScreen untuk navigasi ke tab lain (0=Beranda, 1=Pindai, 2=Riwayat).
  final void Function(int tabIndex)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.bgCanvas,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildGreetingAppBar(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      _buildHeroCard(context),
                      const SizedBox(height: AppSpacing.lg),
                      _buildSectionHeader(
                        title: 'Aksi Cepat',
                        badgeText: 'INSTAN',
                      ),
                      const SizedBox(height: 12),
                      _buildQuickActions(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildSectionHeader(
                        title: 'Panduan & Keamanan',
                        badgeText: 'TIPS',
                      ),
                      const SizedBox(height: 12),
                      _buildStorageRecommendation(),
                      const SizedBox(height: 12),
                      _buildSafetyDisclaimer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── GREETING APP BAR (Terinspirasi Screen 2 Design Guide) ──
  Widget _buildGreetingAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margin,
        AppSpacing.md,
        AppSpacing.margin,
        4,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: [AppShadows.glow(AppColors.accent, alpha: 0.30)],
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              color: AppColors.onAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'MEATFRESH AI',
                  style: AppTextStyles.headlineSm.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          _IconCircleAction(
            icon: Icons.history_rounded,
            tooltip: 'Buka Riwayat',
            onTap: () => onNavigateToTab?.call(2),
          ),
        ],
      ),
    );
  }

  // ─── HERO FULL FRESH MEAT + RED GRADIENT CTA CARD ──────────
  Widget _buildHeroCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.meatRedLight,
            AppColors.meatRed,
            AppColors.meatRedDark,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [AppShadows.glow(AppColors.meatRed, alpha: 0.30)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Full-bleed fresh meat photo with seamless red gradient blend
            SizedBox(
              height: 178,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/hero_fresh_meat.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.meatRedLight,
                            AppColors.meatRedDark,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Soft top vignette + seamless bottom gradient into meat-red body
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.22),
                            Colors.transparent,
                            AppColors.meatRed.withValues(alpha: 0.65),
                            AppColors.meatRed,
                          ],
                          stops: const [0.0, 0.40, 0.80, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.42),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'AI VISION READY',
                            style: AppTextStyles.labelSm.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Meat-Red Gradient Hero Body + Golden Amber (#FDC323) Arrow CTA
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.meatRed,
                    AppColors.meatRedDark,
                  ],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CEK KESEGARAN\nDAGING KAMU',
                    style: AppTextStyles.headlineLgMobile.copyWith(
                      color: AppColors.onPrimary,
                      fontSize: 22,
                      height: 1.22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Analisis visual kesegaran daging secara instan langsung dari kamera.',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.88),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MeatRedStartCta(
                    onTap: () => onNavigateToTab?.call(1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── SECTION HEADER ────────────────────────────────────────
  Widget _buildSectionHeader({
    required String title,
    required String badgeText,
  }) {
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

  // ─── AKSI CEPAT (2-Column Elevated Cards) ──────────────────
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _QuickFeatureCard(
            title: 'RIWAYAT',
            subtitle: 'SEMUA SCAN',
            icon: Icons.history_rounded,
            bannerColor: AppColors.secondaryFixed,
            iconBgColor: AppColors.secondary,
            iconColor: Colors.white,
            accentDotColor: AppColors.tertiary,
            onTap: () => onNavigateToTab?.call(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickFeatureCard(
            title: 'UNGGAH',
            subtitle: 'DARI GALERI',
            icon: Icons.photo_library_rounded,
            bannerColor: AppColors.accentSoft,
            iconBgColor: AppColors.accent,
            iconColor: AppColors.onAccent,
            accentDotColor: AppColors.primary,
            onTap: () => onNavigateToTab?.call(1),
          ),
        ),
      ],
    );
  }

  // ─── REKOMENDASI PENYIMPANAN ───────────────────────────────
  Widget _buildStorageRecommendation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
        boxShadow: [AppShadows.softSm()],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.tertiaryFixed,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.kitchen_rounded,
              color: AppColors.tertiaryDark,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REKOMENDASI PENYIMPANAN',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Daging sapi segar? Simpan di chiller < 4°C (1-2 hari). Bekukan di freezer untuk penyimpanan lebih lama (4-12 bulan).',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _TempChip(
                      icon: Icons.ac_unit_rounded,
                      label: 'Chiller < 4°C',
                      bgColor: AppColors.secondaryFixed,
                      fgColor: AppColors.secondaryDark,
                    ),
                    _TempChip(
                      icon: Icons.severe_cold_rounded,
                      label: 'Freezer -18°C',
                      bgColor: AppColors.tertiaryFixed,
                      fgColor: AppColors.tertiaryDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── PERINGATAN KEAMANAN ───────────────────────────────────
  Widget _buildSafetyDisclaimer() {
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.onAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catatan Keamanan Pangan',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.amberInk,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Aplikasi ini membantu, namun tidak menggantikan INSPEKSI KEAMANAN PANGAN resmi. Selalu cek bau, tekstur, dan suhu penyimpanan.',
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

// ─── MEAT-RED HERO CTA BAR WITH GOLDEN CIRCLE ARROW ─────────
class _MeatRedStartCta extends StatefulWidget {
  final VoidCallback onTap;

  const _MeatRedStartCta({required this.onTap});

  @override
  State<_MeatRedStartCta> createState() => _MeatRedStartCtaState();
}

class _MeatRedStartCtaState extends State<_MeatRedStartCta> {
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
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.meatRedDark,
                AppColors.meatRedDeep,
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MULAI CEK',
                      style: AppTextStyles.labelLg.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'PINDAI DENGAN KAMERA',
                      style: AppTextStyles.labelSm.copyWith(
                        color: Colors.white.withValues(alpha: 0.80),
                        fontSize: 10.5,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: [AppShadows.glow(AppColors.accent, alpha: 0.35)],
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
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
}

// ─── QUICK FEATURE CARD ─────────────────────────────────────
class _QuickFeatureCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bannerColor;
  final Color iconBgColor;
  final Color iconColor;
  final Color accentDotColor;
  final VoidCallback onTap;

  const _QuickFeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bannerColor,
    required this.iconBgColor,
    required this.iconColor,
    required this.accentDotColor,
    required this.onTap,
  });

  @override
  State<_QuickFeatureCard> createState() => _QuickFeatureCardState();
}

class _QuickFeatureCardState extends State<_QuickFeatureCard> {
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderSubtle, width: 1),
            boxShadow: [AppShadows.softSm()],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mini visual header mimicking design-guide cards
              Container(
                height: 62,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.bannerColor,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -12,
                      bottom: -14,
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.accentDotColor.withValues(alpha: 0.16),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 11,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: widget.iconBgColor,
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: [
                            AppShadows.glow(widget.iconBgColor, alpha: 0.25)
                          ],
                        ),
                        child: Icon(
                          widget.icon,
                          size: 21,
                          color: widget.iconColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.title,
                style: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.subtitle,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconCircleAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _IconCircleAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.bgSurface,
        shape: const CircleBorder(),
        elevation: 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderSubtle, width: 1),
              boxShadow: [AppShadows.softSm()],
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 21),
          ),
        ),
      ),
    );
  }
}

class _TempChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color fgColor;

  const _TempChip({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.fgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fgColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
