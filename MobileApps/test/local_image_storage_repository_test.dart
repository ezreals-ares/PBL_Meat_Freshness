import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meatfresh_ai/core/failures.dart';
import 'package:meatfresh_ai/data/repositories/local_image_storage_repository.dart';

void main() {
  late Directory tempRoot;
  late Directory docsDir;
  late Directory sourceDir;
  late LocalImageStorageRepository storage;

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('meatfresh_storage_test_');
    docsDir = Directory('${tempRoot.path}/docs')..createSync();
    sourceDir = Directory('${tempRoot.path}/src')..createSync();
    storage = LocalImageStorageRepository(
      getDocumentsDirectory: () async => docsDir,
    );
  });

  tearDown(() async {
    if (await tempRoot.exists()) {
      await tempRoot.delete(recursive: true);
    }
  });

  test('saveScanImage menyalin file dengan mempertahankan ekstensi .png',
      () async {
    final source = File('${sourceDir.path}/sample.png');
    await source.writeAsBytes([1, 2, 3, 4]);

    final outcome = await storage.saveScanImage(source.path);

    expect(outcome.failure, isNull);
    expect(outcome.path, isNotNull);
    expect(outcome.path, endsWith('.png'));
    expect(await File(outcome.path!).exists(), isTrue);
    expect(await File(outcome.path!).readAsBytes(), [1, 2, 3, 4]);
  });

  test('saveScanImage memakai default .jpg jika file sumber tanpa ekstensi',
      () async {
    final source = File('${sourceDir.path}/raw_capture');
    await source.writeAsBytes([5, 6, 7]);

    final outcome = await storage.saveScanImage(source.path);

    expect(outcome.failure, isNull);
    expect(outcome.path, endsWith('.jpg'));
    expect(await File(outcome.path!).exists(), isTrue);
  });

  test('saveScanImage beruntun menghasilkan nama file unik tanpa tabrakan',
      () async {
    final source = File('${sourceDir.path}/meat.jpg');
    await source.writeAsBytes([0xFF, 0xD8, 0xFF]);

    final first = await storage.saveScanImage(source.path);
    final second = await storage.saveScanImage(source.path);

    expect(first.failure, isNull);
    expect(second.failure, isNull);
    expect(first.path, isNot(equals(second.path)));
    expect(await File(first.path!).exists(), isTrue);
    expect(await File(second.path!).exists(), isTrue);
  });

  test('saveScanImage mengembalikan LocalFailure jika file sumber tidak ada',
      () async {
    final outcome =
        await storage.saveScanImage('${sourceDir.path}/missing.jpg');

    expect(outcome.path, isNull);
    expect(outcome.failure, isA<LocalFailure>());
    expect(outcome.failure?.message, 'File gambar sumber tidak ditemukan.');
  });

  test('deleteScanImage menghapus file yang ada dan mengabaikan file hilang',
      () async {
    final source = File('${sourceDir.path}/to_delete.jpg');
    await source.writeAsBytes([9, 8, 7]);
    final saved = await storage.saveScanImage(source.path);
    expect(await File(saved.path!).exists(), isTrue);

    await storage.deleteScanImage(saved.path!);
    expect(await File(saved.path!).exists(), isFalse);

    // Memanggil ulang pada file yang sudah tidak ada tidak boleh melempar error
    await storage.deleteScanImage(saved.path!);
  });
}
