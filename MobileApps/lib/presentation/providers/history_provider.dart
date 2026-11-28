import 'package:flutter/material.dart';
import '../../domain/models/classification_result.dart';
import '../../domain/repositories/classification_repository.dart';

/// Provider managing the history screen state.
///
/// Semua dependensi disuntikkan via constructor (Dependency Inversion Principle).
/// Menerima error sebagai `Failure` dari repository, tanpa try-catch di UI layer.
class HistoryProvider extends ChangeNotifier {
  final ClassificationRepository _repository;

  HistoryProvider({required this._repository});

  List<ClassificationResult> _items = [];
  bool _isLoading = false;
  String _activeFilter = 'all';
  String? _errorMessage;

  // ─── Getters ──────────────────────────────────────────────

  List<ClassificationResult> get items => _items;
  bool get isLoading => _isLoading;
  String get activeFilter => _activeFilter;
  String? get errorMessage => _errorMessage;

  /// Items filtered by freshness status.
  List<ClassificationResult> get filteredItems {
    if (_activeFilter == 'all') return List.unmodifiable(_items);
    return _items.where((item) => item.result == _activeFilter).toList();
  }

  /// Count of each status for filter chips.
  int countByResult(String result) =>
      _items.where((i) => i.result == result).length;

  // ─── Actions ──────────────────────────────────────────────

  /// Load all history from the database.
  Future<void> loadHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final outcome = await _repository.getAll();
    if (outcome.failure != null) {
      _errorMessage = outcome.failure!.message;
    } else {
      _items = outcome.results;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Delete a single item by id.
  Future<void> deleteItem(int id) async {
    final failure = await _repository.delete(id);
    if (failure != null) {
      _errorMessage = failure.message;
    } else {
      _items.removeWhere((i) => i.id == id);
    }
    notifyListeners();
  }

  /// Delete all history.
  Future<void> deleteAll() async {
    final failure = await _repository.deleteAll();
    if (failure != null) {
      _errorMessage = failure.message;
    } else {
      _items = [];
    }
    notifyListeners();
  }

  /// Set the active filter.
  void setFilter(String filter) {
    if (_activeFilter == filter) return;
    _activeFilter = filter;
    notifyListeners();
  }

  /// Reset filter back to all.
  void resetFilters() {
    if (_activeFilter == 'all') return;
    _activeFilter = 'all';
    notifyListeners();
  }
}
