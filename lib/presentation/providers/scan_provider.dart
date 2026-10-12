import 'package:flutter/material.dart';
import '../../data/ml/tflite_service.dart';
import '../../data/ml/image_preprocessor.dart';
import '../../data/repositories/classification_repository.dart';
import '../../domain/models/classification_result.dart';

/// Scan flow states.
enum ScanState { idle, imageSelected, processing, success, error }

/// Provider managing the capture → preview → analyze → result flow.
class ScanProvider extends ChangeNotifier {
  final TfliteService _tfliteService = TfliteService();
  final ClassificationRepository _repository = ClassificationRepository();

  ScanState _scanState = ScanState.idle;
  String? _selectedImagePath;
  ClassificationResult? _currentResult;
  String? _errorMessage;

  // ─── Getters ──────────────────────────────────────────────

  ScanState get scanState => _scanState;
  String? get selectedImagePath => _selectedImagePath;
  ClassificationResult? get currentResult => _currentResult;
  String? get errorMessage => _errorMessage;
  bool get isModelLoaded => _tfliteService.isModelLoaded;

  // ─── Actions ──────────────────────────────────────────────

  /// Set the selected image path (from camera or gallery).
  void selectImage(String path) {
    _selectedImagePath = path;
    _scanState = ScanState.imageSelected;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear the current selection and go back to idle.
  void clearSelection() {
    _selectedImagePath = null;
    _scanState = ScanState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// Run analysis on the selected image.
  Future<void> analyzeImage() async {
    if (_selectedImagePath == null) return;

    _scanState = ScanState.processing;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Copy image to app storage
      final storedPath =
          await ImagePreprocessor.copyToAppStorage(_selectedImagePath!);

      // 2. Run classification (currently mock, will be real TFLite)
      final output = await _tfliteService.classify(storedPath);

      // 3. Create result
      final result = ClassificationResult(
        imagePath: storedPath,
        result: output['result'] as String,
        confidence: (output['confidence'] as num).toDouble(),
        createdAt: DateTime.now(),
      );

      // 4. Save to database
      _currentResult = await _repository.save(result);
      _scanState = ScanState.success;
    } catch (e) {
      _errorMessage = 'Analysis failed. Please try again.';
      _scanState = ScanState.error;
    }

    notifyListeners();
  }

  /// Full reset back to idle state.
  void reset() {
    _selectedImagePath = null;
    _currentResult = null;
    _scanState = ScanState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _tfliteService.dispose();
    super.dispose();
  }
}
