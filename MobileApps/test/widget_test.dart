import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatfresh_ai/app.dart';
import 'package:meatfresh_ai/data/api/dio_client.dart';
import 'package:meatfresh_ai/data/api/meat_prediction_remote_datasource.dart';
import 'package:meatfresh_ai/data/db/classification_dao.dart';
import 'package:meatfresh_ai/data/repositories/local_image_storage_repository.dart';
import 'package:meatfresh_ai/data/repositories/remote_meat_classifier_repository.dart';
import 'package:meatfresh_ai/data/repositories/remote_server_health_repository.dart';
import 'package:meatfresh_ai/data/repositories/sqlite_classification_repository.dart';
import 'package:meatfresh_ai/domain/repositories/server_health_repository.dart';
import 'package:meatfresh_ai/domain/usecases/analyze_meat_usecase.dart';
import 'package:meatfresh_ai/presentation/providers/history_provider.dart';
import 'package:meatfresh_ai/presentation/providers/scan_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App renders without crash', (WidgetTester tester) async {
    final dio = DioClient.create(baseUrl: 'https://example.test');
    final remoteDataSource = MeatPredictionRemoteDataSourceImpl(dio: dio);
    final classifierRepository = RemoteMeatClassifierRepository(
      remoteDataSource: remoteDataSource,
    );
    final serverHealthRepository = RemoteServerHealthRepository(
      remoteDataSource: remoteDataSource,
    );
    const imageStorageRepository = LocalImageStorageRepository();
    final dao = ClassificationDao();
    final classificationRepository = SqliteClassificationRepository(
      dao: dao,
      imageStorageRepository: imageStorageRepository,
    );

    final analyzeMeatUseCase = AnalyzeMeatUseCase(
      imageStorageRepository: imageStorageRepository,
      classifierRepository: classifierRepository,
      classificationRepository: classificationRepository,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ServerHealthRepository>.value(value: serverHealthRepository),
          ChangeNotifierProvider(
            create: (_) => ScanProvider(analyzeMeatUseCase: analyzeMeatUseCase),
          ),
          ChangeNotifierProvider(
            create: (_) => HistoryProvider(repository: classificationRepository),
          ),
        ],
        child: const MeatFreshApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
