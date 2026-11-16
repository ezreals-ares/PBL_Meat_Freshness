import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatfresh_ai/core/failures.dart';
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
}
