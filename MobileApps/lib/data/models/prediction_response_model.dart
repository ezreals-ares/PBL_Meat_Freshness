import '../../domain/models/prediction_model_type.dart';
import '../../domain/models/prediction_output.dart';
import '../errors/app_exceptions.dart';
import 'model_type_codec.dart';

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
  final bool isMeat;
  final String? reason;
  final double? meatCoverage;

  const PredictionResponseModel({
    required this.model,
    required this.label,
    required this.confidence,
    required this.probabilities,
    this.segmentationFallback = false,
    this.isMeat = true,
    this.reason,
    this.meatCoverage,
  });

  /// Normalisasi label dari FastAPI (`half-fresh` -> `half_fresh`)
  /// agar konsisten dengan konvensi domain & aplikasi.
  static String normalizeLabel(String rawLabel) {
    return rawLabel.trim().toLowerCase().replaceAll('-', '_');
  }

  /// Pemetaan string `model` dari API ke enum domain.
  static PredictionModelType parseModelType(String? value) {
    return ModelTypeCodec.tryParse(value) ?? PredictionModelType.netv2;
  }

  factory PredictionResponseModel.fromJson(Map<String, dynamic> json) {
    final rawLabel = json['label'];
    if (rawLabel is! String || rawLabel.trim().isEmpty) {
      throw const InferenceException(
        'Format respons server tidak valid: label prediksi kosong.',
      );
    }

    final normalizedLabel = normalizeLabel(rawLabel);
    final rawProbs = json['probabilities'];

    final normalizedProbs = <String, double>{};
    if (rawProbs is Map) {
      for (final entry in rawProbs.entries) {
        final key = entry.key;
        final value = entry.value;
        if (key is String && value is num) {
          normalizedProbs[normalizeLabel(key)] = value.toDouble();
        }
      }
    }

    final rawModel = json['model'];
    final modelName = (rawModel is String && rawModel.trim().isNotEmpty)
        ? rawModel.trim()
        : 'netv2';
    final rawReasonValue = json['reason'];
    final rawReason =
        rawReasonValue is String ? rawReasonValue.trim() : null;
    final confidenceValue = json['confidence'];
    final fallbackValue = json['segmentation_fallback'];
    final isMeatValue = json['is_meat'];
    final coverageValue = json['meat_coverage'];

    return PredictionResponseModel(
      model: modelName,
      label: normalizedLabel,
      confidence: confidenceValue is num ? confidenceValue.toDouble() : 0.0,
      probabilities: normalizedProbs,
      segmentationFallback: fallbackValue is bool ? fallbackValue : false,
      isMeat:
          isMeatValue is bool ? isMeatValue : (normalizedLabel != 'non_meat'),
      reason: (rawReason != null && rawReason.isNotEmpty) ? rawReason : null,
      meatCoverage: coverageValue is num ? coverageValue.toDouble() : null,
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
      isMeat: isMeat,
      rejectionReason: reason,
      meatCoverage: meatCoverage,
    );
  }
}
