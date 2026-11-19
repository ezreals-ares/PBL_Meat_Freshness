# 🥩 MeatFresh AI — Dokumentasi Proyek Lengkap

> Aplikasi Flutter untuk **deteksi kesegaran daging** menggunakan kamera & API FastAPI (MobileNetV2 & SVM), dengan antarmuka bergaya **Neobrutalism** dan arsitektur **Clean Architecture + SOLID**.

---

## Daftar Isi

1. [Gambaran Umum Aplikasi](#1-gambaran-umum-aplikasi)
2. [Teknologi & Dependensi](#2-teknologi--dependensi)
3. [Struktur Folder (Project Tree)](#3-struktur-folder-project-tree)
4. [Arsitektur Aplikasi](#4-arsitektur-aplikasi)
5. [Penjelasan Setiap File](#5-penjelasan-setiap-file)
   - [Entry Point](#-entry-point)
   - [Core Layer](#-core-layer)
   - [Data Layer — API (FastAPI + Dio)](#-data-layer--api-fastapi--dio)
   - [Data Layer — Database (SQLite)](#-data-layer--database-sqlite)
   - [Data Layer — Models & Errors](#-data-layer--models--errors)
   - [Data Layer — Repository](#-data-layer--repository)
   - [Domain Layer](#-domain-layer)
   - [Presentation Layer — Providers](#-presentation-layer--providers-state-management)
   - [Presentation Layer — Screens & Theme](#-presentation-layer--screens--theme)
   - [Presentation Layer — Widgets](#-presentation-layer--widgets)
   - [Tests](#-tests)
6. [Alur Kerja Aplikasi](#6-alur-kerja-aplikasi)
7. [Database Schema](#7-database-schema)
8. [Sistem Desain Neobrutalism](#8-sistem-desain-neobrutalism)
9. [Refactor Clean Architecture, SOLID & Integrasi API](#9-refactor-clean-architecture-solid--integrasi-api)
10. [Status Pengembangan & TODO](#10-status-pengembangan--todo)
11. [Audit Kelayakan Produksi & Rencana Perbaikan](#11-audit-kelayakan-produksi--rencana-perbaikan)

---

## 1. Gambaran Umum Aplikasi

**MeatFresh AI** adalah aplikasi mobile berbasis Flutter yang membantu pengguna mendeteksi kesegaran daging secara visual menggunakan kamera atau galeri smartphone. Gambar dikirim ke backend **FastAPI** (`/predict/netv2` atau `/predict/svm`) untuk diklasifikasikan ke dalam tiga kategori:

| Label | Kode | Emoji | Warna |
|-------|------|-------|-------|
| Segar | `fresh` | ✅ | Hijau (`#3DDC84`) |
| Setengah Segar | `half_fresh` | ⚠️ | Kuning (`#FFC93C`) |
| Busuk | `spoiled` | ⛔ | Merah (`#FF4D4D`) |

Hasil scan dan salinan gambar disimpan secara lokal menggunakan **SQLite** sehingga riwayat tetap tersedia secara offline.

---

## 2. Teknologi & Dependensi

| Package | Versi | Kegunaan |
|---------|-------|---------|
| `flutter` | SDK | Framework UI utama |
| `dio` | ^5.11.1 | HTTP client untuk request multipart ke API FastAPI |
| `provider` | ^6.1.5 | State management (`ChangeNotifier`) |
| `sqflite` | ^2.4.2 | Database SQLite lokal |
| `path` | ^1.9.1 | Utilitas path file |
| `path_provider` | ^2.1.5 | Akses direktori sistem (`Documents`, App Data) |
| `image_picker` | ^1.1.2 | Ambil foto dari kamera / pilih dari galeri |
| `permission_handler` | ^11.3.1 | Manajemen izin kamera & storage |
| `google_fonts` | ^6.2.1 | Font SpaceGrotesk & PlusJakartaSans |
| `intl` | ^0.19.0 | Format tanggal & waktu |
| `cupertino_icons` | ^1.0.8 | Ikon iOS-style cadangan |

**Dev dependencies:**
- `flutter_lints` ^6.0.0 — Enforces Dart best practices
- `flutter_test` — Unit & widget testing

---

## 3. Struktur Folder (Project Tree)

```text
MobileApps/
│
├── lib/                                   ← Source code utama Flutter (Dart)
│   ├── main.dart                          ← Entry point + wiring DI terpusat
│   ├── app.dart                           ← Root widget MaterialApp
│   │
│   ├── core/                              ← Fondasi murni Dart lintas layer
│   │   ├── constants.dart                 ← Konstanta global (label, threshold, disclaimer)
│   │   ├── failures.dart                  ← Sealed class Failure (Network, Server, Local, Validation)
│   │   └── format.dart                    ← Fungsi murni pemformatan tanggal
│   │
│   ├── data/                              ← Layer akses data (API, SQLite, Storage)
│   │   ├── api/                           ← FastAPI + Dio
│   │   │   ├── api_endpoints.dart         ← Base URL, endpoint /predict/netv2 & /predict/svm, timeout
│   │   │   ├── dio_client.dart            ← Factory konfigurasi Dio (BaseOptions)
│   │   │   └── meat_prediction_remote_datasource.dart  ← Upload multipart & mapping DioException
│   │   ├── db/                            ← SQLite
│   │   │   ├── db_helper.dart             ← Singleton DB, buat schema tabel
│   │   │   └── classification_dao.dart    ← CRUD operations ke tabel DB
│   │   ├── errors/
│   │   │   └── app_exceptions.dart        ← Exception internal khusus Data Layer
│   │   ├── models/                        ← Mapper eksternal (JSON & SQLite)
│   │   │   ├── classification_model.dart  ← Model SQLite + konversi toEntity()
│   │   │   └── prediction_response_model.dart ← Parsing JSON FastAPI + normalisasi label
│   │   └── repositories/                  ← Implementasi kontrak domain (konversi Exception → Failure)
│   │       ├── classification_repository.dart        ← ClassificationRepositoryImpl
│   │       ├── local_image_storage_repository.dart   ← LocalImageStorageRepository
│   │       └── remote_meat_classifier_repository.dart ← RemoteMeatClassifierRepository
│   │
│   ├── domain/                            ← Business logic & kontrak (100% murni Dart)
│   │   ├── models/
│   │   │   ├── classification_result.dart ← Entity utama hasil klasifikasi
│   │   │   ├── prediction_model_type.dart ← Enum pilihan model AI (netv2, svm)
│   │   │   └── prediction_output.dart     ← Entity output prediksi dari classifier
│   │   ├── repositories/                  ← Kontrak abstrak (mengembalikan Record + Failure)
│   │   │   ├── classification_repository.dart
│   │   │   ├── image_storage_repository.dart
│   │   │   └── meat_classifier_repository.dart
│   │   └── usecases/
│   │       └── analyze_meat_usecase.dart  ← Orkestrasi simpan gambar → prediksi AI → simpan riwayat
│   │
│   └── presentation/                      ← Layer UI (bebas Dio, SQLite, & Data Layer)
│       ├── shell_screen.dart              ← Wrapper navigasi (Bottom Nav Bar) + refresh riwayat
│       ├── home/
│       │   └── home_screen.dart           ← Halaman beranda
│       ├── capture/
│       │   └── capture_screen.dart        ← Ambil foto (kamera / galeri)
│       ├── preview/
│       │   └── preview_screen.dart        ← Pratinjau foto sebelum analisis
│       ├── result/
│       │   └── result_screen.dart         ← Tampilkan hasil klasifikasi
│       ├── history/
│       │   └── history_screen.dart        ← Daftar riwayat semua scan
│       ├── providers/                     ← State management
│       │   ├── scan_provider.dart         ← State alur scan [DI via AnalyzeMeatUseCase]
│       │   └── history_provider.dart      ← State halaman riwayat [DI via ClassificationRepository]
│       ├── theme/                         ← Desain sistem & ekstensi UI
│       │   ├── theme.dart                 ← Sistem desain Neobrutalism lengkap
│       │   └── result_ui_ext.dart         ← Extension UI (statusColor, statusIcon) untuk entity
│       └── widgets/                       ← Komponen UI reusable
│           ├── confidence_bar.dart        ← Progress bar nilai confidence
│           ├── neo_badge.dart             ← Badge label status kesegaran
│           ├── neo_button.dart            ← Tombol neobrutalist + animasi
│           ├── neo_card.dart              ← Card container neobrutalist
│           └── neo_loading.dart           ← Loading overlay neobrutalist
│
├── android/                               ← Konfigurasi Android native (izin CAMERA, STORAGE, INTERNET)
├── assets/
│   └── model/                             ← Direktori asset model
├── test/                                  ← Unit & widget tests (11 test)
│   ├── analyze_meat_usecase_test.dart
│   ├── format_test.dart
│   ├── prediction_response_model_test.dart
│   ├── remote_meat_classifier_repository_test.dart
│   └── widget_test.dart
├── pubspec.yaml                           ← Deklarasi dependensi & assets
├── pubspec.lock                           ← Lock file versi dependensi
├── analysis_options.yaml                  ← Konfigurasi lint Dart
├── README.md                              ← README proyek
└── DOKUMENTASI.md                         ← File ini
```

---

## 4. Arsitektur Aplikasi

Proyek ini mengikuti pola **Clean Architecture (Layer-first)** dengan arah dependensi ketat menuju ke dalam (**Domain**).

```text
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                    │
│                                                         │
│  ShellScreen (Bottom Nav)                               │
│  ├── HomeScreen                                         │
│  ├── CaptureScreen → PreviewScreen → ResultScreen       │
│  └── HistoryScreen                                      │
│                                                         │
│  Providers (ChangeNotifier)                             │
│  ├── ScanProvider    → bergantung pada AnalyzeMeatUseCase│
│  └── HistoryProvider → bergantung pada ClassificationRepo│
└────────────────────┬────────────────────────────────────┘
                     │ bergantung pada (abstraksi + Failure)
┌────────────────────▼────────────────────────────────────┐
│                    DOMAIN LAYER                         │
│                                                         │
│  Use Case : AnalyzeMeatUseCase                          │
│  Entities : ClassificationResult, PredictionOutput,     │
│             PredictionModelType                         │
│  Kontrak  : ClassificationRepository,                   │
│             MeatClassifierRepository,                   │
│             ImageStorageRepository                      │
└────────────────────┬────────────────────────────────────┘
                     │ mengimplementasikan kontrak
┌────────────────────▼────────────────────────────────────┐
│                     DATA LAYER                          │
│                                                         │
│  ClassificationRepositoryImpl   → ClassificationDao → DB  │
│  RemoteMeatClassifierRepository → RemoteDataSource → Dio│
│  LocalImageStorageRepository    → File Storage          │
│  Models: ClassificationModel, PredictionResponseModel   │
└─────────────────────────────────────────────────────────┘
                     │ fondasi (Dart murni)
┌────────────────────▼────────────────────────────────────┐
│                     CORE LAYER                          │
│                                                         │
│  constants.dart │ failures.dart │ format.dart           │
└─────────────────────────────────────────────────────────┘
```

**Aturan Dependensi (Dependency Rule):**
- **Presentation** hanya mengenal **Domain** dan **Core** (0 import `dio`, `sqflite`, atau `data/`).
- **Domain** dan **Core** 100% **murni Dart** (0 import `package:flutter`, `dio`, `sqflite`, atau `data/`/`presentation/`).
- **Data** mengimplementasikan kontrak Domain, menampung detail HTTP/SQLite/JSON, dan menangkap seluruh exception untuk dikonversi menjadi `Failure`.
- **Composition Root (Wiring DI)** dilakukan terpusat di `main.dart`.

---

## 5. Penjelasan Setiap File

---

### 📌 Entry Point

#### `lib/main.dart`

File paling awal yang dieksekusi Flutter saat aplikasi dijalankan, sekaligus berfungsi sebagai **Composition Root (Wiring Dependency Injection)**.

**Yang dilakukan:**
1. `WidgetsFlutterBinding.ensureInitialized()` — memastikan binding Flutter siap sebelum plugin digunakan.
2. `SystemChrome.setPreferredOrientations([portraitUp])` — mengunci orientasi aplikasi ke **portrait**.
3. `SystemChrome.setSystemUIOverlayStyle(...)` — membuat **status bar transparan** dengan ikon gelap.
4. **Wiring DI terpusat:** merakit `DioClient.create()`, `MeatPredictionRemoteDataSourceImpl`, `RemoteMeatClassifierRepository`, `LocalImageStorageRepository`, `ClassificationDao`, `ClassificationRepositoryImpl`, dan `AnalyzeMeatUseCase`.
5. `runApp(MultiProvider(...))` — menyuntikkan `ScanProvider` dan `HistoryProvider` ke widget tree.

#### `lib/app.dart`

Root widget aplikasi `MeatFreshApp` (`StatelessWidget`) yang membangun `MaterialApp` dengan tema `buildAppTheme()` dari `presentation/theme/theme.dart` dan `home: const ShellScreen()`.

---

### 🧱 Core Layer *(Murni Dart)*

#### `lib/core/constants.dart`

Menyimpan konstanta global lintas layer (tanpa URL/endpoint backend):
- `appName`: `'MeatFresh AI'`
- `labels`: `['fresh', 'half_fresh', 'spoiled']`
- `labelDisplayNames`: peta kode label → teks Indonesia (`SEGAR`, `SETENGAH SEGAR`, `BUSUK`)
- `lowConfidenceThreshold`: `0.5`
- `disclaimer`: teks peringatan keamanan pangan di layar hasil

#### `lib/core/failures.dart`

Hierarki `sealed class Failure` yang digunakan sebagai representasi error dalam bentuk **data** pada return record `({..., Failure? failure})`:
- `NetworkFailure(message)` — tidak ada koneksi internet, timeout, atau server tidak dapat dijangkau.
- `ServerFailure(message, {statusCode})` — server mengembalikan HTTP 4xx/5xx atau format respons tidak valid.
- `LocalFailure(message)` — operasi penyimpanan SQLite atau file lokal gagal.
- `ValidationFailure(message)` — validasi input bisnis gagal di domain layer.

#### `lib/core/format.dart`

Fungsi murni `formatScanTimestamp(DateTime dateTime)` menggunakan `DateFormat('dd MMM, HH:mm')` agar `HistoryScreen` tidak memanggil `DateFormat` langsung di widget dan dapat diuji dengan unit test.

---

### 🌐 Data Layer — API (FastAPI + Dio)

#### `lib/data/api/api_endpoints.dart`

Konfigurasi terpusat untuk endpoint dan kredensial backend FastAPI dengan mode ketat melalui `--dart-define` / `--dart-define-from-file=env.json` (panduan lengkap di `BUILDGUIDE.md`, template di `env.example.json`):
- `baseUrl`: `String.fromEnvironment('API_BASE_URL', defaultValue: '')` (wajib diisi; tidak ada URL *hardcode* di kode sumber)
- `apiKey`: `String.fromEnvironment('API_KEY', defaultValue: '')` (dikirim via header `X-API-Key` bila terisi)
- `predictNetV2`: `'/predict/netv2'`, `predictSvm`: `'/predict/svm'`, `health`: `'/health'`
- `timeout`: `Duration(seconds: int.fromEnvironment('API_TIMEOUT_SECONDS', defaultValue: 30))`
- `normalizeAndValidateBaseUrl(raw)`: menolak nilai kosong serta memvalidasi skema `http`/`https`, host non-kosong, dan normalisasi trailing slash.

#### `lib/data/api/dio_client.dart`

Factory `DioClient.create({baseUrl, apiKey, timeout})` yang memvalidasi `baseUrl` lewat `ApiEndpoints.normalizeAndValidateBaseUrl(...)` dan menyiapkan instance `Dio` dengan `BaseOptions` (`connectTimeout`, `sendTimeout`, `receiveTimeout`, header `Accept: application/json`, dan header `X-API-Key` saat `apiKey` diisi).

#### `lib/data/api/meat_prediction_remote_datasource.dart`

Kontrak `MeatPredictionRemoteDataSource` dan implementasinya `MeatPredictionRemoteDataSourceImpl`:
- Mengirim gambar sebagai `multipart/form-data` (field `'file'`) melalui `_dio.post(...)`.
- Memeriksa keberadaan file lokal sebelum upload (melempar `ImageProcessingException` jika hilang).
- Memetakan `DioException` (timeout, connection error, HTTP `400`/`401`/`403`/`413`/`422`/`429` dengan pembacaan `Retry-After`/`5xx`, bad certificate, `SocketException`) menjadi `NetworkException` atau `InferenceException`.

---

### 💾 Data Layer — Database (SQLite)

#### `lib/data/db/db_helper.dart`

**Singleton** yang mengelola koneksi ke database SQLite `meatfresh.db` (versi 2, mendukung migrasi otomatis `onUpgrade` dari v1 ke v2) dan mengeksekusi `CREATE TABLE classifications`.

#### `lib/data/db/classification_dao.dart`

**Data Access Object (DAO)** — satu-satunya kelas yang menyentuh query SQL untuk tabel `classifications`. Menerima `DbHelper` opsional melalui constructor untuk kebutuhan testing.

| Method | Return | Keterangan |
|--------|--------|-----------|
| `insert(ClassificationModel model)` | `Future<int>` | Simpan model baru ke SQLite, return ID yang di-generate |
| `getAll()` | `Future<List<ClassificationModel>>` | Ambil semua record, urut terbaru dulu (`created_at DESC`) |
| `delete(id)` | `Future<int>` | Hapus satu record by ID |
| `deleteAll()` | `Future<int>` | Hapus semua record |

---

### 🧩 Data Layer — Models & Errors

#### `lib/data/errors/app_exceptions.dart`

Hierarki exception internal khusus Data Layer (`AppException`, `InferenceException`, `NetworkException`, `ImageProcessingException`). Exception ini hanya hidup di `lib/data/` dan wajib diubah menjadi `Failure` di layer repository.

#### `lib/data/models/classification_model.dart`

**Data Model** yang memperluas `ClassificationResult` untuk serialisasi SQLite (`toMap()`, `fromMap()`), `fromEntity()`, dan `toEntity()`. Bebas dari import Flutter UI.

#### `lib/data/models/prediction_response_model.dart`

Model JSON response dari endpoint FastAPI (`/predict/netv2` dan `/predict/svm`). Menormalisasi label `'half-fresh'` → `'half_fresh'`, memetakan string model (`'netv2'`/`'svm'`) lewat `parseModelType(...)`, dan mengonversinya menjadi entity murni via `toEntity()`.

---

### 📦 Data Layer — Repository

#### `lib/data/repositories/classification_repository.dart`

`ClassificationRepositoryImpl` mengimplementasikan `ClassificationRepository` dari domain. Membungkus operasi `ClassificationDao` dalam `try-catch`, mengonversi `ClassificationModel` menjadi entity via `.toEntity()`, dan mengembalikan `LocalFailure` jika terjadi error.

#### `lib/data/repositories/remote_meat_classifier_repository.dart`

`RemoteMeatClassifierRepository` mengimplementasikan `MeatClassifierRepository`. Memetakan `PredictionModelType.netv2` → `ApiEndpoints.predictNetV2` dan `PredictionModelType.svm` → `ApiEndpoints.predictSvm`, lalu menangkap `NetworkException` / `ImageProcessingException` / `AppException` menjadi `ServerFailure`, `NetworkFailure`, atau `LocalFailure`.

#### `lib/data/repositories/local_image_storage_repository.dart`

`LocalImageStorageRepository` mengimplementasikan `ImageStorageRepository`. Menyalin file gambar sementara (kamera/galeri) ke direktori privat `Documents/scan_images/scan_<timestamp>.ext` dan mendukung injeksi fungsi `getDocumentsDirectory` untuk testing.

---

### 🏛️ Domain Layer *(100% Murni Dart)*

#### `lib/domain/models/classification_result.dart`

Entity murni yang merepresentasikan satu hasil scan (`id`, `imagePath`, `meatType`, `result`, `confidence`, `createdAt`) beserta helper murni Dart (`displayName`, `statusEmoji`, `isLowConfidence`, `confidencePercent`, `copyWith`).

#### `lib/domain/models/prediction_model_type.dart`

Enum identitas model bisnis `enum PredictionModelType { netv2, svm }` tanpa detail string/URL backend.

#### `lib/domain/models/prediction_output.dart`

Entity hasil prediksi AI (`label`, `confidence`, `modelType`, `probabilities`, `segmentationFallback`).

#### Kontrak Repository (`lib/domain/repositories/`)
- `classification_repository.dart` — kontrak `save`, `getAll`, `delete`, `deleteAll` berbasis `({..., Failure? failure})`.
- `meat_classifier_repository.dart` — kontrak `classify({required imagePath, required modelType})`.
- `image_storage_repository.dart` — kontrak `saveScanImage(sourcePath)`.

#### `lib/domain/usecases/analyze_meat_usecase.dart`

Use case `AnalyzeMeatUseCase` yang mengorkestrasi 3 kontrak repository secara berurutan:
1. Validasi path gambar (mengembalikan `ValidationFailure` jika kosong).
2. Salin gambar ke penyimpanan lokal via `ImageStorageRepository`.
3. Kirim gambar ke FastAPI sesuai `modelType` via `MeatClassifierRepository`.
4. Simpan `ClassificationResult` ke SQLite via `ClassificationRepository`.

---

### 🖥️ Presentation Layer — Providers (State Management)

#### `lib/presentation/providers/scan_provider.dart`

Mengelola state alur pindai (`idle → imageSelected → processing → success / error`) serta pilihan model aktif (`selectedModel`, default `PredictionModelType.netv2`). Menerima `AnalyzeMeatUseCase` via constructor DI dan membaca `outcome.failure` tanpa `try-catch`.

#### `lib/presentation/providers/history_provider.dart`

Mengelola state daftar riwayat (`items`, `filteredItems`, `activeFilter`, `searchQuery`, `isLoading`, `errorMessage`). Menerima `ClassificationRepository` via constructor DI dan memproses `Failure` tanpa `try-catch`.

---

### 🖥️ Presentation Layer — Screens & Theme

- `lib/presentation/shell_screen.dart` — Bottom Navigation Bar 3 tab (**BERANDA**, **PINDAI**, **RIWAYAT**) dengan `IndexedStack`; otomatis memanggil `HistoryProvider.loadHistory()` setiap kali tab **RIWAYAT** dipilih.
- `lib/presentation/home/home_screen.dart` — Beranda dengan Hero Banner, tombol **MULAI CEK**, aksi cepat, disclaimer, dan rekomendasi penyimpanan.
- `lib/presentation/capture/capture_screen.dart` — Pengambilan foto dari kamera/galeri, animasi pulse viewfinder, loading overlay `NeoLoading`, serta sinkronisasi `HistoryProvider.loadHistory()` segera setelah `analyzeImage()` sukses.
- `lib/presentation/preview/preview_screen.dart` — Pratinjau foto sebelum analisis dijalankan.
- `lib/presentation/result/result_screen.dart` — Menampilkan ID scan, preview foto, kartu verdict, bar confidence, peringatan low confidence, dan catatan keamanan.
- `lib/presentation/history/history_screen.dart` — Pencarian, filter chip status, daftar riwayat (memakai `formatScanTimestamp`), serta hapus item.
- `lib/presentation/theme/theme.dart` — Palet `AppColors`, `AppShadows`, `AppBorders`, `AppRadius`, `AppSpacing`, `AppTextStyles`, dan `buildAppTheme()`.
- `lib/presentation/theme/result_ui_ext.dart` — Extension `ClassificationResultUiExt` (`statusColor`, `statusIcon`) khusus UI Flutter.

---

### 🎨 Presentation Layer — Widgets

Terletak di `lib/presentation/widgets/`:
- `confidence_bar.dart` — Progress bar segmented neobrutalism.
- `neo_badge.dart` — Badge pill status (`FRESH`, `HALF-FRESH`, `SPOILED`).
- `neo_button.dart` — Tombol neobrutalist dengan animasi press-down.
- `neo_card.dart` — Container card neobrutalist.
- `neo_loading.dart` — Overlay/inline loading indicator neobrutalism.

---

### 🧪 Tests

- `test/analyze_meat_usecase_test.dart` — Menguji skenario sukses `netv2`, sukses `svm`, `NetworkFailure`, dan `ValidationFailure` menggunakan fake repository.
- `test/prediction_response_model_test.dart` — Menguji parsing JSON FastAPI (`/predict/netv2` & `/predict/svm`), normalisasi `'half-fresh'` → `'half_fresh'`, dan `segmentation_fallback`.
- `test/remote_meat_classifier_repository_test.dart` — Menguji request multipart `Dio` ke `/predict/netv2`, `/predict/svm`, dan pemetaan HTTP 413 menjadi `ServerFailure` menggunakan fake `HttpClientAdapter`.
- `test/format_test.dart` — Menguji fungsi murni `formatScanTimestamp`.
- `test/widget_test.dart` — Smoke test rendering `MeatFreshApp` dengan wiring DI.

---

## 6. Alur Kerja Aplikasi

```text
[Buka Aplikasi]
      │
      ▼
[HomeScreen] ──── tombol "MULAI CEK" ────►
      │                                   │
      │                                   ▼
      │                           [CaptureScreen]
      │                           ┌──────────────┐
      │                           │ Kamera       │
      │                           │ atau Galeri  │
      │                           └──────┬───────┘
      │                                  │ foto dipilih
      │                                  ▼
      │                           [PreviewScreen]
      │                           ┌──────────────────────┐
      │                           │ Tampilkan foto       │
      │                           │ [PILIH FOTO LAIN] ◄──┤ kembali
      │                           │ [ANALISIS]           │
      │                           └──────┬───────────────┘
      │                                  │ tap ANALISIS
      │                                  ▼
      │                    ScanProvider.analyzeImage()
      │                    → AnalyzeMeatUseCase.call()
      │                    ┌──────────────────────────────────────┐
      │                    │ 1. LocalImageStorageRepository       │
      │                    │ 2. RemoteMeatClassifierRepository    │
      │                    │    (Dio POST /predict/netv2 | /svm)  │
      │                    │ 3. ClassificationRepositoryImpl      │
      │                    │    (Simpan ke SQLite)                │
      │                    └──────────────┬───────────────────────┘
      │                                   │
      │                         ┌─────────┴──────────┐
      │                         ▼                    ▼
      │                   [SUCCESS]              [ERROR (Failure)]
      │                       │                    │
      │                       ▼                    ▼
      │         HistoryProvider.loadHistory()  SnackBar pesan Failure
      │                       │
      │                       ▼
      │               [ResultScreen]
      │                       │
      ▼                       ▼
[HistoryScreen] ◄─────────────┘ (juga auto-refresh saat tab Riwayat dibuka)
```

---

## 7. Database Schema

**File:** `meatfresh.db` (SQLite lokal)

**Tabel: `classifications`**

| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|-----------|
| `id` | `INTEGER` | `PRIMARY KEY AUTOINCREMENT` | ID unik auto-increment |
| `image_path` | `TEXT` | `NOT NULL` | Path absolut file gambar |
| `meat_type` | `TEXT` | — | Jenis daging (nullable, untuk fitur mendatang) |
| `result` | `TEXT` | `NOT NULL` | Kode hasil: `fresh`, `half_fresh`, `spoiled` |
| `confidence` | `REAL` | `NOT NULL` | Confidence score: 0.0 – 1.0 |
| `created_at` | `TEXT` | `NOT NULL` | Timestamp ISO 8601 |
| `model_used` | `TEXT` | — | Model AI yang dipakai (`netv2` atau `svm`) |
| `probabilities_json` | `TEXT` | — | JSON distribusi probabilitas tiap kelas |
| `segmentation_fallback` | `INTEGER` | — | Flag fallback segmentasi SVM (`0` / `1` / `null`) |

---

## 8. Sistem Desain Neobrutalism

| Elemen | Implementasi di MeatFresh AI |
|--------|------------------------------|
| **Border tebal** | Border hitam `#111111` ketebalan 1.5–3.5px |
| **Hard offset shadow** | Blur = 0, offset solid 2×2 hingga 5×5 px berwarna hitam |
| **Warna saturasi tinggi** | Merah primer `#B52603`, hijau `#3DDC84`, kuning `#FFC93C`, biru `#0054CB` |
| **Tipografi bold** | SpaceGrotesk (headline/label) & PlusJakartaSans (body) |
| **Animasi press-down** | Translate +2px saat ditekan + shadow mengecil ke `hardSmall` |
| **Background krem** | Canvas `#FDF6EC` |

---

## 9. Refactor Clean Architecture, SOLID & Integrasi API

### 📊 Perbandingan Sebelum vs Sesudah

| Aspek | ❌ Sebelum Refactor | ✅ Sesudah Refactor |
|-------|---------------------|---------------------|
| **Klasifikasi AI** | Mock acak lokal di `TfliteService` (di-`new` langsung oleh `ScanProvider`). | Terhubung ke FastAPI (`/predict/netv2` & `/predict/svm`) via **`Dio`** di `lib/data/api/`. `TfliteService` dihapus. |
| **Domain Entity & Model** | `ClassificationResult` mengimpor Flutter (`Color`, `IconData`) serta memiliki `toMap()`/`fromMap()`. | Entity murni Dart di `domain/models/`; mapper SQLite & JSON terpisah di `data/models/` (`ClassificationModel`, `PredictionResponseModel`). |
| **Error Handling** | Exception dilempar sampai `ScanProvider`/`HistoryProvider` dan ditangani `try-catch`. | Menggunakan `sealed class Failure` + record `({..., Failure? failure})`. Exception hanya internal `lib/data/errors/`. |
| **Sterilitas `core/` & `presentation/`** | `theme.dart`, `result_ui_ext.dart`, `app_exceptions.dart` ada di `core/`; `DateFormat` dipanggil langsung di `HistoryScreen`. | `core/` 100% murni Dart (`constants`, `failures`, `format`); tema & widgets di `presentation/`; `DateFormat` dipindah ke `core/format.dart`. |
| **Dependency Injection** | Provider membuat dependency konkret sendiri (`ClassificationRepository()`, `TfliteService()`). | Semua dependensi dirakit di `main.dart` dan disuntikkan via constructor ke `AnalyzeMeatUseCase`, `ScanProvider`, dan `HistoryProvider`. |
| **Sinkronisasi Riwayat** | Hasil scan baru belum muncul di tab Riwayat sebelum restart aplikasi. | `HistoryProvider.loadHistory()` dipanggil saat scan sukses di `CaptureScreen` dan setiap kali tab Riwayat dipilih di `ShellScreen`. |

### 🔍 Bukti Verifikasi
- **Grep sterilitas layer (Presentation, Widgets, Domain, Core, Data)**: **0 pelanggaran** arah dependensi.
- **`flutter analyze`**: **`No issues found!`**.
- **`flutter test`**: **`All tests passed!`** (11/11 test unit & widget lulus).

---

## 10. Status Pengembangan & TODO

### ✅ Sudah Selesai
- [x] Refactor Clean Architecture (Domain, Data, Presentation, Core) & prinsip SOLID
- [x] Integrasi endpoint FastAPI `/predict/netv2` dan `/predict/svm` menggunakan `dio` di `lib/data/api/`
- [x] Error handling berbasis `Failure` + record (`NetworkFailure`, `ServerFailure`, `LocalFailure`, `ValidationFailure`)
- [x] Use case bisnis `AnalyzeMeatUseCase` & injeksi dependensi terpusat di `main.dart`
- [x] Database SQLite lokal (`meatfresh.db`) & sinkronisasi otomatis daftar riwayat setelah scan
- [x] Sistem desain Neobrutalism & seluruh 5 layar UI (Home, Capture, Preview, Result, History)
- [x] **UI pemilih model (`netv2` vs `svm`)** — pilihan model di `PreviewScreen` terhubung ke `ScanProvider.selectModel(...)`
- [x] **Tampilan detail probabilitas & info SVM fallback** — `modelType`, `probabilities`, dan `segmentationFallback` disimpan di SQLite (v2) dan ditampilkan di `ResultScreen` serta `HistoryScreen`
- [x] Unit tests (use case, repository Dio dengan mock adapter, response model, classification model, formatter) & widget test (13/13 lulus)
- [x] Verifikasi `flutter analyze` bersih (`No issues found!`)

### 🚧 Masih TODO

#### Prioritas Sedang
- [ ] **Izin kamera/storage eksplisit** — integrasi `permission_handler` di `CaptureScreen` sebelum memanggil `image_picker`
- [ ] **Kolom `meat_type`** — UI untuk input jenis daging (ayam, sapi, kambing, dll.)
- [ ] **Navigasi detail dari riwayat & fitur hapus semua** — lengkapi `onTap` item di `HistoryScreen` dan tombol `deleteAll()`
- [ ] **Export riwayat** — fitur ekspor ke CSV atau PDF

#### Prioritas Rendah
- [ ] **Widget tests lanjutan** — test interaksi layar Capture, Preview, Result, dan History
- [ ] **Onboarding screen** — panduan penggunaan pertama kali
- [ ] **Pengaturan** — dark mode toggle, bahasa, ukuran font

---

## 11. Audit Kelayakan Produksi & Rencana Perbaikan

> Hasil audit menyeluruh terhadap `MobileApps/` (November 2026) untuk mempersiapkan aplikasi agar layak digunakan secara nyata oleh pengguna (*production-ready*).

### 🔴 P0 — Kritis (Wajib Sebelum Rilis)

| # | Temuan | Lokasi | Solusi yang Disarankan |
|---|--------|--------|------------------------|
| 1 | **Belum ada validasi objek non-daging** — foto selain daging tetap diklasifikasikan paksa menjadi `fresh`/`half_fresh`/`spoiled` dan disimpan ke SQLite. | `lib/data/models/prediction_response_model.dart`, `lib/domain/usecases/analyze_meat_usecase.dart`, `lib/presentation/result/result_screen.dart` | Tambahkan validasi non-daging di FastAPI (mis. `"is_meat": false`), lewati penyimpanan SQLite di use case, dan tampilkan kartu penolakan khusus di `ResultScreen`. |
| 2 | ~~**URL backend di-hardcode ke host sementara tanpa autentikasi**~~ — **✅ Selesai.** URL *hardcode* dihapus total (`API_BASE_URL` memakai mode ketat `defaultValue: ''`). Konfigurasi kini wajib disuntikkan via `--dart-define` / `--dart-define-from-file=env.json` (`env.example.json`, panduan di `BUILDGUIDE.md`), divalidasi di `DioClient`, mengirim `X-API-Key`, serta memetakan HTTP `401`/`403`/`429`. Backend `FastAPI/` dilengkapi autentikasi `X-API-Key` & *sliding-window rate limiter*. | `lib/data/api/api_endpoints.dart`, `dio_client.dart`, `meat_prediction_remote_datasource.dart`, `BUILDGUIDE.md`, `FastAPI/security.py`, `FastAPI/main.py` | Terapkan `--dart-define-from-file=env.json` saat build rilis sesuai `BUILDGUIDE.md` dengan domain HTTPS permanen, `API_KEY` rahasia, dan `REQUIRE_API_KEY=true`. |
| 3 | **Default model aktif masih `netv2`, bukan `svm`** — user yang langsung menekan `ANALISIS` tanpa memilih model akan memakai MobileNetV2. | `lib/presentation/providers/scan_provider.dart` (`_selectedModel`) | Ubah default ke `PredictionModelType.svm` (atau simpan preferensi model terakhir user). |
| 4 | **Konfigurasi release Android masih template bawaan** — `namespace` masih `com.example.flutter_application_1`, build `release` memakai `debug` keystore, dan ikon launcher masih bawaan Flutter. | `android/app/build.gradle.kts`, `android/app/src/main/res/mipmap-*` | Selaraskan `namespace`, siapkan *release keystore* resmi, serta pasang ikon aplikasi & *splash screen* MeatFresh AI. |

### 🟠 P1 — Bug Fungsional & Kebocoran Storage

| # | Temuan | Lokasi | Solusi yang Disarankan |
|---|--------|--------|------------------------|
| 5 | **Pencarian berdasarkan ID tidak berfungsi** — placeholder menyebut `'CARI JENIS DAGING ATAU ID...'`, tetapi filter hanya mengecek `displayName` dan `meatType`. | `lib/presentation/providers/history_provider.dart` (`filteredItems`), `lib/presentation/history/history_screen.dart` | Tambahkan pencocokan terhadap `item.id.toString()` dan pola `#MF-<id>`. |
| 6 | **Kebocoran file gambar (*orphan files*)** — file tersalin ke `Documents/scan_images/` sebelum request API dan tidak dihapus saat API gagal maupun saat `delete(id)` / `deleteAll()`. | `lib/domain/usecases/analyze_meat_usecase.dart`, `lib/data/repositories/classification_repository.dart` | Hapus file salinan jika API gagal/non-daging, serta hapus file fisik gambar terkait saat catatan riwayat dihapus. |
| 7 | **Loading overlay belum memblokir tombol Back & cancel request** — menekan Back saat proses analisis bisa mem-pop `PreviewScreen` dan memicu navigasi route yang salah. | `lib/presentation/widgets/neo_loading.dart`, `lib/presentation/capture/capture_screen.dart` | Bungkus overlay dengan `PopScope(canPop: false)` atau tambahkan mekanisme `CancelToken` Dio. |
| 8 | **Tombol `PINDAI LAGI` salah arah saat dibuka dari Riwayat** — `Navigator.pop(context)` mengembalikan user ke `HistoryScreen`, bukan ke `CaptureScreen`. | `lib/presentation/result/result_screen.dart`, `lib/presentation/history/history_screen.dart` | Arahkan `PINDAI LAGI` untuk kembali ke root lalu berpindah ke tab `PINDAI` (atau bedakan argumen asal navigasi). |
| 9 | **Tombol `EKSPOR` masih placeholder & `deleteAll()` belum ada di UI** — tombol `EKSPOR` hanya menampilkan `"Fitur ekspor segera hadir"`. | `lib/presentation/history/history_screen.dart`, `lib/presentation/providers/history_provider.dart` | Implementasikan ekspor CSV/PDF (atau sembunyikan tombol sementara) dan tambahkan aksi `Hapus Semua` dengan konfirmasi. |

### 🟡 P2 — UX, Performa & Keandalan Lapangan

- [ ] **Izin kamera/galeri eksplisit (`permission_handler`)** — tambahkan alur permintaan izin & tombol *"Buka Pengaturan"* (`openAppSettings()`) di `CaptureScreen` saat izin ditolak permanen.
- [ ] **Navigasi Back & pintasan Beranda** — tambahkan `PopScope` di `ShellScreen` agar tombol Back di tab `PINDAI`/`RIWAYAT` kembali ke `BERANDA` dulu; bedakan pintasan `UNGGAH DARI GALERI` di `HomeScreen` dan beri aksi pada ikon perisai di AppBar.
- [ ] **Efisiensi animasi `CaptureScreen`** — hentikan `_pulseController` saat tab `PINDAI` tidak aktif di `IndexedStack` untuk menghemat CPU/baterai.
- [ ] **Resiliensi error & panduan pengguna** — tambahkan tombol `COBA LAGI` di `_buildErrorState` serta `RefreshIndicator` di `HistoryScreen`; tambahkan panduan pencahayaan (hindari lampu terlalu kuning hangat di mana akurasi SVM Lanjutan turun ke `60,98%`) serta input opsional `meat_type`.

### 🔵 P3 — Pengujian, Build & Dokumentasi

- [ ] **Build ulang APK & regresi E2E pasca-redesain** — bangun ulang APK debug terbaru dan jalankan ulang `AutomationTest` (Appium) beserta skenario alur `PreviewScreen` → `SVM` → `ResultScreen`.
- [ ] **Widget tests lanjutan & penyelarasan dokumen** — tambahkan widget test untuk `CaptureScreen`, `PreviewScreen`, `ResultScreen`, `HistoryScreen`, serta selaraskan `MobileApps/README.md`, `pubspec.yaml`, dan bagian arsitektur/desain pada `DOKUMENTASI.md` dengan kondisi terkini (FastAPI + modern *soft-UI*).

---

*Dokumentasi ini diperbarui berdasarkan analisis source code proyek MeatFresh AI (`MobileApps/`).*
*Versi: 1.2.0 (FastAPI Dio + Clean Architecture & Failure Pattern) | Flutter SDK: ^3.13.1 | Terakhir diperbarui: November 2026*
