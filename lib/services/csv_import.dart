import 'package:csv/csv.dart';
import '../models/category.dart';
import '../models/expense.dart';
import '../models/trip.dart';

class CsvParseResult {
  CsvParseResult(this.expenses, this.errors);
  final List<Expense> expenses;
  final List<String> errors;
}

class CsvImporter {
  static CsvParseResult parse(
    String content, {
    required List<Category> categories,
    required List<Trip> trips,
    required String Function() idGenerator,
  }) {
    final normalized = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
      eol: '\n',
    ).convert(normalized);

    final errors = <String>[];
    final expenses = <Expense>[];

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;

      final first = row.first.toString().trim().toLowerCase();
      if (i == 0 && first.contains('дата')) continue;

      if (row.length < 7) {
        errors.add('Row ${i + 1}: expected 7 columns, got ${row.length}');
        continue;
      }

      try {
        final date = DateTime.parse(row[0].toString().trim());
        final amount =
            double.parse(row[1].toString().trim().replaceAll(',', '.'));
        final categoryName = row[2].toString().trim();
        final payee = row[3].toString().trim();
        final method = row[4].toString().trim();
        final comment = row[5].toString().trim();
        final tripName = row[6].toString().trim();

        final category = _findCategory(categories, categoryName);
        if (category == null) {
          errors.add('Row ${i + 1}: unknown category "$categoryName"');
          continue;
        }

        String? tripId;
        if (tripName.isNotEmpty) {
          final trip = _findTrip(trips, tripName);
          if (trip == null) {
            errors.add('Row ${i + 1}: unknown trip "$tripName"');
            continue;
          }
          tripId = trip.id;
        }

        expenses.add(Expense(
          id: idGenerator(),
          amount: amount,
          categoryId: category.id,
          date: date,
          payee: payee,
          paymentMethod: _mapMethod(method),
          comment: comment,
          tripId: tripId,
        ));
      } catch (e) {
        errors.add('Row ${i + 1}: $e');
      }
    }
    return CsvParseResult(expenses, errors);
  }

  static Category? _findCategory(List<Category> list, String name) {
    final n = name.toLowerCase();
    for (final c in list) {
      if (c.name.toLowerCase() == n) return c;
    }
    return null;
  }

  static Trip? _findTrip(List<Trip> list, String name) {
    final n = name.toLowerCase();
    for (final t in list) {
      if (t.name.toLowerCase() == n) return t;
    }
    return null;
  }

  static String _mapMethod(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('карт') || s.contains('card')) return 'card';
    if (s.contains('нал') || s.contains('cash')) return 'cash';
    if (s.contains('qr')) return 'qr';
    return 'other';
  }
}
