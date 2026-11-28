import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../widgets/vector_illustrations.dart';

/// Area viewfinder interaktif dengan reticle berdenyut & badge target pada CaptureScreen.
class CaptureViewfinder extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final VoidCallback onTap;

  const CaptureViewfinder({
    super.key,
    required this.pulseAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [AppShadows.softCard(color: AppColors.primaryDark)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: ScannerBackdropPainter()),
                Positioned(
                  top: 18,
                  left: 18,
                  child: _buildBracket(true, true),
                ),
                Positioned(
                  top: 18,
                  right: 18,
                  child: _buildBracket(true, false),
                ),
                Positioned(
                  bottom: 18,
                  left: 18,
                  child: _buildBracket(false, true),
                ),
                Positioned(
                  bottom: 18,
                  right: 18,
                  child: _buildBracket(false, false),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        boxShadow: [AppShadows.softSm()],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.gps_fixed_rounded,
                            size: 15,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'TARGET: DAGING',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: ScaleTransition(
                    scale: pulseAnimation,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.14),
                        border: Border.all(
                          color: AppColors.accent,
                          width: 2.5,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent,
                          ),
                          child: const Icon(
                            Icons.center_focus_weak_rounded,
                            size: 24,
                            color: AppColors.onAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        'Ketuk area ini untuk buka kamera',
                        style: AppTextStyles.labelSm.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBracket(bool isTop, bool isLeft) {
    const side = BorderSide(color: AppColors.accent, width: 3.5);
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: isTop && isLeft ? const Radius.circular(10) : Radius.zero,
          topRight: isTop && !isLeft ? const Radius.circular(10) : Radius.zero,
          bottomLeft:
              !isTop && isLeft ? const Radius.circular(10) : Radius.zero,
          bottomRight:
              !isTop && !isLeft ? const Radius.circular(10) : Radius.zero,
        ),
        border: Border(
          top: isTop ? side : BorderSide.none,
          bottom: !isTop ? side : BorderSide.none,
          left: isLeft ? side : BorderSide.none,
          right: !isLeft ? side : BorderSide.none,
        ),
      ),
    );
  }
}

/// Barisan chip tips pengambilan foto daging di bawah viewfinder.
class CaptureTipsRow extends StatelessWidget {
  const CaptureTipsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _CaptureTipChip(
          icon: Icons.wb_sunny_outlined,
          label: 'Cahaya Cukup',
        ),
        _CaptureTipChip(
          icon: Icons.center_focus_strong_outlined,
          label: 'Fokus Jelas',
        ),
        _CaptureTipChip(
          icon: Icons.straighten_rounded,
          label: 'Jarak 15–30 cm',
        ),
      ],
    );
  }
}

class _CaptureTipChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CaptureTipChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.tertiaryDark),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
