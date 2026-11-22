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
extension ClassificationResultUiExt on ClassificationResult {
  /// Nama model AI untuk ditampilkan pada halaman hasil.
  String get modelDisplayName => modelType?.displayName ?? 'LOKAL';

  /// Label singkat model untuk badge riwayat.
  String get modelShortName => modelType?.shortName ?? '';

  /// Warna utama status sesuai hasil klasifikasi.
  Color get statusColor {
    switch (result) {
      case 'fresh':
        return AppColors.statusFresh;
      case 'half_fresh':
        return AppColors.statusHalf;
      case 'spoiled':
        return AppColors.statusSpoiled;
      default:
        return AppColors.tertiary;
    }
  }

  /// Warna container lembut untuk badge/kartu status.
  Color get statusSoftColor {
    switch (result) {
      case 'fresh':
        return AppColors.statusFreshSoft;
      case 'half_fresh':
        return AppColors.statusHalfSoft;
      case 'spoiled':
        return AppColors.statusSpoiledSoft;
      default:
        return AppColors.surfaceContainer;
    }
  }

  /// Warna teks ber-kontras tinggi di atas [statusColor].
  Color get statusOnColor {
    switch (result) {
      case 'fresh':
        return AppColors.onPrimary;
      case 'half_fresh':
        return AppColors.onAccent;
      case 'spoiled':
        return AppColors.onError;
      default:
        return AppColors.onPrimary;
    }
  }

  /// Warna teks ber-kontras tinggi di atas [statusSoftColor].
  Color get statusInkColor {
    switch (result) {
      case 'fresh':
        return AppColors.statusFreshInk;
      case 'half_fresh':
        return AppColors.amberInk;
      case 'spoiled':
        return AppColors.statusSpoiledInk;
      default:
        return AppColors.textPrimary;
    }
  }

  /// Ikon status sesuai hasil klasifikasi.
  IconData get statusIcon {
    switch (result) {
      case 'fresh':
        return Icons.verified_rounded;
      case 'half_fresh':
        return Icons.warning_amber_rounded;
      case 'spoiled':
        return Icons.dangerous_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  /// Ringkasan saran singkat per status kesegaran.
  String get statusAdvice {
    switch (result) {
      case 'fresh':
        return 'Warna dan permukaan tampak segar. Aman untuk diolah atau disimpan di chiller.';
      case 'half_fresh':
        return 'Kesegaran mulai menurun. Segera masak hingga matang sempurna dan cek aroma.';
      case 'spoiled':
        return 'Indikasi pembusukan terdeteksi. Sebaiknya tidak dikonsumsi demi keamanan pangan.';
      default:
        return 'Periksa kembali kondisi fisik dan aroma daging sebelum diolah.';
    }
  }
}
