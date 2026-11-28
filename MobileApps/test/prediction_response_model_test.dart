import 'package:flutter_test/flutter_test.dart';
import 'package:meatfresh_ai/data/errors/app_exceptions.dart';
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
    expect(entity.isMeat, isTrue);
    expect(entity.rejectionReason, isNull);
  });

  test('PredictionResponseModel.fromJson memetakan penolakan non-daging', () {
    final json = {
      'model': 'netv2',
      'is_meat': false,
      'label': 'non_meat',
      'confidence': 0.0,
      'probabilities': <String, dynamic>{},
      'reason': 'Objek daging tidak terdeteksi pada gambar.',
      'meat_coverage': 0.02,
    };

    final entity = PredictionResponseModel.fromJson(json).toEntity();

    expect(entity.modelType, PredictionModelType.netv2);
    expect(entity.isMeat, isFalse);
    expect(entity.label, 'non_meat');
    expect(entity.rejectionReason, 'Objek daging tidak terdeteksi pada gambar.');
    expect(entity.meatCoverage, 0.02);
  });

  test('PredictionResponseModel.fromJson melempar InferenceException bila label kosong atau hilang',
      () {
    expect(
      () => PredictionResponseModel.fromJson(<String, dynamic>{}),
      throwsA(isA<InferenceException>()),
    );
    expect(
      () => PredictionResponseModel.fromJson({'label': '   ', 'confidence': 0.5}),
      throwsA(isA<InferenceException>()),
    );
  });

  test('PredictionResponseModel.fromJson menangani probabilities non-Map secara aman',
      () {
    final entity = PredictionResponseModel.fromJson({
      'model': 'svm',
      'label': 'fresh',
      'confidence': 0.9,
      'probabilities': ['invalid'],
    }).toEntity();

    expect(entity.modelType, PredictionModelType.svm);
    expect(entity.label, 'fresh');
    expect(entity.probabilities, isEmpty);
  });

  test('PredictionResponseModel.fromJson aman saat field opsional bertipe JSON tak terduga',
      () {
    final entity = PredictionResponseModel.fromJson({
      'model': 42,
      'label': 'half-fresh',
      'confidence': 'bad',
      'probabilities': {'fresh': 'invalid', 'half-fresh': 0.8},
      'segmentation_fallback': 'yes',
      'is_meat': 1,
      'reason': 123,
      'meat_coverage': 'low',
    }).toEntity();

    expect(entity.modelType, PredictionModelType.netv2);
    expect(entity.label, 'half_fresh');
    expect(entity.confidence, 0.0);
    expect(entity.probabilities, {'half_fresh': 0.8});
    expect(entity.segmentationFallback, isFalse);
    expect(entity.isMeat, isTrue);
    expect(entity.rejectionReason, isNull);
    expect(entity.meatCoverage, isNull);
  });
}
