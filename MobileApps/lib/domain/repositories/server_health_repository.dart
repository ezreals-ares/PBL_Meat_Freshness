import '../../core/failures.dart';

/// Kontrak domain untuk memeriksa keterjangkauan server inferensi AI.
abstract interface class ServerHealthRepository {
  /// Menguji koneksi ke server backend.
  /// Berhasil → `latencyMs` berisi waktu respons (ms); gagal → `failure` terisi.
  Future<({int? latencyMs, Failure? failure})> checkHealth();
}
