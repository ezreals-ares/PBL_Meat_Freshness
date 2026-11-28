import 'dart:io';

import 'package:dio/dio.dart';

import '../errors/app_exceptions.dart';
import '../models/prediction_response_model.dart';
import 'api_endpoints.dart';

/// Kontrak remote data source untuk komunikasi HTTP dengan FastAPI.
abstract class MeatPredictionRemoteDataSource {
  Future<PredictionResponseModel> predict({
    required String endpointPath,
    required String imagePath,
  });
}

/// Implementasi [MeatPredictionRemoteDataSource] menggunakan library [Dio]
/// untuk mengirim gambar multipart ke `/predict/netv2` dan `/predict/svm`.
class MeatPredictionRemoteDataSourceImpl
    implements MeatPredictionRemoteDataSource {
  final Dio _dio;

  MeatPredictionRemoteDataSourceImpl({required this._dio});

  @override
  Future<PredictionResponseModel> predict({
    required String endpointPath,
    required String imagePath,
  }) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw const ImageProcessingException('File gambar tidak ditemukan.');
      }

      final fileLength = await file.length();
      if (fileLength == 0) {
        throw const ImageProcessingException('File gambar kosong atau rusak.');
      }
      if (fileLength > ApiEndpoints.maxUploadBytes) {
        throw const ImageProcessingException(
          'Ukuran gambar terlalu besar (maksimal 10MB).',
        );
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.post<dynamic>(
        endpointPath,
        data: formData,
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const InferenceException('Format respons server tidak valid.');
      }

      return PredictionResponseModel.fromJson(data);
    } on AppException {
      rethrow;
    } on FileSystemException catch (e) {
      throw ImageProcessingException('Gagal membaca file gambar lokal.', e);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw InferenceException(
        'Terjadi kesalahan saat memproses prediksi di server.',
        e,
      );
    }
  }

  AppException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return NetworkException(
          'Waktu koneksi ke server habis. Periksa jaringan lalu coba lagi.',
          originalError: e,
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
          originalError: e,
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        return NetworkException(
          _extractErrorMessage(e.response, statusCode),
          statusCode: statusCode,
          originalError: e,
        );
      case DioExceptionType.cancel:
        return NetworkException(
          'Permintaan ke server dibatalkan.',
          originalError: e,
        );
      case DioExceptionType.badCertificate:
        return NetworkException(
          'Sertifikat SSL server tidak valid.',
          originalError: e,
        );
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return NetworkException(
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
            originalError: e,
          );
        }
        return InferenceException(
          'Gagal memproses prediksi dari server.',
          e,
        );
    }
  }

  String _extractErrorMessage(Response<dynamic>? response, int? statusCode) {
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail.trim();
      }
    }

    switch (statusCode) {
      case 400:
        return 'File bukan gambar yang valid.';
      case 401:
        return 'Autentikasi API gagal. Periksa konfigurasi API key.';
      case 403:
        return 'Akses ke layanan prediksi ditolak.';
      case 413:
        return 'Ukuran gambar terlalu besar (maksimal 10MB).';
      case 422:
        return 'Permintaan tidak valid oleh server.';
      case 429:
        final retryAfterRaw = response?.headers.value('retry-after')?.trim();
        final retrySeconds =
            retryAfterRaw != null ? int.tryParse(retryAfterRaw) : null;
        if (retrySeconds != null && retrySeconds > 0) {
          return 'Terlalu banyak permintaan. Coba lagi dalam $retrySeconds detik.';
        }
        return 'Terlalu banyak permintaan. Tunggu beberapa saat lalu coba lagi.';
      default:
        if (statusCode != null && statusCode >= 500) {
          return 'Server mengalami gangguan ($statusCode). Coba lagi nanti.';
        }
        return 'Permintaan gagal dengan kode ${statusCode ?? 'tidak diketahui'}.';
    }
  }
}
