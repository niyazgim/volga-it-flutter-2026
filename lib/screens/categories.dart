import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../state/app_state.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  Future<void> _add(BuildContext context) async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Новая категория'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Название'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (name == null || name.isEmpty) return;
    await context.read<AppState>().addCategory(name);
  }

  Future<void> _edit(BuildContext context, Category c) async {
    final ctrl = TextEditingController(text: c.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Переименовать'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Название'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (name == null || name.isEmpty) return;
    await context.read<AppState>().updateCategory(c.copyWith(name: name));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Категории')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
      body: ListView(
        children: [
          for (final c in s.categories)
            ListTile(
              title: Text(c.name),
              subtitle: c.isStandard ? const Text('Стандартная') : null,
              trailing: c.isStandard
                  ? null
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _edit(context, c),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () =>
                              context.read<AppState>().deleteCategory(c.id),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}
