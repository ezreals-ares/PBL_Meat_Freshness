# MeatFresh AI — Deteksi Kesegaran Daging Berbasis Citra

Platform deteksi awal kesegaran daging berbasis citra yang terdiri dari aplikasi Android (**Flutter**), layanan inferensi API (**FastAPI** dengan model **MobileNetV2** & **SVM**), notebook pelatihan model (**TrainModel**), dan pengujian E2E otomatis (**Appium + WebdriverIO**).

---

## Struktur Repositori

```text
PBL_Meat_Freshness/
├── MobileApps/       # Aplikasi Android Flutter (Clean Architecture, Provider, SQLite)
├── FastAPI/          # Backend REST API inferensi MobileNetV2 & SVM + keamanan X-API-Key
├── TrainModel/       # Notebook eksperimen & pelatihan model (MobileNetV2, SVM, ShuffleNet)
├── AutomationTest/   # E2E Automation Testing (Appium + WebdriverIO + Allure Report)
├── README.md
└── LICENSE           # MIT License
```

---

## Fitur Utama

- **Pindai, Pilih Model AI & Preview Fullscreen** — Ambil foto dari kamera atau unggah dari galeri, pilih model **MobileNetV2** (`NETV2`, Deep Learning CNN) atau **SVM** (Fitur Warna & Tekstur), dapatkan klasifikasi (`SEGAR` / `SETENGAH SEGAR` / `BUSUK`) beserta penolakan otomatis objek non-daging, skor kepercayaan, distribusi probabilitas, dan ketuk gambar hasil untuk tampilan *fullscreen pinch-to-zoom*.
- **Riwayat Klasifikasi Lokal (SQLite)** — Menyimpan hasil pindai lengkap dengan foto lokal, model yang dipakai, timestamp, 4 filter status (`SEMUA`, `SEGAR`, `SETENGAH SEGAR`, `BUSUK`), serta mode pilih/pilih semua, hapus terpilih, dan hapus semua.
- **Menu Pengaturan** — Mengatur model AI default, memeriksa status & latensi koneksi `/health` server AI, memantau/meminta izin kamera & galeri, serta panduan pengambilan foto akurat.
- **Keamanan & Konfigurasi Produksi API** — Endpoint inferensi `/predict/netv2` dan `/predict/svm` dilindungi header `X-API-Key` dan *sliding-window rate limiting* di `FastAPI/`, serta injeksi konfigurasi `--dart-define-from-file=env.json` di `MobileApps/` tanpa URL hardcoded.
- **Panduan Keamanan & Penyimpanan** — Informasi suhu chiller/freezer serta peringatan batasan analisis visual.
- **Pengujian Otomatis** — Unit & widget test Flutter (`MobileApps/test/`), unit test keamanan & validasi non-daging FastAPI (`FastAPI/test_security.py`, `FastAPI/test_meat_validator.py`), dan E2E test Android (`AutomationTest/`).

---

## Arsitektur & Cara Kerja

1. **Mobile App (`MobileApps/`)** mengirim foto daging ke endpoint FastAPI (`/predict/netv2` atau `/predict/svm`) melalui `Dio` dengan header `X-API-Key`.
2. **Backend (`FastAPI/`)** memvalidasi API key & batas rate limit, lalu menjalankan:
   - **MobileNetV2**: preprocessing citra `224×224` dan inferensi `.tflite` terkuantisasi (`ai-edge-litert`).
   - **SVM Lanjutan**: segmentasi area daging + ekstraksi fitur warna/tekstur (`183` fitur) dan klasifikasi probabilistik (`svm_meat_fitur_lanjutan.pkl`), dengan fallback ke seluruh frame jika segmentasi gagal (`segmentation_fallback`).
3. **Hasil** dikembalikan ke aplikasi sebagai JSON (`is_meat`, `label`, `confidence`, `probabilities`, `reason`, `meat_coverage`, `segmentation_fallback`), ditampilkan di layar hasil (atau kartu penolakan non-daging), dan riwayat daging valid disimpan ke SQLite lokal.

---

## Panduan Menjalankan

### 1. Backend (`FastAPI/`)
```powershell
cd FastAPI
copy .env.example .env   # isi API_KEY sesuai kebutuhan
docker compose up -d --build
```
Atau jalankan unit test keamanan & validator non-daging:
```powershell
cd FastAPI
.\.venv\Scripts\python.exe -m unittest -v test_security.py test_meat_validator.py
```

### 2. Aplikasi Mobile (`MobileApps/`)
Salin `MobileApps/env.example.json` menjadi `MobileApps/env.json`, isi `API_BASE_URL` dan `API_KEY`, lalu jalankan:
```powershell
cd MobileApps
flutter pub get
flutter run --dart-define-from-file=env.json
```
Lihat [MobileApps/BUILDGUIDE.md](MobileApps/BUILDGUIDE.md) untuk panduan lengkap build APK debug/release, dan [MobileApps/DOKUMENTASI.md](MobileApps/DOKUMENTASI.md) untuk dokumentasi teknis lengkap.

### 3. Automation Test (`AutomationTest/`)
Pastikan perangkat/emulator Android terhubung (`adb devices`) dan APK debug sudah tersedia:
```powershell
cd AutomationTest
npm install
npm test
npm run report:generate
npm run report:open
```

---

## Dataset

Model dilatih menggunakan [Meat Freshness Image Dataset](https://www.kaggle.com/datasets/vinayakshanawad/meat-freshness-image-dataset) (±2.266 citra, 3 kelas: *Fresh*, *Half-Fresh*, *Spoiled*) dengan pendekatan *transfer learning* (MobileNetV2) serta ekstraksi fitur warna & tekstur (SVM).

---

## Tautan Proyek

| Kebutuhan | Tautan |
|---|---|
| Jira (backlog & sprint) | [Board PBL](https://nawafazril303.atlassian.net/jira/software/projects/PBL/list?jql=project%20%3D%20PBL%20ORDER%20BY%20cf%5B10019%5D%20ASC) |
| Dataset | [Kaggle — Meat Freshness Image Dataset](https://www.kaggle.com/datasets/vinayakshanawad/meat-freshness-image-dataset) |
| SKPL | [Google Docs — SKPL Meat Fresh AI](https://docs.google.com/document/d/1mJTl77ezW0QOKESKH1Kkd0Oc_nO5MLcQGwybGipyexc/edit?usp=sharing) |
| TSTC (Test Scenario & Test Case) | [Google Sheets — TSTC](https://docs.google.com/spreadsheets/d/10LqTvhYHU62ruZWzWAYnipIbd1ANF0eWsJ7ggX1NXfw/edit?usp=sharing) |

---

## Tim

| Nama | NIM | Peran |
|---|---|---|
| Nawaf Azril Annaufal | 244107020047 | Project Manager |
| Bima Adiwijaya | 244107020022 | ML Engineer |
| Adellia Salsa Al Barra | 244107020222 | QA / Tester |
| Rafi Abyantara Pratama | 244107020126 | Mobile Engineer |

---

## Catatan & Lisensi

Hasil klasifikasi merupakan **prediksi model**, bukan verifikasi pasti atas keamanan pangan. Selalu utamakan pemeriksaan fisik (bau, tekstur, warna, dan suhu penyimpanan) sebelum mengonsumsi daging.

Dirilis di bawah [MIT License](LICENSE).
