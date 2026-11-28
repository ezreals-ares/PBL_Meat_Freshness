/// Konfigurasi URL, kredensial, dan path endpoint FastAPI.
///
/// Nilai konfigurasi mendukung injeksi saat build/run via `--dart-define`
/// (atau `--dart-define-from-file=env.json`) agar endpoint maupun API key tidak
/// terpaku pada URL sementara di kode sumber. Disimpan di `lib/data/api/`
/// agar detail infrastruktur backend tidak bocor ke `core/`, `domain/`, maupun
/// `presentation/`.
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '',
  );
  static const String apiKeyHeader = 'X-API-Key';

  static const String predictNetV2 = '/predict/netv2';
  static const String predictSvm = '/predict/svm';
  static const String health = '/health';
  static const int maxUploadBytes = 10 * 1024 * 1024;

  static const int _timeoutSeconds = int.fromEnvironment(
    'API_TIMEOUT_SECONDS',
    defaultValue: 30,
  );
  static const Duration timeout = Duration(seconds: _timeoutSeconds);

  /// Menormalisasi [raw] (trim + hapus trailing slash) dan memastikan
  /// `API_BASE_URL` sudah diisi serta memiliki skema `http`/`https` dan host valid.
  static String normalizeAndValidateBaseUrl(String raw) {
    var normalized = raw.trim();
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        raw,
        'baseUrl',
        'API_BASE_URL belum dikonfigurasi. Jalankan/build dengan '
            '--dart-define-from-file=env.json atau '
            '--dart-define=API_BASE_URL=https://... (lihat BUILDGUIDE.md).',
      );
    }

    final uri = Uri.tryParse(normalized);
    final hasValidScheme =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (!hasValidScheme || uri.host.isEmpty) {
      throw ArgumentError.value(
        raw,
        'baseUrl',
        'Base URL API tidak valid. Gunakan format http(s)://host[:port].',
      );
    }

    return normalized;
  }
}
