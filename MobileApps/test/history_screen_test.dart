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

  _FakeClassificationRepository(this.items);

  @override
  Future<Failure?> delete(int id) async => null;

  @override
  Future<Failure?> deleteAll() async => null;

  @override
  Future<({Failure? failure, List<ClassificationResult> results})>
      getAll() async => (results: items, failure: null);

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

  testWidgets('HistoryScreen pencarian mendukung filter berdasarkan ID (#MF-12 & 12)',
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

    expect(find.text('FRESH'), findsOneWidget);
    expect(find.text('SPOILED'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '#MF-12');
    await tester.pumpAndSettle();

    expect(find.text('FRESH'), findsOneWidget);
    expect(find.text('SPOILED'), findsNothing);

    await tester.enterText(find.byType(TextField), '99');
    await tester.pumpAndSettle();

    expect(find.text('FRESH'), findsNothing);
    expect(find.text('SPOILED'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
