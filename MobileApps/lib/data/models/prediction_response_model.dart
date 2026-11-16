import '../../domain/models/prediction_model_type.dart';
import '../../domain/models/prediction_output.dart';

/// Data model untuk mem-parsing JSON response dari endpoint FastAPI
/// (`/predict/netv2` dan `/predict/svm`).
///
/// Semua detail format API (string 'netv2'/'svm', label 'half-fresh',
/// key 'segmentation_fallback') hanya dikenal di kelas ini.
class PredictionResponseModel {
  final String model;
  final String label;
  final double confidence;
  final Map<String, double> probabilities;
  final bool segmentationFallback;

  const PredictionResponseModel({
    required this.model,
    required this.label,
    required this.confidence,
    required this.probabilities,
    this.segmentationFallback = false,
  });

  /// Normalisasi label dari FastAPI (`half-fresh` -> `half_fresh`)
  /// agar konsisten dengan konvensi domain & aplikasi.
  static String normalizeLabel(String rawLabel) {
    return rawLabel.trim().toLowerCase().replaceAll('-', '_');
  }

  /// Pemetaan string `model` dari API ke enum domain.
  static PredictionModelType parseModelType(String? value) {
    switch (value?.toLowerCase()) {
      case 'svm':
        return PredictionModelType.svm;
      case 'netv2':
      default:
        return PredictionModelType.netv2;
    }
  }

  factory PredictionResponseModel.fromJson(Map<String, dynamic> json) {
    final rawLabel = json['label'] as String? ?? '';
    final rawProbs = json['probabilities'] as Map<String, dynamic>? ?? const {};

    final normalizedProbs = <String, double>{};
    for (final entry in rawProbs.entries) {
      final value = entry.value;
      if (value is num) {
        normalizedProbs[normalizeLabel(entry.key)] = value.toDouble();
      }
    }

    return PredictionResponseModel(
      model: json['model'] as String? ?? 'netv2',
      label: normalizeLabel(rawLabel),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      probabilities: normalizedProbs,
      segmentationFallback: json['segmentation_fallback'] as bool? ?? false,
    );
  }

  /// Konversi model data menjadi pure Dart domain entity [PredictionOutput].
  PredictionOutput toEntity() {
    return PredictionOutput(
      label: label,
      confidence: confidence,
      modelType: parseModelType(model),
      probabilities: Map<String, double>.unmodifiable(probabilities),
      segmentationFallback: segmentationFallback,
    );
  }
}
