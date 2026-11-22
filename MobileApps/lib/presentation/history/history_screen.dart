import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/format.dart';
import '../theme/theme.dart';
import '../theme/result_ui_ext.dart';
import '../../domain/models/classification_result.dart';
import '../widgets/neo_badge.dart';
import '../widgets/vector_illustrations.dart';
import '../providers/history_provider.dart';
import '../result/result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _deleteItem(BuildContext context, ClassificationResult item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (item.id != null) {
                context.read<HistoryProvider>().deleteItem(item.id!);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Catatan dihapus')),
              );
            },
            child: const Text(
              'HAPUS',
              style: TextStyle(
                color: AppColors.statusSpoiled,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, provider, _) {
        final items = provider.items;
        final filtered = provider.filteredItems;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: AppColors.bgCanvas,
            body: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  AppSpacing.md,
                  AppSpacing.margin,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, items.length),
                    const SizedBox(height: AppSpacing.md),
                    _buildSearchBar(context, provider),
                    const SizedBox(height: 14),
                    _buildFilterChips(context, provider, items),
                    const SizedBox(height: AppSpacing.md),
                    if (provider.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else if (provider.errorMessage != null)
                      _buildErrorState(provider.errorMessage!)
                    else if (filtered.isEmpty)
                      _buildEmptyState(context)
                    else
                      ...filtered.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildHistoryCard(context, item),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── HEADER ───────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, int totalCount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RIWAYAT SCAN', style: AppTextStyles.headlineLgMobile),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '$totalCount SAMPEL DIANALISIS',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ),
        _SoftPillButton(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur ekspor segera hadir')),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.download_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'EKSPOR',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── SEARCH BAR ───────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context, HistoryProvider provider) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: AppColors.borderSubtle, width: 1),
              boxShadow: [AppShadows.softSm()],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: AppColors.tertiaryDark,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => provider.setSearchQuery(v),
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari jenis daging atau ID...',
                      hintStyle: AppTextStyles.bodySm.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (provider.searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      provider.setSearchQuery('');
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.cancel_rounded,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.16),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.tune_rounded,
            size: 20,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  // ─── FILTER CHIPS ─────────────────────────────────────────
  Widget _buildFilterChips(
    BuildContext context,
    HistoryProvider provider,
    List<ClassificationResult> items,
  ) {
    final filters = [
      ('all', 'SEMUA (${items.length})'),
      ('fresh', 'SEGAR (${provider.countByResult("fresh")})'),
      ('half_fresh', 'SETENGAH SEGAR (${provider.countByResult("half_fresh")})'),
      ('spoiled', 'BUSUK (${provider.countByResult("spoiled")})'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isActive = provider.activeFilter == f.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                provider.setFilter(f.$1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.borderSubtle,
                    width: 1,
                  ),
                  boxShadow: isActive
                      ? [AppShadows.glow(AppColors.primary, alpha: 0.22)]
                      : [AppShadows.softSm()],
                ),
                child: Text(
                  f.$2,
                  style: AppTextStyles.labelSm.copyWith(
                    color: isActive ? Colors.white : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── HISTORY CARD ─────────────────────────────────────────
  Widget _buildHistoryCard(BuildContext context, ClassificationResult item) {
    final timeStr = formatScanTimestamp(item.createdAt);
    final statusColor = item.statusColor;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(result: item),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderSubtle, width: 1),
          boxShadow: [AppShadows.softSm()],
        ),
        child: Row(
          children: [
            // Thumbnail rounded dengan strip status halus
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
                    File(item.imagePath).existsSync()
                        ? Image.file(File(item.imagePath), fit: BoxFit.cover)
                        : const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 28,
                              color: AppColors.textTertiary,
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
                      NeoBadge.fromResult(item.result),
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
            // Tombol hapus ramah sentuh (>= 44x44)
            Material(
              color: AppColors.statusSpoiledSoft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                onTap: () => _deleteItem(context, item),
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
          ],
        ),
      ),
    );
  }

  // ─── ERROR STATE ──────────────────────────────────────────
  Widget _buildErrorState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 36,
            color: AppColors.error,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── EMPTY STATE ──────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
        boxShadow: [AppShadows.softCard()],
      ),
      child: Column(
        children: [
          const EmptyHistoryIllustration(),
          const SizedBox(height: 12),
          Text('BELUM ADA CEK', style: AppTextStyles.headlineSm),
          const SizedBox(height: 6),
          Text(
            'Ambil foto daging dari tab pindai untuk mulai mencatat hasil kesegaran.',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.read<HistoryProvider>().resetFilters();
              _searchController.clear();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(AppRadius.full),
                boxShadow: [AppShadows.glow(AppColors.accent, alpha: 0.32)],
              ),
              child: Text(
                'RESET FILTER',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.onAccent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftPillButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _SoftPillButton({required this.child, required this.onTap});

  @override
  State<_SoftPillButton> createState() => _SoftPillButtonState();
}

class _SoftPillButtonState extends State<_SoftPillButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: AppColors.borderSubtle, width: 1),
            boxShadow: [AppShadows.softSm()],
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
