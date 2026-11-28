import 'package:flutter_test/flutter_test.dart';
import 'package:meatfresh_ai/core/failures.dart';
import 'package:meatfresh_ai/data/db/classification_dao.dart';
import 'package:meatfresh_ai/data/models/classification_model.dart';
import 'package:meatfresh_ai/data/repositories/sqlite_classification_repository.dart';
import 'package:meatfresh_ai/domain/models/classification_result.dart';
import 'package:meatfresh_ai/domain/models/prediction_model_type.dart';
import 'package:meatfresh_ai/domain/repositories/image_storage_repository.dart';

class _FakeClassificationDao implements ClassificationDao {
  final Map<int, ClassificationModel> _rows = {};
  int _nextId = 1;
  bool throwOnInsert = false;
  bool throwOnGetAll = false;
  bool throwOnDelete = false;
  bool throwOnDeleteAll = false;

  void seed(ClassificationModel model) {
    final id = model.id ?? _nextId++;
    _rows[id] = model.copyWith(id: id);
  }

  @override
  Future<int> insert(ClassificationModel model) async {
    if (throwOnInsert) throw Exception('DB insert error');
    final id = model.id ?? _nextId++;
    _rows[id] = model.copyWith(id: id);
    return id;
  }

  @override
  Future<List<ClassificationModel>> getAll() async {
    if (throwOnGetAll) throw Exception('DB getAll error');
    final list = _rows.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<String?> getImagePathById(int id) async {
    return _rows[id]?.imagePath;
  }

  @override
  Future<List<String>> getAllImagePaths() async {
    return _rows.values
        .map((m) => m.imagePath)
        .where((p) => p.isNotEmpty)
        .toList();
  }

  @override
  Future<int> delete(int id) async {
    if (throwOnDelete) throw Exception('DB delete error');
    return _rows.remove(id) != null ? 1 : 0;
  }

  @override
  Future<int> deleteAll() async {
    if (throwOnDeleteAll) throw Exception('DB deleteAll error');
    final count = _rows.length;
    _rows.clear();
    return count;
  }
}

class _FakeImageStorage implements ImageStorageRepository {
  final List<String> deletedPaths = [];

  @override
  Future<void> deleteScanImage(String imagePath) async {
    deletedPaths.add(imagePath);
  }

  @override
  Future<({Failure? failure, String? path})> saveScanImage(
          String sourcePath) async =>
      (path: sourcePath, failure: null);
}

ClassificationResult _sampleResult({
  int? id,
  required String imagePath,
}) {
  return ClassificationResult(
    id: id,
    imagePath: imagePath,
    result: 'fresh',
    confidence: 0.92,
    createdAt: DateTime(2026, 11, 28, 12, 0),
    modelType: PredictionModelType.svm,
  );
}

void main() {
  late _FakeClassificationDao dao;
  late _FakeImageStorage imageStorage;
  late SqliteClassificationRepository repository;

  setUp(() {
    dao = _FakeClassificationDao();
    imageStorage = _FakeImageStorage();
    repository = SqliteClassificationRepository(
      dao: dao,
      imageStorageRepository: imageStorage,
    );
  });

  test('save mengembalikan entity dengan ID baru dan memetakan error DB ke LocalFailure',
      () async {
    final ok = await repository.save(_sampleResult(imagePath: '/scans/a.jpg'));
    expect(ok.failure, isNull);
    expect(ok.result?.id, 1);

    dao.throwOnInsert = true;
    final fail =
        await repository.save(_sampleResult(imagePath: '/scans/b.jpg'));
    expect(fail.result, isNull);
    expect(fail.failure, isA<LocalFailure>());
  });

  test('getAll mengonversi model ke entity dan memetakan error DB ke LocalFailure',
      () async {
    dao.seed(ClassificationModel.fromEntity(
      _sampleResult(id: 5, imagePath: '/scans/five.jpg'),
    ));

    final ok = await repository.getAll();
    expect(ok.failure, isNull);
    expect(ok.results, hasLength(1));
    expect(ok.results.first.id, 5);

    dao.throwOnGetAll = true;
    final fail = await repository.getAll();
    expect(fail.results, isEmpty);
    expect(fail.failure, isA<LocalFailure>());
  });

  test('delete menghapus baris DB dan membersihkan file gambar terkait',
      () async {
    dao.seed(ClassificationModel.fromEntity(
      _sampleResult(id: 10, imagePath: '/scans/item10.jpg'),
    ));

    final failure = await repository.delete(10);
    expect(failure, isNull);
    expect(imageStorage.deletedPaths, ['/scans/item10.jpg']);
  });

  test('delete tidak menghapus file gambar jika penghapusan DB gagal', () async {
    dao.seed(ClassificationModel.fromEntity(
      _sampleResult(id: 11, imagePath: '/scans/item11.jpg'),
    ));
    dao.throwOnDelete = true;

    final failure = await repository.delete(11);
    expect(failure, isA<LocalFailure>());
    expect(imageStorage.deletedPaths, isEmpty);
  });

  test('deleteAll menghapus semua baris DB dan seluruh file gambar terkait',
      () async {
    dao.seed(ClassificationModel.fromEntity(
      _sampleResult(id: 1, imagePath: '/scans/one.jpg'),
    ));
    dao.seed(ClassificationModel.fromEntity(
      _sampleResult(id: 2, imagePath: '/scans/two.jpg'),
    ));

    final failure = await repository.deleteAll();
    expect(failure, isNull);
    expect(imageStorage.deletedPaths, ['/scans/one.jpg', '/scans/two.jpg']);
  });

  test('deleteAll tidak menghapus file gambar jika penghapusan DB gagal',
      () async {
    dao.seed(ClassificationModel.fromEntity(
      _sampleResult(id: 1, imagePath: '/scans/one.jpg'),
    ));
    dao.throwOnDeleteAll = true;

    final failure = await repository.deleteAll();
    expect(failure, isA<LocalFailure>());
    expect(imageStorage.deletedPaths, isEmpty);
  });

  test('delete pada ID yang tidak ada (0 baris terhapus) tidak memanggil deleteScanImage',
      () async {
    final failure = await repository.delete(999);
    expect(failure, isNull);
    expect(imageStorage.deletedPaths, isEmpty);
  });

  test('deleteAll menduplikasi-bersihkan path gambar ganda sebelum memanggil deleteScanImage',
      () async {
    dao.seed(ClassificationModel.fromEntity(
      _sampleResult(id: 1, imagePath: '/scans/shared.jpg'),
    ));
    dao.seed(ClassificationModel.fromEntity(
      _sampleResult(id: 2, imagePath: '/scans/shared.jpg'),
    ));
    dao.seed(ClassificationModel.fromEntity(
      _sampleResult(id: 3, imagePath: '/scans/unique.jpg'),
    ));

    final failure = await repository.deleteAll();
    expect(failure, isNull);
    expect(imageStorage.deletedPaths, ['/scans/shared.jpg', '/scans/unique.jpg']);
  });
}
