import 'package:flutter_test/flutter_test.dart';
import 'package:meatfresh_ai/core/constants.dart';
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
  bool returnNullPathWithoutFailure = false;
  int saveCalls = 0;
  final List<String> deletedPaths = [];

  @override
  Future<({String? path, Failure? failure})> saveScanImage(
      String sourcePath) async {
    saveCalls++;
    if (failureToReturn != null) {
      return (path: null, failure: failureToReturn);
    }
    if (returnNullPathWithoutFailure) {
      return (path: null, failure: null);
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
  bool returnNullOutputWithoutFailure = false;
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
    if (returnNullOutputWithoutFailure) {
      return (output: null, failure: null);
    }
    return (output: nextOutput, failure: null);
  }
}

class _FakeClassificationRepository implements ClassificationRepository {
  ClassificationResult? lastSaved;
  Failure? saveFailureToReturn;

  @override
  Future<({ClassificationResult? result, Failure? failure})> save(
      ClassificationResult result) async {
    if (saveFailureToReturn != null) {
      return (result: null, failure: saveFailureToReturn);
    }
    lastSaved = result.copyWith(id: 42);
    return (result: lastSaved, failure: null);
  }

  @override
  Future<({List<ClassificationResult> results, Failure? failure})>
      getAll() async => (
            results: lastSaved != null ? [lastSaved!] : <ClassificationResult>[],
            failure: null,
          );

  @override
  Future<Failure?> delete(int id) async => null;

  @override
  Future<Failure?> deleteAll() async => null;
}

void main() {
  final fixedNow = DateTime(2026, 11, 28, 15, 0);
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
      clock: () => fixedNow,
    );
  });

  test('AnalyzeMeatUseCase sukses mengklasifikasi sumber netv2 lalu menyimpan gambar & riwayat',
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
    expect(fakeClassifier.lastImagePath, '/tmp/camera.jpg');
    expect(fakeImageStorage.saveCalls, 1);
    expect(outcome.result?.id, 42);
    expect(outcome.result?.imagePath, '/app_docs/scan_images/copied.jpg');
    expect(outcome.result?.result, 'fresh');
    expect(outcome.result?.confidence, 0.94);
    expect(outcome.result?.createdAt, fixedNow);
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
    expect(fakeClassifier.lastImagePath, '/tmp/gallery.jpg');
    expect(fakeImageStorage.saveCalls, 1);
    expect(outcome.result?.result, 'half_fresh');
    expect(outcome.result?.displayName, 'SETENGAH SEGAR');
    expect(outcome.result?.modelType, PredictionModelType.svm);
    expect(outcome.result?.segmentationFallback, isTrue);
  });

  test('AnalyzeMeatUseCase mengembalikan NetworkFailure tanpa menulis storage maupun DB',
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
    expect(fakeImageStorage.saveCalls, 0);
    expect(fakeImageStorage.deletedPaths, isEmpty);
    expect(fakeClassificationRepo.lastSaved, isNull);
  });

  test('AnalyzeMeatUseCase tidak menulis storage/DB saat objek non-daging ditolak',
      () async {
    fakeClassifier.nextOutput = const PredictionOutput(
      label: AppConstants.nonMeatLabel,
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
    expect(outcome.result?.isNonMeat, isTrue);
    expect(outcome.result?.result, AppConstants.nonMeatLabel);
    expect(outcome.result?.imagePath, '/tmp/meja.jpg');
    expect(outcome.result?.createdAt, fixedNow);
    expect(outcome.result?.rejectionReason, 'Objek daging tidak terdeteksi.');
    expect(fakeImageStorage.saveCalls, 0);
    expect(fakeImageStorage.deletedPaths, isEmpty);
    expect(fakeClassificationRepo.lastSaved, isNull);
  });

  test('AnalyzeMeatUseCase mengembalikan ValidationFailure jika path kosong',
      () async {
    final outcome = await useCase(
      sourceImagePath: '   ',
      modelType: PredictionModelType.netv2,
    );

    expect(outcome.result, isNull);
    expect(outcome.failure, isA<ValidationFailure>());
    expect(fakeImageStorage.saveCalls, 0);
    expect(fakeClassificationRepo.lastSaved, isNull);
  });

  test('AnalyzeMeatUseCase menghapus salinan gambar bila penyimpanan DB gagal',
      () async {
    fakeClassifier.nextOutput = const PredictionOutput(
      label: 'fresh',
      confidence: 0.91,
      modelType: PredictionModelType.netv2,
      probabilities: {'fresh': 0.91, 'half_fresh': 0.06, 'spoiled': 0.03},
    );
    fakeClassificationRepo.saveFailureToReturn =
        const LocalFailure('Gagal menyimpan hasil klasifikasi.');

    final outcome = await useCase(
      sourceImagePath: '/tmp/camera.jpg',
      modelType: PredictionModelType.netv2,
    );

    expect(outcome.result, isNull);
    expect(outcome.failure, isA<LocalFailure>());
    expect(fakeImageStorage.saveCalls, 1);
    expect(fakeImageStorage.deletedPaths, ['/app_docs/scan_images/copied.jpg']);
  });

  test('AnalyzeMeatUseCase mengembalikan ServerFailure bila classifier mengembalikan output null tanpa failure',
      () async {
    fakeClassifier.returnNullOutputWithoutFailure = true;

    final outcome = await useCase(
      sourceImagePath: '/tmp/camera.jpg',
      modelType: PredictionModelType.netv2,
    );

    expect(outcome.result, isNull);
    expect(outcome.failure, isA<ServerFailure>());
    expect(fakeImageStorage.saveCalls, 0);
    expect(fakeClassificationRepo.lastSaved, isNull);
  });

  test('AnalyzeMeatUseCase mengembalikan LocalFailure bila storage mengembalikan path null tanpa failure',
      () async {
    fakeClassifier.nextOutput = const PredictionOutput(
      label: 'fresh',
      confidence: 0.9,
      modelType: PredictionModelType.svm,
    );
    fakeImageStorage.returnNullPathWithoutFailure = true;

    final outcome = await useCase(
      sourceImagePath: '/tmp/camera.jpg',
      modelType: PredictionModelType.svm,
    );

    expect(outcome.result, isNull);
    expect(outcome.failure, isA<LocalFailure>());
    expect(fakeImageStorage.saveCalls, 1);
    expect(fakeClassificationRepo.lastSaved, isNull);
  });
}
