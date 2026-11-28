import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatfresh_ai/core/failures.dart';
import 'package:meatfresh_ai/domain/models/classification_result.dart';
import 'package:meatfresh_ai/domain/models/prediction_model_type.dart';
import 'package:meatfresh_ai/domain/models/prediction_output.dart';
import 'package:meatfresh_ai/domain/repositories/classification_repository.dart';
import 'package:meatfresh_ai/domain/repositories/image_storage_repository.dart';
import 'package:meatfresh_ai/domain/repositories/meat_classifier_repository.dart';
import 'package:meatfresh_ai/domain/repositories/server_health_repository.dart';
import 'package:meatfresh_ai/domain/usecases/analyze_meat_usecase.dart';
import 'package:meatfresh_ai/presentation/providers/scan_provider.dart';
import 'package:meatfresh_ai/presentation/settings/settings_screen.dart';
import 'package:meatfresh_ai/presentation/theme/theme.dart';
import 'package:provider/provider.dart';

class _DummyImageStorage implements ImageStorageRepository {
  @override
  Future<void> deleteScanImage(String imagePath) async {}

  @override
  Future<({Failure? failure, String? path})> saveScanImage(
          String sourcePath) async =>
      (path: sourcePath, failure: null);
}

class _DummyClassifier implements MeatClassifierRepository {
  @override
  Future<({Failure? failure, PredictionOutput? output})> classify({
    required String imagePath,
    required PredictionModelType modelType,
  }) async =>
      (output: null, failure: const NetworkFailure('offline'));
}

class _DummyClassificationRepo implements ClassificationRepository {
  @override
  Future<Failure?> delete(int id) async => null;

  @override
  Future<Failure?> deleteAll() async => null;

  @override
  Future<({Failure? failure, List<ClassificationResult> results})>
      getAll() async => (results: const <ClassificationResult>[], failure: null);

  @override
  Future<({Failure? failure, ClassificationResult? result})> save(
          ClassificationResult result) async =>
      (result: result, failure: null);
}

class _FakeServerHealthRepository implements ServerHealthRepository {
  int? latencyToReturn = 42;
  Failure? failureToReturn;

  @override
  Future<({Failure? failure, int? latencyMs})> checkHealth() async {
    if (failureToReturn != null) {
      return (latencyMs: null, failure: failureToReturn);
    }
    return (latencyMs: latencyToReturn, failure: null);
  }
}

Widget _buildTestApp({
  required ScanProvider scanProvider,
  required ServerHealthRepository healthRepo,
  Future<({bool cameraGranted, bool galleryGranted})> Function()?
      loadPermissions,
  Future<bool> Function()? onRequestCameraPermission,
  Future<bool> Function()? onOpenSystemSettings,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: scanProvider),
      Provider<ServerHealthRepository>.value(value: healthRepo),
    ],
    child: MaterialApp(
      theme: buildAppTheme(),
      home: SettingsScreen(
        loadPermissions: loadPermissions ??
            () async => (cameraGranted: false, galleryGranted: true),
        onRequestCameraPermission: onRequestCameraPermission,
        onOpenSystemSettings: onOpenSystemSettings,
      ),
    ),
  );
}

ScanProvider _buildScanProvider() => ScanProvider(
      analyzeMeatUseCase: AnalyzeMeatUseCase(
        imageStorageRepository: _DummyImageStorage(),
        classifierRepository: _DummyClassifier(),
        classificationRepository: _DummyClassificationRepo(),
      ),
    );

void main() {
  void setNarrowPhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('SettingsScreen merender seluruh 4 bagian tanpa overflow pada 360dp',
      (WidgetTester tester) async {
    setNarrowPhoneViewport(tester);
    final scanProvider = _buildScanProvider();
    final healthRepo = _FakeServerHealthRepository();

    await tester.pumpWidget(
      _buildTestApp(scanProvider: scanProvider, healthRepo: healthRepo),
    );
    await tester.pumpAndSettle();

    expect(find.text('PENGATURAN'), findsOneWidget);
    expect(find.text('Preferensi Analisis AI'), findsOneWidget);
    expect(find.text('Status Server AI'), findsOneWidget);
    expect(find.text('Izin Perangkat'), findsOneWidget);
    expect(find.text('Panduan & Tentang'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SettingsScreen mengganti model default AI di ScanProvider',
      (WidgetTester tester) async {
    setNarrowPhoneViewport(tester);
    final scanProvider = _buildScanProvider();
    final healthRepo = _FakeServerHealthRepository();

    expect(scanProvider.selectedModel, PredictionModelType.netv2);

    await tester.pumpWidget(
      _buildTestApp(scanProvider: scanProvider, healthRepo: healthRepo),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('SVM'));
    await tester.pumpAndSettle();

    expect(scanProvider.selectedModel, PredictionModelType.svm);
  });

  testWidgets('SettingsScreen menampilkan status server terhubung & error saat dicek',
      (WidgetTester tester) async {
    setNarrowPhoneViewport(tester);
    final scanProvider = _buildScanProvider();
    final healthRepo = _FakeServerHealthRepository()..latencyToReturn = 38;

    await tester.pumpWidget(
      _buildTestApp(scanProvider: scanProvider, healthRepo: healthRepo),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('CEK KONEKSI SERVER'));
    await tester.tap(find.text('CEK KONEKSI SERVER'));
    await tester.pumpAndSettle();

    expect(find.text('TERHUBUNG (38 MS)'), findsOneWidget);

    healthRepo.failureToReturn =
        const NetworkFailure('Server tidak dapat dijangkau.');
    await tester.tap(find.text('CEK KONEKSI SERVER'));
    await tester.pumpAndSettle();

    expect(find.text('TIDAK TERJANGKAU'), findsOneWidget);
    expect(find.text('Server tidak dapat dijangkau.'), findsOneWidget);
  });

  testWidgets('SettingsScreen menampilkan status izin perangkat dan aksi pengaturan sistem',
      (WidgetTester tester) async {
    setNarrowPhoneViewport(tester);
    final scanProvider = _buildScanProvider();
    final healthRepo = _FakeServerHealthRepository();
    var openedSystemSettings = false;

    await tester.pumpWidget(
      _buildTestApp(
        scanProvider: scanProvider,
        healthRepo: healthRepo,
        loadPermissions: () async =>
            (cameraGranted: false, galleryGranted: true),
        onRequestCameraPermission: () async => true,
        onOpenSystemSettings: () async {
          openedSystemSettings = true;
          return true;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('IZINKAN'));
    await tester.pumpAndSettle();

    expect(find.text('IZINKAN'), findsOneWidget);
    expect(find.text('DIIZINKAN'), findsOneWidget);

    await tester.tap(find.text('IZINKAN'));
    await tester.pumpAndSettle();
    expect(find.text('DIIZINKAN'), findsNWidgets(2));

    await tester.ensureVisible(find.text('BUKA PENGATURAN SISTEM'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('BUKA PENGATURAN SISTEM'));
    await tester.pumpAndSettle();
    expect(openedSystemSettings, isTrue);
  });
}
