import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatfresh_ai/core/failures.dart';
import 'package:meatfresh_ai/domain/models/classification_result.dart';
import 'package:meatfresh_ai/domain/models/prediction_model_type.dart';
import 'package:meatfresh_ai/domain/repositories/classification_repository.dart';
import 'package:meatfresh_ai/presentation/history/history_screen.dart';
import 'package:meatfresh_ai/presentation/providers/history_provider.dart';
import 'package:provider/provider.dart';

class _FakeClassificationRepository implements ClassificationRepository {
  final List<ClassificationResult> items;
  final List<int> deletedIds = [];
  int deleteAllCalls = 0;

  _FakeClassificationRepository(List<ClassificationResult> initialItems)
      : items = List<ClassificationResult>.from(initialItems);

  @override
  Future<Failure?> delete(int id) async {
    deletedIds.add(id);
    items.removeWhere((item) => item.id == id);
    return null;
  }

  @override
  Future<Failure?> deleteAll() async {
    deleteAllCalls++;
    items.clear();
    return null;
  }

  @override
  Future<({Failure? failure, List<ClassificationResult> results})>
      getAll() async => (results: List<ClassificationResult>.from(items), failure: null);

  @override
  Future<({Failure? failure, ClassificationResult? result})> save(
          ClassificationResult result) async =>
      (result: result, failure: null);
}

void main() {
  testWidgets(
      'HistoryScreen card half_fresh tidak overflow pada layar sempit (360dp)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeRepo = _FakeClassificationRepository([
      ClassificationResult(
        id: 12,
        imagePath: '/nonexistent/sample.jpg',
        result: 'half_fresh',
        confidence: 0.99,
        createdAt: DateTime(2026, 11, 20, 20, 45),
        modelType: PredictionModelType.netv2,
      ),
    ]);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => HistoryProvider(repository: fakeRepo),
        child: const MaterialApp(
          home: HistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('HALF-FRESH'), findsOneWidget);
    expect(find.text('99% KEPERCAYAAN'), findsOneWidget);
    expect(find.text('NETV2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HistoryScreen hanya menampilkan 4 chip filter tanpa search bar dan ikon filter',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeRepo = _FakeClassificationRepository([
      ClassificationResult(
        id: 12,
        imagePath: '/nonexistent/sample12.jpg',
        result: 'fresh',
        confidence: 0.95,
        createdAt: DateTime(2026, 11, 20, 20, 45),
        modelType: PredictionModelType.svm,
      ),
      ClassificationResult(
        id: 99,
        imagePath: '/nonexistent/sample99.jpg',
        result: 'spoiled',
        confidence: 0.88,
        createdAt: DateTime(2026, 11, 20, 19, 10),
        modelType: PredictionModelType.netv2,
      ),
    ]);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => HistoryProvider(repository: fakeRepo),
        child: const MaterialApp(
          home: HistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(find.byIcon(Icons.tune_rounded), findsNothing);
    expect(find.text('SEMUA (2)'), findsOneWidget);
    expect(find.text('SEGAR (1)'), findsOneWidget);
    expect(find.text('SETENGAH SEGAR (0)'), findsOneWidget);
    expect(find.text('BUSUK (1)'), findsOneWidget);

    expect(find.text('FRESH'), findsOneWidget);
    expect(find.text('SPOILED'), findsOneWidget);

    await tester.tap(find.text('SEGAR (1)'));
    await tester.pumpAndSettle();
    expect(find.text('FRESH'), findsOneWidget);
    expect(find.text('SPOILED'), findsNothing);

    await tester.ensureVisible(find.text('BUSUK (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('BUSUK (1)'));
    await tester.pumpAndSettle();
    expect(find.text('FRESH'), findsNothing);
    expect(find.text('SPOILED'), findsOneWidget);

    await tester.ensureVisible(find.text('SETENGAH SEGAR (0)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SETENGAH SEGAR (0)'));
    await tester.pumpAndSettle();
    expect(find.text('BELUM ADA CEK'), findsOneWidget);
    expect(find.text('RESET FILTER'), findsOneWidget);

    await tester.tap(find.text('RESET FILTER'));
    await tester.pumpAndSettle();
    expect(find.text('FRESH'), findsOneWidget);
    expect(find.text('SPOILED'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HistoryScreen mendukung pilih item, pilih semua, dan hapus terpilih',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeRepo = _FakeClassificationRepository([
      ClassificationResult(
        id: 12,
        imagePath: '/nonexistent/sample12.jpg',
        result: 'fresh',
        confidence: 0.95,
        createdAt: DateTime(2026, 11, 20, 20, 45),
        modelType: PredictionModelType.svm,
      ),
      ClassificationResult(
        id: 99,
        imagePath: '/nonexistent/sample99.jpg',
        result: 'spoiled',
        confidence: 0.88,
        createdAt: DateTime(2026, 11, 20, 19, 10),
        modelType: PredictionModelType.netv2,
      ),
    ]);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => HistoryProvider(repository: fakeRepo),
        child: const MaterialApp(
          home: HistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('PILIH'));
    await tester.pumpAndSettle();

    expect(find.text('PILIH SEMUA'), findsOneWidget);
    expect(find.text('0 DIPILIH'), findsOneWidget);
    expect(find.text('HAPUS SEMUA'), findsNothing);
    expect(find.text('BATAL'), findsOneWidget);

    await tester.tap(find.text('BATAL'));
    await tester.pumpAndSettle();
    expect(find.text('PILIH'), findsOneWidget);
    expect(find.text('HAPUS SEMUA'), findsOneWidget);

    await tester.tap(find.text('PILIH'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('FRESH'));
    await tester.pumpAndSettle();
    expect(find.text('1 DIPILIH'), findsOneWidget);
    expect(find.text('HAPUS TERPILIH (1)'), findsOneWidget);

    await tester.tap(find.text('PILIH SEMUA'));
    await tester.pumpAndSettle();
    expect(find.text('2 DIPILIH'), findsOneWidget);
    expect(find.text('BATAL PILIH'), findsOneWidget);

    await tester.tap(find.text('BATAL PILIH'));
    await tester.pumpAndSettle();
    expect(find.text('0 DIPILIH'), findsOneWidget);

    await tester.tap(find.text('FRESH'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('HAPUS TERPILIH (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Hapus 1 Catatan Terpilih?'), findsOneWidget);
    await tester.tap(find.text('HAPUS'));
    await tester.pumpAndSettle();

    expect(fakeRepo.deletedIds, [12]);
    expect(find.text('FRESH'), findsNothing);
    expect(find.text('SPOILED'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HistoryScreen mendukung tombol HAPUS SEMUA dengan konfirmasi',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeRepo = _FakeClassificationRepository([
      ClassificationResult(
        id: 1,
        imagePath: '/nonexistent/sample1.jpg',
        result: 'fresh',
        confidence: 0.91,
        createdAt: DateTime(2026, 11, 20, 20, 45),
      ),
      ClassificationResult(
        id: 2,
        imagePath: '/nonexistent/sample2.jpg',
        result: 'spoiled',
        confidence: 0.85,
        createdAt: DateTime(2026, 11, 20, 19, 10),
      ),
    ]);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => HistoryProvider(repository: fakeRepo),
        child: const MaterialApp(
          home: HistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('HAPUS SEMUA'));
    await tester.pumpAndSettle();

    expect(find.text('Hapus Semua Riwayat?'), findsOneWidget);
    await tester.tap(find.text('HAPUS SEMUA').last);
    await tester.pumpAndSettle();

    expect(fakeRepo.deleteAllCalls, 1);
    expect(find.text('BELUM ADA CEK'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
