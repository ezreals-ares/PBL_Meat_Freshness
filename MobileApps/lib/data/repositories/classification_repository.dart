import '../../core/failures.dart';
import '../../domain/models/classification_result.dart';
import '../../domain/repositories/classification_repository.dart';
import '../db/classification_dao.dart';
import '../models/classification_model.dart';

/// Implementasi konkret [ClassificationRepository] menggunakan SQLite (sqflite).
///
/// Semua exception dari DAO ditangkap di sini dan dikembalikan sebagai
/// [LocalFailure] — UI tidak pernah menerima error mentah.
class ClassificationRepositoryImpl implements ClassificationRepository {
  final ClassificationDao _dao;

  /// [dao] disuntikkan dari luar agar bisa diganti dengan mock saat testing
  /// (Dependency Inversion Principle).
  ClassificationRepositoryImpl({required this._dao});

  @override
  Future<({ClassificationResult? result, Failure? failure})> save(
      ClassificationResult result) async {
    try {
      final model = ClassificationModel.fromEntity(result);
      final id = await _dao.insert(model);
      return (result: model.copyWith(id: id).toEntity(), failure: null);
    } catch (e) {
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
    } catch (e) {
      return (
        results: const <ClassificationResult>[],
        failure: const LocalFailure('Gagal memuat riwayat klasifikasi.'),
      );
    }
  }

  @override
  Future<Failure?> delete(int id) async {
    try {
      await _dao.delete(id);
      return null;
    } catch (e) {
      return const LocalFailure('Gagal menghapus hasil klasifikasi.');
    }
  }

  @override
  Future<Failure?> deleteAll() async {
    try {
      await _dao.deleteAll();
      return null;
    } catch (e) {
      return const LocalFailure('Gagal menghapus seluruh riwayat.');
    }
  }
}
