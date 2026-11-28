import '../../core/constants.dart';
import 'prediction_model_type.dart';

/// Domain entity untuk hasil klasifikasi kesegaran daging.
/// Murni Dart — tanpa import Flutter, tanpa serialisasi database.
class ClassificationResult {
  final int? id;
  final String imagePath;
  final String? meatType;
  final String result; // 'fresh' | 'half_fresh' | 'spoiled' | 'non_meat'
  final double confidence; // 0.0 - 1.0
  final DateTime createdAt;
  final PredictionModelType? modelType;
  final Map<String, double>? probabilities;
  final bool? segmentationFallback;
  final bool isMeat;
  final String? rejectionReason;

  const ClassificationResult({
    this.id,
    required this.imagePath,
    this.meatType,
    required this.result,
    required this.confidence,
    required this.createdAt,
    this.modelType,
    this.probabilities,
    this.segmentationFallback,
    this.isMeat = true,
    this.rejectionReason,
  });

  // ─── Display & business helpers (pure Dart) ────────────────

  /// Apakah hasil mengindikasikan objek bukan daging.
  bool get isNonMeat => !isMeat || result == AppConstants.nonMeatLabel;

  /// Label status yang mudah dibaca.
  String get displayName =>
      AppConstants.labelDisplayNames[result] ?? result.toUpperCase();

  /// Whether the confidence is below the low-confidence threshold.
  bool get isLowConfidence =>
      confidence.isNaN || confidence < AppConstants.lowConfidenceThreshold;

  /// Confidence as a clamped percentage string, e.g. "94.0%".
  String get confidencePercent {
    final safe = confidence.isNaN ? 0.0 : confidence.clamp(0.0, 1.0);
    return '${(safe * 100).toStringAsFixed(1)}%';
  }

  /// Create a copy with updated fields.
  ClassificationResult copyWith({
    int? id,
    String? imagePath,
    String? meatType,
    String? result,
    double? confidence,
    DateTime? createdAt,
    PredictionModelType? modelType,
    Map<String, double>? probabilities,
    bool? segmentationFallback,
    bool? isMeat,
    String? rejectionReason,
  }) {
    return ClassificationResult(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      meatType: meatType ?? this.meatType,
      result: result ?? this.result,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
      modelType: modelType ?? this.modelType,
      probabilities: probabilities ?? this.probabilities,
      segmentationFallback: segmentationFallback ?? this.segmentationFallback,
      isMeat: isMeat ?? this.isMeat,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClassificationResult &&
        other.id == id &&
        other.imagePath == imagePath &&
        other.meatType == meatType &&
        other.result == result &&
        other.confidence == confidence &&
        other.createdAt == createdAt &&
        other.modelType == modelType &&
        _mapsEqual(other.probabilities, probabilities) &&
        other.segmentationFallback == segmentationFallback &&
        other.isMeat == isMeat &&
        other.rejectionReason == rejectionReason;
  }

  @override
  int get hashCode => Object.hash(
        id,
        imagePath,
        meatType,
        result,
        confidence,
        createdAt,
        modelType,
        _mapHash(probabilities),
        segmentationFallback,
        isMeat,
        rejectionReason,
      );

  @override
  String toString() {
    return 'ClassificationResult(id: $id, result: $result, '
        'confidence: $confidence, modelType: $modelType, isMeat: $isMeat)';
  }

  static bool _mapsEqual(Map<String, double>? a, Map<String, double>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null || a.length != b.length) return false;
    for (final entry in a.entries) {
      if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  static int _mapHash(Map<String, double>? map) {
    if (map == null) return 0;
    final keys = map.keys.toList()..sort();
    return Object.hashAll(keys.map((k) => Object.hash(k, map[k])));
  }
}
