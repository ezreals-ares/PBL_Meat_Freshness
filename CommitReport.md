# Laporan Commit Tiap Anggota — Meat Fresh AI

**Proyek:** Meat Fresh AI — Deteksi Kesegaran Daging Berbasis Citra (PBL Terintegrasi, Semester 5)
**Repository:** [ezreals-ares/PBL_Meat_Freshness](https://github.com/ezreals-ares/PBL_Meat_Freshness)
**Branch yang dilaporkan:** `dev` (branch aktif pengembangan)
**Periode commit:** 9 September 2026 – 22 November 2026
**Tanggal laporan dibuat:** 22 November 2026, 13.20 WIB
**Sumber data:** Riwayat commit GitHub branch `dev`, dicek langsung pada 22 November 2026

## Ringkasan

Total **58 commit** oleh **4 kontributor** di branch `dev` selama periode tersebut.

| Anggota | GitHub | Peran | Commit | Persentase | Commit pertama | Commit terakhir |
|---|---|---|---|---|---|---|
| Nawaf Azril Annaufal | `ezreals-ares` | Project Manager | 40 | 69.0% | 09 Sep 2026 11.12 WIB | 22 Nov 2026 12.09 WIB |
| Rafi Abyantara Pratama | `rafi1624` | Mobile Engineer | 13 | 22.4% | 22 Oct 2026 09.26 WIB | 22 Nov 2026 12.07 WIB |
| Adellia Salsa Al Barra | `Adellia03` | QA / Tester — QA Lead | 3 | 5.2% | 12 Oct 2026 09.46 WIB | 12 Oct 2026 09.57 WIB |
| Bima Adiwijaya | `bimaadiwijaya8` | ML Engineer | 2 | 3.4% | 21 Oct 2026 16.44 WIB | 02 Nov 2026 06.46 WIB |

## Nawaf Azril Annaufal — Project Manager

- **GitHub:** [ezreals-ares](https://github.com/ezreals-ares)
- **Total commit di `dev`:** 40 (27 commit langsung, 13 merge commit)
- **Periode aktif:** 09 Sep 2026 11.12 – 22 Nov 2026 12.09 WIB

**Fokus pekerjaan:** inisiasi Flutter, FastAPI (`/predict/svm` dan `/predict/netv2`, autentikasi API key, rate limiting), integrasi Dio dan arsitektur domain/data/presentation, dokumentasi, serta me-merge PR dari branch fs1, fs3, dan fs4.

### Daftar commit

| Tanggal (WIB) | SHA | Pesan commit |
|---|---|---|
| 22 Nov 2026 12.09 | `f66ce29` | Merge pull request #11 from ezreals-ares/fs4 |
| 22 Nov 2026 11.27 | `0604b3e` | Merge pull request #10 from ezreals-ares/fs1 |
| 20 Nov 2026 02.22 | `7439290` | feat(mobile): require dart-define API config, API key header, and build guide |
| 20 Nov 2026 01.28 | `ccf537c` | feat(fastapi): add API key auth and sliding-window rate limiting |
| 16 Nov 2026 20.37 | `2ff76d0` | Merge pull request #9 from ezreals-ares/fs1 |
| 16 Nov 2026 20.35 | `9dc7b64` | docs(mobile): update DOKUMENTASI.md for FastAPI Dio, DB v2, and high-priority UI |
| 16 Nov 2026 20.35 | `d8f32ea` | test(mobile): test prediction metadata persistence and usecase propagation |
| 16 Nov 2026 20.35 | `7a41298` | feat(presentation): add NetV2/SVM model selector and probability/fallback UI |
| 16 Nov 2026 20.35 | `43b361e` | feat(domain,data): persist prediction model type, probabilities, and SVM fallback |
| 16 Nov 2026 19.54 | `4e93588` | Merge pull request #8 from ezreals-ares/fs1 |
| 16 Nov 2026 19.53 | `61405d7` | fix(presentation): refresh history immediately after scan and on tab switch |
| 16 Nov 2026 19.47 | `a772a8e` | Merge pull request #7 from ezreals-ares/fs1 |
| 16 Nov 2026 19.45 | `0166785` | Merge branch 'dev' into fs1 |
| 16 Nov 2026 19.42 | `47b86a8` | Merge pull request #6 from ezreals-ares/fs4 |
| 16 Nov 2026 19.04 | `2b5ace7` | test(mobile): update widget test and add unit tests for usecase, Dio repo, model, and format |
| 16 Nov 2026 19.04 | `00e14cf` | refactor(presentation): sterilize core/presentation layers, wire DI, and use Failure state |
| 16 Nov 2026 19.03 | `2b51ac5` | feat(data): configure FastAPI Dio client, remote classifier, and Failure-based repositories |
| 16 Nov 2026 19.02 | `0a960c6` | refactor(domain): add Failure contracts, prediction entities, and AnalyzeMeatUseCase |
| 16 Nov 2026 19.01 | `e1ef8cc` | chore(mobile): add dio dependency and internet permission |
| 16 Nov 2026 14.29 | `5f362dd` | feat(fastapi): add /predict/svm and /predict/netv2 endpoints |
| 09 Nov 2026 09.48 | `8fdc2c7` | Merge pull request #5 from ezreals-ares/fs1 |
| 09 Nov 2026 09.06 | `84b25c7` | style: add one layer (MobileApps) |
| 09 Nov 2026 09.04 | `846ffcf` | feat(add): FastAPI init |
| 09 Nov 2026 09.00 | `33815b0` | feat: remove DOKUMENTASI.md from .gitignore |
| 09 Nov 2026 09.00 | `29aab7d` | feat(add): Documentation Change |
| 09 Nov 2026 08.59 | `8f9d6e7` | feat: update widget tests to include dependency injection for ScanProvider and HistoryProvider |
| 09 Nov 2026 08.58 | `9e5ed73` | feat: enhance dependency injection in main.dart for ScanProvider and HistoryProvider |
| 09 Nov 2026 08.56 | `99f8755` | feat: refactor providers to use constructor injection for dependencies |
| 09 Nov 2026 08.55 | `5e05bfb` | feat: update ClassificationResult model and add ClassificationRepository interface |
| 09 Nov 2026 08.54 | `90662bb` | feat: refactor classification data handling with ClassificationModel and update DAO methods |
| 09 Nov 2026 08.50 | `ac54024` | feat: add ClassificationResult extension for UI representation |
| 02 Nov 2026 07.00 | `01855fc` | Merge pull request #4 from ezreals-ares/fs3 |
| 22 Oct 2026 19.31 | `9efcd17` | Merge pull request #3 from ezreals-ares/fs1 |
| 22 Oct 2026 19.27 | `9a18d9e` | docs(readme): update readme & gitignore |
| 21 Oct 2026 18.09 | `44f3f5a` | Merge pull request #2 from ezreals-ares/fs3 |
| 12 Oct 2026 07.38 | `0b3b6cf` | Merge remote-tracking branch 'origin/dev' into fs1 |
| 12 Oct 2026 07.27 | `4ec02e7` | PBL Init |
| 10 Sep 2026 01.46 | `0f88b21` | Merge pull request #1 from ezreals-ares/fs1 |
| 10 Sep 2026 01.43 | `ef05122` | Flutter Init |
| 09 Sep 2026 11.12 | `941c3e7` | Initial commit |

## Rafi Abyantara Pratama — Mobile Engineer

- **GitHub:** [rafi1624](https://github.com/rafi1624)
- **Total commit di `dev`:** 13 (12 commit langsung, 1 merge commit)
- **Periode aktif:** 22 Oct 2026 09.26 – 22 Nov 2026 12.07 WIB

**Fokus pekerjaan:** implementasi dan redesign aplikasi Flutter — tema neo-brutalist, dashboard, kamera/scan, hasil klasifikasi, riwayat scan, navigasi, widget, serta model ShuffleNet.

### Daftar commit

| Tanggal (WIB) | SHA | Pesan commit |
|---|---|---|
| 22 Nov 2026 12.07 | `4f831b9` | test: add widget tests for history and redesigned screens |
| 22 Nov 2026 12.07 | `f15f6f7` | feat(history): update scan history list UI and filter chips |
| 22 Nov 2026 12.07 | `116cf65` | feat(result): modernize classification result verdict and confidence display |
| 22 Nov 2026 12.07 | `25fa7e2` | feat(scan): redesign camera viewfinder and preview confirmation flow |
| 22 Nov 2026 12.07 | `b27938b` | feat(home): redesign dashboard layout and hero banner |
| 22 Nov 2026 12.07 | `accf833` | feat(navigation): redesign bottom navigation bar with haptic feedback |
| 22 Nov 2026 12.06 | `21965b4` | feat(widgets): implement redesigned neo-brutalist card, badge, and illustration components |
| 22 Nov 2026 12.06 | `344ec67` | chore(assets): add hero image and configure pubspec assets |
| 22 Nov 2026 12.06 | `f4f3edd` | style(theme): update typography, colors, and neo-brutalist theme |
| 16 Nov 2026 06.59 | `9a3dd5c` | fix: bug history |
| 09 Nov 2026 09.59 | `c3bafb8` | refactor: syncronize |
| 09 Nov 2026 09.50 | `fb1e6cc` | Merge branch 'dev' of https://github.com/ezreals-ares/PBL_Meat_Freshness into fs4 |
| 22 Oct 2026 09.26 | `25666f6` | feat(model): add model shufflenet |

## Adellia Salsa Al Barra — QA / Tester — QA Lead

- **GitHub:** `Adellia03`
- **Total commit di `dev`:** 3
- **Periode aktif:** 12 Oct 2026 09.46 – 12 Oct 2026 09.57 WIB

**Fokus pekerjaan:** inisiasi awal proyek (PBL Init) dan rekomendasi penyimpanan.

### Daftar commit

| Tanggal (WIB) | SHA | Pesan commit |
|---|---|---|
| 12 Oct 2026 09.57 | `9a4f93d` | PBL Init |
| 12 Oct 2026 09.54 | `adea119` | PBL Init |
| 12 Oct 2026 09.46 | `8d00558` | Menambahkan Rekomendasi Penyimpanan |

## Bima Adiwijaya — ML Engineer

- **GitHub:** [bimaadiwijaya8](https://github.com/bimaadiwijaya8)
- **Total commit di `dev`:** 2
- **Periode aktif:** 21 Oct 2026 16.44 – 02 Nov 2026 06.46 WIB

**Fokus pekerjaan:** pelatihan model MobileNetV2 di Google Colab, dikirim via branch fs3 (PR #2 dan PR #4).

### Daftar commit

| Tanggal (WIB) | SHA | Pesan commit |
|---|---|---|
| 02 Nov 2026 06.46 | `4ac340a` | Dibuat menggunakan Colab |
| 21 Oct 2026 16.44 | `c6c1665` | Dibuat menggunakan Colab |

## Status Branch Lain (per 22 November 2026)

| Branch | Keterangan |
|---|---|
| `dev` | Branch aktif. 58 commit, 4 kontributor. Commit terakhir: merge PR #11 (fs4) oleh Nawaf, 22 November 2026 pukul 12.09 WIB. |
| `fs1` | 60 commit — sama dengan `dev` ditambah 2 commit yang **belum masuk `dev`**: `9ddbde9` test E2E Appium WebdriverIO dengan Allure reporting (Nawaf, 22 Nov 2026) dan `6004bad` merge `dev` ke `fs1` (Nawaf, 22 Nov 2026). |
| `fs4` | 57 commit, isinya pekerjaan Rafi (redesign UI 22 Nov 2026). Sudah di-merge ke `dev` lewat PR #11. |
| `fs3` | 3 commit — 2 commit Bima (Colab, 21 Okt dan 1 Nov 2026) ditambah initial commit. Keduanya sudah masuk `dev` lewat PR #2 dan PR #4. |
| `fs2` | Hanya initial commit (9 Sep 2026). Tidak ada pekerjaan tercatat di branch ini. |
| `production` | Hanya initial commit (9 Sep 2026). Belum ada rilis yang di-merge ke branch ini. |
