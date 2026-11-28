# MeatFresh AI — Appium Automation Test

Suite pengujian End-to-End (E2E) otomatis menggunakan **WebdriverIO + Appium (UiAutomator2) + Mocha** untuk aplikasi Flutter **MeatFresh AI** (`com.meatfresh.ai`).

## Struktur Folder

```text
AutomationTest/
├── package.json                    # Konfigurasi dependensi & skrip pengujian
├── wdio.conf.js                    # Konfigurasi WebdriverIO + Appium UiAutomator2
├── .gitignore
├── README.md
└── test/
    ├── pageobjects/                # Page Object Model (POM) sesuai UI Flutter
    │   ├── BasePage.js             # Helper selector Android content-desc & Bottom Nav
    │   ├── HomePage.js             # Halaman Beranda (HomeScreen)
    │   ├── CapturePage.js          # Halaman Pindai (CaptureScreen)
    │   ├── PreviewPage.js          # Halaman Pratinjau & Pemilih Model (PreviewScreen)
    │   └── HistoryPage.js          # Halaman Riwayat & Filter (HistoryScreen)
    └── specs/                      # Skenario uji E2E
        ├── home.e2e.js
        ├── navigation.e2e.js
        ├── capture.e2e.js
        └── history.e2e.js
```

## Prasyarat

1. **Node.js & npm** sudah terpasang (`node -v`, `npm -v`).
2. **Android SDK** (`ANDROID_HOME` / `adb`) terpasang dan perangkat fisik atau Android Emulator sudah berjalan (`adb devices`).
3. **Appium UiAutomator2 driver** sudah terpasang (`npm run driver:list`).
4. **APK Debug Flutter** sudah dibuat di `MobileApps/`:

```powershell
cd ..\MobileApps
flutter build apk --debug --dart-define-from-file=env.json
```

Path APK bawaan yang digunakan `wdio.conf.js` adalah `../MobileApps/build/app/outputs/flutter-apk/app-debug.apk` (package `com.meatfresh.ai`, activity `com.example.flutter_application_1.MainActivity`).

## Cara Menjalankan Pengujian

Masuk ke folder `AutomationTest/`:

```powershell
cd C:\Code\PBL_Meat_Freshness\AutomationTest
```

Jalankan seluruh suite pengujian (Appium server dijalankan otomatis oleh `@wdio/appium-service`):

```powershell
npm test
```

Atau jalankan per skenario:

```powershell
npm run test:home
npm run test:navigation
npm run test:capture
npm run test:history
```

Jika pengujian gagal, screenshot otomatis disimpan ke folder `screenshots/` dan log Appium tersimpan di `logs/`.

## Variabel Environment Opsional

Anda dapat menimpa konfigurasi perangkat/APK tanpa mengubah `wdio.conf.js`:

- `DEVICE_NAME`: Nama device/emulator (bawaan: `Android Emulator`)
- `UDID`: Serial device dari output `adb devices` (berguna jika ada lebih dari 1 device)
- `APP_PATH`: Path kustom menuju file `.apk`

Contoh di PowerShell:

```powershell
$env:DEVICE_NAME="Pixel_7_API_34"
$env:UDID="emulator-5554"
npm test
```
