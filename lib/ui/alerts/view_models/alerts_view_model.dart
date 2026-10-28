import 'package:flutter/foundation.dart';

import '../../../data/repositories/alert_repository.dart';
import '../../../domain/models/stock_alert.dart';

class AlertsViewModel extends ChangeNotifier {
  AlertsViewModel({required AlertRepository repository})
    : _repository = repository;

  final AlertRepository _repository;

  bool _loading = false;
  List<StockAlert> _alerts = [];
  final Set<Severity> _activeFilters = {};
  String _query = '';

  bool get loading => _loading;

  Set<Severity> get activeFilters => Set.unmodifiable(_activeFilters);

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    try {
      _alerts = await _repository.fetchAlerts();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  List<StockAlert> get visibleAlerts {
    final normalizedQuery = _normalize(_query);

    final alerts = _alerts.where((alert) {
      final matchesSeverity =
          _activeFilters.isEmpty || _activeFilters.contains(alert.severity);

      final matchesSearch =
          normalizedQuery.isEmpty ||
          _normalize(alert.medicineNameEn).contains(normalizedQuery) ||
          _normalize(alert.medicineNameAr).contains(normalizedQuery);

      return matchesSeverity && matchesSearch;
    }).toList();

    alerts.sort((a, b) {
      // Unacknowledged alerts first.
      if (a.acknowledged != b.acknowledged) {
        return a.acknowledged ? 1 : -1;
      }

      // Critical, high, medium, low.
      final severityCompare = a.severity.index.compareTo(b.severity.index);

      if (severityCompare != 0) {
        return severityCompare;
      }

      // Fewer days of cover first.
      final daysCompare = a.daysOfCover.compareTo(b.daysOfCover);

      if (daysCompare != 0) {
        return daysCompare;
      }

      // Alphabetical English medicine name.
      return a.medicineNameEn.toLowerCase().compareTo(
        b.medicineNameEn.toLowerCase(),
      );
    });

    return List.unmodifiable(alerts);
  }

  void toggleFilter(Severity severity) {
    if (_activeFilters.contains(severity)) {
      _activeFilters.remove(severity);
    } else {
      _activeFilters.add(severity);
    }

    notifyListeners();
  }

  void setQuery(String query) {
    if (_query == query) return;

    _query = query;
    notifyListeners();
  }

  Future<void> acknowledge(String id) async {
    final index = _alerts.indexWhere((alert) => alert.id == id);

    if (index == -1 || _alerts[index].acknowledged) {
      return;
    }

    await _repository.acknowledge(id);

    _alerts[index] = _alerts[index].copyWith(acknowledged: true);

    notifyListeners();
  }

  int get unacknowledgedCriticalCount {
    return _alerts.where((alert) {
      return alert.severity == Severity.critical && !alert.acknowledged;
    }).length;
  }

  String _normalize(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[أإآ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('ـ', '')
        .replaceAll(RegExp(r'[\u064B-\u0652]'), '');
  }
}
