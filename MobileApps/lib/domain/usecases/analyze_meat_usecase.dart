import '../../core/constants.dart';
import '../../core/failures.dart';
import '../models/classification_result.dart';
import '../models/prediction_model_type.dart';
import '../repositories/classification_repository.dart';
import '../repositories/image_storage_repository.dart';
import '../repositories/meat_classifier_repository.dart';

/// Use case bisnis untuk alur analisis kesegaran daging:
/// 1. Klasifikasi gambar sumber via [MeatClassifierRepository] (`netv2` atau `svm`).
/// 2. Tolak objek non-daging tanpa menulis salinan permanen maupun SQLite.
/// 3. Untuk daging valid, salin gambar via [ImageStorageRepository], lalu simpan ke [ClassificationRepository].
///
/// Setiap langkah yang gagal langsung menghentikan alur dan meneruskan
/// [Failure]-nya — tidak ada exception yang keluar dari use case ini.
class AnalyzeMeatUseCase {
  static DateTime _defaultClock() => DateTime.now();

  final ImageStorageRepository _imageStorageRepository;
  final MeatClassifierRepository _classifierRepository;
  final ClassificationRepository _classificationRepository;
  final DateTime Function() _clock;

  const AnalyzeMeatUseCase({
    required this._imageStorageRepository,
    required this._classifierRepository,
    required this._classificationRepository,
    DateTime Function()? clock,
  }) : _clock = clock ?? _defaultClock;

  Future<({ClassificationResult? result, Failure? failure})> call({
    required String sourceImagePath,
    required PredictionModelType modelType,
  }) async {
    final trimmedSource = sourceImagePath.trim();
    if (trimmedSource.isEmpty) {
      return (
        result: null,
        failure: const ValidationFailure('Gambar belum dipilih.'),
      );
    }

    // 1. Klasifikasi langsung dari gambar sumber (hindari write/delete I/O saat gagal/non-daging)
    final prediction = await _classifierRepository.classify(
      imagePath: trimmedSource,
      modelType: modelType,
    );
    final output = prediction.output;
    if (prediction.failure != null || output == null) {
      return (
        result: null,
        failure: prediction.failure ??
            const ServerFailure('Respons klasifikasi tidak tersedia.'),
      );
    }

    final now = _clock();

    // 2. Jika bukan daging, kembalikan penolakan tanpa menulis storage maupun SQLite
    if (output.isNonMeat) {
      return (
        result: ClassificationResult(
          imagePath: trimmedSource,
          result: AppConstants.nonMeatLabel,
          confidence: output.confidence,
          createdAt: now,
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

    // 3. Simpan salinan gambar permanen hanya untuk daging valid
    final stored = await _imageStorageRepository.saveScanImage(trimmedSource);
    final storedPath = stored.path;
    if (stored.failure != null || storedPath == null || storedPath.isEmpty) {
      return (
        result: null,
        failure: stored.failure ??
            const LocalFailure('Gagal memperoleh lokasi gambar tersimpan.'),
      );
    }

    // 4. Simpan riwayat ke SQLite; bersihkan file salinan jika save gagal
    final result = ClassificationResult(
      imagePath: storedPath,
      result: output.label,
      confidence: output.confidence,
      createdAt: now,
      modelType: output.modelType,
      probabilities:
          output.probabilities.isNotEmpty ? output.probabilities : null,
      segmentationFallback: output.segmentationFallback,
    );

    final saved = await _classificationRepository.save(result);
    if (saved.failure != null) {
      await _imageStorageRepository.deleteScanImage(storedPath);
    }
    return saved;
  }
}
