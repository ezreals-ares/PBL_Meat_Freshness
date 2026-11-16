import 'prediction_model_type.dart';

/// Domain entity untuk hasil klasifikasi kesegaran daging.
/// Murni Dart — tanpa import Flutter, tanpa serialisasi database.
class ClassificationResult {
  final int? id;
  final String imagePath;
  final String? meatType;
  final String result; // 'fresh' | 'half_fresh' | 'spoiled'
  final double confidence; // 0.0 - 1.0
  final DateTime createdAt;
  final PredictionModelType? modelType;
  final Map<String, double>? probabilities;
  final bool? segmentationFallback;

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
  });

  // ─── Display helpers (pure Dart) ───────────────────────────

  /// Label status yang mudah dibaca.
  String get displayName {
    switch (result) {
      case 'fresh':
        return 'SEGAR';
      case 'half_fresh':
        return 'SETENGAH SEGAR';
      case 'spoiled':
        return 'BUSUK';
      default:
        return result.toUpperCase();
    }
  }

  /// Emoji prefix for accessibility.
  String get statusEmoji {
    switch (result) {
      case 'fresh':
        return '✅';
      case 'half_fresh':
        return '⚠️';
      case 'spoiled':
        return '⛔';
      default:
        return '❓';
    }
  }

  /// Whether the confidence is below the low-confidence threshold.
  bool get isLowConfidence => confidence < 0.5;

  /// Confidence as a percentage string, e.g. "94.0%".
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

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
    );
  }
}
