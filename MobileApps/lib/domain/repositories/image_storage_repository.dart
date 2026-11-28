import '../../core/failures.dart';

/// Kontrak domain untuk penyimpanan file gambar pindai secara persisten.
///
/// Memisahkan detail sistem file (`path_provider`, `dart:io`) dari domain dan presentation.
abstract class ImageStorageRepository {
  /// Salin gambar ke penyimpanan privat aplikasi.
  /// Berhasil → `path` berisi lokasi baru; gagal → `failure` terisi.
  Future<({String? path, Failure? failure})> saveScanImage(String sourcePath);

  /// Hapus file gambar pindai jika tidak lagi diperlukan (misalnya saat gagal atau non-daging).
  Future<void> deleteScanImage(String imagePath);
}
