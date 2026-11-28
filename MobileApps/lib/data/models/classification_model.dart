import 'dart:convert';

import '../../domain/models/classification_result.dart';
import '../../domain/models/prediction_model_type.dart';
import 'model_type_codec.dart';

/// Data model yang memperluas [ClassificationResult] dengan serialisasi SQLite
/// (`toMap` / `fromMap`) dan konversi ke entity murni (`toEntity`).
///
/// Hanya bertugas sebagai mapper data eksternal — bebas dari import Flutter UI.
class ClassificationModel extends ClassificationResult {
  const ClassificationModel({
    super.id,
    required super.imagePath,
    super.meatType,
    required super.result,
    required super.confidence,
    required super.createdAt,
    super.modelType,
    super.probabilities,
    super.segmentationFallback,
    super.isMeat = true,
    super.rejectionReason,
  });

  // ─── SQLite serialization ─────────────────────────────────

  /// Konversi ke Map untuk disimpan ke SQLite.
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'image_path': imagePath,
        'meat_type': meatType,
        'result': result,
        'confidence': confidence,
        'created_at': createdAt.toIso8601String(),
        'model_used': ModelTypeCodec.encode(modelType),
        'probabilities_json':
            probabilities != null ? jsonEncode(probabilities) : null,
        'segmentation_fallback':
            segmentationFallback == null ? null : (segmentationFallback! ? 1 : 0),
      };

  /// Parsing dari baris SQLite ke [ClassificationModel] secara defensif.
  factory ClassificationModel.fromMap(Map<String, dynamic> map) {
    final parsedModelType =
        ModelTypeCodec.tryParse(map['model_used'] as String?);

    Map<String, double>? parsedProbs;
    final rawJson = map['probabilities_json'] as String?;
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawJson);
        if (decoded is Map) {
          final safeMap = <String, double>{};
          for (final entry in decoded.entries) {
            final key = entry.key;
            final value = entry.value;
            if (key is String && value is num) {
              safeMap[key] = value.toDouble();
            }
          }
          if (safeMap.isNotEmpty) {
            parsedProbs = safeMap;
          }
        }
      } catch (_) {
        parsedProbs = null;
      }
    }

    final rawFallback = map['segmentation_fallback'];
    final bool? parsedFallback =
        rawFallback == null ? null : (rawFallback == 1 || rawFallback == true);

    final rawCreatedAt = map['created_at'] as String?;
    final parsedCreatedAt = rawCreatedAt != null
        ? (DateTime.tryParse(rawCreatedAt) ??
            DateTime.fromMillisecondsSinceEpoch(0))
        : DateTime.fromMillisecondsSinceEpoch(0);

    return ClassificationModel(
      id: map['id'] as int?,
      imagePath: map['image_path'] as String? ?? '',
      meatType: map['meat_type'] as String?,
      result: map['result'] as String? ?? '',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      createdAt: parsedCreatedAt,
      modelType: parsedModelType,
      probabilities: parsedProbs,
      segmentationFallback: parsedFallback,
    );
  }

  /// Buat [ClassificationModel] dari domain entity.
  factory ClassificationModel.fromEntity(ClassificationResult entity) =>
      ClassificationModel(
        id: entity.id,
        imagePath: entity.imagePath,
        meatType: entity.meatType,
        result: entity.result,
        confidence: entity.confidence,
        createdAt: entity.createdAt,
        modelType: entity.modelType,
        probabilities: entity.probabilities,
        segmentationFallback: entity.segmentationFallback,
        isMeat: entity.isMeat,
        rejectionReason: entity.rejectionReason,
      );

  /// Konversi ke domain entity murni.
  ClassificationResult toEntity() => ClassificationResult(
        id: id,
        imagePath: imagePath,
        meatType: meatType,
        result: result,
        confidence: confidence,
        createdAt: createdAt,
        modelType: modelType,
        probabilities: probabilities != null
            ? Map<String, double>.unmodifiable(probabilities!)
            : null,
        segmentationFallback: segmentationFallback,
        isMeat: isMeat,
        rejectionReason: rejectionReason,
      );

  @override
  ClassificationModel copyWith({
    int? id,
    String? imagePath,
    String? meatType,
    String? result,
    double? confidence,
    DateTime? createdAt,
    PredictionModelType? modelType,
    Map<String, double>? probabilities,
    bool? segmentationFallback,
    bool? isMeat,
    String? rejectionReason,
  }) {
    return ClassificationModel(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      meatType: meatType ?? this.meatType,
      result: result ?? this.result,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
      modelType: modelType ?? this.modelType,
      probabilities: probabilities ?? this.probabilities,
      segmentationFallback: segmentationFallback ?? this.segmentationFallback,
      isMeat: isMeat ?? this.isMeat,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
