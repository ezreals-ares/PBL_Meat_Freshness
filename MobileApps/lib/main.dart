import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'data/db/classification_dao.dart';
import 'data/ml/tflite_service.dart';
import 'data/repositories/classification_repository.dart';
import 'presentation/providers/scan_provider.dart';
import 'presentation/providers/history_provider.dart';

/// Entry point aplikasi.
///
/// Semua dependensi dirakit di sini (Dependency Injection terpusat).
/// Widget/Provider tidak pernah membuat dependency sendiri — hanya
/// menerima abstraksi yang disuntikkan dari file ini.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // ─── Dependency Injection (Wiring) ───────────────────────
  // Data layer: infrastruktur konkret dirakit satu kali di sini
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
}
