import '../../core/failures.dart';
import '../models/classification_result.dart';
import '../models/prediction_model_type.dart';
import '../repositories/classification_repository.dart';
import '../repositories/image_storage_repository.dart';
import '../repositories/meat_classifier_repository.dart';

/// Use case bisnis untuk alur analisis kesegaran daging:
/// 1. Simpan salinan gambar secara persisten via [ImageStorageRepository].
/// 2. Klasifikasi gambar via [MeatClassifierRepository] (`netv2` atau `svm`).
/// 3. Bangun [ClassificationResult] dan simpan ke riwayat via [ClassificationRepository].
///
/// Setiap langkah yang gagal langsung menghentikan alur dan meneruskan
/// [Failure]-nya — tidak ada exception yang keluar dari use case ini.
class AnalyzeMeatUseCase {
  final ImageStorageRepository _imageStorageRepository;
  final MeatClassifierRepository _classifierRepository;
  final ClassificationRepository _classificationRepository;

  const AnalyzeMeatUseCase({
    required this._imageStorageRepository,
    required this._classifierRepository,
    required this._classificationRepository,
  });

  Future<({ClassificationResult? result, Failure? failure})> call({
    required String sourceImagePath,
    required PredictionModelType modelType,
  }) async {
    if (sourceImagePath.trim().isEmpty) {
      return (
        result: null,
        failure: const ValidationFailure('Gambar belum dipilih.'),
      );
    }

    // 1. Simpan salinan gambar
    final stored = await _imageStorageRepository.saveScanImage(sourceImagePath);
    if (stored.failure != null) {
      return (result: null, failure: stored.failure);
    }

    // 2. Klasifikasi via model yang dipilih
    final prediction = await _classifierRepository.classify(
      imagePath: stored.path!,
      modelType: modelType,
    );
    if (prediction.failure != null) {
      await _imageStorageRepository.deleteScanImage(stored.path!);
      return (result: null, failure: prediction.failure);
    }
    final output = prediction.output!;

    // 2b. Jika bukan daging, hapus salinan permanen dan lewati penyimpanan SQLite
    if (!output.isMeat || output.label == 'non_meat') {
      await _imageStorageRepository.deleteScanImage(stored.path!);
      return (
        result: ClassificationResult(
          imagePath: sourceImagePath,
          result: 'non_meat',
          confidence: output.confidence,
          createdAt: DateTime.now(),
          modelType: output.modelType,
          probabilities:
              output.probabilities.isNotEmpty ? output.probabilities : null,
          segmentationFallback: output.segmentationFallback,
          isMeat: false,
          rejectionReason: output.rejectionReason,
        ),
        failure: null,
      );
    }

    // 3. Simpan ke riwayat
    final result = ClassificationResult(
      imagePath: stored.path!,
      result: output.label,
      confidence: output.confidence,
      createdAt: DateTime.now(),
      modelType: output.modelType,
      probabilities: output.probabilities,
      segmentationFallback: output.segmentationFallback,
    );

    return _classificationRepository.save(result);
  }
}
