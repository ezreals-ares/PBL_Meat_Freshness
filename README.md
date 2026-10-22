# Meat Fresh AI — Deteksi Kesegaran Daging Berbasis Citra

Aplikasi Android (Flutter) untuk pemeriksaan awal kondisi daging dari foto. Pengguna memotret daging lewat kamera atau memilih dari galeri, lalu aplikasi menjalankan model CNN **secara lokal di perangkat** (TensorFlow Lite, tanpa internet) dan menampilkan hasil klasifikasi.

## Fitur Utama

- **Pindai kesegaran** — ambil foto dari kamera atau galeri, dapatkan label kelas (Fresh / Half-Fresh / Spoiled) + persentase confidence
- **Riwayat klasifikasi** — tersimpan lokal (SQLite): lihat, cari, filter, hapus, dan ekspor
- **Panduan pengambilan gambar** — tips memotret agar hasil klasifikasi optimal
- **Peringatan batasan** — penjelasan bahwa hasil adalah prediksi model, bukan verifikasi pasti
- **Rekomendasi penyimpanan daging**

## Cara Kerja

1. Gambar di-*preprocessing* (resize 224×224, normalisasi)
2. Model CNN (MobileNetV2, dikonversi ke TensorFlow Lite) melakukan inferensi on-device
3. Hasil: label kelas, confidence, ikon, dan foto yang dianalisis

## Dataset

Model dilatih dengan [Meat Freshness Image Dataset](https://www.kaggle.com/datasets/vinayakshanawad/meat-freshness-image-dataset) (±2.266 citra, 3 kelas: Fresh, Half-Fresh, Spoiled) menggunakan *transfer learning*.

## Tautan Proyek

| Kebutuhan | Tautan |
|---|---|
| Jira (backlog & sprint) | [Board PBL](https://nawafazril303.atlassian.net/jira/software/projects/PBL/list?jql=project%20%3D%20PBL%20ORDER%20BY%20cf%5B10019%5D%20ASC) |
| Dataset | [Kaggle — Meat Freshness Image Dataset](https://www.kaggle.com/datasets/vinayakshanawad/meat-freshness-image-dataset) |
| SKPL | [Google Docs — SKPL Meat Fresh AI](https://docs.google.com/document/d/1mJTl77ezW0QOKESKH1Kkd0Oc_nO5MLcQGwybGipyexc/edit?usp=sharing) |
| TSTC (Test Scenario & Test Case) | [Google Sheets — TSTC](https://docs.google.com/spreadsheets/d/10LqTvhYHU62ruZWzWAYnipIbd1ANF0eWsJ7ggX1NXfw/edit?usp=sharing) |

## Tim

| Nama | NIM | Peran |
|---|---|---|
| Nawaf Azril Annaufal | 244107020047 | Project Manager |
| Bima Adiwijaya | 244107020022 | ML Engineer |
| Adellia Salsa Al Barra | 244107020222 | QA / Tester |
| Rafi Abyantara Pratama | 244107020126 | Mobile Engineer |

## Catatan

Hasil klasifikasi adalah **prediksi model**, bukan verifikasi pasti atas kondisi daging. Selalu utamakan pemeriksaan fisik (bau, tekstur, warna) untuk keputusan konsumsi.
