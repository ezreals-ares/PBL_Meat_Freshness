import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../theme/result_ui_ext.dart';
import '../theme/theme.dart';
import '../providers/history_provider.dart';
import '../providers/scan_provider.dart';
import '../preview/preview_screen.dart';
import '../result/result_screen.dart';
import '../widgets/neo_loading.dart';
import '../widgets/vector_illustrations.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (photo != null && mounted) {
        _navigateToPreview(photo.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Akses kamera diperlukan. Aktifkan izin di pengaturan.'),
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (image != null && mounted) {
        _navigateToPreview(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Tidak dapat mengakses galeri. Periksa izin aplikasi.'),
          ),
        );
      }
    }
  }

  void _navigateToPreview(String imagePath) {
    final scanProvider = context.read<ScanProvider>();
    scanProvider.selectImage(imagePath);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewScreen(
          imagePath: imagePath,
          onAnalyze: () => _startAnalysis(context),
        ),
      ),
    );
  }

  Future<void> _startAnalysis(BuildContext ctx) async {
    final scanProvider = ctx.read<ScanProvider>();

    NeoLoading.show(
      ctx,
      text: 'MENGANALISIS (${scanProvider.selectedModel.shortName})...',
    );

    await scanProvider.analyzeImage();
    NeoLoading.hide();

    if (!mounted) return;

    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (scanProvider.scanState == ScanState.success &&
        scanProvider.currentResult != null) {
      if (scanProvider.currentResult!.isMeat) {
        context.read<HistoryProvider>().loadHistory();
      }
      nav.pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(result: scanProvider.currentResult!),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            scanProvider.errorMessage ?? 'Analisis gagal. Coba lagi.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bgCanvas,
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCurvedHeader(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  AppSpacing.md,
                  AppSpacing.margin,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildViewfinder(),
                    const SizedBox(height: 14),
                    _buildCaptureTips(),
                    const SizedBox(height: AppSpacing.md),
                    _buildActionCards(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── CURVED SLATE-TEAL HEADER (Terinspirasi Screen 3 Guide) ─
  Widget _buildCurvedHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.tertiary, AppColors.primary],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.margin,
            AppSpacing.md,
            AppSpacing.margin,
            22,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ANALISIS VISUAL',
                      style: AppTextStyles.labelSm.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'AMBIL ATAU PILIH\nFOTO',
                style: AppTextStyles.headlineLgMobile.copyWith(
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Arahkan kamera ke permukaan daging dengan pencahayaan merata.',
                style: AppTextStyles.bodySm.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── VIEWFINDER ────────────────────────────────────────────
  Widget _buildViewfinder() {
    return GestureDetector(
      onTap: _pickFromCamera,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [AppShadows.softCard(color: AppColors.primaryDark)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: ScannerBackdropPainter()),
                // Corner scan brackets
                Positioned(
                  top: 18,
                  left: 18,
                  child: _buildBracket(true, true),
                ),
                Positioned(
                  top: 18,
                  right: 18,
                  child: _buildBracket(true, false),
                ),
                Positioned(
                  bottom: 18,
                  left: 18,
                  child: _buildBracket(false, true),
                ),
                Positioned(
                  bottom: 18,
                  right: 18,
                  child: _buildBracket(false, false),
                ),
                // Top target pill badge
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        boxShadow: [AppShadows.softSm()],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.gps_fixed_rounded,
                            size: 15,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'TARGET: DAGING',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Pulsing center focus reticle
                Center(
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.14),
                        border: Border.all(
                          color: AppColors.accent,
                          width: 2.5,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent,
                          ),
                          child: const Icon(
                            Icons.center_focus_weak_rounded,
                            size: 24,
                            color: AppColors.onAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Subtle bottom tap hint
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        'Ketuk area ini untuk buka kamera',
                        style: AppTextStyles.labelSm.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBracket(bool isTop, bool isLeft) {
    const side = BorderSide(color: AppColors.accent, width: 3.5);
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: isTop && isLeft ? const Radius.circular(10) : Radius.zero,
          topRight: isTop && !isLeft ? const Radius.circular(10) : Radius.zero,
          bottomLeft:
              !isTop && isLeft ? const Radius.circular(10) : Radius.zero,
          bottomRight:
              !isTop && !isLeft ? const Radius.circular(10) : Radius.zero,
        ),
        border: Border(
          top: isTop ? side : BorderSide.none,
          bottom: !isTop ? side : BorderSide.none,
          left: isLeft ? side : BorderSide.none,
          right: !isLeft ? side : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCaptureTips() {
    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _CaptureTipChip(
          icon: Icons.wb_sunny_outlined,
          label: 'Cahaya Cukup',
        ),
        _CaptureTipChip(
          icon: Icons.center_focus_strong_outlined,
          label: 'Fokus Jelas',
        ),
        _CaptureTipChip(
          icon: Icons.straighten_rounded,
          label: 'Jarak 15–30 cm',
        ),
      ],
    );
  }

  // ─── ACTION CARDS (Thumb-Zone Ergonomic) ───────────────────
  Widget _buildActionCards() {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            backgroundColor: AppColors.primary,
            iconBgColor: AppColors.accent,
            iconColor: AppColors.onAccent,
            labelColor: Colors.white.withValues(alpha: 0.80),
            headlineColor: Colors.white,
            icon: Icons.photo_camera_rounded,
            label: 'KAMERA',
            headline: 'AMBIL FOTO',
            hasGlow: true,
            onTap: _pickFromCamera,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            backgroundColor: AppColors.bgSurface,
            iconBgColor: AppColors.secondaryFixed,
            iconColor: AppColors.secondaryDark,
            labelColor: AppColors.textSecondary,
            headlineColor: AppColors.textPrimary,
            icon: Icons.add_photo_alternate_rounded,
            label: 'GALERI',
            headline: 'UNGGAH FOTO',
            hasGlow: false,
            onTap: _pickFromGallery,
          ),
        ),
      ],
    );
  }
}

class _CaptureTipChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CaptureTipChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.tertiaryDark),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final Color backgroundColor;
  final Color iconBgColor;
  final Color iconColor;
  final Color labelColor;
  final Color headlineColor;
  final IconData icon;
  final String label;
  final String headline;
  final bool hasGlow;
  final VoidCallback onTap;

  const _ActionCard({
    required this.backgroundColor,
    required this.iconBgColor,
    required this.iconColor,
    required this.labelColor,
    required this.headlineColor,
    required this.icon,
    required this.label,
    required this.headline,
    required this.hasGlow,
    required this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
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
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: widget.hasGlow
                ? null
                : Border.all(color: AppColors.borderSubtle, width: 1),
            boxShadow: [
              widget.hasGlow
                  ? AppShadows.glow(widget.backgroundColor, alpha: 0.28)
                  : AppShadows.softSm(),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, size: 26, color: widget.iconColor),
              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                style: AppTextStyles.labelSm.copyWith(
                  color: widget.labelColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.headline,
                style: AppTextStyles.headlineSm.copyWith(
                  fontSize: 15.5,
                  color: widget.headlineColor,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
