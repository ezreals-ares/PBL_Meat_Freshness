import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Kartu modern lembut dengan sudut membulat dan bayangan halus.
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
    this.borderWidth = 1.0,
    this.borderRadius = AppRadius.lg,
    this.shadowX = 0,
    this.shadowY = 8,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.bgSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderWidth > 0
            ? Border.all(color: AppColors.borderSubtle, width: borderWidth)
            : null,
        boxShadow: [AppShadows.softCard()],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
