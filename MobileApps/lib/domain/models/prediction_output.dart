import '../../core/constants.dart';
import 'prediction_model_type.dart';

/// Pure Dart entity yang merepresentasikan output mentah dari layanan klasifikasi AI.
class PredictionOutput {
  final String label; // 'fresh' | 'half_fresh' | 'spoiled' | 'non_meat'
  final double confidence; // 0.0 - 1.0
  final PredictionModelType modelType;
  final Map<String, double> probabilities;
  final bool segmentationFallback;
  final bool isMeat;
  final String? rejectionReason;
  final double? meatCoverage;

  const PredictionOutput({
    required this.label,
    required this.confidence,
    required this.modelType,
    this.probabilities = const {},
    this.segmentationFallback = false,
    this.isMeat = true,
    this.rejectionReason,
    this.meatCoverage,
  });

  /// Apakah output menandakan gambar bukan daging.
  bool get isNonMeat => !isMeat || label == AppConstants.nonMeatLabel;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PredictionOutput &&
        other.label == label &&
        other.confidence == confidence &&
        other.modelType == modelType &&
        _mapsEqual(other.probabilities, probabilities) &&
        other.segmentationFallback == segmentationFallback &&
        other.isMeat == isMeat &&
        other.rejectionReason == rejectionReason &&
        other.meatCoverage == meatCoverage;
  }

  @override
  int get hashCode => Object.hash(
        label,
        confidence,
        modelType,
        _mapHash(probabilities),
        segmentationFallback,
        isMeat,
        rejectionReason,
        meatCoverage,
      );

  @override
  String toString() {
    return 'PredictionOutput(label: $label, confidence: $confidence, '
        'modelType: $modelType, isMeat: $isMeat)';
  }

  static bool _mapsEqual(Map<String, double> a, Map<String, double> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  static int _mapHash(Map<String, double> map) {
    final keys = map.keys.toList()..sort();
    return Object.hashAll(keys.map((k) => Object.hash(k, map[k])));
  }
}
