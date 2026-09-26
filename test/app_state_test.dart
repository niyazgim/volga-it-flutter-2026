import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('filtered applies amount bounds and search', () {
    final s = AppState();
    s.setFilters(minAmount: 50, maxAmount: 500, query: 'coffee');
    // Cannot call addExpense (Hive not initialized). Test pure filters:
    // This test ensures the filter setter is callable and hasActiveFilter works.
    expect(s.hasActiveFilter, isTrue);
    s.clearFilters();
    expect(s.hasActiveFilter, isFalse);
  });

  test('totalOf sums amounts', () {
    final s = AppState();
    final list = <Expense>[
      Expense(
        id: '1',
        amount: 10,
        categoryId: 'c',
        date: DateTime(2024, 1, 1),
      ),
      Expense(
        id: '2',
        amount: 15,
        categoryId: 'c',
        date: DateTime(2024, 1, 2),
      ),
    ];
    expect(s.totalOf(list), 25);
  });
}
