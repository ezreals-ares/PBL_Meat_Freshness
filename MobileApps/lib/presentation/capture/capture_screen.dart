import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../preview/preview_screen.dart';
import '../providers/history_provider.dart';
import '../providers/scan_provider.dart';
import '../result/result_screen.dart';
import '../theme/result_ui_ext.dart';
import '../theme/theme.dart';
import '../widgets/loading_overlay.dart';
import 'widgets/capture_action_card.dart';
import 'widgets/capture_viewfinder.dart';

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

    AppLoadingOverlay.show(
      ctx,
      text: 'MENGANALISIS (${scanProvider.selectedModel.shortName})...',
    );

    await scanProvider.analyzeImage();
    AppLoadingOverlay.hide();

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
              _buildCurvedHeader(),
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
                    CaptureViewfinder(
                      pulseAnimation: _pulseAnimation,
                      onTap: _pickFromCamera,
                    ),
                    const SizedBox(height: 14),
                    const CaptureTipsRow(),
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

  Widget _buildCurvedHeader() {
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

  Widget _buildActionCards() {
    return Row(
      children: [
        Expanded(
          child: CaptureActionCard(
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
          child: CaptureActionCard(
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
