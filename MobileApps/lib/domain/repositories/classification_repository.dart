import '../models/classification_result.dart';

/// Kontrak repository untuk operasi klasifikasi daging.
///
/// Domain mendefinisikan APA yang dibutuhkan — data layer yang
/// mengimplementasikan BAGAIMANA. Interface ini tinggal di domain sehingga
/// arah dependensi selalu mengarah ke dalam (Dependency Inversion Principle).
abstract class ClassificationRepository {
  /// Simpan hasil klasifikasi. Mengembalikan hasil dengan ID yang digenerate.
  Future<ClassificationResult> save(ClassificationResult result);

  /// Ambil semua riwayat klasifikasi, terbaru lebih dulu.
  Future<List<ClassificationResult>> getAll();

  /// Ambil satu hasil by ID, null jika tidak ada.
  Future<ClassificationResult?> getById(int id);

  /// Hapus satu hasil by ID.
  Future<void> delete(int id);

  /// Hapus semua riwayat.
  Future<void> deleteAll();

  /// Hitung total riwayat tersimpan.
  Future<int> count();
}
