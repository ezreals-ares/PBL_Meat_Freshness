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

  /// Pemetaan model domain -> endpoint API (detail API tetap di data layer).
  static const Map<PredictionModelType, String> _endpointMap = {
    PredictionModelType.netv2: ApiEndpoints.predictNetV2,
    PredictionModelType.svm: ApiEndpoints.predictSvm,
  };

  RemoteMeatClassifierRepository({
    required this._remoteDataSource,
  });

  @override
  Future<({PredictionOutput? output, Failure? failure})> classify({
    required String imagePath,
    required PredictionModelType modelType,
  }) async {
    try {
      final model = await _remoteDataSource.predict(
        endpointPath: _endpointMap[modelType]!,
        imagePath: imagePath,
      );
      return (output: model.toEntity(), failure: null);
    } on NetworkException catch (e) {
      final Failure failure = e.statusCode != null
          ? ServerFailure(e.message, statusCode: e.statusCode)
          : NetworkFailure(e.message);
      return (output: null, failure: failure);
    } on ImageProcessingException catch (e) {
      return (output: null, failure: LocalFailure(e.message));
    } on AppException catch (e) {
      return (output: null, failure: ServerFailure(e.message));
    } catch (_) {
      return (
        output: null,
        failure: const ServerFailure('Terjadi kesalahan saat memproses prediksi.'),
      );
    }
  }
}
