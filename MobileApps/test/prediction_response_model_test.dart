import 'package:flutter_test/flutter_test.dart';
import 'package:meatfresh_ai/data/models/prediction_response_model.dart';
import 'package:meatfresh_ai/domain/models/prediction_model_type.dart';

void main() {
  test('PredictionResponseModel.fromJson memetakan response netv2 & normalisasi half-fresh',
      () {
    final json = {
      'model': 'netv2',
      'label': 'half-fresh',
      'confidence': 0.87,
      'probabilities': {
        'fresh': 0.08,
        'half-fresh': 0.87,
        'spoiled': 0.05,
      },
    };

    final entity = PredictionResponseModel.fromJson(json).toEntity();

    expect(entity.modelType, PredictionModelType.netv2);
    expect(entity.label, 'half_fresh');
    expect(entity.confidence, 0.87);
    expect(entity.probabilities['half_fresh'], 0.87);
    expect(entity.segmentationFallback, isFalse);
  });

  test('PredictionResponseModel.fromJson memetakan response svm & segmentation_fallback',
      () {
    final json = {
      'model': 'svm',
      'label': 'spoiled',
      'confidence': 0.91,
      'probabilities': {
        'fresh': 0.02,
        'half-fresh': 0.07,
        'spoiled': 0.91,
      },
      'segmentation_fallback': true,
    };

    final entity = PredictionResponseModel.fromJson(json).toEntity();

    expect(entity.modelType, PredictionModelType.svm);
    expect(entity.label, 'spoiled');
    expect(entity.confidence, 0.91);
    expect(entity.segmentationFallback, isTrue);
  });
}
