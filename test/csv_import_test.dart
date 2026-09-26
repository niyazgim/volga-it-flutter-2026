import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/models/trip.dart';
import 'package:expense_tracker/services/csv_import.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a valid CSV row', () {
    const content =
        '2024-01-02,100.5,Продукты,Магазин,card,обед,\n';
    final result = CsvImporter.parse(
      content,
      categories: const [
        Category(id: 'c1', name: 'Продукты', isStandard: true),
      ],
      trips: const <Trip>[],
      idGenerator: () => 'id1',
    );
    expect(result.errors, isEmpty);
    expect(result.expenses.length, 1);
    expect(result.expenses.first.amount, 100.5);
    expect(result.expenses.first.categoryId, 'c1');
    expect(result.expenses.first.paymentMethod, 'card');
  });

  test('reports unknown category', () {
    const content = '2024-01-02,10,Nope,X,cash,,\n';
    final result = CsvImporter.parse(
      content,
      categories: const <Category>[],
      trips: const <Trip>[],
      idGenerator: () => 'x',
    );
    expect(result.expenses, isEmpty);
    expect(result.errors, isNotEmpty);
  });
}
