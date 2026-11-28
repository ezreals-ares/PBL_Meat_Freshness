import 'package:flutter_test/flutter_test.dart';
import 'package:meatfresh_ai/core/failures.dart';
import 'package:meatfresh_ai/domain/models/classification_result.dart';
import 'package:meatfresh_ai/domain/models/prediction_model_type.dart';
import 'package:meatfresh_ai/domain/models/prediction_output.dart';
import 'package:meatfresh_ai/domain/repositories/classification_repository.dart';
import 'package:meatfresh_ai/domain/repositories/image_storage_repository.dart';
import 'package:meatfresh_ai/domain/repositories/meat_classifier_repository.dart';
import 'package:meatfresh_ai/domain/usecases/analyze_meat_usecase.dart';

class _FakeImageStorageRepository implements ImageStorageRepository {
  Failure? failureToReturn;
  final List<String> deletedPaths = [];

  @override
  Future<({String? path, Failure? failure})> saveScanImage(
      String sourcePath) async {
    if (failureToReturn != null) {
      return (path: null, failure: failureToReturn);
    }
    return (path: '/app_docs/scan_images/copied.jpg', failure: null);
  }

  @override
  Future<void> deleteScanImage(String imagePath) async {
    deletedPaths.add(imagePath);
  }
}

class _FakeMeatClassifierRepository implements MeatClassifierRepository {
  PredictionOutput? nextOutput;
  Failure? failureToReturn;
  PredictionModelType? lastRequestedModel;
  String? lastImagePath;

  @override
  Future<({PredictionOutput? output, Failure? failure})> classify({
    required String imagePath,
    required PredictionModelType modelType,
  }) async {
    lastImagePath = imagePath;
    lastRequestedModel = modelType;
    if (failureToReturn != null) {
      return (output: null, failure: failureToReturn);
    }
    return (output: nextOutput, failure: null);
  }
}

class _FakeClassificationRepository implements ClassificationRepository {
  ClassificationResult? lastSaved;

  @override
  Future<({ClassificationResult? result, Failure? failure})> save(
      ClassificationResult result) async {
    lastSaved = result.copyWith(id: 42);
    return (result: lastSaved, failure: null);
  }

  @override
  Future<({List<ClassificationResult> results, Failure? failure})>
      getAll() async =>
          (results: lastSaved != null ? [lastSaved!] : <ClassificationResult>[], failure: null);

  @override
  Future<Failure?> delete(int id) async => null;

  @override
  Future<Failure?> deleteAll() async => null;
}

void main() {
  late _FakeImageStorageRepository fakeImageStorage;
  late _FakeMeatClassifierRepository fakeClassifier;
  late _FakeClassificationRepository fakeClassificationRepo;
  late AnalyzeMeatUseCase useCase;

  setUp(() {
    fakeImageStorage = _FakeImageStorageRepository();
    fakeClassifier = _FakeMeatClassifierRepository();
    fakeClassificationRepo = _FakeClassificationRepository();
    useCase = AnalyzeMeatUseCase(
      imageStorageRepository: fakeImageStorage,
      classifierRepository: fakeClassifier,
      classificationRepository: fakeClassificationRepo,
    );
  });

  test('AnalyzeMeatUseCase sukses memanggil classifier netv2 dan menyimpan ke repo',
      () async {
    fakeClassifier.nextOutput = const PredictionOutput(
      label: 'fresh',
      confidence: 0.94,
      modelType: PredictionModelType.netv2,
      probabilities: {'fresh': 0.94, 'half_fresh': 0.04, 'spoiled': 0.02},
    );

    final outcome = await useCase(
      sourceImagePath: '/tmp/camera.jpg',
      modelType: PredictionModelType.netv2,
    );

    expect(outcome.failure, isNull);
    expect(fakeClassifier.lastRequestedModel, PredictionModelType.netv2);
    expect(fakeClassifier.lastImagePath, '/app_docs/scan_images/copied.jpg');
    expect(outcome.result?.id, 42);
    expect(outcome.result?.result, 'fresh');
    expect(outcome.result?.confidence, 0.94);
    expect(outcome.result?.modelType, PredictionModelType.netv2);
    expect(outcome.result?.probabilities?['fresh'], 0.94);
    expect(fakeClassificationRepo.lastSaved?.id, 42);
  });

  test('AnalyzeMeatUseCase sukses meneruskan model svm', () async {
    fakeClassifier.nextOutput = const PredictionOutput(
      label: 'half_fresh',
      confidence: 0.78,
      modelType: PredictionModelType.svm,
      probabilities: {'fresh': 0.12, 'half_fresh': 0.78, 'spoiled': 0.10},
      segmentationFallback: true,
    );

    final outcome = await useCase(
      sourceImagePath: '/tmp/gallery.jpg',
      modelType: PredictionModelType.svm,
    );

    expect(outcome.failure, isNull);
    expect(fakeClassifier.lastRequestedModel, PredictionModelType.svm);
    expect(outcome.result?.result, 'half_fresh');
    expect(outcome.result?.displayName, 'SETENGAH SEGAR');
    expect(outcome.result?.modelType, PredictionModelType.svm);
    expect(outcome.result?.segmentationFallback, isTrue);
  });

  test('AnalyzeMeatUseCase mengembalikan NetworkFailure tanpa menyimpan ke DB',
      () async {
    fakeClassifier.failureToReturn =
        const NetworkFailure('Tidak dapat terhubung ke server.');

    final outcome = await useCase(
      sourceImagePath: '/tmp/camera.jpg',
      modelType: PredictionModelType.netv2,
    );

    expect(outcome.result, isNull);
    expect(outcome.failure, isA<NetworkFailure>());
    expect(outcome.failure?.message, 'Tidak dapat terhubung ke server.');
    expect(fakeClassificationRepo.lastSaved, isNull);
    expect(fakeImageStorage.deletedPaths, ['/app_docs/scan_images/copied.jpg']);
  });

  test('AnalyzeMeatUseCase tidak menyimpan objek non-daging ke DB dan menghapus file salinan',
      () async {
    fakeClassifier.nextOutput = const PredictionOutput(
      label: 'non_meat',
      confidence: 0.0,
      modelType: PredictionModelType.svm,
      isMeat: false,
      rejectionReason: 'Objek daging tidak terdeteksi.',
      meatCoverage: 0.01,
    );

    final outcome = await useCase(
      sourceImagePath: '/tmp/meja.jpg',
      modelType: PredictionModelType.svm,
    );

    expect(outcome.failure, isNull);
    expect(outcome.result?.isMeat, isFalse);
    expect(outcome.result?.result, 'non_meat');
    expect(outcome.result?.imagePath, '/tmp/meja.jpg');
    expect(outcome.result?.rejectionReason, 'Objek daging tidak terdeteksi.');
    expect(fakeClassificationRepo.lastSaved, isNull);
    expect(fakeImageStorage.deletedPaths, ['/app_docs/scan_images/copied.jpg']);
  });

  test('AnalyzeMeatUseCase mengembalikan ValidationFailure jika path kosong',
      () async {
    final outcome = await useCase(
      sourceImagePath: '   ',
      modelType: PredictionModelType.netv2,
    );

    expect(outcome.result, isNull);
    expect(outcome.failure, isA<ValidationFailure>());
    expect(fakeClassificationRepo.lastSaved, isNull);
  });
}
