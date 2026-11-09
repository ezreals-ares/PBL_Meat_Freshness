import '../../core/errors/app_exceptions.dart';
import '../../domain/models/classification_result.dart';
import '../../domain/repositories/classification_repository.dart';
import '../db/classification_dao.dart';
import '../models/classification_model.dart';

/// Implementasi konkret [ClassificationRepository] menggunakan SQLite (sqflite).
///
/// Semua exception dari DAO dikonversi ke [StorageException] sebelum
/// sampai ke domain/presentation — UI tidak pernah menerima error mentah.
class ClassificationRepositoryImpl implements ClassificationRepository {
  final ClassificationDao _dao;

  /// [dao] disuntikkan dari luar agar bisa diganti dengan mock saat testing
  /// (Dependency Inversion Principle).
  ClassificationRepositoryImpl({required this._dao});

  @override
  Future<ClassificationResult> save(ClassificationResult result) async {
    try {
      final model = ClassificationModel.fromEntity(result);
      final id = await _dao.insert(model);
      return model.copyWith(id: id);
    } catch (e) {
      throw StorageException('Failed to save classification result.', e);
    }
  }

  @override
  Future<List<ClassificationResult>> getAll() async {
    try {
      return await _dao.getAll();
    } catch (e) {
      throw StorageException('Failed to load classification history.', e);
    }
  }

  @override
  Future<ClassificationResult?> getById(int id) async {
    try {
      return await _dao.getById(id);
    } catch (e) {
      throw StorageException('Failed to load classification result.', e);
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      await _dao.delete(id);
    } catch (e) {
      throw StorageException('Failed to delete classification result.', e);
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _dao.deleteAll();
    } catch (e) {
      throw StorageException('Failed to clear classification history.', e);
    }
  }

  @override
  Future<int> count() async {
    try {
      return await _dao.count();
    } catch (e) {
      throw StorageException('Failed to count classification results.', e);
    }
  }
}
