import 'package:flutter/material.dart';
import 'theme.dart';
import '../../domain/models/classification_result.dart';

/// Extension Flutter untuk [ClassificationResult] agar domain dan core tetap murni Dart.
///
/// Getter [statusColor] dan [statusIcon] membutuhkan `package:flutter` sehingga
/// ditempatkan di presentation layer.
extension ClassificationResultUiExt on ClassificationResult {
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
