import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/server_health_repository.dart';
import '../providers/scan_provider.dart';
import '../theme/theme.dart';
import '../widgets/curved_app_bar.dart';
import 'widgets/settings_cards.dart';

/// Layar Pengaturan — preferensi model AI, status server, izin perangkat, dan panduan.
class SettingsScreen extends StatefulWidget {
  final Future<({bool cameraGranted, bool galleryGranted})> Function()?
      loadPermissions;
  final Future<bool> Function()? onRequestCameraPermission;
  final Future<bool> Function()? onRequestGalleryPermission;
  final Future<bool> Function()? onOpenSystemSettings;

  const SettingsScreen({
    super.key,
    this.loadPermissions,
    this.onRequestCameraPermission,
    this.onRequestGalleryPermission,
    this.onOpenSystemSettings,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  ServerCheckStatus _serverStatus = ServerCheckStatus.idle;
  int? _latencyMs;
  String? _serverError;

  bool _cameraGranted = false;
  bool _galleryGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissions();
    }
  }

  Future<void> _refreshPermissions() async {
    final result = await (widget.loadPermissions != null
        ? widget.loadPermissions!()
        : _defaultLoadPermissions());
    if (!mounted) return;
    setState(() {
      _cameraGranted = result.cameraGranted;
      _galleryGranted = result.galleryGranted;
    });
  }

  Future<({bool cameraGranted, bool galleryGranted})>
      _defaultLoadPermissions() async {
    try {
      final cameraStatus = await Permission.camera.status;
      final photosStatus = await Permission.photos.status;
      var galleryGranted = photosStatus.isGranted || photosStatus.isLimited;
      if (!galleryGranted) {
        final storageStatus = await Permission.storage.status;
        galleryGranted = storageStatus.isGranted || storageStatus.isLimited;
      }
      return (
        cameraGranted: cameraStatus.isGranted,
        galleryGranted: galleryGranted,
      );
    } catch (_) {
      return (cameraGranted: false, galleryGranted: false);
    }
  }

  Future<void> _requestCameraPermission() async {
    final granted = await (widget.onRequestCameraPermission != null
        ? widget.onRequestCameraPermission!()
        : _defaultRequestCamera());
    if (!mounted) return;
    setState(() => _cameraGranted = granted);
  }

  Future<void> _requestGalleryPermission() async {
    final granted = await (widget.onRequestGalleryPermission != null
        ? widget.onRequestGalleryPermission!()
        : _defaultRequestGallery());
    if (!mounted) return;
    setState(() => _galleryGranted = granted);
  }

  Future<bool> _defaultRequestCamera() async {
    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _defaultRequestGallery() async {
    try {
      final photosStatus = await Permission.photos.request();
      if (photosStatus.isGranted || photosStatus.isLimited) {
        return true;
      }
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted || storageStatus.isLimited;
    } catch (_) {
      return false;
    }
  }

  Future<void> _openSystemSettings() async {
    if (widget.onOpenSystemSettings != null) {
      await widget.onOpenSystemSettings!();
      return;
    }
    try {
      await openAppSettings();
    } catch (_) {}
  }

  Future<void> _checkServerConnection() async {
    final healthRepo =
        Provider.of<ServerHealthRepository?>(context, listen: false);
    if (healthRepo == null) {
      setState(() {
        _serverStatus = ServerCheckStatus.error;
        _latencyMs = null;
        _serverError = 'Layanan pemeriksaan server tidak tersedia.';
      });
      return;
    }

    setState(() {
      _serverStatus = ServerCheckStatus.checking;
      _serverError = null;
    });

    final outcome = await healthRepo.checkHealth();
    if (!mounted) return;

    if (outcome.failure != null) {
      setState(() {
        _serverStatus = ServerCheckStatus.error;
        _latencyMs = null;
        _serverError = outcome.failure!.message;
      });
    } else {
      setState(() {
        _serverStatus = ServerCheckStatus.connected;
        _latencyMs = outcome.latencyMs;
        _serverError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanProvider = context.watch<ScanProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bgCanvas,
        body: Column(
          children: [
            CurvedAppBar(
              title: 'PENGATURAN',
              onBack: () => Navigator.pop(context),
              trailing: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  AppSpacing.md,
                  AppSpacing.margin,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SettingsSectionHeader(
                      title: 'Preferensi Analisis AI',
                      badgeText: 'MODEL',
                    ),
                    const SizedBox(height: 10),
                    DefaultModelCard(
                      selectedModel: scanProvider.selectedModel,
                      onSelectModel: scanProvider.selectModel,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const SettingsSectionHeader(
                      title: 'Status Server AI',
                      badgeText: 'KONEKSI',
                    ),
                    const SizedBox(height: 10),
                    ServerStatusCard(
                      status: _serverStatus,
                      latencyMs: _latencyMs,
                      errorMessage: _serverError,
                      onCheck: _checkServerConnection,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const SettingsSectionHeader(
                      title: 'Izin Perangkat',
                      badgeText: 'AKSES',
                    ),
                    const SizedBox(height: 10),
                    DevicePermissionsCard(
                      cameraGranted: _cameraGranted,
                      galleryGranted: _galleryGranted,
                      onRequestCamera: _requestCameraPermission,
                      onRequestGallery: _requestGalleryPermission,
                      onOpenSystemSettings: _openSystemSettings,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const SettingsSectionHeader(
                      title: 'Panduan & Tentang',
                      badgeText: 'INFO',
                    ),
                    const SizedBox(height: 10),
                    const PhotoGuideCard(),
                    const SizedBox(height: 12),
                    const AboutAppCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
