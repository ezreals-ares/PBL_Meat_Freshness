import '../../core/failures.dart';
import '../models/classification_result.dart';

/// Kontrak repository riwayat klasifikasi.
///
/// Domain mendefinisikan APA yang dibutuhkan — data layer yang
/// mengimplementasikan BAGAIMANA. Error dikembalikan sebagai [Failure]
/// di dalam record, tidak pernah dilempar sebagai exception.
abstract interface class ClassificationRepository {
  /// Simpan hasil klasifikasi. Berhasil → `result` berisi data dengan ID baru.
  Future<({ClassificationResult? result, Failure? failure})> save(
      ClassificationResult result);

  /// Ambil semua riwayat, terbaru lebih dulu.
  Future<({List<ClassificationResult> results, Failure? failure})> getAll();

  /// Hapus satu hasil by ID. Mengembalikan `null` jika berhasil.
  Future<Failure?> delete(int id);

  /// Hapus semua riwayat. Mengembalikan `null` jika berhasil.
  Future<Failure?> deleteAll();
}
