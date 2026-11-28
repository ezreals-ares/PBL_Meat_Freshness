import 'dart:developer' as developer;

import '../../core/failures.dart';
import '../../domain/models/classification_result.dart';
import '../../domain/repositories/classification_repository.dart';
import '../../domain/repositories/image_storage_repository.dart';
import '../db/classification_dao.dart';
import '../models/classification_model.dart';

/// Implementasi konkret [ClassificationRepository] menggunakan SQLite (sqflite)
/// serta sinkronisasi pembersihan file gambar lokal saat catatan dihapus.
///
/// Semua exception dari DAO ditangkap di sini dan dikembalikan sebagai
/// [LocalFailure] — UI tidak pernah menerima error mentah.
class SqliteClassificationRepository implements ClassificationRepository {
  final ClassificationDao _dao;
  final ImageStorageRepository? _imageStorageRepository;

  /// [dao] disuntikkan dari luar agar bisa diganti dengan mock saat testing
  /// (Dependency Inversion Principle).
  SqliteClassificationRepository({
    required this._dao,
    this._imageStorageRepository,
  });

  @override
  Future<({ClassificationResult? result, Failure? failure})> save(
      ClassificationResult result) async {
    try {
      final model = ClassificationModel.fromEntity(result);
      final id = await _dao.insert(model);
      return (result: model.copyWith(id: id).toEntity(), failure: null);
    } catch (e, stackTrace) {
      developer.log(
        'Gagal menyimpan hasil klasifikasi',
        name: 'SqliteClassificationRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return (
        result: null,
        failure: const LocalFailure('Gagal menyimpan hasil klasifikasi.'),
      );
    }
  }

  @override
  Future<({List<ClassificationResult> results, Failure? failure})>
      getAll() async {
    try {
      final models = await _dao.getAll();
      return (results: models.map((m) => m.toEntity()).toList(), failure: null);
    } catch (e, stackTrace) {
      developer.log(
        'Gagal memuat riwayat klasifikasi',
        name: 'SqliteClassificationRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return (
        results: const <ClassificationResult>[],
        failure: const LocalFailure('Gagal memuat riwayat klasifikasi.'),
      );
    }
  }

  @override
  Future<Failure?> delete(int id) async {
    try {
      final imagePath = await _dao.getImagePathById(id);
      final deletedRows = await _dao.delete(id);
      if (deletedRows > 0 &&
          imagePath != null &&
          imagePath.isNotEmpty &&
          _imageStorageRepository != null) {
        await _imageStorageRepository.deleteScanImage(imagePath);
      }
      return null;
    } catch (e, stackTrace) {
      developer.log(
        'Gagal menghapus hasil klasifikasi (id=$id)',
        name: 'SqliteClassificationRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return const LocalFailure('Gagal menghapus hasil klasifikasi.');
    }
  }

  @override
  Future<Failure?> deleteAll() async {
    try {
      final imagePaths = await _dao.getAllImagePaths();
      await _dao.deleteAll();
      if (_imageStorageRepository != null && imagePaths.isNotEmpty) {
        await Future.wait(
          imagePaths.toSet().map(_imageStorageRepository.deleteScanImage),
        );
      }
      return null;
    } catch (e, stackTrace) {
      developer.log(
        'Gagal menghapus seluruh riwayat',
        name: 'SqliteClassificationRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return const LocalFailure('Gagal menghapus seluruh riwayat.');
    }
  }
}
