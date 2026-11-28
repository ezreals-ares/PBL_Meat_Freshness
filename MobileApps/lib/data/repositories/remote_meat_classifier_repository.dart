import 'dart:developer' as developer;

import '../errors/app_exceptions.dart';
import '../../core/failures.dart';
import '../../domain/models/prediction_model_type.dart';
import '../../domain/models/prediction_output.dart';
import '../../domain/repositories/meat_classifier_repository.dart';
import '../api/api_endpoints.dart';
import '../api/meat_prediction_remote_datasource.dart';

/// Implementasi [MeatClassifierRepository] yang terhubung ke FastAPI backend
/// untuk endpoint `/predict/netv2` dan `/predict/svm`.
///
/// Batas data → domain: semua exception dari datasource ditangkap di sini
/// dan dikembalikan sebagai [Failure].
class RemoteMeatClassifierRepository implements MeatClassifierRepository {
  final MeatPredictionRemoteDataSource _remoteDataSource;

  RemoteMeatClassifierRepository({
    required this._remoteDataSource,
  });

  /// Pemetaan model domain -> endpoint API secara exhaustive.
  static String _endpointFor(PredictionModelType modelType) {
    return switch (modelType) {
      PredictionModelType.netv2 => ApiEndpoints.predictNetV2,
      PredictionModelType.svm => ApiEndpoints.predictSvm,
    };
  }

  @override
  Future<({PredictionOutput? output, Failure? failure})> classify({
    required String imagePath,
    required PredictionModelType modelType,
  }) async {
    try {
      final model = await _remoteDataSource.predict(
        endpointPath: _endpointFor(modelType),
        imagePath: imagePath,
      );
      return (output: model.toEntity(), failure: null);
    } on NetworkException catch (e, stackTrace) {
      developer.log(
        'Kegagalan jaringan/HTTP saat klasifikasi',
        name: 'RemoteMeatClassifierRepository',
        error: e,
        stackTrace: stackTrace,
      );
      final Failure failure = e.statusCode != null
          ? ServerFailure(e.message, statusCode: e.statusCode)
          : NetworkFailure(e.message);
      return (output: null, failure: failure);
    } on ImageProcessingException catch (e, stackTrace) {
      developer.log(
        'Kegagalan pemrosesan gambar lokal sebelum upload',
        name: 'RemoteMeatClassifierRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return (output: null, failure: LocalFailure(e.message));
    } on AppException catch (e, stackTrace) {
      developer.log(
        'Kegagalan inferensi/data layer',
        name: 'RemoteMeatClassifierRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return (output: null, failure: ServerFailure(e.message));
    } catch (e, stackTrace) {
      developer.log(
        'Kesalahan tak terduga saat klasifikasi',
        name: 'RemoteMeatClassifierRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return (
        output: null,
        failure: const ServerFailure('Terjadi kesalahan saat memproses prediksi.'),
      );
    }
  }
}
