# 🥩 MeatFresh AI — Dokumentasi Proyek Lengkap

> Aplikasi Flutter untuk **deteksi kesegaran daging** secara on-device menggunakan kamera & model Machine Learning (TFLite), dengan antarmuka bergaya **Neobrutalism**.

---

## Daftar Isi

1. [Gambaran Umum Aplikasi](#1-gambaran-umum-aplikasi)
2. [Teknologi & Dependensi](#2-teknologi--dependensi)
3. [Struktur Folder (Project Tree)](#3-struktur-folder-project-tree)
4. [Arsitektur Aplikasi](#4-arsitektur-aplikasi)
5. [Penjelasan Setiap File](#5-penjelasan-setiap-file)
   - [Entry Point](#-entry-point)
   - [Core Layer](#-core-layer)
   - [Data Layer — Database](#-data-layer--database-sqlite)
   - [Data Layer — Machine Learning](#-data-layer--machine-learning)
   - [Data Layer — Repository](#-data-layer--repository)
   - [Domain Layer](#-domain-layer)
   - [Presentation Layer — Providers](#-presentation-layer--providers-state-management)
   - [Presentation Layer — Screens](#-presentation-layer--screens)
   - [Widgets](#-widgets-reusable-neobrutalist-components)
   - [Assets & Sistem](#-assets--sys)
6. [Alur Kerja Aplikasi](#6-alur-kerja-aplikasi)
7. [Database Schema](#7-database-schema)
8. [Sistem Desain Neobrutalism](#8-sistem-desain-neobrutalism)
9. [Refactor Clean Architecture & SOLID](#9-refactor-clean-architecture--solid)
10. [Status Pengembangan & TODO](#10-status-pengembangan--todo)

---

## 1. Gambaran Umum Aplikasi

**MeatFresh AI** adalah aplikasi mobile berbasis Flutter yang membantu pengguna mendeteksi kesegaran daging secara visual menggunakan kamera smartphone. Aplikasi menganalisis foto daging dan mengklasifikasikannya ke dalam tiga kategori:

| Label | Kode | Emoji | Warna |
|-------|------|-------|-------|
| Segar | `fresh` | ✅ | Hijau (`#3DDC84`) |
| Setengah Segar | `half_fresh` | ⚠️ | Kuning (`#FFC93C`) |
| Busuk | `spoiled` | ⛔ | Merah (`#FF4D4D`) |

Semua proses berjalan **sepenuhnya di perangkat** (on-device) — tidak memerlukan koneksi internet. Hasil scan disimpan secara lokal menggunakan SQLite.

---

## 2. Teknologi & Dependensi

| Package | Versi | Kegunaan |
|---------|-------|---------|
| `flutter` | SDK | Framework UI utama |
| `provider` | ^6.1.5 | State management (ChangeNotifier) |
| `sqflite` | ^2.4.2 | Database SQLite lokal |
| `path` | ^1.9.1 | Utilitas path file |
| `path_provider` | ^2.1.5 | Akses direktori sistem (Documents, App Data) |
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

```
PBL_Meat_Freshness/
│
├── lib/                                   ← Source code utama Flutter (Dart)
│   ├── main.dart                          ← Entry point + wiring DI terpusat
│   ├── app.dart                           ← Root widget MaterialApp
│   │
│   ├── core/                              ← Fondasi lintas layer
│   │   ├── constants.dart                 ← Konstanta global (label, threshold)
│   │   ├── theme.dart                     ← Sistem desain Neobrutalism lengkap
│   │   ├── result_ui_ext.dart             ← Extension Flutter untuk ClassificationResult [BARU]
│   │   └── errors/
│   │       └── app_exceptions.dart        ← Hierarki exception custom
│   │
│   ├── data/                              ← Layer akses data
│   │   ├── db/                            ← SQLite
│   │   │   ├── db_helper.dart             ← Singleton DB, buat schema tabel
│   │   │   └── classification_dao.dart    ← CRUD operations ke tabel DB
│   │   ├── ml/                            ← Machine Learning
│   │   │   ├── tflite_service.dart        ← Inferensi model TFLite (saat ini mock)
│   │   │   └── image_preprocessor.dart    ← Salin & preprocess gambar
│   │   ├── models/                        ← [BARU] Data models dengan serialisasi
│   │   │   └── classification_model.dart  ← Model SQLite + Flutter helpers
│   │   └── repositories/
│   │       └── classification_repository.dart  ← ClassificationRepositoryImpl [REFACTOR]
│   │
│   ├── domain/                            ← Business logic & model data (murni Dart)
│   │   ├── models/
│   │   │   └── classification_result.dart ← Entity murni tanpa Flutter/DB [BERSIHKAN]
│   │   └── repositories/                  ← [BARU] Kontrak abstrak repository
│   │       └── classification_repository.dart  ← Abstract ClassificationRepository
│   │
│   ├── presentation/                      ← Layer UI
│   │   ├── shell_screen.dart              ← Wrapper navigasi (Bottom Nav Bar)
│   │   ├── home/
│   │   │   └── home_screen.dart           ← Halaman beranda
│   │   ├── capture/
│   │   │   └── capture_screen.dart        ← Ambil foto (kamera / galeri)
│   │   ├── preview/
│   │   │   └── preview_screen.dart        ← Pratinjau foto sebelum analisis
│   │   ├── result/
│   │   │   └── result_screen.dart         ← Tampilkan hasil klasifikasi
│   │   ├── history/
│   │   │   └── history_screen.dart        ← Daftar riwayat semua scan
│   │   └── providers/                     ← State management
│   │       ├── scan_provider.dart         ← State alur scan [DI via constructor]
│   │       └── history_provider.dart      ← State halaman riwayat [DI via constructor]
│   │
│   └── widgets/                           ← Komponen UI reusable
│       ├── confidence_bar.dart            ← Progress bar nilai confidence
│       ├── neo_badge.dart                 ← Badge label status kesegaran
│       ├── neo_button.dart                ← Tombol neobrutalist + animasi
│       ├── neo_card.dart                  ← Card container neobrutalist
│       └── neo_loading.dart               ← Loading overlay neobrutalist
│
├── assets/
│   └── model/                             ← Placeholder model TFLite (.tflite)
│
├── sys/                                   ← Dokumentasi internal & referensi desain
│   ├── MeatFresh_AI_PRD_Design_Neobrutalism.md
│   ├── MeatFresh_AI_PRD_Engineering.md
│   └── stitch_pembangun_berbasis_referensi/
│       ├── history_meatfresh_ai/          ← Referensi UI halaman riwayat
│       ├── home_meatfresh_ai/             ← Referensi UI halaman beranda
│       ├── neobrutalist_freshness/        ← Panduan desain neobrutalism
│       ├── scan_capture_meatfresh_ai/     ← Referensi UI halaman scan
│       └── scan_result_meatfresh_ai/     ← Referensi UI halaman hasil
│
├── android/                               ← Konfigurasi Android native (Gradle, Manifest)
├── web/                                   ← Konfigurasi Flutter Web
├── test/                                  ← Folder unit & widget tests
├── pubspec.yaml                           ← Deklarasi dependensi & assets
├── pubspec.lock                           ← Lock file versi dependensi
├── analysis_options.yaml                  ← Konfigurasi lint Dart
├── README.md                              ← README proyek
└── DOKUMENTASI.md                         ← File ini
```

---

## 4. Arsitektur Aplikasi

Proyek ini mengikuti pola **Clean Architecture** yang dimodifikasi untuk Flutter, dengan pemisahan yang jelas antara layer UI, business logic, dan akses data.

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                    │
│                                                         │
│  ShellScreen (Bottom Nav)                               │
│  ├── HomeScreen                                         │
│  ├── CaptureScreen → PreviewScreen → ResultScreen       │
│  └── HistoryScreen                                      │
│                                                         │
│  Providers (ChangeNotifier) — menerima abstraksi via DI │
│  ├── ScanProvider   (alur scan)                         │
│  └── HistoryProvider (state riwayat)                    │
└────────────────────┬────────────────────────────────────┘
                     │ bergantung pada (abstraksi)
┌────────────────────▼────────────────────────────────────┐
│                    DOMAIN LAYER                         │
│                                                         │
│  ClassificationResult  (entity murni Dart)              │
│  ClassificationRepository  (abstract — kontrak)         │
└────────────────────┬────────────────────────────────────┘
                     │ mengimplementasikan kontrak
┌────────────────────▼────────────────────────────────────┐
│                     DATA LAYER                          │
│                                                         │
│  ClassificationRepositoryImpl (implements kontrak)      │
│  ClassificationModel  (entity + serialisasi SQLite)     │
│  ├── ClassificationDao → DbHelper (SQLite)              │
│  ├── TfliteService (inferensi ML)                       │
│  └── ImagePreprocessor (copy & preprocess gambar)       │
└─────────────────────────────────────────────────────────┘
                     │ fondasi
┌────────────────────▼────────────────────────────────────┐
│                     CORE LAYER                          │
│                                                         │
│  constants.dart │ theme.dart │ app_exceptions.dart      │
│  result_ui_ext.dart  (extension Flutter untuk entity)   │
└─────────────────────────────────────────────────────────┘
```

**Aturan Dependensi (Dependency Rule):**
- Presentation bergantung ke Domain (abstraksi), **bukan** ke Data.
- Domain tidak tahu apapun tentang Flutter, Dio, atau SQLite.
- Data mengimplementasikan kontrak yang didefinisikan Domain.
- Wiring DI dilakukan **hanya** di `main.dart`.

**State Management** menggunakan **Provider** dengan dua `ChangeNotifier`:
- `ScanProvider` — disediakan secara global via `MultiProvider` di `main.dart`
- `HistoryProvider` — disediakan secara global via `MultiProvider` di `main.dart`

---

## 5. Penjelasan Setiap File

---

### 📌 Entry Point

---

#### `lib/main.dart`

File paling awal yang dieksekusi Flutter saat aplikasi dijalankan, sekaligus berfungsi sebagai **pusat perakitan dependensi (Wiring Dependency Injection)**.

**Yang dilakukan:**
1. `WidgetsFlutterBinding.ensureInitialized()` — memastikan binding Flutter siap sebelum plugin digunakan.
2. `SystemChrome.setPreferredOrientations([portraitUp])` — mengunci orientasi aplikasi ke **portrait** saja.
3. `SystemChrome.setSystemUIOverlayStyle(...)` — membuat **status bar transparan** dengan ikon gelap agar cocok dengan tema neobrutalism.
4. **Wiring Dependency Injection (DI)** — Menginstansiasi `ClassificationDao`, `ClassificationRepositoryImpl`, dan `TfliteService` satu kali di tingkat atas.
5. `runApp(MultiProvider(...))` — menyuntikkan dependensi ke provider:
   - `ScanProvider(tfliteService: ..., repository: ...)`
   - `HistoryProvider(repository: ...)`

```dart
// Wiring DI di main.dart
final dao = ClassificationDao();
final repository = ClassificationRepositoryImpl(dao: dao);
final tfliteService = TfliteService();

runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => ScanProvider(
          tfliteService: tfliteService,
          repository: repository,
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => HistoryProvider(
          repository: repository,
        ),
      ),
    ],
    child: const MeatFreshApp(),
  ),
);
```

---

#### `lib/app.dart`

Root widget aplikasi `MeatFreshApp` (extends `StatelessWidget`).

**Yang dilakukan:**
- Membuat `MaterialApp` dengan:
  - `title: 'MeatFresh AI'`
  - `theme: buildAppTheme()` — tema neobrutalism dari `core/theme.dart`
  - `home: ShellScreen()` — layar pertama yang ditampilkan
  - `debugShowCheckedModeBanner: false` — menghilangkan banner "DEBUG"

---

### 🧱 Core Layer

---

#### `lib/core/constants.dart`

Menyimpan semua **konstanta global** yang dipakai lintas file agar tidak ada *magic string* atau *magic number* yang tersebar.

| Konstanta | Nilai | Kegunaan |
|-----------|-------|---------|
| `modelAssetPath` | `'assets/model/meatfresh_model.tflite'` | Path asset model TFLite |
| `labelDisplayNames` | `{'fresh': 'SEGAR', 'half_fresh': 'SETENGAH SEGAR', 'spoiled': 'BUSUK'}` | Peta label kode → teks tampilan |
| `lowConfidenceThreshold` | `0.5` | Batas confidence dianggap rendah |
| `disclaimer` | *(string panjang)* | Teks peringatan di layar hasil |

---

#### `lib/core/theme.dart`

File paling penting untuk **sistem desain Neobrutalism** aplikasi. Semua warna, tipografi, shadow, border, dan spacing didefinisikan di sini — tidak ada nilai hardcoded di widget manapun.

**Kelas yang terdapat di dalam file ini:**

##### `AppColors`
Palet warna lengkap:
- `primary` — Merah tua (`#B52603`) — warna brand utama
- `primaryContainer` — Merah terang (`#FF5A36`) — warna tombol & aksen
- `secondary` — Biru (`#0054CB`)
- `tertiary` — Teal (`#006879`)
- `bgCanvas` — Krem (`#FDF6EC`) — background halaman
- `bgSurface` — Putih (`#FFFFFF`) — background card
- `statusFresh` — Hijau (`#3DDC84`)
- `statusHalf` — Kuning (`#FFC93C`)
- `statusSpoiled` — Merah (`#FF4D4D`)
- `borderDefault` — Hitam (`#111111`) — border semua elemen
- `shadowHard` — Hitam (`#111111`) — warna shadow offset

##### `AppShadows`
Factory untuk shadow bergaya neobrutalism (hard offset, blur = 0):
- `hard({x, y, color})` — shadow dasar (default 4×4)
- `hardSmall()` — shadow kecil 2×2 (untuk state *ditekan*)
- `hardMedium()` — shadow sedang 3×3
- `hardLarge()` — shadow besar 5×5

##### `AppBorders`
Ketebalan border standar: `thin` (1.5), `medium` (2.5), `thick` (3.0)

##### `AppRadius`
Radius sudut: `sm` (4), `md` (8), `lg` (12), `xl` (16), `full` (9999 = pill)

##### `AppSpacing`
Sistem spasi: `xs` (4), `sm` (8), `md` (16), `lg` (24), `xl` (36), `margin` (16)

##### `AppTextStyles`
Style teks yang telah dikonfigurasi (font, ukuran, berat, tinggi baris):
- Headline: `headlineXlMobile` (32px), `headlineLgMobile` (26px), `headlineMd` (24px), `headlineSm` (20px) — font **SpaceGrotesk**
- Body: `bodyLg` (18px), `bodyMd` (16px), `bodySm` (14px) — font **PlusJakartaSans**
- Label: `labelLg` (14px), `labelMd` (12px), `labelSm` (10px) — font **SpaceGrotesk**, weight 700–800

##### `buildAppTheme() → ThemeData`
Fungsi yang merakit semua elemen di atas menjadi `ThemeData` Material3 yang siap dipakai `MaterialApp`.

---

#### `lib/core/errors/app_exceptions.dart`

Hierarki exception terstruktur untuk error handling yang konsisten di seluruh aplikasi.

```
Exception
├── AppException (base class, pesan + originalError)
│   ├── ModelLoadException    — TFLite model gagal dimuat
│   ├── InferenceException    — Inferensi model gagal
│   ├── StorageException      — Operasi SQLite gagal
│   └── ImageProcessingException — Preprocessing gambar gagal
├── DatabaseException         — Error spesifik sqflite
└── PermissionDeniedException — Izin kamera/storage ditolak
```

Setiap exception menyimpan `message` (string deskripsi) dan `originalError` (exception asli dari library) untuk debugging.

---

#### `lib/core/result_ui_ext.dart`

Extension Flutter pada domain entity `ClassificationResult`. 

File ini menjembatani entity domain murni dengan kebutuhan visual presentasi. Menjaga domain tetap 100% murni Dart (tanpa dependensi Flutter), sementara helper presentasi seperti `Color` dan `IconData` tetap mudah diakses oleh widget.

**Extension Getters:**
- `statusColor` → Mengembalikan `Color` status (`AppColors.statusFresh`, `statusHalf`, atau `statusSpoiled`)
- `statusIcon` → Mengembalikan `IconData` status (`Icons.check_circle`, `warning`, `block`)

---

### 💾 Data Layer — Database (SQLite)

---

#### `lib/data/db/db_helper.dart`

**Singleton** yang mengelola koneksi ke database SQLite `meatfresh.db`.

**Method:**

| Method | Return | Keterangan |
|--------|--------|-----------|
| `DbHelper.instance` | `DbHelper` | Singleton instance, hanya ada satu |
| `get database` | `Future<Database>` | Lazy getter — inisialisasi DB jika belum ada |
| `_initDb()` | `Future<Database>` | Buka/buat file DB di path sistem |
| `_onCreate(db, version)` | `Future<void>` | Eksekusi SQL `CREATE TABLE` pertama kali |
| `close()` | `Future<void>` | Tutup koneksi DB (dipanggil saat dispose app) |

**Schema tabel `classifications`:**
```sql
CREATE TABLE classifications (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  image_path  TEXT NOT NULL,
  meat_type   TEXT,
  result      TEXT NOT NULL,
  confidence  REAL NOT NULL,
  created_at  TEXT NOT NULL
);
```

---

#### `lib/data/db/classification_dao.dart`

**Data Access Object (DAO)** — satu-satunya kelas yang boleh langsung menyentuh SQL queries untuk tabel `classifications`. Mendukung Dependency Injection dengan menerima parameter opsional `DbHelper` (memudahkan mocking saat unit test).

**Method:**

| Method | Return | Keterangan |
|--------|--------|-----------|
| `insert(ClassificationModel model)` | `Future<int>` | Simpan model baru ke SQLite, return ID yang di-generate |
| `getAll()` | `Future<List<ClassificationResult>>` | Ambil semua record, urut terbaru dulu |
| `getById(id)` | `Future<ClassificationResult?>` | Ambil satu record by ID, null jika tidak ada |
| `delete(id)` | `Future<int>` | Hapus satu record by ID, return jumlah baris terhapus |
| `deleteAll()` | `Future<int>` | Hapus semua record |
| `count()` | `Future<int>` | Hitung total record |

---

#### `lib/data/models/classification_model.dart`

**Data Model** yang memperluas (`extends`) domain entity `ClassificationResult`. Bertanggung jawab atas:
1. **Serialisasi / Deserialisasi SQLite**: `toMap()` dan `ClassificationModel.fromMap(map)`.
2. **Konversi Entity**: `toEntity()` dan `ClassificationModel.fromEntity(entity)`.
3. **Display Helpers Flutter**: Menyimpan getter `statusColor` dan `statusIcon` yang membutuhkan `package:flutter`.

Dengan meletakkan serialisasi di file ini, domain layer tetap steril dari urusan database.

---

### 🤖 Data Layer — Machine Learning

---

#### `lib/data/ml/tflite_service.dart`

Service yang bertanggung jawab memuat model TFLite dan menjalankan **inferensi klasifikasi** pada gambar daging.

> ⚠️ **Status saat ini:** Masih menggunakan **hasil mock (acak berbobot)**. Model TFLite nyata belum diintegrasikan.

**Method:**

| Method | Return | Keterangan |
|--------|--------|-----------|
| `get isModelLoaded` | `bool` | Cek apakah model sudah dimuat |
| `loadModel()` | `Future<void>` | Muat model dari assets (saat ini: simulasi delay 500ms) |
| `classify(imagePath)` | `Future<Map<String, dynamic>>` | Jalankan klasifikasi, return `{result: String, confidence: double}` |
| `dispose()` | `void` | Bebaskan resource interpreter |

**Distribusi hasil mock:**
- `fresh` (SEGAR) — 60% peluang
- `half_fresh` (SETENGAH SEGAR) — 25% peluang
- `spoiled` (BUSUK) — 15% peluang
- `confidence` — random antara 0.65 – 0.99

**TODO integrasi TFLite nyata:**
```dart
// 1. Tambahkan dependency di pubspec.yaml:
//    tflite_flutter: ^0.11.0

// 2. Di loadModel():
_interpreter = await Interpreter.fromAsset('model/meatfresh_model.tflite');

// 3. Di classify():
final input = await ImagePreprocessor.prepare(imagePath);
final output = List.filled(1 * 3, 0.0).reshape([1, 3]);
_interpreter.run(input, output);
final probs = output[0] as List<double>;
final maxIdx = probs.indexOf(probs.reduce(max));
return {'result': labels[maxIdx], 'confidence': probs[maxIdx]};
```

---

#### `lib/data/ml/image_preprocessor.dart`

Kelas utilitas statis untuk mempersiapkan gambar sebelum dianalisis.

**Method:**

| Method | Return | Keterangan |
|--------|--------|-----------|
| `copyToAppStorage(sourcePath)` | `Future<String>` | Salin file gambar ke direktori privat app (`Documents/scan_images/scan_<timestamp>.ext`), return path baru |

**Mengapa gambar perlu disalin?**
File dari kamera bersifat sementara (temp). Menyalinnya ke app storage memastikan gambar tetap tersedia meskipun file temp sudah terhapus.

**TODO preprocessing untuk TFLite:**
```dart
// Ketika model nyata siap, tambahkan method prepare():
static Future<Float32List> prepare(String imagePath) async {
  // 1. Decode JPEG/PNG ke buffer pixel
  // 2. Resize ke 224×224 (atau ukuran input model)
  // 3. Normalisasi: bagi /255.0 (atau pakai mean/std dari training)
  // 4. Konversi ke Float32List dalam format NHWC [1, H, W, 3]
}
```

---

### 📦 Data Layer — Repository

---

#### `lib/data/repositories/classification_repository.dart`

Implementasi konkret **`ClassificationRepositoryImpl`** yang mengimplementasikan interface kontrak `ClassificationRepository` dari domain layer.

Menerima `ClassificationDao` melalui constructor injection. Menjadi pelindung domain dari raw exception sqflite dengan membungkus semua operasi ke dalam `try-catch` dan melempar `StorageException`.

**Method (mengimplementasikan kontrak domain):**

| Method | Return | Keterangan |
|--------|--------|-----------|
| `save(result)` | `Future<ClassificationResult>` | Konversi entity ke model, simpan via DAO, return entity ber-ID baru |
| `getAll()` | `Future<List<ClassificationResult>>` | Ambil semua riwayat via DAO |
| `getById(id)` | `Future<ClassificationResult?>` | Ambil satu hasil by ID |
| `delete(id)` | `Future<void>` | Hapus satu hasil |
| `deleteAll()` | `Future<void>` | Hapus semua riwayat |
| `count()` | `Future<int>` | Hitung total riwayat tersimpan |

Semua method membungkus operasi DAO dalam `try-catch` dan melempar `StorageException` jika terjadi error.

---

### 🏛️ Domain Layer

---

#### `lib/domain/models/classification_result.dart`

**Domain Entity murni (Dart murni)** yang merepresentasikan hasil scan/klasifikasi daging. 

> 🛡️ **Steril dari Flutter & Database:** Tidak ada import `package:flutter`, tidak ada referensi `Color` atau `IconData`, dan tidak ada method serialisasi `toMap()`/`fromMap()`.

**Field:**
| Field | Tipe | Keterangan |
|-------|------|-----------|
| `id` | `int?` | ID unik dari database (null sebelum disimpan) |
| `imagePath` | `String` | Path absolut file gambar di storage app |
| `meatType` | `String?` | Jenis daging (opsional, untuk fitur mendatang) |
| `result` | `String` | Kode hasil: `'fresh'`, `'half_fresh'`, atau `'spoiled'` |
| `confidence` | `double` | Tingkat kepercayaan model: 0.0 – 1.0 |
| `createdAt` | `DateTime` | Waktu scan dilakukan |

**Display helpers (pure Dart getter):**
| Getter | Return | Contoh |
|--------|--------|--------|
| `displayName` | `String` | `"SEGAR"`, `"SETENGAH SEGAR"`, `"BUSUK"` |
| `statusEmoji` | `String` | `"✅"`, `"⚠️"`, `"⛔"` |
| `isLowConfidence` | `bool` | `true` jika confidence < 0.5 |
| `confidencePercent` | `String` | `"94.0%"` |

**Method:**
- `copyWith({...})` — buat salinan objek entity dengan field tertentu diubah

---

#### `lib/domain/repositories/classification_repository.dart`

**Kontrak interface repository (Domain Contract).** 

Mendefinisikan *apa* kebutuhan domain tanpa mempedulikan *bagaimana* data tersebut diambil atau disimpan (apakah SQLite, REST API, atau mock data).

```dart
abstract class ClassificationRepository {
  Future<ClassificationResult> save(ClassificationResult result);
  Future<List<ClassificationResult>> getAll();
  Future<ClassificationResult?> getById(int id);
  Future<void> delete(int id);
  Future<void> deleteAll();
  Future<int> count();
}
```

---

### 🖥️ Presentation Layer — Providers (State Management)

---

#### `lib/presentation/providers/scan_provider.dart`

Mengelola **seluruh alur scan** dari pemilihan gambar hingga hasil tersimpan. Extends `ChangeNotifier`.

> 💉 **Dependency Injection via Constructor:** Menerima `TfliteService` dan `ClassificationRepository` (interface abstraksi) melalui constructor. Tidak pernah membuat dependency konkret sendiri (`new`).

**Constructor:**
```dart
ScanProvider({
  required TfliteService tfliteService,
  required ClassificationRepository repository,
});
```

**State Machine:**
```
idle → imageSelected → processing → success
                                  → error
```

**Enum `ScanState`:**
- `idle` — tidak ada gambar dipilih
- `imageSelected` — gambar sudah dipilih, belum dianalisis
- `processing` — sedang menjalankan analisis
- `success` — analisis berhasil
- `error` — analisis gagal

**Method:**

| Method | Keterangan |
|--------|-----------|
| `selectImage(path)` | Set path gambar, ubah state ke `imageSelected` |
| `clearSelection()` | Reset gambar, kembali ke `idle` |
| `analyzeImage()` | Urutan: copy gambar → classify → buat model → simpan ke DB → state `success` atau `error` |
| `reset()` | Full reset semua state ke `idle` |

**Alur `analyzeImage()`:**
```
1. Set state → processing
2. ImagePreprocessor.copyToAppStorage(path)   ← salin gambar ke app storage
3. TfliteService.classify(storedPath)         ← jalankan inferensi ML
4. Buat ClassificationResult dari output
5. ClassificationRepository.save(result)      ← simpan ke SQLite via abstraksi
6. Set state → success (atau error jika exception)
```

---

#### `lib/presentation/providers/history_provider.dart`

Mengelola **state halaman riwayat** termasuk data, filter, dan pencarian. Extends `ChangeNotifier`.

> 💉 **Dependency Injection via Constructor:** Menerima `ClassificationRepository` (interface domain) melalui constructor.

**Constructor:**
```dart
HistoryProvider({
  required ClassificationRepository repository,
});
```

**State internal:**
- `_items` — daftar semua hasil scan dari DB
- `_isLoading` — indikator loading
- `_activeFilter` — filter aktif: `'all'`, `'fresh'`, `'half_fresh'`, `'spoiled'`
- `_searchQuery` — teks pencarian aktif
- `_errorMessage` — pesan error jika load gagal

**Computed getter:**
- `filteredItems` — item yang sudah difilter berdasarkan status dan search query
- `countByResult(result)` — jumlah item per status (untuk chip filter)

**Method:**

| Method | Keterangan |
|--------|-----------|
| `loadHistory()` | Ambil semua riwayat dari repository, update `_items` |
| `deleteItem(id)` | Hapus satu item dari DB dan hapus dari `_items` secara lokal |
| `deleteAll()` | Hapus semua riwayat dari DB dan kosongkan `_items` |
| `setFilter(filter)` | Set filter aktif, trigger rebuild UI |
| `setSearchQuery(query)` | Set query pencarian, trigger rebuild UI |
| `resetFilters()` | Reset filter ke 'all' dan kosongkan pencarian |

---

### 🖥️ Presentation Layer — Screens

---

#### `lib/presentation/shell_screen.dart`

**Wrapper navigasi utama** yang mengelola Bottom Navigation Bar dengan tiga tab.

**Cara kerja:**
- Menggunakan `IndexedStack` untuk menjaga state setiap tab tetap hidup saat berpindah tab (tidak rebuild dari nol).
- Tiga tab: **BERANDA** (index 0), **PINDAI** (index 1), **RIWAYAT** (index 2).
- Meneruskan callback `onNavigateToTab` ke `HomeScreen` agar tombol di beranda bisa berpindah tab secara programatik.

**Widget:**
- `_buildBottomNav()` — Membangun navigation bar dengan styling neobrutalism.
- `_buildNavItem(index, icon, label)` — Item navigasi dengan animasi warna aktif (background merah saat aktif).

---

#### `lib/presentation/home/home_screen.dart`

**Halaman beranda** — halaman pertama yang dilihat pengguna saat membuka aplikasi.

**Komponen yang ditampilkan:**
1. **Hero Banner** — Card merah besar dengan ikon daging, nama aplikasi, dan tagline.
2. **Tombol "MULAI CEK"** — Card merah besar dengan animasi press-down, navigasi ke tab Pindai.
3. **Quick Actions** — Dua tombol kecil: "RIWAYAT" dan "UNGGAH" (dari galeri).
4. **Safety Disclaimer** — Banner kuning berisi peringatan bahwa aplikasi bukan pengganti inspeksi resmi.

**Widget internal `_PressableCard`:**
- `StatefulWidget` yang mengimplementasikan animasi press-down neobrutalism.
- `onTapDown` → translate +2px & shadow mengecil (kesan ditekan).
- `onTapUp` / `onTapCancel` → kembali ke posisi semula.

---

#### `lib/presentation/capture/capture_screen.dart`

**Halaman scan/capture** — tempat pengguna mengambil atau memilih foto daging.

**Fitur:**
- **Animasi pulse** pada tombol kamera (scale 0.9 → 1.1, loop, `AnimationController` + `SingleTickerProviderStateMixin`).
- **Tombol Kamera** — `_pickFromCamera()`: buka kamera native via `image_picker`, quality 85%, maxWidth 1920px.
- **Tombol Galeri** — `_pickFromGallery()`: buka galeri via `image_picker`.
- Setelah foto dipilih → navigasi `push` ke `PreviewScreen`.
- Jika kamera/galeri ditolak → tampilkan `SnackBar` pesan error.

**Integrasi dengan Provider:**
- Listen ke `ScanProvider.scanState`.
- Jika state berubah ke `processing` → tampilkan `NeoLoading` overlay.
- Jika state berubah ke `success` → navigasi `push` ke `ResultScreen`.

---

#### `lib/presentation/preview/preview_screen.dart`

**Halaman pratinjau foto** — tampil antara capture dan analisis, memberi pengguna kesempatan mengkonfirmasi atau mengganti foto.

**Tampilan:**
- Foto yang dipilih (~60% ruang layar) dengan `Image.file()`, `BoxFit.cover`.
- Teks panduan: "Pastikan daging terlihat jelas dan pencahayaan cukup."
- **Tombol "PILIH FOTO LAIN"** — `Navigator.pop()` kembali ke CaptureScreen.
- **Tombol "ANALISIS"** — memanggil callback `onAnalyze` (yang diset oleh CaptureScreen untuk memanggil `ScanProvider.analyzeImage()`).

**Widget internal `_PressableButton`:**
- Animasi press-down neobrutalism, dua varian: primary (merah) dan secondary (putih).

---

#### `lib/presentation/result/result_screen.dart`

**Halaman hasil analisis** — menampilkan detail hasil klasifikasi setelah `analyzeImage()` berhasil.

**Komponen:**
1. **Scan ID Bar** — Timestamp scan dan ID unik.
2. **Preview Gambar** — Foto daging yang dianalisis.
3. **Verdict Card** — Card besar dengan warna status, emoji, nama status (`SEGAR/SETENGAH SEGAR/BUSUK`), dan skor confidence.
4. **Confidence Card** — Progress bar visual dari confidence score.
5. **Low Confidence Warning** — Banner kuning dengan teks peringatan, hanya muncul jika `confidence < 0.5`.
6. **Safety Notice** — Disclaimer teks dari `AppConstants.disclaimer`.
7. **Action Buttons** — Tombol "SCAN LAGI" (reset + navigasi ke Capture) dan "LIHAT RIWAYAT".

---

#### `lib/presentation/history/history_screen.dart`

**Halaman riwayat** — daftar semua scan yang tersimpan dengan fitur filter dan pencarian.

**Fitur:**
- **Auto-load** saat tab pertama kali dibuka (via `initState` → `HistoryProvider.loadHistory()`).
- **Filter Chips** — tombol SEMUA / SEGAR / SETENGAH SEGAR / BUSUK dengan counter badge.
- **Search Bar** — kolom pencarian yang memfilter berdasarkan nama status atau jenis daging.
- **Daftar Riwayat** — `ListView.builder` dengan item berisi: thumbnail gambar, badge status, persentase confidence, waktu scan, dan tombol hapus.
- **Hapus Semua** — tombol di AppBar untuk menghapus seluruh riwayat (dengan dialog konfirmasi).
- **Empty State** — tampil saat tidak ada data atau tidak ada yang cocok dengan filter.
- **Error State** — tampil jika load dari DB gagal.

**Widget internal `_PressableButton`:**
- Wrapper dengan animasi press-down neobrutalism untuk setiap tombol di dalam layar ini.

---

### 🎨 Widgets (Reusable Neobrutalist Components)

---

#### `lib/widgets/confidence_bar.dart`

Progress bar horizontal bergaya neobrutalism untuk menampilkan nilai **confidence** model.

- Nilai 0.0–1.0 divisualisasikan sebagai bar horizontal.
- Warna bar berubah secara dinamis sesuai level kepercayaan.
- Border tebal dan background kontras sesuai tema neobrutalism.

---

#### `lib/widgets/neo_badge.dart`

Badge berbentuk **pill** (sudut bulat penuh) untuk label status kesegaran daging.

**Factory constructors:**
- `NeoBadge.fresh()` → background hijau, ikon `check_circle`, teks "FRESH"
- `NeoBadge.halfFresh()` → background kuning, ikon `warning`, teks "HALF-FRESH"
- `NeoBadge.spoiled()` → background merah, ikon `block`, teks "SPOILED", teks putih
- `NeoBadge.fromResult(String result)` → dispatch otomatis ke salah satu factory di atas

Semua badge memiliki border hitam dan hard shadow kecil (2×2).

---

#### `lib/widgets/neo_button.dart`

Tombol neobrutalist yang dapat dikonfigurasi penuh.

**Parameter:**
- `child` — konten tombol (biasanya `Row` icon + text)
- `onPressed` — callback aksi
- `backgroundColor` — default ke `AppColors.primaryContainer`
- `borderWidth`, `borderRadius`, `padding`, `width`, `height` — configurable

**Animasi:**
- `onTapDown` → translate +2px (kesan ditekan), shadow mengecil ke `hardSmall`
- `onTapUp` / `onTapCancel` → kembali normal
- Durasi animasi: 100ms

---

#### `lib/widgets/neo_card.dart`

Container card neobrutalist yang bisa dipakai di mana saja.

**Parameter:**
- `child` — konten card
- `backgroundColor` — default putih
- `padding` — default 16px semua sisi
- `borderWidth` — default 2.5px
- `borderRadius` — default 12px
- `shadowX`, `shadowY` — offset shadow, default 4×4
- `onTap` — opsional, membuat card menjadi tappable

---

#### `lib/widgets/neo_loading.dart`

Loading indicator bergaya neobrutalism. Bisa dipakai dua cara:

**1. Inline widget:**
```dart
NeoLoading(text: 'MEMPROSES...')
```

**2. Overlay global:**
```dart
// Tampilkan di atas semua konten
NeoLoading.show(context, text: 'MENGANALISIS GAMBAR...');

// Sembunyikan
NeoLoading.hide();
```

**Tampilan:**
- Background semi-transparan (krem 85% opacity) menutupi seluruh layar.
- Card putih di tengah dengan:
  - Spinner merah dalam lingkaran merah border hitam
  - Teks bold uppercase
  - Teks deskripsi secondary

---

### 📁 Assets & Sys

---

#### `assets/model/`
Direktori yang dideklarasikan di `pubspec.yaml` sebagai asset path. Saat ini hanya berisi `.gitkeep` sebagai placeholder. Di sinilah file `meatfresh_model.tflite` akan ditempatkan saat model nyata siap.

#### `sys/`
Bukan bagian dari source code Flutter. Berisi dokumentasi internal tim:
- `MeatFresh_AI_PRD_Design_Neobrutalism.md` — Product Requirements Document untuk aspek desain visual.
- `MeatFresh_AI_PRD_Engineering.md` — Product Requirements Document untuk aspek teknik/engineering.
- `stitch_pembangun_berbasis_referensi/` — Koleksi referensi UI setiap halaman dalam format HTML + screenshot, digunakan sebagai acuan visual saat development.

---

## 6. Alur Kerja Aplikasi

```
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
      │                    ┌─────────────────────────────┐
      │                    │ 1. copyToAppStorage()        │
      │                    │ 2. TfliteService.classify()  │
      │                    │ 3. Repository.save()         │
      │                    └──────────────┬──────────────┘
      │                                   │
      │                         ┌─────────┴──────────┐
      │                         ▼                    ▼
      │                   [SUCCESS]              [ERROR]
      │                       │                    │
      │                       ▼                    ▼
      │               [ResultScreen]       SnackBar / error state
      │               ┌─────────────────┐
      │               │ Foto daging     │
      │               │ Badge status    │
      │               │ Confidence bar  │
      │               │ [SCAN LAGI]     │
      │               │ [LIHAT RIWAYAT] │
      │               └────────────┬────┘
      │                            │
      ▼                            ▼
[HistoryScreen] ◄─────────────────┘
┌─────────────────────────────────┐
│ Filter chips (SEMUA/SEGAR/...)  │
│ Search bar                       │
│ Daftar hasil scan (ListView)     │
│ Hapus per item / hapus semua     │
└─────────────────────────────────┘
```

---

## 7. Database Schema

**File:** `meatfresh.db` (SQLite, tersimpan di direktori data app Android)

**Tabel: `classifications`**

| Kolom | Tipe | Constraint | Keterangan |
|-------|------|-----------|-----------|
| `id` | `INTEGER` | `PRIMARY KEY AUTOINCREMENT` | ID unik auto-increment |
| `image_path` | `TEXT` | `NOT NULL` | Path absolut file gambar |
| `meat_type` | `TEXT` | — | Jenis daging (nullable, untuk fitur mendatang) |
| `result` | `TEXT` | `NOT NULL` | Kode hasil: `fresh`, `half_fresh`, `spoiled` |
| `confidence` | `REAL` | `NOT NULL` | Confidence score: 0.0 – 1.0 |
| `created_at` | `TEXT` | `NOT NULL` | Timestamp ISO 8601, contoh: `2026-10-12T08:00:00.000` |

---

## 8. Sistem Desain Neobrutalism

Neobrutalism adalah gaya desain yang menggunakan elemen-elemen berikut secara konsisten:

| Elemen | Implementasi di MeatFresh AI |
|--------|------------------------------|
| **Border tebal** | Semua card, tombol, badge menggunakan border hitam `#111111` ketebalan 1.5–3.0px |
| **Hard offset shadow** | Blur = 0, offset solid 2×2 hingga 5×5 pixel, warna hitam — memberi efek 3D datar |
| **Warna saturasi tinggi** | Merah primer `#B52603`, hijau status `#3DDC84`, kuning `#FFC93C`, biru `#0054CB` |
| **Tipografi bold** | SpaceGrotesk (headline, label) weight 700–800; PlusJakartaSans (body) weight 500–600 |
| **Animasi press-down** | Translate +2px saat ditekan + shadow mengecil dari 4×4 ke 2×2 (kesan fisik ditekan) |
| **Background krem** | Canvas `#FDF6EC` (bukan putih murni) — kontras lebih lembut |
| **Teks uppercase** | Semua label, tombol, dan badge menggunakan `HURUF BESAR` |

---

## 9. Refactor Clean Architecture & SOLID

Pada iterasi ini, dilakukan refactoring untuk memenuhi kaidah **Clean Architecture** dan prinsip **SOLID** (terutama *Single Responsibility* dan *Dependency Inversion*) sesuai panduan `CLEAN_ARCHITECTURE.md`.

---

### 📊 Perbandingan Sebelum vs Sesudah

| Aspek | ❌ Sebelum Refactor | ✅ Sesudah Refactor |
|-------|---------------------|---------------------|
| **Domain Entity** (`classification_result.dart`) | Mengimpor `package:flutter/material.dart`, memiliki method database `toMap()`/`fromMap()`, serta properti visual `statusColor` & `statusIcon`. Melanggar *Single Responsibility* & aturan layer. | **Murni Dart (`pure Dart`)**: Tanpa import Flutter, tanpa mapping database. Hanya memuat data bisnis inti dan helper teks murni. |
| **Model Data Layer** (`classification_model.dart`) | Belum ada pemisahan antara entity dan model data. Satu kelas mengerjakan semuanya. | Dibuat khusus di `data/models/classification_model.dart` yang meng-extends entity, menangani `toMap()`, `fromMap()`, dan konversi `toEntity()`. |
| **Kontrak Repository** (`domain/repositories/`) | Tidak ada interface/kontrak di domain layer. Repository langsung berupa kelas konkret di data layer. | Dibuat interface abstrak `ClassificationRepository` di dalam domain layer. Domain mendefinisikan *apa* yang dibutuhkan, bukan *bagaimana*. |
| **Implementasi Repository** (`data/repositories/`) | `ClassificationRepository` langsung menginstansiasi `ClassificationDao` sendiri (`_dao = ClassificationDao()`). | Diubah menjadi `ClassificationRepositoryImpl` yang mengimplementasikan interface domain dan menerima `ClassificationDao` via constructor injection. |
| **Dependency Injection di Provider** (`scan_provider.dart`, `history_provider.dart`) | Provider membuat dependency konkret sendiri di field: `final _repo = ClassificationRepository()`, `final _ml = TfliteService()`. Melanggar *Dependency Inversion*. | Seluruh dependensi disuntikkan via constructor (`ScanProvider({required this._tfliteService, required this._repository})`). Provider hanya mengenal interface domain. |
| **Wiring Dependensi** (`main.dart` & `widget_test.dart`) | Provider dipanggil dengan constructor kosong: `ScanProvider()`, `HistoryProvider()`. | Terpusat di `main.dart` (Composition Root). Semua infrastruktur dirakit sekali lalu di-inject ke provider tree. |
| **UI Helpers Visual** (`statusColor`, `statusIcon`) | Tercampur di entity domain (`lib/domain/models/`). | Dipindahkan ke `lib/core/result_ui_ext.dart` sebagai extension method pada entity, menjaga domain tetap steril. |

---

### 🏛️ Penerapan Prinsip SOLID

#### 1. S — Single Responsibility Principle (SRP)
- **Entity Domain** (`ClassificationResult`): Hanya bertanggung jawab atas struktur data bisnis klasifikasi daging.
- **Data Model** (`ClassificationModel`): Bertanggung jawab atas serialisasi SQLite dan mapping.
- **Repository Implementation** (`ClassificationRepositoryImpl`): Bertanggung jawab atas koordinasi penyimpanan data dan translasi exception ke `StorageException`.
- **UI Extension** (`ClassificationResultUiExt`): Bertanggung jawab atas adaptasi visual (Color/Icon) khusus UI Flutter.

#### 2. O — Open/Closed Principle (OCP)
- Kontrak `ClassificationRepository` terbuka untuk ekstensi (misalnya menambah `RemoteClassificationRepository` untuk cloud sync) tanpa perlu mengubah domain use case maupun presentation layer.

#### 3. L — Liskov Substitution Principle (LSP)
- `ClassificationModel` adalah turunan sah dari `ClassificationResult`. Kapan pun domain membutuhkan entity, model dapat disubstitusikan atau dikonversi dengan `toEntity()` tanpa efek samping.

#### 4. I — Interface Segregation Principle (ISP)
- Repository domain hanya memuat method-method yang benar-benar dibutuhkan oleh use case/provider (`save`, `getAll`, `getById`, `delete`, `deleteAll`, `count`).

#### 5. D — Dependency Inversion Principle (DIP)
- **High-level module** (`ScanProvider`, `HistoryProvider`) **tidak bergantung pada low-level module** (`ClassificationRepositoryImpl`, `ClassificationDao`, `sqflite`). Keduanya bergantung pada abstraksi (`ClassificationRepository` interface).
- Wiring konkret hanya terjadi di satu titik masuk (`main.dart`).

---

### 🔍 Bukti Verifikasi Sterilitas & Kualitas Kode

Sesuai aturan Clean Architecture, layer domain dan presentation diverifikasi sterilitasnya:

1. **Domain Steril (Dart Murni):**
   - File `lib/domain/models/classification_result.dart` dan `lib/domain/repositories/classification_repository.dart` **bebas dari** `import 'package:flutter'`, `sqflite`, atau package platform lainnya.
2. **Presentation Bebas Query Langsung:**
   - Tidak ada pemanggilan raw database atau inisialisasi repository langsung di dalam folder presentation/pages/widgets.
3. **Flutter Analyzer:**
   - Menjalankan `flutter analyze`: **`No issues found!`** (0 error, 0 warning, 0 info).

---

## 10. Status Pengembangan & TODO

### ✅ Sudah Selesai
- [x] Struktur proyek Clean Architecture berbasis First-Layer
- [x] Pemisahan Domain Entity murni & Data Model dengan SQLite serialization
- [x] Interface abstraksi repository di domain & implementasi konkret di data layer
- [x] Penerapan Dependency Injection (DI) terpusat pada Provider & main.dart
- [x] Sistem desain Neobrutalism lengkap (theme, komponen, visual extensions)
- [x] Alur navigasi (Shell + 3 tab)
- [x] Integrasi kamera & galeri (`image_picker`)
- [x] Database SQLite (schema, DAO, repository)
- [x] State management (`ScanProvider`, `HistoryProvider`)
- [x] Semua 5 layar UI (Home, Capture, Preview, Result, History)
- [x] Filter & search di halaman riwayat
- [x] Reusable widget library (NeoCard, NeoButton, NeoBadge, NeoLoading, ConfidenceBar)
- [x] Error handling terstruktur (custom exceptions)
- [x] Verifikasi `flutter analyze` bersih (No issues found)

### 🚧 Masih TODO

#### Prioritas Tinggi
- [ ] **Integrasi model TFLite nyata** — tambah `tflite_flutter` di pubspec, letakkan `meatfresh_model.tflite` di `assets/model/`, implementasi `ImagePreprocessor.prepare()` dan ganti mock di `TfliteService.classify()`
- [ ] **Preprocessing gambar** — resize 224×224, normalisasi pixel sesuai pipeline training model

#### Prioritas Sedang
- [ ] **Izin kamera/storage eksplisit** — integrasi `permission_handler` di `CaptureScreen` sebelum memanggil `image_picker`
- [ ] **Kolom `meat_type`** — UI untuk input jenis daging (ayam, sapi, kambing, dll.)
- [ ] **Export riwayat** — fitur ekspor ke CSV atau PDF

#### Prioritas Rendah
- [ ] **Unit tests use case & repository mock** — pengujian repository dengan fake/mock tanpa database asli
- [ ] **Widget tests** — test interaksi untuk semua layar utama
- [ ] **Onboarding screen** — panduan penggunaan pertama kali
- [ ] **Pengaturan** — dark mode toggle, bahasa, ukuran font

---

*Dokumentasi ini dibuat otomatis berdasarkan analisis source code proyek MeatFresh AI.*
*Versi: 1.1.0 (Clean Architecture & SOLID Edition) | Flutter SDK: ^3.13.1 | Terakhir diperbarui: November 2026*
