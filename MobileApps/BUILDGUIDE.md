# Panduan Build & Konfigurasi APK — MeatFresh AI

Panduan ini menjelaskan cara menyiapkan konfigurasi lingkungan (`env.json`), menyinkronkannya dengan backend `FastAPI/`, serta menjalankan dan mem-build APK aplikasi Flutter **MeatFresh AI** (`MobileApps/`).

> **Penting:** Mulai versi konfigurasi ketat (`API_BASE_URL` tanpa nilai *hardcode* di [lib/data/api/api_endpoints.dart](lib/data/api/api_endpoints.dart)), aplikasi wajib dijalankan atau di-build dengan menyertakan `API_BASE_URL` melalui `--dart-define-from-file=env.json` atau `--dart-define=API_BASE_URL=...`.

---

## 1. Prasyarat

- **Flutter SDK** `^3.13.1` dan **Dart SDK** (`flutter doctor` bersih untuk Android toolchain).
- **Android SDK & `adb`** terpasang apabila ingin menginstal APK langsung ke perangkat/emulator.
- **Backend FastAPI** (`../FastAPI`) aktif dan dapat diakses (misalnya via Instabox / server HTTPS publik atau localhost untuk emulator).
- Jalankan seluruh perintah Flutter di bawah ini dari direktori `MobileApps/`:

```powershell
cd C:\Code\PBL_Meat_Freshness\MobileApps
```

---

## 2. Konfigurasi Lingkungan (`env.json`)

Salin berkas template [env.example.json](env.example.json) menjadi `env.json` di folder `MobileApps/`:

```powershell
Copy-Item env.example.json env.json
```

> Berkas `env.json` sudah terdaftar di [.gitignore](.gitignore) sehingga kredensial lokal tidak ikut ter-commit ke Git.

### Daftar Variabel

| Variabel | Wajib | Default | Keterangan |
|---|---|---|---|
| `API_BASE_URL` | **Ya** | `""` | Base URL backend FastAPI berformat `http://` atau `https://` (tanpa path endpoint). |
| `API_KEY` | Opsional* | `""` | Kunci rahasia yang dikirim via header `X-API-Key`. *Wajib sama dengan `API_KEY` di server apabila autentikasi FastAPI aktif.* |
| `API_TIMEOUT_SECONDS` | Tidak | `"30"` | Batas waktu tunggu (`connectTimeout`, `sendTimeout`, `receiveTimeout`) dalam detik. |

### Contoh Isi `env.json`

**a. Untuk Server Publik / Instabox (Rekomendasi):**

```json
{
  "API_BASE_URL": "https://8000-agq6gs7y3hvdgpfa33qiputqnm.instabox.tech",
  "API_KEY": "ganti-dengan-api-key-rahasia",
  "API_TIMEOUT_SECONDS": "30"
}
```

**b. Untuk Server Lokal di Komputer yang Sama:**

- **Android Emulator:** gunakan `http://10.0.2.2:8000` (IP alias komputer host dari dalam emulator).
- **HP Fisik (Wi-Fi yang sama):** gunakan IP LAN komputer, misalnya `http://192.168.1.10:8000`.

---

## 3. Menjalankan Aplikasi (Development)

**Menggunakan `env.json` (disarankan):**

```powershell
flutter run --dart-define-from-file=env.json
```

**Atau langsung lewat flag `--dart-define`:**

```powershell
flutter run `
  --dart-define=API_BASE_URL=https://api.example.com `
  --dart-define=API_KEY=ganti-dengan-api-key-rahasia
```

---

## 4. Build APK & App Bundle

Pastikan dependensi sudah terunduh (`flutter pub get`) sebelum build.

### a. Build APK Debug

Cocok untuk pengujian langsung di perangkat atau suite E2E Appium (`AutomationTest`):

```powershell
flutter build apk --debug --dart-define-from-file=env.json
```

Lokasi hasil build:
`MobileApps/build/app/outputs/flutter-apk/app-debug.apk`

### b. Build APK Release

Cocok untuk distribusi uji coba / APK siap pasang:

```powershell
flutter build apk --release --dart-define-from-file=env.json
```

Lokasi hasil build:
`MobileApps/build/app/outputs/flutter-apk/app-release.apk`

> **Catatan Rilis:** Konfigurasi `release` pada [android/app/build.gradle.kts](android/app/build.gradle.kts) saat ini masih memakai `debug` signing key. Sebelum unggah ke Google Play Store, siapkan *release keystore* resmi dan bangun **Android App Bundle (`.aab`)**:
>
> ```powershell
> flutter build appbundle --release --dart-define-from-file=env.json
> ```

### c. Instalasi APK ke Perangkat Android via ADB

1. Pastikan perangkat terdeteksi:
   ```powershell
   adb devices
   ```
2. Pasang APK hasil build:
   ```powershell
   adb install -r build\app\outputs\flutter-apk\app-release.apk
   ```

---

## 5. Sinkronisasi dengan Backend FastAPI

Agar aplikasi dan server saling terhubung dengan aman:

1. Di server / Instabox, masuk ke folder `FastAPI/` dan buat `.env` dari [../FastAPI/.env.example](../FastAPI/.env.example):
   ```env
   API_KEY=ganti-dengan-api-key-rahasia
   REQUIRE_API_KEY=true
   RATE_LIMIT_ENABLED=true
   RATE_LIMIT_REQUESTS=30
   RATE_LIMIT_WINDOW_SECONDS=60
   ```
   Pastikan nilai `API_KEY` di `FastAPI/.env` **sama persis** dengan `API_KEY` di `MobileApps/env.json`.
2. Jalankan ulang layanan backend:
   ```bash
   docker compose up -d --build
   ```
3. Verifikasi endpoint backend:
   ```bash
   # Healthcheck terbuka (harus 200 OK)
   curl https://api.example.com/health

   # Tanpa API key (harus ditolak 401)
   curl -X POST https://api.example.com/predict/svm -F "file=@contoh.jpg"

   # Dengan API key yang benar (harus 200 OK)
   curl -X POST https://api.example.com/predict/svm ^
     -H "X-API-Key: ganti-dengan-api-key-rahasia" ^
     -F "file=@contoh.jpg"
   ```

---

## 6. Menjalankan Pengujian & Troubleshooting

### Analisis Statis & Unit/Widget Test

Unit test mem-bypass `API_BASE_URL` melalui URL mock lokal (`https://example.test`), sehingga dapat dijalankan langsung tanpa `env.json`:

```powershell
flutter analyze
flutter test
```

### Troubleshooting Umum

| Gejala / Pesan Error | Penyebab | Solusi |
|---|---|---|
| `ArgumentError: API_BASE_URL belum dikonfigurasi` | Menjalankan `flutter run`/`build` tanpa `--dart-define-from-file=env.json` atau `--dart-define=API_BASE_URL=...` | Buat `MobileApps/env.json` lalu sertakan `--dart-define-from-file=env.json`. |
| `ArgumentError: Base URL API tidak valid` | `API_BASE_URL` tidak diawali `http://` atau `https://`, atau host kosong | Periksa penulisan URL (mis. `https://api.example.com`, tanpa spasi). |
| `HTTP 401 — Autentikasi API gagal` | `API_KEY` di `env.json` kosong atau tidak cocok dengan `API_KEY` di server FastAPI | Samakan `API_KEY` di `MobileApps/env.json` dan `FastAPI/.env`, lalu build ulang APK (karena `--dart-define` dikompilasi ke dalam aplikasi). |
| `HTTP 429 — Terlalu banyak permintaan` | Melebihi batas `RATE_LIMIT_REQUESTS` dalam satu `RATE_LIMIT_WINDOW_SECONDS` | Tunggu sesuai durasi pada pesan error (`Retry-After`) atau sesuaikan kuota di `FastAPI/.env`. |
| `Tidak dapat terhubung ke server` | Server Instabox/Docker belum menyala, URL berubah, atau perangkat tidak punya akses internet | Cek endpoint `/health` di browser/`curl`, perbarui `API_BASE_URL` di `env.json`, lalu build ulang. |
