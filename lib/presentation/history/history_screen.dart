import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../domain/models/classification_result.dart';
import '../../widgets/neo_badge.dart';
import '../providers/history_provider.dart';

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
              child: const Text('BATAL')),
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
            child: const Text('HAPUS',
                style: TextStyle(color: AppColors.statusSpoiled)),
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

        return Scaffold(
          backgroundColor: AppColors.bgCanvas,
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margin, AppSpacing.md, AppSpacing.margin, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, items.length),
                  const SizedBox(height: AppSpacing.md),
                  _buildSearchBar(context, provider),
                  const SizedBox(height: AppSpacing.md),
                  _buildFilterChips(context, provider, items),
                  const SizedBox(height: AppSpacing.md),
                  if (provider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (provider.errorMessage != null)
                    _buildErrorState(provider.errorMessage!)
                  else if (filtered.isEmpty)
                    _buildEmptyState(context)
                  else
                    ...filtered.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildHistoryCard(context, item),
                        )),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RIWAYAT SCAN', style: AppTextStyles.headlineLgMobile),
              const SizedBox(height: 2),
              Text('$totalCount SAMPEL DIANALISIS',
                  style: AppTextStyles.labelMd
                      .copyWith(color: AppColors.textSecondary, letterSpacing: 1)),
            ],
          ),
        ),
        _PressableButton(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur ekspor segera hadir')),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.download, size: 18, color: AppColors.textPrimary),
              const SizedBox(width: 6),
              Text('EKSPOR',
                  style: AppTextStyles.labelSm.copyWith(letterSpacing: 1)),
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
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: AppColors.borderDefault, width: 2.5),
              boxShadow: [AppShadows.hardMedium()],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => provider.setSearchQuery(v),
                    style: AppTextStyles.labelMd,
                    decoration: InputDecoration(
                      hintText: 'CARI JENIS DAGING ATAU ID...',
                      hintStyle: AppTextStyles.labelMd
                          .copyWith(color: AppColors.textSecondary),
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
                    child: const Icon(Icons.cancel,
                        size: 18, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.secondaryFixed,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderDefault, width: 2.5),
            boxShadow: [AppShadows.hardMedium()],
          ),
          child: const Icon(Icons.tune, size: 20, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  // ─── FILTER CHIPS ─────────────────────────────────────────
  Widget _buildFilterChips(
      BuildContext context, HistoryProvider provider, List<ClassificationResult> items) {
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
              onTap: () => provider.setFilter(f.$1),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.textPrimary
                      : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: AppColors.borderDefault, width: 2),
                  boxShadow: [AppShadows.hardSmall()],
                ),
                child: Text(
                  f.$2,
                  style: AppTextStyles.labelSm.copyWith(
                    color: isActive
                        ? AppColors.onPrimary
                        : AppColors.textPrimary,
                    letterSpacing: 1,
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
    final timeStr = DateFormat('dd MMM, HH:mm').format(item.createdAt);
    final statusColor = item.statusColor;

    return GestureDetector(
      onTap: () {
        // TODO: Navigasi ke tampilan detail
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderDefault, width: 2.5),
          boxShadow: [AppShadows.hardMedium()],
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.borderDefault, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md - 2),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    File(item.imagePath).existsSync()
                        ? Image.file(File(item.imagePath), fit: BoxFit.cover)
                        : const Center(
                            child: Icon(Icons.image,
                                size: 28,
                                color: AppColors.surfaceContainerHighest),
                          ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(height: 6, color: statusColor),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Konten
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      NeoBadge.fromResult(item.result),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: AppColors.borderDefault, width: 1),
                        ),
                        child: Text(
                          '${(item.confidence * 100).toInt()}% KEPERCAYAAN',
                          style: AppTextStyles.labelSm
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.meatType?.toUpperCase() ?? item.displayName,
                    style: AppTextStyles.headlineSm.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.schedule,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(timeStr.toUpperCase(),
                          style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 1)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Tombol hapus
            GestureDetector(
              onTap: () => _deleteItem(context, item),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border:
                      Border.all(color: AppColors.borderDefault, width: 2),
                  boxShadow: [AppShadows.hardSmall()],
                ),
                child: const Icon(Icons.delete,
                    size: 20, color: AppColors.textPrimary),
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
        border: Border.all(color: AppColors.borderDefault, width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 32, color: AppColors.error),
          const SizedBox(height: 8),
          Text(message,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.error),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ─── EMPTY STATE ──────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderDefault, width: 2.5),
        boxShadow: [AppShadows.hard()],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainer,
              border: Border.all(color: AppColors.borderDefault, width: 2),
            ),
            child: const Icon(Icons.inventory_2,
                size: 32, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Text('BELUM ADA CEK', style: AppTextStyles.headlineSm),
          const SizedBox(height: 4),
          Text(
            'Ambil foto daging dari tab pindai untuk memulai!',
            style:
                AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              context.read<HistoryProvider>().resetFilters();
              _searchController.clear();
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border:
                    Border.all(color: AppColors.borderDefault, width: 2),
                boxShadow: [AppShadows.hardSmall()],
              ),
              child: Text('RESET FILTER',
                  style: AppTextStyles.labelMd
                      .copyWith(color: AppColors.onPrimary)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PRESSABLE BUTTON ───────────────────────────────────────
class _PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableButton({required this.child, required this.onTap});

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        transform: Matrix4.translationValues(
            _pressed ? 2 : 0, _pressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.borderDefault, width: 2.5),
          boxShadow: [
            _pressed ? AppShadows.hardSmall() : AppShadows.hardMedium()
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
