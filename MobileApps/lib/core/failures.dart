/// Failure: representasi error sebagai DATA (bukan exception) yang dikirim
/// dari repository ke domain dan presentation.
///
/// Exception mentah (Dio, sqflite, dart:io) hanya boleh hidup di data layer;
/// repository implementation wajib menangkapnya lalu mengubahnya menjadi
/// salah satu subclass [Failure] di bawah ini.
sealed class Failure {
  const Failure(this.message);

  /// Pesan yang aman ditampilkan ke pengguna.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Tidak ada koneksi, timeout, atau server tidak dapat dijangkau.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Server merespons dengan error (HTTP 4xx/5xx) atau respons tidak valid.
class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode});

  final int? statusCode;
}

/// Kegagalan penyimpanan lokal (SQLite, file system).
class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

/// Input tidak valid sebelum diproses (aturan bisnis di domain).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
