import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatfresh_ai/core/failures.dart';
import 'package:meatfresh_ai/data/api/api_endpoints.dart';
import 'package:meatfresh_ai/data/api/dio_client.dart';
import 'package:meatfresh_ai/data/api/meat_prediction_remote_datasource.dart';
import 'package:meatfresh_ai/data/repositories/remote_meat_classifier_repository.dart';
import 'package:meatfresh_ai/domain/models/prediction_model_type.dart';

class _FakeHttpClientAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions options) onFetch;
  RequestOptions? lastOptions;

  _FakeHttpClientAdapter(this.onFetch);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (requestStream != null) {
      await requestStream.drain<void>();
    }
    lastOptions = options;
    return onFetch(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(Map<String, dynamic> body, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  late Directory tempDir;
  late File tempImage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('meatfresh_dio_test_');
    tempImage = File('${tempDir.path}/sample.jpg');
    await tempImage.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('RemoteMeatClassifierRepository memanggil /predict/netv2 via Dio', () async {
    final adapter = _FakeHttpClientAdapter(
      (_) => _jsonResponse({
        'model': 'netv2',
        'label': 'fresh',
        'confidence': 0.95,
        'probabilities': {
          'fresh': 0.95,
          'half-fresh': 0.03,
          'spoiled': 0.02,
        },
      }, 200),
    );
    final dio = DioClient.create(baseUrl: 'https://example.test')
      ..httpClientAdapter = adapter;

    final repo = RemoteMeatClassifierRepository(
      remoteDataSource: MeatPredictionRemoteDataSourceImpl(dio: dio),
    );

    final outcome = await repo.classify(
      imagePath: tempImage.path,
      modelType: PredictionModelType.netv2,
    );

    expect(outcome.failure, isNull);
    expect(adapter.lastOptions?.path, '/predict/netv2');
    expect(adapter.lastOptions?.method, 'POST');
    expect(adapter.lastOptions?.data, isA<FormData>());
    expect(outcome.output?.modelType, PredictionModelType.netv2);
    expect(outcome.output?.label, 'fresh');
    expect(outcome.output?.confidence, 0.95);
  });

  test('RemoteMeatClassifierRepository memanggil /predict/svm via Dio', () async {
    final adapter = _FakeHttpClientAdapter(
      (_) => _jsonResponse({
        'model': 'svm',
        'label': 'half-fresh',
        'confidence': 0.81,
        'probabilities': {
          'fresh': 0.10,
          'half-fresh': 0.81,
          'spoiled': 0.09,
        },
        'segmentation_fallback': true,
      }, 200),
    );
    final dio = DioClient.create(baseUrl: 'https://example.test')
      ..httpClientAdapter = adapter;

    final repo = RemoteMeatClassifierRepository(
      remoteDataSource: MeatPredictionRemoteDataSourceImpl(dio: dio),
    );

    final outcome = await repo.classify(
      imagePath: tempImage.path,
      modelType: PredictionModelType.svm,
    );

    expect(outcome.failure, isNull);
    expect(adapter.lastOptions?.path, '/predict/svm');
    expect(outcome.output?.modelType, PredictionModelType.svm);
    expect(outcome.output?.label, 'half_fresh');
    expect(outcome.output?.segmentationFallback, isTrue);
  });

  test('RemoteMeatClassifierRepository mengembalikan ServerFailure saat HTTP 413',
      () async {
    final adapter = _FakeHttpClientAdapter(
      (_) => _jsonResponse({'detail': 'File terlalu besar (maks 10MB)'}, 413),
    );
    final dio = DioClient.create(baseUrl: 'https://example.test')
      ..httpClientAdapter = adapter;

    final repo = RemoteMeatClassifierRepository(
      remoteDataSource: MeatPredictionRemoteDataSourceImpl(dio: dio),
    );

    final outcome = await repo.classify(
      imagePath: tempImage.path,
      modelType: PredictionModelType.netv2,
    );

    expect(outcome.output, isNull);
    expect(
      outcome.failure,
      isA<ServerFailure>()
          .having((f) => f.statusCode, 'statusCode', 413)
          .having((f) => f.message, 'message', 'File terlalu besar (maks 10MB)'),
    );
  });

  test('DioClient.create menormalisasi trailing slash dan menyisipkan X-API-Key',
      () async {
    final adapter = _FakeHttpClientAdapter(
      (_) => _jsonResponse({
        'model': 'svm',
        'label': 'fresh',
        'confidence': 0.9,
        'probabilities': {'fresh': 0.9, 'half-fresh': 0.08, 'spoiled': 0.02},
      }, 200),
    );
    final dio = DioClient.create(
      baseUrl: '  https://api.example.test///  ',
      apiKey: '  rahasia-123  ',
    )..httpClientAdapter = adapter;

    expect(dio.options.baseUrl, 'https://api.example.test');
    expect(dio.options.headers[ApiEndpoints.apiKeyHeader], 'rahasia-123');

    final repo = RemoteMeatClassifierRepository(
      remoteDataSource: MeatPredictionRemoteDataSourceImpl(dio: dio),
    );
    await repo.classify(
      imagePath: tempImage.path,
      modelType: PredictionModelType.svm,
    );

    expect(
      adapter.lastOptions?.headers[ApiEndpoints.apiKeyHeader],
      'rahasia-123',
    );
  });

  test('DioClient.create tidak menyisipkan X-API-Key saat apiKey kosong', () {
    final dio = DioClient.create(
      baseUrl: 'https://api.example.test',
      apiKey: '   ',
    );

    expect(dio.options.headers.containsKey(ApiEndpoints.apiKeyHeader), isFalse);
  });

  test('DioClient.create melempar ArgumentError saat baseUrl tidak valid', () {
    for (final invalidUrl in const ['', '   ', '/', 'api.example.com', 'ftp://example.com']) {
      expect(
        () => DioClient.create(baseUrl: invalidUrl),
        throwsArgumentError,
        reason: 'URL "$invalidUrl" seharusnya ditolak',
      );
    }
  });

  test('Mode ketat: ApiEndpoints.baseUrl kosong tanpa dart-define dan DioClient.create() melempar ArgumentError',
      () {
    expect(ApiEndpoints.baseUrl, isEmpty);
    expect(
      () => DioClient.create(),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message.toString(),
          'message',
          contains('API_BASE_URL'),
        ),
      ),
    );
  });

  test('RemoteMeatClassifierRepository memetakan HTTP 401 dan 403 ke ServerFailure',
      () async {
    final adapter401 = _FakeHttpClientAdapter(
      (_) => ResponseBody.fromString('Unauthorized', 401),
    );
    final dio401 = DioClient.create(baseUrl: 'https://example.test')
      ..httpClientAdapter = adapter401;
    final repo401 = RemoteMeatClassifierRepository(
      remoteDataSource: MeatPredictionRemoteDataSourceImpl(dio: dio401),
    );

    final outcome401 = await repo401.classify(
      imagePath: tempImage.path,
      modelType: PredictionModelType.svm,
    );
    expect(outcome401.output, isNull);
    expect(
      outcome401.failure,
      isA<ServerFailure>()
          .having((f) => f.statusCode, 'statusCode', 401)
          .having(
            (f) => f.message,
            'message',
            'Autentikasi API gagal. Periksa konfigurasi API key.',
          ),
    );

    final adapter403 = _FakeHttpClientAdapter(
      (_) => ResponseBody.fromString('Forbidden', 403),
    );
    final dio403 = DioClient.create(baseUrl: 'https://example.test')
      ..httpClientAdapter = adapter403;
    final repo403 = RemoteMeatClassifierRepository(
      remoteDataSource: MeatPredictionRemoteDataSourceImpl(dio: dio403),
    );

    final outcome403 = await repo403.classify(
      imagePath: tempImage.path,
      modelType: PredictionModelType.netv2,
    );
    expect(outcome403.output, isNull);
    expect(
      outcome403.failure,
      isA<ServerFailure>()
          .having((f) => f.statusCode, 'statusCode', 403)
          .having(
            (f) => f.message,
            'message',
            'Akses ke layanan prediksi ditolak.',
          ),
    );
  });

  test('RemoteMeatClassifierRepository memetakan HTTP 429 + Retry-After ke ServerFailure',
      () async {
    final adapter = _FakeHttpClientAdapter(
      (_) => ResponseBody.fromString(
        'Too Many Requests',
        429,
        headers: {
          'retry-after': ['15'],
        },
      ),
    );
    final dio = DioClient.create(baseUrl: 'https://example.test')
      ..httpClientAdapter = adapter;
    final repo = RemoteMeatClassifierRepository(
      remoteDataSource: MeatPredictionRemoteDataSourceImpl(dio: dio),
    );

    final outcome = await repo.classify(
      imagePath: tempImage.path,
      modelType: PredictionModelType.svm,
    );

    expect(outcome.output, isNull);
    expect(
      outcome.failure,
      isA<ServerFailure>()
          .having((f) => f.statusCode, 'statusCode', 429)
          .having(
            (f) => f.message,
            'message',
            'Terlalu banyak permintaan. Coba lagi dalam 15 detik.',
          ),
    );
  });

  test('RemoteMeatClassifierRepository memetakan respons HTTP 200 non-daging ke PredictionOutput',
      () async {
    final adapter = _FakeHttpClientAdapter(
      (_) => _jsonResponse({
        'model': 'svm',
        'is_meat': false,
        'label': 'non_meat',
        'confidence': 0.0,
        'probabilities': <String, dynamic>{},
        'reason': 'Objek daging tidak terdeteksi pada gambar.',
        'meat_coverage': 0.02,
      }, 200),
    );
    final dio = DioClient.create(baseUrl: 'https://example.test')
      ..httpClientAdapter = adapter;
    final repo = RemoteMeatClassifierRepository(
      remoteDataSource: MeatPredictionRemoteDataSourceImpl(dio: dio),
    );

    final outcome = await repo.classify(
      imagePath: tempImage.path,
      modelType: PredictionModelType.svm,
    );

    expect(outcome.failure, isNull);
    expect(outcome.output?.isMeat, isFalse);
    expect(outcome.output?.label, 'non_meat');
    expect(
      outcome.output?.rejectionReason,
      'Objek daging tidak terdeteksi pada gambar.',
    );
  });

  test('DioClient.create melempar ArgumentError saat timeout <= 0', () {
    expect(
      () => DioClient.create(
        baseUrl: 'https://example.test',
        timeout: Duration.zero,
      ),
      throwsArgumentError,
    );
    expect(
      () => DioClient.create(
        baseUrl: 'https://example.test',
        timeout: const Duration(seconds: -5),
      ),
      throwsArgumentError,
    );
  });

  test('RemoteMeatClassifierRepository gagal cepat (LocalFailure) pada file hilang, 0-byte, atau >10MB tanpa memanggil network',
      () async {
    var networkCalled = false;
    final adapter = _FakeHttpClientAdapter((_) {
      networkCalled = true;
      return _jsonResponse({'label': 'fresh', 'confidence': 0.9}, 200);
    });
    final dio = DioClient.create(baseUrl: 'https://example.test')
      ..httpClientAdapter = adapter;
    final repo = RemoteMeatClassifierRepository(
      remoteDataSource: MeatPredictionRemoteDataSourceImpl(dio: dio),
    );

    // 1. File hilang
    final missingOutcome = await repo.classify(
      imagePath: '${tempDir.path}/tidak_ada.jpg',
      modelType: PredictionModelType.netv2,
    );
    expect(missingOutcome.failure, isA<LocalFailure>());
    expect(missingOutcome.failure?.message, 'File gambar tidak ditemukan.');

    // 2. File 0 byte
    final emptyFile = File('${tempDir.path}/empty.jpg');
    await emptyFile.writeAsBytes(const []);
    final emptyOutcome = await repo.classify(
      imagePath: emptyFile.path,
      modelType: PredictionModelType.netv2,
    );
    expect(emptyOutcome.failure, isA<LocalFailure>());
    expect(emptyOutcome.failure?.message, 'File gambar kosong atau rusak.');

    // 3. File > 10MB (gunakan truncate agar cepat tanpa alokasi buffer 10MB)
    final oversizedFile = File('${tempDir.path}/oversized.jpg');
    final raf = await oversizedFile.open(mode: FileMode.write);
    await raf.truncate(ApiEndpoints.maxUploadBytes + 1);
    await raf.close();
    final oversizedOutcome = await repo.classify(
      imagePath: oversizedFile.path,
      modelType: PredictionModelType.svm,
    );
    expect(oversizedOutcome.failure, isA<LocalFailure>());
    expect(
      oversizedOutcome.failure?.message,
      'Ukuran gambar terlalu besar (maksimal 10MB).',
    );
    expect(networkCalled, isFalse);
  });

  test('RemoteMeatClassifierRepository memetakan connectionTimeout & SocketException ke NetworkFailure',
      () async {
    final timeoutAdapter = _FakeHttpClientAdapter((options) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionTimeout,
      );
    });
    final timeoutDio = DioClient.create(baseUrl: 'https://example.test')
      ..httpClientAdapter = timeoutAdapter;
    final timeoutRepo = RemoteMeatClassifierRepository(
      remoteDataSource: MeatPredictionRemoteDataSourceImpl(dio: timeoutDio),
    );

    final timeoutOutcome = await timeoutRepo.classify(
      imagePath: tempImage.path,
      modelType: PredictionModelType.netv2,
    );
    expect(timeoutOutcome.failure, isA<NetworkFailure>());

    final socketAdapter = _FakeHttpClientAdapter((options) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.unknown,
        error: const SocketException('Connection refused'),
      );
    });
    final socketDio = DioClient.create(baseUrl: 'https://example.test')
      ..httpClientAdapter = socketAdapter;
    final socketRepo = RemoteMeatClassifierRepository(
      remoteDataSource: MeatPredictionRemoteDataSourceImpl(dio: socketDio),
    );

    final socketOutcome = await socketRepo.classify(
      imagePath: tempImage.path,
      modelType: PredictionModelType.svm,
    );
    expect(socketOutcome.failure, isA<NetworkFailure>());
  });

  test('RemoteMeatClassifierRepository memetakan HTTP 500 dengan detail spasi kosong ke fallback ServerFailure',
      () async {
    final adapter = _FakeHttpClientAdapter(
      (_) => _jsonResponse({'detail': '   '}, 500),
    );
    final dio = DioClient.create(baseUrl: 'https://example.test')
      ..httpClientAdapter = adapter;
    final repo = RemoteMeatClassifierRepository(
      remoteDataSource: MeatPredictionRemoteDataSourceImpl(dio: dio),
    );

    final outcome = await repo.classify(
      imagePath: tempImage.path,
      modelType: PredictionModelType.netv2,
    );

    expect(outcome.output, isNull);
    expect(
      outcome.failure,
      isA<ServerFailure>()
          .having((f) => f.statusCode, 'statusCode', 500)
          .having(
            (f) => f.message,
            'message',
            'Server mengalami gangguan (500). Coba lagi nanti.',
          ),
    );
  });

  test('RemoteMeatClassifierRepository memetakan respons HTTP 200 tanpa label ke ServerFailure',
      () async {
    final adapter = _FakeHttpClientAdapter(
      (_) => _jsonResponse({'confidence': 0.8}, 200),
    );
    final dio = DioClient.create(baseUrl: 'https://example.test')
      ..httpClientAdapter = adapter;
    final repo = RemoteMeatClassifierRepository(
      remoteDataSource: MeatPredictionRemoteDataSourceImpl(dio: dio),
    );

    final outcome = await repo.classify(
      imagePath: tempImage.path,
      modelType: PredictionModelType.netv2,
    );

    expect(outcome.output, isNull);
    expect(outcome.failure, isA<ServerFailure>());
  });
}
