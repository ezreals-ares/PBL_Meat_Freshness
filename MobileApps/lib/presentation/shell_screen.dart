import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';
import 'home/home_screen.dart';
import 'capture/capture_screen.dart';
import 'history/history_screen.dart';
import 'providers/history_provider.dart';
import 'widgets/pressable_scale.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int? _previousIndex;
  int _transitionDirection = 1;

  static const int _historyTabIndex = 2;
  static const Duration _tabTransitionDuration = Duration(milliseconds: 280);
  static const Duration _navIndicatorDuration = Duration(milliseconds: 300);

  late final Widget _homeScreen;
  static const Widget _captureScreen = CaptureScreen();
  static const Widget _historyScreen = HistoryScreen();

  late final AnimationController _tabController;

  @override
  void initState() {
    super.initState();
    _homeScreen = HomeScreen(onNavigateToTab: _onTabSelected);
    _tabController = AnimationController(
      vsync: this,
      duration: _tabTransitionDuration,
      value: 1.0,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && _previousIndex != null) {
          setState(() => _previousIndex = null);
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) {
      if (index == _historyTabIndex) {
        context.read<HistoryProvider>().loadHistory();
      }
      return;
    }

    HapticFeedback.selectionClick();
    if (index == _historyTabIndex) {
      context.read<HistoryProvider>().loadHistory();
    }

    setState(() {
      _previousIndex = _currentIndex;
      _transitionDirection = index > _currentIndex ? 1 : -1;
      _currentIndex = index;
    });
    _tabController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildTabLayer(0, _homeScreen),
          _buildTabLayer(
            1,
            TickerMode(
              enabled: _currentIndex == 1,
              child: _captureScreen,
            ),
          ),
          _buildTabLayer(2, _historyScreen),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTabLayer(int index, Widget child) {
    final isCurrent = _currentIndex == index;
    final isPrevious = _previousIndex == index;
    final isVisible = isCurrent || isPrevious;

    return Offstage(
      offstage: !isVisible,
      child: IgnorePointer(
        ignoring: !isCurrent,
        child: ExcludeSemantics(
          excluding: !isCurrent,
          child: AnimatedBuilder(
            animation: _tabController,
            child: child,
            builder: (context, builtChild) {
              if (isCurrent && _previousIndex == null) {
                return builtChild!;
              }

              final t = _tabController.value;
              final eased = Curves.easeOutCubic.transform(t);
              final double opacity;
              final double slideX;
              final double scale;

              if (isCurrent) {
                opacity =
                    const Interval(0.10, 1.0, curve: Curves.easeOutCubic)
                        .transform(t);
                slideX = (1.0 - eased) * 0.045 * _transitionDirection;
                scale = 0.985 + (0.015 * eased);
              } else if (isPrevious) {
                opacity = 1.0 -
                    const Interval(0.0, 0.70, curve: Curves.easeOut)
                        .transform(t);
                slideX = -eased * 0.035 * _transitionDirection;
                scale = 1.0;
              } else {
                return builtChild!;
              }

              return FractionalTranslation(
                translation: Offset(slideX, 0),
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: builtChild,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    const double itemGap = 10;

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final slotWidth = (constraints.maxWidth - itemGap * 2) / 3;
              final indicatorLeft = _currentIndex * (slotWidth + itemGap);
              final isCenterActive = _currentIndex == 1;

              return SizedBox(
                height: 56,
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: _navIndicatorDuration,
                      curve: Curves.easeOutCubic,
                      left: indicatorLeft,
                      top: 0,
                      width: slotWidth,
                      height: 56,
                      child: AnimatedContainer(
                        duration: _tabTransitionDuration,
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: isCenterActive
                              ? AppColors.primary
                              : AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          boxShadow: isCenterActive
                              ? [
                                  AppShadows.glow(
                                    AppColors.primary,
                                    alpha: 0.28,
                                  ),
                                ]
                              : const [],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _buildNavItem(
                          index: 0,
                          icon: Icons.home_rounded,
                          inactiveIcon: Icons.home_outlined,
                          label: 'BERANDA',
                        ),
                        const SizedBox(width: itemGap),
                        _buildNavItem(
                          index: 1,
                          icon: Icons.document_scanner_rounded,
                          inactiveIcon: Icons.document_scanner_outlined,
                          label: 'PINDAI',
                          isCenterPrimary: true,
                        ),
                        const SizedBox(width: itemGap),
                        _buildNavItem(
                          index: 2,
                          icon: Icons.receipt_long_rounded,
                          inactiveIcon: Icons.receipt_long_outlined,
                          label: 'RIWAYAT',
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
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
    final activeFg = isCenterPrimary ? AppColors.onPrimary : AppColors.primary;
    final activeIconColor =
        isCenterPrimary ? AppColors.accent : AppColors.primary;

    return Expanded(
      child: PressableScale(
        pressedScale: 0.94,
        enableHaptic: false,
        onTap: () => _onTabSelected(index),
        child: SizedBox(
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isActive ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.85, end: 1.0).animate(anim),
                      child: child,
                    ),
                  ),
                  child: Icon(
                    isActive ? icon : inactiveIcon,
                    key: ValueKey<bool>(isActive),
                    size: 22,
                    color: isActive ? activeIconColor : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                style: AppTextStyles.labelSm.copyWith(
                  color: isActive ? activeFg : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: 0.6,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
