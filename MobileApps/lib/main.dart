import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'data/api/dio_client.dart';
import 'data/api/meat_prediction_remote_datasource.dart';
import 'data/db/classification_dao.dart';
import 'data/repositories/classification_repository.dart';
import 'data/repositories/local_image_storage_repository.dart';
import 'data/repositories/remote_meat_classifier_repository.dart';
import 'domain/usecases/analyze_meat_usecase.dart';
import 'presentation/providers/history_provider.dart';
import 'presentation/providers/scan_provider.dart';

/// Entry point aplikasi.
///
/// Semua dependensi dirakit di sini (Composition Root / Dependency Injection terpusat).
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
  // Data layer: client Dio, remote FastAPI datasource, dan penyimpanan lokal
  final dio = DioClient.create();
  final remoteDataSource = MeatPredictionRemoteDataSourceImpl(dio: dio);
  final classifierRepository = RemoteMeatClassifierRepository(
    remoteDataSource: remoteDataSource,
  );
  const imageStorageRepository = LocalImageStorageRepository();

  final dao = ClassificationDao();
  final classificationRepository = ClassificationRepositoryImpl(dao: dao);

  // Domain layer: use case menggabungkan abstraksi repository
  final analyzeMeatUseCase = AnalyzeMeatUseCase(
    imageStorageRepository: imageStorageRepository,
    classifierRepository: classifierRepository,
    classificationRepository: classificationRepository,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ScanProvider(
            analyzeMeatUseCase: analyzeMeatUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(
            repository: classificationRepository,
          ),
        ),
      ],
      child: const MeatFreshApp(),
    ),
  );
}
