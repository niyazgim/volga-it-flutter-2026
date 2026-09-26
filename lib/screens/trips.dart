import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../state/app_state.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  Future<void> _addOrEdit(BuildContext context, {Trip? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    var start = existing?.startDate ?? DateTime.now();
    var end = existing?.endDate ?? DateTime.now();

    final df = DateFormat('yyyy-MM-dd');
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text(existing == null ? 'Новая командировка' : 'Изменить'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Название'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final p = await showDatePicker(
                          context: ctx,
                          initialDate: start,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (p != null) setSt(() => start = p);
                      },
                      child: Text(df.format(start)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final p = await showDatePicker(
                          context: ctx,
                          initialDate: end,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (p != null) setSt(() => end = p);
                      },
                      child: Text(df.format(end)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
    if (saved != true) return;
    if (!context.mounted) return;
    final name = nameCtrl.text.trim();
    if (name.isEmpty) return;
    final s = context.read<AppState>();
    if (existing == null) {
      await s.addTrip(Trip(
        id: s.newId(),
        name: name,
        startDate: start,
        endDate: end,
      ));
    } else {
      await s.updateTrip(
        existing.copyWith(name: name, startDate: start, endDate: end),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final df = DateFormat('yyyy-MM-dd');
    return Scaffold(
      appBar: AppBar(title: const Text('Командировки')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEdit(context),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
      body: ListView(
        children: [
          for (final t in s.trips)
            ListTile(
              title: Text(t.name),
              subtitle: Text('${df.format(t.startDate)} — ${df.format(t.endDate)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _addOrEdit(context, existing: t),
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () =>
                        context.read<AppState>().deleteTrip(t.id),
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
