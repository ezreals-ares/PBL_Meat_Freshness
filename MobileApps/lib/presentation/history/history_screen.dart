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
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ResultScreen(result: item),
                                  ),
                                );
                              },
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
