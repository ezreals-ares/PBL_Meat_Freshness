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
  String _searchQuery = '';
  String? _errorMessage;

  // ─── Getters ──────────────────────────────────────────────

  List<ClassificationResult> get items => _items;
  bool get isLoading => _isLoading;
  String get activeFilter => _activeFilter;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;

  /// Items filtered by status and search query (mendukung nama, jenis daging, dan ID/#MF-ID).
  List<ClassificationResult> get filteredItems {
    final query = _searchQuery.trim().toLowerCase();
    return _items.where((item) {
      final matchesFilter =
          _activeFilter == 'all' || item.result == _activeFilter;
      if (!matchesFilter) return false;
      if (query.isEmpty) return true;

      final id = item.id;
      final matchesName = item.displayName.toLowerCase().contains(query);
      final matchesMeat =
          item.meatType?.toLowerCase().contains(query) ?? false;
      final matchesId = id != null &&
          (id.toString().contains(query) ||
              'mf-$id'.contains(query) ||
              '#mf-$id'.contains(query));

      return matchesName || matchesMeat || matchesId;
    }).toList();
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
    _activeFilter = filter;
    notifyListeners();
  }

  /// Set the search query.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clear search and filter.
  void resetFilters() {
    _activeFilter = 'all';
    _searchQuery = '';
    notifyListeners();
  }
}
