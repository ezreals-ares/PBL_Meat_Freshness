import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatfresh_ai/app.dart';
import 'package:provider/provider.dart';
import 'package:meatfresh_ai/presentation/providers/scan_provider.dart';
import 'package:meatfresh_ai/presentation/providers/history_provider.dart';

void main() {
  testWidgets('App renders without crash', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ScanProvider()),
          ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ],
        child: const MeatFreshApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
