import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/format.dart';
import '../../../domain/models/classification_result.dart';
import '../../theme/result_ui_ext.dart';
import '../../theme/theme.dart';
import '../../widgets/status_badge.dart';

/// Kartu item riwayat scan daging dengan thumbnail hemat memori dan layout anti-overflow.
class HistoryCard extends StatelessWidget {
  final ClassificationResult item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onLongPress;

  const HistoryCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = formatScanTimestamp(item.createdAt);
    final statusColor = item.statusColor;
    final highlightSelected = isSelectionMode && isSelected;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: highlightSelected
              ? AppColors.primarySoft.withValues(alpha: 0.45)
              : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: highlightSelected ? AppColors.primary : AppColors.borderSubtle,
            width: highlightSelected ? 1.5 : 1,
          ),
          boxShadow: [AppShadows.softSm()],
        ),
        child: Row(
          children: [
            // Thumbnail rounded dengan decode asinkron & cacheWidth kecil
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(item.imagePath),
                      fit: BoxFit.cover,
                      cacheWidth: 160,
                      errorBuilder: (ctx, err, st) => const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 28,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(height: 5, color: statusColor),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Konten dengan Wrap anti-overflow pada layar sempit (360dp)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      StatusBadge.fromResult(item.result),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '${(item.confidence * 100).toInt()}% KEPERCAYAAN',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.meatType?.toUpperCase() ?? item.displayName,
                    style: AppTextStyles.headlineSm.copyWith(fontSize: 15.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeStr.toUpperCase(),
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (item.modelShortName.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryFixed,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            item.modelShortName,
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.secondaryDark,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Mode pilih: indikator centang; mode normal: tombol hapus ramah sentuh (>= 42x42)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: isSelectionMode
                  ? SizedBox(
                      key: ValueKey<bool>(isSelected),
                      width: 42,
                      height: 42,
                      child: Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 24,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                    )
                  : Material(
                      key: const ValueKey<String>('delete_action'),
                      color: AppColors.statusSpoiledSoft,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        onTap: onDelete,
                        child: const SizedBox(
                          width: 42,
                          height: 42,
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: AppColors.statusSpoiled,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
