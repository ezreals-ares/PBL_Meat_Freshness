import '../../domain/models/prediction_model_type.dart';

/// Codec murni Dart untuk konversi antara string eksternal (`'netv2'`, `'svm'`)
/// dan domain enum [PredictionModelType].
class ModelTypeCodec {
  ModelTypeCodec._();

  /// Memetakan string model mentah (DB/API) ke [PredictionModelType],
  /// atau `null` jika kosong/tidak dikenal.
  static PredictionModelType? tryParse(String? raw) {
    switch (raw?.trim().toLowerCase()) {
      case 'svm':
        return PredictionModelType.svm;
      case 'netv2':
        return PredictionModelType.netv2;
      default:
        return null;
    }
  }

  /// Serialisasi [PredictionModelType] ke string penyimpanan.
  static String? encode(PredictionModelType? type) {
    switch (type) {
      case PredictionModelType.netv2:
        return 'netv2';
      case PredictionModelType.svm:
        return 'svm';
      case null:
        return null;
    }
  }
}
