import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

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
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.margin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tampilan gambar — ~60% ruang yang tersedia
                    Expanded(
                      flex: 6,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          border: Border.all(
                              color: AppColors.borderDefault, width: 3.0),
                          borderRadius:
                              BorderRadius.circular(AppRadius.lg),
                          boxShadow: [AppShadows.hard()],
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppRadius.lg - 3.0),
                          child: Image.file(
                            File(widget.imagePath),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (ctx, err, st) => const Center(
                              child: Icon(Icons.broken_image,
                                  size: 64,
                                  color: AppColors.surfaceContainer),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Keterangan panduan
                    Text(
                      'Pastikan daging terlihat jelas dan pencahayaan cukup.',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    // Tombol aksi
                    _PressableButton(
                      text: 'PILIH FOTO LAIN',
                      icon: Icons.photo_library,
                      isPrimary: false,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _PressableButton(
                      text: 'ANALISIS',
                      icon: Icons.science,
                      isPrimary: true,
                      onPressed: widget.onAnalyze,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.margin, vertical: AppSpacing.sm),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(Icons.arrow_back,
                  color: AppColors.textPrimary, size: 24),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.borderDefault, width: 2),
            ),
            child:
                const Icon(Icons.restaurant, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Text('PRATINJAU FOTO', style: AppTextStyles.headlineSm),
          const Spacer(),
        ],
      ),
    );
  }
}

// ─── PRESSABLE BUTTON ───────────────────────────────────────
class _PressableButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _PressableButton({
    required this.text,
    required this.icon,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
            _isPressed ? 2.0 : 0.0, _isPressed ? 2.0 : 0.0, 0.0),
        height: 56,
        decoration: BoxDecoration(
          color: widget.isPrimary
              ? AppColors.primaryContainer
              : AppColors.bgSurface,
          border: Border.all(
              color: AppColors.borderDefault,
              width: widget.isPrimary ? 3.0 : 2.5),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            _isPressed ? AppShadows.hardSmall() : AppShadows.hard(),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon,
                size: 20,
                color: widget.isPrimary
                    ? AppColors.onPrimary
                    : AppColors.textPrimary),
            const SizedBox(width: 8),
            Text(
              widget.text,
              style: AppTextStyles.labelLg.copyWith(
                color: widget.isPrimary
                    ? AppColors.onPrimary
                    : AppColors.textPrimary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
