import 'prediction_model_type.dart';

/// Pure Dart entity yang merepresentasikan output mentah dari layanan klasifikasi AI.
class PredictionOutput {
  final String label; // 'fresh' | 'half_fresh' | 'spoiled'
  final double confidence; // 0.0 - 1.0
  final PredictionModelType modelType;
  final Map<String, double> probabilities;
  final bool segmentationFallback;

  const PredictionOutput({
    required this.label,
    required this.confidence,
    required this.modelType,
    this.probabilities = const {},
    this.segmentationFallback = false,
  });
}
