import 'dart:developer' as developer;

import '../../core/failures.dart';
import '../../domain/repositories/server_health_repository.dart';
import '../api/meat_prediction_remote_datasource.dart';
import '../errors/app_exceptions.dart';

/// Implementasi [ServerHealthRepository] yang memeriksa endpoint `/health` FastAPI.
class RemoteServerHealthRepository implements ServerHealthRepository {
  final MeatPredictionRemoteDataSource _remoteDataSource;

  RemoteServerHealthRepository({
    required this._remoteDataSource,
  });

  @override
  Future<({int? latencyMs, Failure? failure})> checkHealth() async {
    final stopwatch = Stopwatch()..start();
    try {
      await _remoteDataSource.checkHealth();
      stopwatch.stop();
      return (latencyMs: stopwatch.elapsedMilliseconds, failure: null);
    } on NetworkException catch (e, stackTrace) {
      stopwatch.stop();
      developer.log(
        'Kegagalan jaringan/HTTP saat memeriksa status server',
        name: 'RemoteServerHealthRepository',
        error: e,
        stackTrace: stackTrace,
      );
      final Failure failure = e.statusCode != null
          ? ServerFailure(e.message, statusCode: e.statusCode)
          : NetworkFailure(e.message);
      return (latencyMs: null, failure: failure);
    } on AppException catch (e, stackTrace) {
      stopwatch.stop();
      developer.log(
        'Kegagalan pemeriksaan status server',
        name: 'RemoteServerHealthRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return (latencyMs: null, failure: ServerFailure(e.message));
    } catch (e, stackTrace) {
      stopwatch.stop();
      developer.log(
        'Kesalahan tak terduga saat memeriksa status server',
        name: 'RemoteServerHealthRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return (
        latencyMs: null,
        failure: const ServerFailure('Gagal memeriksa koneksi ke server.'),
      );
    }
  }
}
