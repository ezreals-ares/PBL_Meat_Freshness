import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';

/// Tombol modern dengan animasi scale lembut dan elevasi berwarna.
class NeoButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const NeoButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.borderWidth = 0,
    this.borderRadius = AppRadius.md,
    this.padding,
    this.width,
    this.height,
  });

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? AppColors.accent;
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 110),
          width: widget.width,
          height: widget.height,
          constraints: const BoxConstraints(minHeight: 48),
          padding: widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 12,
              ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.borderWidth > 0
                ? Border.all(
                    color: AppColors.borderSubtle,
                    width: widget.borderWidth,
                  )
                : null,
            boxShadow: _isPressed
                ? [AppShadows.softSm(color: bg)]
                : [AppShadows.glow(bg, alpha: 0.30)],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
