import 'package:intl/intl.dart';

/// Fungsi murni pemformatan waktu pindai agar dapat diuji tanpa widget
/// dan menjaga presentation bebas dari pemanggilan DateFormat langsung.
String formatScanTimestamp(DateTime dateTime) {
  return DateFormat('dd MMM, HH:mm').format(dateTime);
}
