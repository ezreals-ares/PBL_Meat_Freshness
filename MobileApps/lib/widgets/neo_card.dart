import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Reusable Neobrutalist card with hard offset shadow and thick border.
class NeoCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final double borderWidth;
  final double borderRadius;
  final double shadowX;
  final double shadowY;
  final VoidCallback? onTap;

  const NeoCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.borderWidth = 2.5,
    this.borderRadius = AppRadius.lg,
    this.shadowX = 4,
    this.shadowY = 4,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.bgSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.borderDefault, width: borderWidth),
        boxShadow: [AppShadows.hard(x: shadowX, y: shadowY)],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
