class AppConstants {
  static const String appName = 'MeatFresh AI';
  static const List<String> labels = ['fresh', 'half_fresh', 'spoiled'];
  static const Map<String, String> labelDisplayNames = {
    'fresh': 'SEGAR',
    'half_fresh': 'SETENGAH SEGAR',
    'spoiled': 'BUSUK',
  };
  static const double lowConfidenceThreshold = 0.5;
  static const String disclaimer =
      'Ini hanya indikasi awal berdasarkan analisis gambar. '
      'Bukan pengganti uji laboratorium atau penilaian ahli.';
}
