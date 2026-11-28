import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';
import 'home/home_screen.dart';
import 'capture/capture_screen.dart';
import 'history/history_screen.dart';
import 'providers/history_provider.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;

  static const int _historyTabIndex = 2;

  late final Widget _homeScreen;
  static const Widget _captureScreen = CaptureScreen();
  static const Widget _historyScreen = HistoryScreen();

  @override
  void initState() {
    super.initState();
    _homeScreen = HomeScreen(onNavigateToTab: _onTabSelected);
  }

  void _onTabSelected(int index) {
    if (index != _currentIndex) {
      HapticFeedback.selectionClick();
    }
    if (index == _historyTabIndex) {
      context.read<HistoryProvider>().loadHistory();
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _homeScreen,
          TickerMode(
            enabled: _currentIndex == 1,
            child: _captureScreen,
          ),
          _historyScreen,
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
        border: const Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
        boxShadow: [AppShadows.navBar()],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.margin,
            10,
            AppSpacing.margin,
            10,
          ),
          child: Row(
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                inactiveIcon: Icons.home_outlined,
                label: 'BERANDA',
              ),
              const SizedBox(width: 10),
              _buildNavItem(
                index: 1,
                icon: Icons.document_scanner_rounded,
                inactiveIcon: Icons.document_scanner_outlined,
                label: 'PINDAI',
                isCenterPrimary: true,
              ),
              const SizedBox(width: 10),
              _buildNavItem(
                index: 2,
                icon: Icons.receipt_long_rounded,
                inactiveIcon: Icons.receipt_long_outlined,
                label: 'RIWAYAT',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData inactiveIcon,
    required String label,
    bool isCenterPrimary = false,
  }) {
    final isActive = _currentIndex == index;
    final activeBg = isCenterPrimary ? AppColors.primary : AppColors.primarySoft;
    final activeFg = isCenterPrimary ? AppColors.onPrimary : AppColors.primary;
    final activeIconColor =
        isCenterPrimary ? AppColors.accent : AppColors.primary;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTabSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 54,
          decoration: BoxDecoration(
            color: isActive ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: isActive && isCenterPrimary
                ? [AppShadows.glow(AppColors.primary, alpha: 0.25)]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? icon : inactiveIcon,
                size: 22,
                color: isActive ? activeIconColor : AppColors.textSecondary,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSm.copyWith(
                  color: isActive ? activeFg : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
