import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/csv_import.dart';
import '../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _importCsv(BuildContext context) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;

    String? content;
    final f = picked.files.single;
    if (f.bytes != null) {
      content = utf8.decode(f.bytes!);
    } else if (f.path != null) {
      content = await File(f.path!).readAsString();
    }
    if (content == null) return;
    if (!context.mounted) return;

    final state = context.read<AppState>();
    final result = CsvImporter.parse(
      content,
      categories: state.categories,
      trips: state.trips,
      idGenerator: state.newId,
    );
    for (final e in result.expenses) {
      await state.addExpense(e);
    }
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Импорт CSV'),
        content: SingleChildScrollView(
          child: Text(
            'Импортировано: ${result.expenses.length}\n'
            'Ошибок: ${result.errors.length}\n\n'
            '${result.errors.take(20).join('\n')}',
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Импорт трат из CSV'),
            subtitle: const Text(
              'Дата, Сумма, Категория, Получатель, Способ, Комментарий, Командировка',
            ),
            onTap: () => _importCsv(context),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Expense Tracker'),
            subtitle: Text('v1.0.0 · BSD-3-Clause'),
          ),
        ],
      ),
    );
  }
}
