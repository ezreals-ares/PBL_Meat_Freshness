import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../providers/scan_provider.dart';
import '../preview/preview_screen.dart';
import '../result/result_screen.dart';
import '../../widgets/neo_loading.dart';

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
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
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
            content: Text('Akses kamera diperlukan. Aktifkan izin di pengaturan.'),
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
            content: Text('Tidak dapat mengakses galeri. Periksa izin aplikasi.'),
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

    // Tampilkan loading overlay
    NeoLoading.show(ctx);

    await scanProvider.analyzeImage();

    // Sembunyikan loading overlay
    NeoLoading.hide();

    if (!mounted) return;

    // Gunakan this.context (State context) setelah async gap
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (scanProvider.scanState == ScanState.success &&
        scanProvider.currentResult != null) {
      // Ganti preview dengan hasil
      nav.pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(result: scanProvider.currentResult!),
        ),
      );
    } else {
      // Tampilkan error
      messenger.showSnackBar(
        SnackBar(
          content: Text(
              scanProvider.errorMessage ?? 'Analisis gagal. Coba lagi.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              _buildHeader(),
              const SizedBox(height: AppSpacing.md),
              _buildViewfinder(),
              const SizedBox(height: AppSpacing.md),
              _buildActionCards(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text('ANALISIS VISUAL',
                style: AppTextStyles.labelSm
                    .copyWith(color: AppColors.textSecondary, letterSpacing: 2)),
          ],
        ),
        const SizedBox(height: 4),
        Text('AMBIL ATAU PILIH\nFOTO', style: AppTextStyles.headlineLgMobile),
      ],
    );
  }

  // ─── VIEWFINDER ───────────────────────────────────────────
  Widget _buildViewfinder() {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderDefault, width: 2.5),
          boxShadow: [AppShadows.hard()],
        ),
        child: Stack(
          children: [
            const Center(
              child: Icon(Icons.image_outlined,
                  size: 64, color: AppColors.surfaceContainer),
            ),
            // Sudut bracket
            Positioned(
                top: 16, left: 16, child: _buildBracket(true, true)),
            Positioned(
                top: 16, right: 16, child: _buildBracket(true, false)),
            Positioned(
                bottom: 16, left: 16, child: _buildBracket(false, true)),
            Positioned(
                bottom: 16,
                right: 16,
                child: _buildBracket(false, false)),
            // Target badge
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border:
                        Border.all(color: AppColors.borderDefault, width: 2),
                    boxShadow: [AppShadows.hardSmall()],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.gps_fixed,
                          size: 16, color: AppColors.statusFresh),
                      const SizedBox(width: 4),
                      Text('TARGET: DAGING', style: AppTextStyles.labelSm),
                    ],
                  ),
                ),
              ),
            ),
            // Animasi fokus tengah
            Center(
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.textPrimary,
                      width: 2.5,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                  child: const Icon(Icons.filter_center_focus,
                      size: 24, color: AppColors.textPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBracket(bool isTop, bool isLeft) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(
                  color: AppColors.textPrimary, width: 3.5)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(
                  color: AppColors.textPrimary, width: 3.5)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(
                  color: AppColors.textPrimary, width: 3.5)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(
                  color: AppColors.textPrimary, width: 3.5)
              : BorderSide.none,
        ),
      ),
    );
  }

  // ─── ACTION CARDS ─────────────────────────────────────────
  Widget _buildActionCards() {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            color: AppColors.secondaryContainer,
            icon: Icons.photo_camera,
            label: 'KAMERA',
            headline: 'AMBIL FOTO',
            onTap: _pickFromCamera,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ActionCard(
            color: AppColors.primaryContainer,
            icon: Icons.add_photo_alternate,
            label: 'GALERI',
            headline: 'UNGGAH FOTO',
            onTap: _pickFromGallery,
          ),
        ),
      ],
    );
  }
}

// ─── ACTION CARD WIDGET ─────────────────────────────────────
class _ActionCard extends StatefulWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String headline;
  final VoidCallback onTap;

  const _ActionCard({
    required this.color,
    required this.icon,
    required this.label,
    required this.headline,
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
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
            _pressed ? 2 : 0, _pressed ? 2 : 0, 0),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border:
              Border.all(color: AppColors.borderDefault, width: 3),
          boxShadow: [
            _pressed ? AppShadows.hardSmall() : AppShadows.hard(),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                    color: AppColors.borderDefault, width: 2.5),
                boxShadow: [AppShadows.hardSmall()],
              ),
              child: Icon(widget.icon,
                  size: 32, color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(widget.label,
                style: AppTextStyles.labelSm.copyWith(
                    letterSpacing: 2, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(widget.headline,
                style: AppTextStyles.headlineSm.copyWith(fontSize: 16),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
