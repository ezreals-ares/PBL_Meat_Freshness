/// Base exception class for the app.
class AppException implements Exception {
  final String message;
  final dynamic originalError;

  const AppException(this.message, [this.originalError]);

  @override
  String toString() => 'AppException: $message';
}

/// Thrown when the TFLite model fails to load.
class ModelLoadException extends AppException {
  const ModelLoadException(super.message, [super.originalError]);
}

/// Thrown when inference fails.
class InferenceException extends AppException {
  const InferenceException(super.message, [super.originalError]);
}

/// Thrown when local storage (SQLite) operations fail.
class StorageException extends AppException {
  const StorageException(super.message, [super.originalError]);
}

/// Thrown when sqflite DB operations fail.
class DatabaseException implements Exception {
  final String message;
  const DatabaseException(this.message);
  @override
  String toString() => 'DatabaseException: $message';
}

/// Thrown when image preprocessing fails.
class ImageProcessingException extends AppException {
  const ImageProcessingException(super.message, [super.originalError]);
}

/// Thrown when a required permission (camera/storage) is denied.
class PermissionDeniedException implements Exception {
  final String message;
  const PermissionDeniedException(this.message);
  @override
  String toString() => 'PermissionDeniedException: $message';
}
