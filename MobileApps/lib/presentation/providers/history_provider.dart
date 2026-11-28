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
  bool _isSelectionMode = false;
  final Set<int> _selectedIds = <int>{};

  // ─── Getters ──────────────────────────────────────────────

  List<ClassificationResult> get items => _items;
  bool get isLoading => _isLoading;
  String get activeFilter => _activeFilter;
  String? get errorMessage => _errorMessage;
  bool get isSelectionMode => _isSelectionMode;
  Set<int> get selectedIds => Set.unmodifiable(_selectedIds);
  int get selectedCount => _selectedIds.length;

  bool isSelected(int? id) => id != null && _selectedIds.contains(id);

  /// Apakah seluruh item pada filter aktif yang memiliki ID sudah dipilih.
  bool get isAllFilteredSelected {
    final selectableIds = filteredItems.map((e) => e.id).whereType<int>().toList();
    if (selectableIds.isEmpty) return false;
    return selectableIds.every(_selectedIds.contains);
  }

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
      final validIds = _items.map((e) => e.id).whereType<int>().toSet();
      _selectedIds.removeWhere((id) => !validIds.contains(id));
      if (_items.isEmpty) {
        _isSelectionMode = false;
      }
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
      _selectedIds.remove(id);
      if (_items.isEmpty) {
        _isSelectionMode = false;
      }
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
      _selectedIds.clear();
      _isSelectionMode = false;
    }
    notifyListeners();
  }

  // ─── Selection Actions ────────────────────────────────────

  /// Aktifkan mode pilih banyak, opsional langsung menandai [initialId].
  void enterSelectionMode({int? initialId}) {
    _isSelectionMode = true;
    if (initialId != null) {
      _selectedIds.add(initialId);
    }
    notifyListeners();
  }

  /// Keluar dari mode pilih banyak dan bersihkan pilihan.
  void exitSelectionMode() {
    if (!_isSelectionMode && _selectedIds.isEmpty) return;
    _isSelectionMode = false;
    _selectedIds.clear();
    notifyListeners();
  }

  /// Toggle status terpilih untuk satu item ber-ID [id].
  void toggleSelection(int id) {
    if (!_isSelectionMode) {
      _isSelectionMode = true;
    }
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  /// Pilih atau batalkan seluruh item yang terlihat pada filter aktif.
  void toggleSelectAllFiltered() {
    final visibleIds = filteredItems.map((e) => e.id).whereType<int>().toList();
    if (visibleIds.isEmpty) return;

    if (!_isSelectionMode) {
      _isSelectionMode = true;
    }

    if (visibleIds.every(_selectedIds.contains)) {
      _selectedIds.removeAll(visibleIds);
    } else {
      _selectedIds.addAll(visibleIds);
    }
    notifyListeners();
  }

  /// Hapus seluruh item yang dipilih dan kembalikan jumlah item yang terhapus.
  Future<int> deleteSelected() async {
    final targetIds = _selectedIds.toList();
    if (targetIds.isEmpty) return 0;

    final allIds = _items.map((e) => e.id).whereType<int>().toSet();
    final deletesAll =
        allIds.isNotEmpty && allIds.every(_selectedIds.contains);

    if (deletesAll) {
      final previousCount = _items.length;
      final failure = await _repository.deleteAll();
      if (failure != null) {
        _errorMessage = failure.message;
        notifyListeners();
        return 0;
      }
      _items = [];
      _selectedIds.clear();
      _isSelectionMode = false;
      notifyListeners();
      return previousCount;
    }

    var deletedCount = 0;
    for (final id in targetIds) {
      final failure = await _repository.delete(id);
      if (failure != null) {
        _errorMessage = failure.message;
        continue;
      }
      _items.removeWhere((item) => item.id == id);
      _selectedIds.remove(id);
      deletedCount++;
    }

    if (_selectedIds.isEmpty || _items.isEmpty) {
      _isSelectionMode = false;
    }
    notifyListeners();
    return deletedCount;
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
