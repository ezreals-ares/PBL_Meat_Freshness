import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../domain/models/classification_result.dart';
import '../providers/history_provider.dart';
import '../result/result_screen.dart';
import '../theme/theme.dart';
import '../widgets/pressable_scale.dart';
import '../widgets/vector_illustrations.dart';
import 'widgets/history_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadHistory();
    });
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

  void _confirmDeleteSelected(BuildContext context, int count) {
    if (count == 0) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus $count Catatan Terpilih?'),
        content: const Text(
          'Semua catatan dan foto yang dipilih akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final deleted =
                  await context.read<HistoryProvider>().deleteSelected();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$deleted catatan dihapus')),
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

  void _confirmDeleteAll(BuildContext context, int totalCount) {
    if (totalCount == 0) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Semua Riwayat?'),
        content: Text(
          'Seluruh $totalCount catatan riwayat dan foto terkait akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<HistoryProvider>().deleteAll();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Seluruh riwayat dihapus')),
              );
            },
            child: const Text(
              'HAPUS SEMUA',
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
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.margin,
                      AppSpacing.md,
                      AppSpacing.margin,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context, items.length),
                          const SizedBox(height: AppSpacing.md),
                          _buildFilterChips(context, provider, items),
                          if (items.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildSelectionActionBar(
                              context,
                              provider,
                              items.length,
                              filtered.isNotEmpty,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),
                  ),
                  if (provider.isLoading)
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                  else if (provider.errorMessage != null)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.margin,
                        0,
                        AppSpacing.margin,
                        32,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _buildErrorState(provider.errorMessage!),
                      ),
                    )
                  else if (filtered.isEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.margin,
                        0,
                        AppSpacing.margin,
                        32,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _buildEmptyState(context),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.margin,
                        0,
                        AppSpacing.margin,
                        32,
                      ),
                      sliver: SliverList.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: HistoryCard(
                              item: item,
                              isSelectionMode: provider.isSelectionMode,
                              isSelected: provider.isSelected(item.id),
                              onTap: () {
                                if (provider.isSelectionMode) {
                                  if (item.id != null) {
                                    provider.toggleSelection(item.id!);
                                  }
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ResultScreen(result: item),
                                  ),
                                );
                              },
                              onLongPress: !provider.isSelectionMode &&
                                      item.id != null
                                  ? () {
                                      HapticFeedback.mediumImpact();
                                      provider.enterSelectionMode(
                                        initialId: item.id,
                                      );
                                    }
                                  : null,
                              onDelete: () => _deleteItem(context, item),
                            ),
                          );
                        },
                      ),
                    ),
                ],
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
        PressableScale(
          pressedScale: 0.96,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur ekspor segera hadir')),
            );
          },
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: AppColors.borderSubtle, width: 1),
              boxShadow: [AppShadows.softSm()],
            ),
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
      (
        'half_fresh',
        'SETENGAH SEGAR (${provider.countByResult("half_fresh")})'
      ),
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
                curve: Curves.easeOutCubic,
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

  // ─── SELECTION & BATCH DELETE BAR ─────────────────────────
  Widget _buildSelectionActionBar(
    BuildContext context,
    HistoryProvider provider,
    int totalCount,
    bool hasVisibleItems,
  ) {
    if (!provider.isSelectionMode) {
      return Row(
        children: [
          PressableScale(
            pressedScale: 0.96,
            onTap: () => provider.enterSelectionMode(),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: AppColors.borderSubtle),
                boxShadow: [AppShadows.softSm()],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.checklist_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'PILIH',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          PressableScale(
            pressedScale: 0.96,
            onTap: () => _confirmDeleteAll(context, totalCount),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.statusSpoiledSoft,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: AppColors.statusSpoiled.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.delete_sweep_rounded,
                    size: 16,
                    color: AppColors.statusSpoiled,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'HAPUS SEMUA',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.statusSpoiledInk,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final allSelected = provider.isAllFilteredSelected;
    final selectedCount = provider.selectedCount;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        boxShadow: [AppShadows.softSm()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(AppRadius.full),
                onTap: hasVisibleItems
                    ? () {
                        HapticFeedback.selectionClick();
                        provider.toggleSelectAllFiltered();
                      }
                    : null,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        allSelected
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        size: 20,
                        color: hasVisibleItems
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        allSelected ? 'BATAL PILIH' : 'PILIH SEMUA',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '$selectedCount DIPILIH',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.primaryDark,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              PressableScale(
                pressedScale: 0.97,
                onTap: provider.exitSelectionMode,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppColors.borderSubtle,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.close_rounded,
                        size: 17,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'BATAL',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PressableScale(
                  pressedScale: 0.98,
                  onTap: selectedCount > 0
                      ? () => _confirmDeleteSelected(context, selectedCount)
                      : () {},
                  child: Opacity(
                    opacity: selectedCount > 0 ? 1.0 : 0.45,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.statusSpoiled,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.delete_outline_rounded,
                            size: 17,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'HAPUS TERPILIH ($selectedCount)',
                              style: AppTextStyles.labelSm.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
          PressableScale(
            onTap: () => context.read<HistoryProvider>().resetFilters(),
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
