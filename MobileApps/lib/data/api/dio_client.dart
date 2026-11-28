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
    String apiKey = ApiEndpoints.apiKey,
    Duration timeout = ApiEndpoints.timeout,
  }) {
    if (timeout <= Duration.zero) {
      throw ArgumentError.value(
        timeout,
        'timeout',
        'Timeout API harus lebih besar dari 0 detik.',
      );
    }

    final normalizedBaseUrl =
        ApiEndpoints.normalizeAndValidateBaseUrl(baseUrl);
    final trimmedKey = apiKey.trim();

    final headers = <String, dynamic>{
      'Accept': 'application/json',
      if (trimmedKey.isNotEmpty) ApiEndpoints.apiKeyHeader: trimmedKey,
    };

    return Dio(
      BaseOptions(
        baseUrl: normalizedBaseUrl,
        connectTimeout: timeout,
        sendTimeout: timeout,
        receiveTimeout: timeout,
        headers: headers,
      ),
    );
  }
}
