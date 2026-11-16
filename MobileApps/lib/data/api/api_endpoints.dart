/// Konfigurasi URL dan path endpoint FastAPI.
///
/// Disimpan di `lib/data/api/` agar detail infrastruktur backend
/// tidak bocor ke `core/`, `domain/`, maupun `presentation/`.
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl =
      'https://8000-agq6gs7y3hvdgpfa33qiputqnm.instabox.tech';
  static const String predictNetV2 = '/predict/netv2';
  static const String predictSvm = '/predict/svm';
  static const Duration timeout = Duration(seconds: 30);
}
