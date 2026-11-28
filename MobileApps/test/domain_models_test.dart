import 'package:flutter_test/flutter_test.dart';
import 'package:meatfresh_ai/core/constants.dart';
import 'package:meatfresh_ai/domain/models/classification_result.dart';
import 'package:meatfresh_ai/domain/models/prediction_model_type.dart';
import 'package:meatfresh_ai/domain/models/prediction_output.dart';

void main() {
  test('ClassificationResult helper displayName, isNonMeat, dan isLowConfidence konsisten dengan AppConstants',
      () {
    final created = DateTime(2026, 11, 28, 12, 0);

    final fresh = ClassificationResult(
      imagePath: '/a.jpg',
      result: 'fresh',
      confidence: AppConstants.lowConfidenceThreshold,
      createdAt: created,
    );
    final halfFresh = fresh.copyWith(result: 'half_fresh', confidence: 0.49);
    final spoiled = fresh.copyWith(result: 'spoiled');
    final nonMeatByFlag = fresh.copyWith(isMeat: false);
    final nonMeatByLabel = fresh.copyWith(result: AppConstants.nonMeatLabel);
    final unknown = fresh.copyWith(result: 'unknown_label');

    expect(fresh.displayName, 'SEGAR');
    expect(fresh.isLowConfidence, isFalse);
    expect(fresh.isNonMeat, isFalse);

    expect(halfFresh.displayName, 'SETENGAH SEGAR');
    expect(halfFresh.isLowConfidence, isTrue);

    expect(spoiled.displayName, 'BUSUK');
    expect(nonMeatByFlag.isNonMeat, isTrue);
    expect(nonMeatByLabel.isNonMeat, isTrue);
    expect(nonMeatByLabel.displayName, 'BUKAN DAGING');
    expect(unknown.displayName, 'UNKNOWN_LABEL');
  });

  test('ClassificationResult.confidencePercent meng-clamp nilai di luar 0..1 dan NaN',
      () {
    final created = DateTime(2026, 11, 28, 12, 0);
    ClassificationResult withConf(double c) => ClassificationResult(
          imagePath: '/a.jpg',
          result: 'fresh',
          confidence: c,
          createdAt: created,
        );

    expect(withConf(0.875).confidencePercent, '87.5%');
    expect(withConf(-0.25).confidencePercent, '0.0%');
    expect(withConf(1.42).confidencePercent, '100.0%');
    expect(withConf(double.nan).confidencePercent, '0.0%');
    expect(withConf(double.nan).isLowConfidence, isTrue);
  });

  test('ClassificationResult mendukung value equality bebas urutan map dan toString informatif',
      () {
    final created = DateTime(2026, 11, 28, 12, 0);
    final a = ClassificationResult(
      id: 7,
      imagePath: '/a.jpg',
      result: 'fresh',
      confidence: 0.9,
      createdAt: created,
      modelType: PredictionModelType.svm,
      probabilities: {'fresh': 0.9, 'half_fresh': 0.1},
    );
    final b = ClassificationResult(
      id: 7,
      imagePath: '/a.jpg',
      result: 'fresh',
      confidence: 0.9,
      createdAt: created,
      modelType: PredictionModelType.svm,
      probabilities: {'half_fresh': 0.1, 'fresh': 0.9},
    );
    final c = b.copyWith(confidence: 0.8);

    expect(a, equals(b));
    expect(a.hashCode, equals(b.hashCode));
    expect(a, isNot(equals(c)));
    expect(a.toString(), contains('ClassificationResult(id: 7, result: fresh'));
  });

  test('PredictionOutput mendukung isNonMeat, value equality, dan toString', () {
    const out1 = PredictionOutput(
      label: 'half_fresh',
      confidence: 0.82,
      modelType: PredictionModelType.netv2,
      probabilities: {'fresh': 0.1, 'half_fresh': 0.82, 'spoiled': 0.08},
      meatCoverage: 0.64,
    );
    const out2 = PredictionOutput(
      label: 'half_fresh',
      confidence: 0.82,
      modelType: PredictionModelType.netv2,
      probabilities: {'spoiled': 0.08, 'fresh': 0.1, 'half_fresh': 0.82},
      meatCoverage: 0.64,
    );
    const nonMeat = PredictionOutput(
      label: AppConstants.nonMeatLabel,
      confidence: 0.0,
      modelType: PredictionModelType.svm,
    );

    expect(out1.isNonMeat, isFalse);
    expect(nonMeat.isNonMeat, isTrue);
    expect(out1, equals(out2));
    expect(out1.hashCode, equals(out2.hashCode));
    expect(out1, isNot(equals(nonMeat)));
    expect(out1.toString(), contains('PredictionOutput(label: half_fresh'));
  });
}
