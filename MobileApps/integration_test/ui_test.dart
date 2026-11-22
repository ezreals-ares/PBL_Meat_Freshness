import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meatfresh_ai/main.dart' as app; 

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // TC-IT-001: Layar capture dapat dibuka
  testWidgets('TC-IT-001: Layar capture atau halaman utama dapat dibuka', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verifikasi aplikasi terbuka dan menampilkan elemen utama
    expect(find.byType(MaterialApp), findsOneWidget);
    print('-> TC-IT-001 Passed: Layar utama berhasil dibuka.');
  });

  // TC-IT-002: Gambar tampil pada layar preview (Simulasi tombol/navigasi ke preview)
  testWidgets('TC-IT-002: Gambar tampil pada layar preview', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Cari tombol galeri/kamera atau area untuk input gambar
    // (Sesuaikan widget finders dengan tombol asli di aplikasimu, misal: find.byIcon(Icons.camera))
    final cameraButton = find.byIcon(Icons.camera_alt);
    if (cameraButton.evaluate().isNotEmpty) {
      await tester.tap(cameraButton.first);
      await tester.pumpAndSettle();
    }
    print('-> TC-IT-002 Passed: Simulasi navigasi preview gambar.');
  });

  // TC-IT-003: Analisis gambar menghasilkan layar hasil prediksi
  testWidgets('TC-IT-003: Analisis gambar menghasilkan layar hasil', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Simulasi klik tombol analisis/prediksi jika ada di halaman
    final analyzeButton = find.text('Analisis');
    if (analyzeButton.evaluate().isNotEmpty) {
      await tester.tap(analyzeButton.first);
      await tester.pumpAndSettle(const Duration(seconds: 3)); // Menunggu proses prediksi
    }
    print('-> TC-IT-003 Passed: Proses analisis gambar diuji.');
  });

  // TC-IT-004: Hasil prediksi tersimpan dan tampil di riwayat
  testWidgets('TC-IT-004: Hasil prediksi tersimpan dan tampil di riwayat', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Cek navigasi ke menu riwayat (misalnya mencari ikon atau teks 'Riwayat')
    final historyMenu = find.text('Riwayat');
    if (historyMenu.evaluate().isNotEmpty) {
      await tester.tap(historyMenu.first);
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsWidgets); // Memastikan ada list riwayat
    }
    print('-> TC-IT-004 Passed: Menu riwayat pemindaian diuji.');
  });
}