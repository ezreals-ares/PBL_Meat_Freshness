import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../core/failures.dart';
import '../../domain/repositories/image_storage_repository.dart';

/// Implementasi [ImageStorageRepository] yang menyalin gambar pindai
/// ke direktori dokumen privat aplikasi.
///
/// [getDocumentsDirectory] dapat disuntikkan saat testing agar tidak
/// bergantung pada platform channel `path_provider`.
class LocalImageStorageRepository implements ImageStorageRepository {
  final Future<Directory> Function() _getDocumentsDirectory;

  const LocalImageStorageRepository({
    Future<Directory> Function()? getDocumentsDirectory,
  }) : _getDocumentsDirectory =
            getDocumentsDirectory ?? getApplicationDocumentsDirectory;

  @override
  Future<({String? path, Failure? failure})> saveScanImage(
      String sourcePath) async {
    try {
      final appDir = await _getDocumentsDirectory();
      final imagesDir = Directory(p.join(appDir.path, 'scan_images'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = p.extension(sourcePath).isNotEmpty
          ? p.extension(sourcePath)
          : '.jpg';
      final destPath = p.join(imagesDir.path, 'scan_$timestamp$ext');

      await File(sourcePath).copy(destPath);
      return (path: destPath, failure: null);
    } catch (_) {
      return (
        path: null,
        failure: const LocalFailure(
            'Gagal menyimpan salinan gambar ke penyimpanan lokal.'),
      );
    }
  }
}
