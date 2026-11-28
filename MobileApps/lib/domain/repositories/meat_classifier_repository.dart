import '../../core/failures.dart';
import '../models/prediction_model_type.dart';
import '../models/prediction_output.dart';

/// Kontrak domain untuk layanan klasifikasi kesegaran daging.
///
/// Domain mendefinisikan APA yang dibutuhkan — data layer yang menentukan
/// BAGAIMANA inferensi dijalankan (FastAPI via Dio atau implementasi lain).
abstract interface class MeatClassifierRepository {
  /// Klasifikasi gambar dengan [modelType].
  /// Berhasil → `output` terisi; gagal → `failure` terisi.
  Future<({PredictionOutput? output, Failure? failure})> classify({
    required String imagePath,
    required PredictionModelType modelType,
  });
}
