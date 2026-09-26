import 'package:hive_flutter/hive_flutter.dart';

class Storage {
  static const _kExpenses = 'expenses';
  static const _kCategories = 'categories';
  static const _kTrips = 'trips';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_kExpenses);
    await Hive.openBox<String>(_kCategories);
    await Hive.openBox<String>(_kTrips);
  }

  static Box<String> get expenses => Hive.box<String>(_kExpenses);
  static Box<String> get categories => Hive.box<String>(_kCategories);
  static Box<String> get trips => Hive.box<String>(_kTrips);
}
