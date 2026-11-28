import 'package:flutter_test/flutter_test.dart';
import 'package:meatfresh_ai/data/models/classification_model.dart';
import 'package:meatfresh_ai/domain/models/classification_result.dart';
import 'package:meatfresh_ai/domain/models/prediction_model_type.dart';

void main() {
  test('ClassificationModel serialisasi toMap/fromMap/toEntity menyimpan detail model & probabilitas',
      () {
    final entity = ClassificationResult(
      id: 7,
      imagePath: '/tmp/meat.jpg',
      result: 'half_fresh',
      confidence: 0.82,
      createdAt: DateTime(2026, 11, 16, 20, 0),
      modelType: PredictionModelType.svm,
      probabilities: const {'fresh': 0.10, 'half_fresh': 0.82, 'spoiled': 0.08},
      segmentationFallback: true,
    );

    final map = ClassificationModel.fromEntity(entity).toMap();
    expect(map['model_used'], 'svm');
    expect(map['segmentation_fallback'], 1);
    expect(map['probabilities_json'], isA<String>());

    final restored = ClassificationModel.fromMap(map).toEntity();
    expect(restored.id, 7);
    expect(restored.modelType, PredictionModelType.svm);
    expect(restored.probabilities?['half_fresh'], 0.82);
    expect(restored.segmentationFallback, isTrue);
  });

  test('ClassificationModel.fromMap kompatibel dengan baris DB versi 1 tanpa kolom baru',
      () {
    final legacyRow = {
      'id': 1,
      'image_path': '/tmp/old.jpg',
      'meat_type': null,
      'result': 'fresh',
      'confidence': 0.91,
      'created_at': '2026-10-12T08:00:00.000',
    };

    final restored = ClassificationModel.fromMap(legacyRow).toEntity();
    expect(restored.modelType, isNull);
    expect(restored.probabilities, isNull);
    expect(restored.segmentationFallback, isNull);
  });

  test('ClassificationModel.fromEntity meneruskan isMeat dan rejectionReason',
      () {
    final entity = ClassificationResult(
      imagePath: '/tmp/table.jpg',
      result: 'non_meat',
      confidence: 0.0,
      createdAt: DateTime(2026, 11, 28, 10, 0),
      modelType: PredictionModelType.netv2,
      isMeat: false,
      rejectionReason: 'Bukan objek daging.',
    );

    final model = ClassificationModel.fromEntity(entity);
    expect(model.isMeat, isFalse);
    expect(model.rejectionReason, 'Bukan objek daging.');
  });

  test('ClassificationModel.fromMap tahan terhadap JSON korup, tanggal invalid, dan model tak dikenal',
      () {
    final corruptedRow = {
      'id': 9,
      'image_path': '/tmp/corrupt.jpg',
      'result': 'fresh',
      'confidence': 0.75,
      'created_at': 'bukan-tanggal-iso',
      'model_used': 'unknown_model_v9',
      'probabilities_json': '{not-valid-json',
    };

    final restored = ClassificationModel.fromMap(corruptedRow).toEntity();
    expect(restored.id, 9);
    expect(restored.modelType, isNull);
    expect(restored.probabilities, isNull);
    expect(restored.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
  });
}
