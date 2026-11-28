import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../widgets/safety_notice_card.dart';
import 'widgets/home_hero_card.dart';
import 'widgets/home_section_cards.dart';

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
                      HomeHeroCard(
                        onStartCheck: () => onNavigateToTab?.call(1),
                      ),
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
                      const StorageRecommendationCard(),
                      const SizedBox(height: 12),
                      const SafetyNoticeCard(
                        title: 'Catatan Keamanan Pangan',
                        message:
                            'Aplikasi ini membantu, namun tidak menggantikan INSPEKSI KEAMANAN PANGAN resmi. Selalu cek bau, tekstur, dan suhu penyimpanan.',
                      ),
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
          HomeIconCircleAction(
            icon: Icons.history_rounded,
            tooltip: 'Buka Riwayat',
            onTap: () => onNavigateToTab?.call(2),
          ),
        ],
      ),
    );
  }

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

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: QuickFeatureCard(
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
          child: QuickFeatureCard(
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
}
