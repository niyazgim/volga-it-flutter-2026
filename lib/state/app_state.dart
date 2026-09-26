import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/category.dart';
import '../models/expense.dart';
import '../models/trip.dart';
import '../services/storage.dart';

class AppState extends ChangeNotifier {
  final List<Expense> _expenses = <Expense>[];
  final List<Category> _categories = <Category>[];
  final List<Trip> _trips = <Trip>[];

  int _idCounter = 0;

  String? filterCategoryId;
  DateTime? filterDateStart;
  DateTime? filterDateEnd;
  double? filterMinAmount;
  double? filterMaxAmount;
  String? filterPaymentMethod;
  String? filterTripId;
  String searchQuery = '';

  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<Category> get categories => List.unmodifiable(_categories);
  List<Trip> get trips => List.unmodifiable(_trips);

  List<Expense> get filtered {
    final q = searchQuery.trim().toLowerCase();
    final list = _expenses.where((e) {
      if (filterCategoryId != null && e.categoryId != filterCategoryId) {
        return false;
      }
      if (filterDateStart != null && e.date.isBefore(filterDateStart!)) {
        return false;
      }
      if (filterDateEnd != null) {
        final end = filterDateEnd!.add(const Duration(days: 1));
        if (e.date.isAfter(end)) return false;
      }
      if (filterMinAmount != null && e.amount < filterMinAmount!) return false;
      if (filterMaxAmount != null && e.amount > filterMaxAmount!) return false;
      if (filterPaymentMethod != null &&
          e.paymentMethod != filterPaymentMethod) {
        return false;
      }
      if (filterTripId != null && e.tripId != filterTripId) return false;
      if (q.isNotEmpty) {
        final c = e.comment.toLowerCase();
        final p = e.payee.toLowerCase();
        if (!c.contains(q) && !p.contains(q)) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  bool get hasActiveFilter =>
      filterCategoryId != null ||
      filterDateStart != null ||
      filterDateEnd != null ||
      filterMinAmount != null ||
      filterMaxAmount != null ||
      filterPaymentMethod != null ||
      filterTripId != null ||
      searchQuery.isNotEmpty;

  String newId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';

  Category? categoryById(String id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  Trip? tripById(String? id) {
    if (id == null) return null;
    for (final t in _trips) {
      if (t.id == id) return t;
    }
    return null;
  }

  double totalOf(Iterable<Expense> list) =>
      list.fold(0.0, (s, e) => s + e.amount);

  Future<void> load() async {
    _expenses
      ..clear()
      ..addAll(Storage.expenses.values
          .map((s) => Expense.fromMap(jsonDecode(s) as Map<String, dynamic>)));
    _categories
      ..clear()
      ..addAll(Storage.categories.values
          .map((s) => Category.fromMap(jsonDecode(s) as Map<String, dynamic>)));
    _trips
      ..clear()
      ..addAll(Storage.trips.values
          .map((s) => Trip.fromMap(jsonDecode(s) as Map<String, dynamic>)));
    if (_categories.isEmpty) {
      await _seedStandardCategories();
    }
    notifyListeners();
  }

  Future<void> _seedStandardCategories() async {
    const names = <String>[
      'Продукты',
      'Кафе',
      'Коммунальные платежи',
      'Транспорт',
      'Одежда',
      'Здоровье',
      'Развлечение',
      'Обучение',
    ];
    for (final n in names) {
      final c = Category(id: newId(), name: n, isStandard: true);
      _categories.add(c);
      await Storage.categories.put(c.id, jsonEncode(c.toMap()));
    }
  }

  Future<void> addExpense(Expense e) async {
    _expenses.add(e);
    await Storage.expenses.put(e.id, jsonEncode(e.toMap()));
    notifyListeners();
  }

  Future<void> updateExpense(Expense e) async {
    final i = _expenses.indexWhere((x) => x.id == e.id);
    if (i == -1) return;
    _expenses[i] = e;
    await Storage.expenses.put(e.id, jsonEncode(e.toMap()));
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((x) => x.id == id);
    await Storage.expenses.delete(id);
    notifyListeners();
  }

  Future<void> addCategory(String name) async {
    final c = Category(id: newId(), name: name);
    _categories.add(c);
    await Storage.categories.put(c.id, jsonEncode(c.toMap()));
    notifyListeners();
  }

  Future<void> updateCategory(Category c) async {
    if (c.isStandard) return;
    final i = _categories.indexWhere((x) => x.id == c.id);
    if (i == -1) return;
    _categories[i] = c;
    await Storage.categories.put(c.id, jsonEncode(c.toMap()));
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    final c = categoryById(id);
    if (c == null || c.isStandard) return;
    _categories.removeWhere((x) => x.id == id);
    await Storage.categories.delete(id);
    notifyListeners();
  }

  Future<void> addTrip(Trip t) async {
    _trips.add(t);
    await Storage.trips.put(t.id, jsonEncode(t.toMap()));
    notifyListeners();
  }

  Future<void> updateTrip(Trip t) async {
    final i = _trips.indexWhere((x) => x.id == t.id);
    if (i == -1) return;
    _trips[i] = t;
    await Storage.trips.put(t.id, jsonEncode(t.toMap()));
    notifyListeners();
  }

  Future<void> deleteTrip(String id) async {
    _trips.removeWhere((x) => x.id == id);
    await Storage.trips.delete(id);
    notifyListeners();
  }

  void setFilters({
    String? categoryId,
    DateTime? dateStart,
    DateTime? dateEnd,
    double? minAmount,
    double? maxAmount,
    String? paymentMethod,
    String? tripId,
    String? query,
  }) {
    filterCategoryId = categoryId;
    filterDateStart = dateStart;
    filterDateEnd = dateEnd;
    filterMinAmount = minAmount;
    filterMaxAmount = maxAmount;
    filterPaymentMethod = paymentMethod;
    filterTripId = tripId;
    if (query != null) searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    filterCategoryId = null;
    filterDateStart = null;
    filterDateEnd = null;
    filterMinAmount = null;
    filterMaxAmount = null;
    filterPaymentMethod = null;
    filterTripId = null;
    searchQuery = '';
    notifyListeners();
  }
}
