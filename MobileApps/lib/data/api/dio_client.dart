import 'package:dio/dio.dart';

import 'api_endpoints.dart';

/// Factory untuk mengonfigurasi instance [Dio] yang digunakan Data Layer.
///
/// Menjaga konfigurasi base URL, timeout, dan header default terpusat
/// di satu tempat (Single Responsibility Principle).
class DioClient {
  DioClient._();

  static Dio create({
    String baseUrl = ApiEndpoints.baseUrl,
    Duration timeout = ApiEndpoints.timeout,
  }) {
    final normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    return Dio(
      BaseOptions(
        baseUrl: normalizedBaseUrl,
        connectTimeout: timeout,
        sendTimeout: timeout,
        receiveTimeout: timeout,
        headers: const {
          'Accept': 'application/json',
        },
      ),
    );
  }
}
