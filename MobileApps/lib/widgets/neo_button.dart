import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Neobrutalist button with press-down animation (translate + shadow shrink).
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
    this.borderWidth = 2.5,
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
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        height: widget.height,
        padding: widget.padding ??
            const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        transform: _isPressed
            ? Matrix4.translationValues(2.0, 2.0, 0.0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
              color: AppColors.borderDefault, width: widget.borderWidth),
          boxShadow: [
            _isPressed ? AppShadows.hardSmall() : AppShadows.hard()
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
