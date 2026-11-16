import 'package:flutter/material.dart';
import '../../domain/models/classification_result.dart';
import '../../domain/models/prediction_model_type.dart';
import '../../domain/usecases/analyze_meat_usecase.dart';

/// Scan flow states.
enum ScanState { idle, imageSelected, processing, success, error }

/// Provider managing the capture → preview → analyze → result flow.
///
/// Semua dependensi disuntikkan via constructor (Dependency Inversion Principle).
/// Presentation hanya bergantung pada domain layer ([AnalyzeMeatUseCase]) dan
/// menerima `Failure` sebagai data — tidak pernah menangkap exception mentah.
class ScanProvider extends ChangeNotifier {
  final AnalyzeMeatUseCase _analyzeMeatUseCase;

  ScanProvider({
    required this._analyzeMeatUseCase,
  });

  ScanState _scanState = ScanState.idle;
  String? _selectedImagePath;
  PredictionModelType _selectedModel = PredictionModelType.netv2;
  ClassificationResult? _currentResult;
  String? _errorMessage;

  // ─── Getters ──────────────────────────────────────────────

  ScanState get scanState => _scanState;
  String? get selectedImagePath => _selectedImagePath;
  PredictionModelType get selectedModel => _selectedModel;
  ClassificationResult? get currentResult => _currentResult;
  String? get errorMessage => _errorMessage;

  // ─── Actions ──────────────────────────────────────────────

  /// Set the selected image path (from camera or gallery).
  void selectImage(String path) {
    _selectedImagePath = path;
    _scanState = ScanState.imageSelected;
    _errorMessage = null;
    notifyListeners();
  }

  /// Pilih model klasifikasi AI (`netv2` atau `svm`).
  void selectModel(PredictionModelType model) {
    if (_selectedModel == model) return;
    _selectedModel = model;
    notifyListeners();
  }

  /// Clear the current selection and go back to idle.
  void clearSelection() {
    _selectedImagePath = null;
    _scanState = ScanState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// Run analysis on the selected image using the active model endpoint.
  Future<void> analyzeImage() async {
    if (_selectedImagePath == null) return;

    _scanState = ScanState.processing;
    _errorMessage = null;
    notifyListeners();

    final outcome = await _analyzeMeatUseCase(
      sourceImagePath: _selectedImagePath!,
      modelType: _selectedModel,
    );

    if (outcome.failure != null) {
      _errorMessage = outcome.failure!.message;
      _scanState = ScanState.error;
    } else {
      _currentResult = outcome.result;
      _scanState = ScanState.success;
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
}
