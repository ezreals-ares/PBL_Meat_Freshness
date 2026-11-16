/// Exception internal DATA LAYER.
///
/// Exception di file ini hanya boleh dilempar & ditangkap di dalam `lib/data/`.
/// Repository implementation wajib mengubahnya menjadi `Failure`
/// (lihat `core/failures.dart`) sebelum dikembalikan ke domain/presentation.
class AppException implements Exception {
  final String message;
  final dynamic originalError;

  const AppException(this.message, [this.originalError]);

  @override
  String toString() => 'AppException: $message';
}

/// Inferensi di server gagal atau respons tidak dapat diproses.
class InferenceException extends AppException {
  const InferenceException(super.message, [super.originalError]);
}

/// Request jaringan gagal atau server mengembalikan HTTP error.
class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException(
    String message, {
    this.statusCode,
    dynamic originalError,
  }) : super(message, originalError);

  @override
  String toString() =>
      'NetworkException(${statusCode ?? 'no-status'}): $message';
}

/// File gambar tidak ditemukan atau gagal diproses sebelum dikirim.
class ImageProcessingException extends AppException {
  const ImageProcessingException(super.message, [super.originalError]);
}
