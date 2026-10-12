import 'package:flutter/material.dart';
import '../../data/repositories/classification_repository.dart';
import '../../domain/models/classification_result.dart';

/// Provider managing the history screen state.
class HistoryProvider extends ChangeNotifier {
  final ClassificationRepository _repository = ClassificationRepository();

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

  /// Items filtered by status and search query.
  List<ClassificationResult> get filteredItems {
    return _items.where((item) {
      final matchesFilter =
          _activeFilter == 'all' || item.result == _activeFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          item.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item.meatType?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);
      return matchesFilter && matchesSearch;
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

    try {
      _items = await _repository.getAll();
    } catch (e) {
      _errorMessage = 'Failed to load history.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Delete a single item by id.
  Future<void> deleteItem(int id) async {
    try {
      await _repository.delete(id);
      _items.removeWhere((i) => i.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete record.';
      notifyListeners();
    }
  }

  /// Delete all history.
  Future<void> deleteAll() async {
    try {
      await _repository.deleteAll();
      _items = [];
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to clear history.';
      notifyListeners();
    }
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
