/// Pilihan model AI untuk klasifikasi kesegaran daging.
///
/// Murni identitas bisnis. Pemetaan ke string/endpoint API ('netv2', 'svm',
/// '/predict/netv2', ...) adalah urusan data layer.
enum PredictionModelType {
  /// MobileNetV2 (CNN).
  netv2,

  /// Support Vector Machine (fitur warna & tekstur).
  svm,
}
