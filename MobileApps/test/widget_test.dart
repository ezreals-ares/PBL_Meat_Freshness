import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatfresh_ai/app.dart';
import 'package:meatfresh_ai/data/api/dio_client.dart';
import 'package:meatfresh_ai/data/api/meat_prediction_remote_datasource.dart';
import 'package:meatfresh_ai/data/db/classification_dao.dart';
import 'package:meatfresh_ai/data/repositories/classification_repository.dart';
import 'package:meatfresh_ai/data/repositories/local_image_storage_repository.dart';
import 'package:meatfresh_ai/data/repositories/remote_meat_classifier_repository.dart';
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
    const imageStorageRepository = LocalImageStorageRepository();
    final dao = ClassificationDao();
    final classificationRepository = ClassificationRepositoryImpl(dao: dao);

    final analyzeMeatUseCase = AnalyzeMeatUseCase(
      imageStorageRepository: imageStorageRepository,
      classifierRepository: classifierRepository,
      classificationRepository: classificationRepository,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
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
