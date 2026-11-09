import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatfresh_ai/app.dart';
import 'package:provider/provider.dart';
import 'package:meatfresh_ai/data/db/classification_dao.dart';
import 'package:meatfresh_ai/data/ml/tflite_service.dart';
import 'package:meatfresh_ai/data/repositories/classification_repository.dart';
import 'package:meatfresh_ai/presentation/providers/scan_provider.dart';
import 'package:meatfresh_ai/presentation/providers/history_provider.dart';

void main() {
  testWidgets('App renders without crash', (WidgetTester tester) async {
    // Rakit dependensi konkret (sama seperti main.dart) untuk test.
    // Untuk unit test yang terisolasi, gunakan repository palsu (mock).
    final dao = ClassificationDao();
    final repository = ClassificationRepositoryImpl(dao: dao);
    final tfliteService = TfliteService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ScanProvider(
              tfliteService: tfliteService,
              repository: repository,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => HistoryProvider(
              repository: repository,
            ),
          ),
        ],
        child: const MeatFreshApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
