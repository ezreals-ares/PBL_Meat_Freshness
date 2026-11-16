import 'package:flutter_test/flutter_test.dart';
import 'package:meatfresh_ai/core/format.dart';

void main() {
  test('formatScanTimestamp memformat DateTime ke pola dd MMM, HH:mm', () {
    final dt = DateTime(2026, 11, 16, 9, 5);
    expect(formatScanTimestamp(dt), '16 Nov, 09:05');
  });
}
