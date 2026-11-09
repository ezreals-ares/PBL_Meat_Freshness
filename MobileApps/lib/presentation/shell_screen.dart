import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'home/home_screen.dart';
import 'capture/capture_screen.dart';
import 'history/history_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  List<Widget> get _screens => [
    HomeScreen(onNavigateToTab: _onTabSelected),
    const CaptureScreen(),
    const HistoryScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface.withValues(alpha: 0.95),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 72,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
            child: Row(
              children: [
                _buildNavItem(0, Icons.cottage, 'BERANDA'),
                const SizedBox(width: AppSpacing.sm),
                _buildNavItem(1, Icons.document_scanner, 'PINDAI'),
                const SizedBox(width: AppSpacing.sm),
                _buildNavItem(2, Icons.receipt_long, 'RIWAYAT'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 22,
                  color: isActive
                      ? AppColors.onPrimary
                      : AppColors.textPrimary),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTextStyles.labelMd.copyWith(
                  color: isActive
                      ? AppColors.onPrimary
                      : AppColors.textPrimary,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
