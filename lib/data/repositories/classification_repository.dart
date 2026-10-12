import '../../core/errors/app_exceptions.dart';
import '../../domain/models/classification_result.dart';
import '../db/classification_dao.dart';

/// Repository wrapping the DAO with error handling.
class ClassificationRepository {
  final ClassificationDao _dao = ClassificationDao();

  /// Save a classification result. Returns the result with its generated id.
  Future<ClassificationResult> save(ClassificationResult result) async {
    try {
      final id = await _dao.insert(result);
      return result.copyWith(id: id);
    } catch (e) {
      throw StorageException('Failed to save classification result.', e);
    }
  }

  /// Get all classification results, newest first.
  Future<List<ClassificationResult>> getAll() async {
    try {
      return await _dao.getAll();
    } catch (e) {
      throw StorageException('Failed to load classification history.', e);
    }
  }

  /// Get a single result by id.
  Future<ClassificationResult?> getById(int id) async {
    try {
      return await _dao.getById(id);
    } catch (e) {
      throw StorageException('Failed to load classification result.', e);
    }
  }

  /// Delete a result by id.
  Future<void> delete(int id) async {
    try {
      await _dao.delete(id);
    } catch (e) {
      throw StorageException('Failed to delete classification result.', e);
    }
  }

  /// Delete all results.
  Future<void> deleteAll() async {
    try {
      await _dao.deleteAll();
    } catch (e) {
      throw StorageException('Failed to clear classification history.', e);
    }
  }

  /// Get count of saved results.
  Future<int> count() async {
    try {
      return await _dao.count();
    } catch (e) {
      throw StorageException('Failed to count classification results.', e);
    }
  }
}
