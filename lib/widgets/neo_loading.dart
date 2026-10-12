import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Neobrutalist loading indicator — chunky bordered spinner + bold text label.
///
/// Can be used as an inline widget in a Stack, or shown/hidden globally
/// using the static [show]/[hide] methods via Overlay.
class NeoLoading extends StatelessWidget {
  final String text;

  const NeoLoading({super.key, this.text = 'ANALYZING IMAGE...'});

  // ─── Overlay management ───────────────────────────────────
  static OverlayEntry? _overlayEntry;

  /// Show the loading overlay on top of the current screen.
  static void show(BuildContext context, {String text = 'ANALYZING IMAGE...'}) {
    if (_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: NeoLoading(text: text),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Hide the loading overlay.
  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgCanvas.withValues(alpha: 0.85),
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          border: Border.all(color: AppColors.borderDefault, width: 3.0),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [AppShadows.hard()],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Spinner in a bordered circle
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                border: Border.all(color: AppColors.borderDefault, width: 3.0),
                shape: BoxShape.circle,
                boxShadow: [AppShadows.hardSmall()],
              ),
              padding: const EdgeInsets.all(AppSpacing.sm + 2),
              child: const CircularProgressIndicator(
                strokeWidth: 4.0,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Bold label
            Text(
              text.toUpperCase(),
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Please wait while we process your image.',
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
