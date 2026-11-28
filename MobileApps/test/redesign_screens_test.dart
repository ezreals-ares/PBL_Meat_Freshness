import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatfresh_ai/core/failures.dart';
import 'package:meatfresh_ai/data/api/dio_client.dart';
import 'package:meatfresh_ai/data/api/meat_prediction_remote_datasource.dart';
import 'package:meatfresh_ai/data/repositories/local_image_storage_repository.dart';
import 'package:meatfresh_ai/data/repositories/remote_meat_classifier_repository.dart';
import 'package:meatfresh_ai/domain/models/classification_result.dart';
import 'package:meatfresh_ai/domain/models/prediction_model_type.dart';
import 'package:meatfresh_ai/domain/repositories/classification_repository.dart';
import 'package:meatfresh_ai/domain/usecases/analyze_meat_usecase.dart';
import 'package:meatfresh_ai/presentation/capture/capture_screen.dart';
import 'package:meatfresh_ai/presentation/home/home_screen.dart';
import 'package:meatfresh_ai/presentation/preview/preview_screen.dart';
import 'package:meatfresh_ai/presentation/providers/history_provider.dart';
import 'package:meatfresh_ai/presentation/providers/scan_provider.dart';
import 'package:meatfresh_ai/presentation/result/result_screen.dart';
import 'package:meatfresh_ai/presentation/shell_screen.dart';
import 'package:meatfresh_ai/presentation/theme/theme.dart';
import 'package:provider/provider.dart';

class _StubClassificationRepository implements ClassificationRepository {
  @override
  Future<Failure?> delete(int id) async => null;

  @override
  Future<Failure?> deleteAll() async => null;

  @override
  Future<({Failure? failure, List<ClassificationResult> results})>
      getAll() async => (results: const <ClassificationResult>[], failure: null);

  @override
  Future<({Failure? failure, ClassificationResult? result})> save(
    ClassificationResult result,
  ) async =>
      (result: result, failure: null);
}

ScanProvider _buildScanProvider() {
  final dio = DioClient.create(baseUrl: 'https://example.test');
  final remote = MeatPredictionRemoteDataSourceImpl(dio: dio);
  final classifier = RemoteMeatClassifierRepository(remoteDataSource: remote);
  final useCase = AnalyzeMeatUseCase(
    imageStorageRepository: const LocalImageStorageRepository(),
    classifierRepository: classifier,
    classificationRepository: _StubClassificationRepository(),
  );
  return ScanProvider(analyzeMeatUseCase: useCase);
}

void main() {
  void setNarrowPhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('HomeScreen & ShellScreen render bersih pada layar 360dp dan menjaga label E2E',
      (WidgetTester tester) async {
    setNarrowPhoneViewport(tester);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => _buildScanProvider()),
          ChangeNotifierProvider(
            create: (_) =>
                HistoryProvider(repository: _StubClassificationRepository()),
          ),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const ShellScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('MEATFRESH AI'), findsOneWidget);
    expect(find.textContaining('CEK KESEGARAN'), findsOneWidget);
    expect(find.text('MULAI CEK'), findsOneWidget);
    expect(find.text('SEMUA SCAN'), findsOneWidget);
    expect(find.text('DARI GALERI'), findsOneWidget);
    expect(find.text('REKOMENDASI PENYIMPANAN'), findsOneWidget);
    expect(find.textContaining('INSPEKSI KEAMANAN PANGAN'), findsOneWidget);
    expect(find.text('BERANDA'), findsOneWidget);
    expect(find.text('PINDAI'), findsOneWidget);
    expect(find.text('RIWAYAT'), findsWidgets);
    expect(tester.takeException(), isNull);

    // Pindah ke tab PINDAI
    await tester.tap(find.text('PINDAI'));
    await tester.pump();
    expect(find.text('ANALISIS VISUAL'), findsOneWidget);
    expect(find.text('TARGET: DAGING'), findsOneWidget);
    expect(find.text('AMBIL FOTO'), findsOneWidget);
    expect(find.text('UNGGAH FOTO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('PreviewScreen memilih model AI dan render tanpa overflow pada 360dp',
      (WidgetTester tester) async {
    setNarrowPhoneViewport(tester);
    final scanProvider = _buildScanProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: scanProvider,
        child: MaterialApp(
          theme: buildAppTheme(),
          home: PreviewScreen(
            imagePath: '/nonexistent/sample.jpg',
            onAnalyze: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('PRATINJAU FOTO'), findsOneWidget);
    expect(find.text('PILIH MODEL AI'), findsOneWidget);
    expect(find.text('MOBILENET V2'), findsOneWidget);
    expect(find.text('SVM'), findsOneWidget);
    expect(find.text('ANALISIS (NETV2)'), findsOneWidget);
    expect(find.text('PILIH FOTO LAIN'), findsOneWidget);

    await tester.tap(find.text('SVM'));
    await tester.pump();
    expect(find.text('ANALISIS (SVM)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ResultScreen menampilkan semua kartu status tanpa overflow pada 360dp',
      (WidgetTester tester) async {
    setNarrowPhoneViewport(tester);

    final sampleResult = ClassificationResult(
      id: 42,
      imagePath: '/nonexistent/sample.jpg',
      meatType: 'Daging Sapi',
      result: 'fresh',
      confidence: 0.94,
      createdAt: DateTime(2026, 11, 21, 10, 30),
      modelType: PredictionModelType.svm,
      probabilities: const {
        'fresh': 0.94,
        'half_fresh': 0.04,
        'spoiled': 0.02,
      },
      segmentationFallback: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: ResultScreen(result: sampleResult),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('HASIL PINDAI'), findsOneWidget);
    expect(find.text('PINDAI #MF-42'), findsOneWidget);
    expect(find.text('MODEL: SVM'), findsOneWidget);
    expect(find.text('DISTRIBUSI PROBABILITAS'), findsOneWidget);
    expect(find.text('PINDAI LAGI'), findsOneWidget);
    expect(find.text('SELESAI'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ResultScreen menampilkan kartu penolakan non-daging pada 360dp',
      (WidgetTester tester) async {
    setNarrowPhoneViewport(tester);

    final nonMeatResult = ClassificationResult(
      imagePath: '/nonexistent/meja.jpg',
      result: 'non_meat',
      confidence: 0.0,
      createdAt: DateTime(2026, 11, 24, 20, 30),
      modelType: PredictionModelType.svm,
      isMeat: false,
      rejectionReason: 'Objek daging tidak terdeteksi pada gambar.',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: ResultScreen(result: nonMeatResult),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('TIDAK DISIMPAN KE RIWAYAT'), findsOneWidget);
    expect(find.text('OBJEK BUKAN DAGING'), findsOneWidget);
    expect(find.text('Objek daging tidak terdeteksi pada gambar.'), findsOneWidget);
    expect(find.text('AMBIL ULANG FOTO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HomeScreen & CaptureScreen standalone render bersih',
      (WidgetTester tester) async {
    setNarrowPhoneViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const HomeScreen(),
      ),
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const CaptureScreen(),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
