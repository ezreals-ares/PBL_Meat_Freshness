import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Indikator loading modern dengan kartu putih melayang & aksen ruby/amber.
class AppLoadingOverlay extends StatelessWidget {
  final String text;

  const AppLoadingOverlay({super.key, this.text = 'MENGANALISIS GAMBAR...'});

  // ─── Overlay management ───────────────────────────────────
  static OverlayEntry? _overlayEntry;

  /// Tampilkan loading overlay di atas layar aktif.
  static void show(
    BuildContext context, {
    String text = 'MENGANALISIS GAMBAR...',
  }) {
    if (_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: AppLoadingOverlay(text: text),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Sembunyikan loading overlay.
  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.textPrimary.withValues(alpha: 0.45),
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [AppShadows.softCard()],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.tertiary],
                ),
                shape: BoxShape.circle,
                boxShadow: [AppShadows.glow(AppColors.primary, alpha: 0.28)],
              ),
              padding: const EdgeInsets.all(16),
              child: const CircularProgressIndicator(
                strokeWidth: 3.5,
                color: AppColors.accent,
                backgroundColor: Color(0x33FFFFFF),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              text.toUpperCase(),
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: 0.8,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Mohon tunggu sebentar, AI sedang memeriksa warna dan tekstur daging.',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
