import 'package:flutter/material.dart';
import 'theme.dart';
import '../../domain/models/classification_result.dart';
import '../../domain/models/prediction_model_type.dart';

/// Extension UI untuk [PredictionModelType] agar label tampilan tetap di Presentation.
extension PredictionModelTypeUiExt on PredictionModelType {
  /// Nama lengkap model untuk UI.
  String get displayName {
    switch (this) {
      case PredictionModelType.netv2:
        return 'MOBILENET V2';
      case PredictionModelType.svm:
        return 'SVM';
    }
  }

  /// Label singkat uppercase untuk badge dan tombol.
  String get shortName {
    switch (this) {
      case PredictionModelType.netv2:
        return 'NETV2';
      case PredictionModelType.svm:
        return 'SVM';
    }
  }

  /// Deskripsi singkat metode klasifikasi.
  String get description {
    switch (this) {
      case PredictionModelType.netv2:
        return 'Deep Learning CNN';
      case PredictionModelType.svm:
        return 'Fitur Warna & Tekstur';
    }
  }
}

/// Extension Flutter untuk [ClassificationResult] agar domain dan core tetap murni Dart.
///
/// Getter [statusColor] dan [statusIcon] membutuhkan `package:flutter` sehingga
/// ditempatkan di presentation layer.
extension ClassificationResultUiExt on ClassificationResult {
  /// Nama model AI untuk ditampilkan pada halaman hasil.
  String get modelDisplayName => modelType?.displayName ?? 'LOKAL';

  /// Label singkat model untuk badge riwayat.
  String get modelShortName => modelType?.shortName ?? '';

  /// Warna status sesuai hasil klasifikasi.
  Color get statusColor {
    switch (result) {
      case 'fresh':
        return AppColors.statusFresh;
      case 'half_fresh':
        return AppColors.statusHalf;
      case 'spoiled':
        return AppColors.statusSpoiled;
      default:
        return AppColors.surfaceContainer;
    }
  }

  /// Ikon status sesuai hasil klasifikasi.
  IconData get statusIcon {
    switch (result) {
      case 'fresh':
        return Icons.check_circle;
      case 'half_fresh':
        return Icons.warning;
      case 'spoiled':
        return Icons.block;
      default:
        return Icons.help;
    }
  }
}
