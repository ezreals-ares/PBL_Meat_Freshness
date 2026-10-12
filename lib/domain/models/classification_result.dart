import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Domain model for a meat freshness classification result.
class ClassificationResult {
  final int? id;
  final String imagePath;
  final String? meatType;
  final String result; // 'fresh' | 'half_fresh' | 'spoiled'
  final double confidence; // 0.0 - 1.0
  final DateTime createdAt;

  ClassificationResult({
    this.id,
    required this.imagePath,
    this.meatType,
    required this.result,
    required this.confidence,
    required this.createdAt,
  });

  // ─── Display helpers ──────────────────────────────────────

  /// Label status yang mudah dibaca.
  String get displayName {
    switch (result) {
      case 'fresh':
        return 'SEGAR';
      case 'half_fresh':
        return 'SETENGAH SEGAR';
      case 'spoiled':
        return 'BUSUK';
      default:
        return result.toUpperCase();
    }
  }

  /// Emoji prefix for accessibility.
  String get statusEmoji {
    switch (result) {
      case 'fresh':
        return '✅';
      case 'half_fresh':
        return '⚠️';
      case 'spoiled':
        return '⛔';
      default:
        return '❓';
    }
  }

  /// Icon for this status.
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

  /// Color for this status.
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

  /// Whether the confidence is below the low-confidence threshold.
  bool get isLowConfidence => confidence < 0.5;

  /// Confidence as a percentage string, e.g. "94.0%".
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

  // ─── SQLite serialization ─────────────────────────────────

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'image_path': imagePath,
        'meat_type': meatType,
        'result': result,
        'confidence': confidence,
        'created_at': createdAt.toIso8601String(),
      };

  factory ClassificationResult.fromMap(Map<String, dynamic> map) =>
      ClassificationResult(
        id: map['id'] as int?,
        imagePath: map['image_path'] as String,
        meatType: map['meat_type'] as String?,
        result: map['result'] as String,
        confidence: (map['confidence'] as num).toDouble(),
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  ClassificationResult copyWith({
    int? id,
    String? imagePath,
    String? meatType,
    String? result,
    double? confidence,
    DateTime? createdAt,
  }) {
    return ClassificationResult(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      meatType: meatType ?? this.meatType,
      result: result ?? this.result,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
