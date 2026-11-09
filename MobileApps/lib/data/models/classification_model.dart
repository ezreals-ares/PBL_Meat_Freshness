import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../domain/models/classification_result.dart';

/// Data model yang memperluas [ClassificationResult] dengan:
/// - Serialisasi SQLite (`toMap` / `fromMap`) — urusan data layer
/// - Display helpers Flutter (`statusColor`, `statusIcon`) — membutuhkan package:flutter
///
/// Domain entity [ClassificationResult] tetap murni Dart tanpa import Flutter.
class ClassificationModel extends ClassificationResult {
  const ClassificationModel({
    super.id,
    required super.imagePath,
    super.meatType,
    required super.result,
    required super.confidence,
    required super.createdAt,
  });

  // ─── Flutter display helpers ──────────────────────────────

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

  // ─── SQLite serialization ─────────────────────────────────

  /// Konversi ke Map untuk disimpan ke SQLite.
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'image_path': imagePath,
        'meat_type': meatType,
        'result': result,
        'confidence': confidence,
        'created_at': createdAt.toIso8601String(),
      };

  /// Parsing dari baris SQLite ke [ClassificationModel].
  factory ClassificationModel.fromMap(Map<String, dynamic> map) =>
      ClassificationModel(
        id: map['id'] as int?,
        imagePath: map['image_path'] as String,
        meatType: map['meat_type'] as String?,
        result: map['result'] as String,
        confidence: (map['confidence'] as num).toDouble(),
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  /// Buat [ClassificationModel] dari domain entity.
  factory ClassificationModel.fromEntity(ClassificationResult entity) =>
      ClassificationModel(
        id: entity.id,
        imagePath: entity.imagePath,
        meatType: entity.meatType,
        result: entity.result,
        confidence: entity.confidence,
        createdAt: entity.createdAt,
      );

  /// Konversi ke domain entity murni.
  ClassificationResult toEntity() => ClassificationResult(
        id: id,
        imagePath: imagePath,
        meatType: meatType,
        result: result,
        confidence: confidence,
        createdAt: createdAt,
      );

  @override
  ClassificationModel copyWith({
    int? id,
    String? imagePath,
    String? meatType,
    String? result,
    double? confidence,
    DateTime? createdAt,
  }) {
    return ClassificationModel(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      meatType: meatType ?? this.meatType,
      result: result ?? this.result,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
