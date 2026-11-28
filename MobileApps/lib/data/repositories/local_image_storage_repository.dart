import 'dart:developer' as developer;
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
  static int _sequence = 0;

  final Future<Directory> Function() _getDocumentsDirectory;

  const LocalImageStorageRepository({
    Future<Directory> Function()? getDocumentsDirectory,
  }) : _getDocumentsDirectory =
            getDocumentsDirectory ?? getApplicationDocumentsDirectory;

  @override
  Future<({String? path, Failure? failure})> saveScanImage(
      String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        return (
          path: null,
          failure: const LocalFailure('File gambar sumber tidak ditemukan.'),
        );
      }

      final appDir = await _getDocumentsDirectory();
      final imagesDir = Directory(p.join(appDir.path, 'scan_images'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final timestamp = DateTime.now().microsecondsSinceEpoch;
      final seq = _sequence++;
      final rawExt = p.extension(sourcePath);
      final ext = rawExt.isNotEmpty ? rawExt : '.jpg';
      final destPath = p.join(imagesDir.path, 'scan_${timestamp}_$seq$ext');

      await sourceFile.copy(destPath);
      return (path: destPath, failure: null);
    } catch (e, stackTrace) {
      developer.log(
        'Gagal menyalin gambar ke penyimpanan lokal',
        name: 'LocalImageStorageRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return (
        path: null,
        failure: const LocalFailure(
            'Gagal menyimpan salinan gambar ke penyimpanan lokal.'),
      );
    }
  }

  @override
  Future<void> deleteScanImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e, stackTrace) {
      developer.log(
        'Gagal menghapus file gambar sementara ($imagePath)',
        name: 'LocalImageStorageRepository',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
