import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/payment_method.dart';
import '../state/app_state.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String? _categoryId;
  DateTime? _start;
  DateTime? _end;
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();
  String? _method;
  String? _tripId;

  @override
  void initState() {
    super.initState();
    final s = context.read<AppState>();
    _categoryId = s.filterCategoryId;
    _start = s.filterDateStart;
    _end = s.filterDateEnd;
    _minCtrl.text = s.filterMinAmount?.toString() ?? '';
    _maxCtrl.text = s.filterMaxAmount?.toString() ?? '';
    _method = s.filterPaymentMethod;
    _tripId = s.filterTripId;
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _start : _end) ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Фильтры', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              initialValue: _categoryId,
              decoration: const InputDecoration(labelText: 'Категория'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Все'),
                ),
                ...s.categories.map(
                  (c) => DropdownMenuItem<String?>(
                    value: c.id,
                    child: Text(c.name),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(true),
                    child: Text(
                      _start == null
                          ? 'Дата с'
                          : '${_start!.year}-${_start!.month}-${_start!.day}',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(false),
                    child: Text(
                      _end == null
                          ? 'Дата по'
                          : '${_end!.year}-${_end!.month}-${_end!.day}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Сумма от'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _maxCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Сумма до'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _method,
              decoration: const InputDecoration(labelText: 'Способ оплаты'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Все'),
                ),
                ...PaymentMethod.values.map(
                  (m) => DropdownMenuItem<String?>(
                    value: m.id,
                    child: Text(m.label),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _method = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _tripId,
              decoration: const InputDecoration(labelText: 'Командировка'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Все'),
                ),
                ...s.trips.map(
                  (t) => DropdownMenuItem<String?>(
                    value: t.id,
                    child: Text(t.name),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _tripId = v),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<AppState>().clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Сбросить'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      context.read<AppState>().setFilters(
                            categoryId: _categoryId,
                            dateStart: _start,
                            dateEnd: _end,
                            minAmount: double.tryParse(_minCtrl.text),
                            maxAmount: double.tryParse(_maxCtrl.text),
                            paymentMethod: _method,
                            tripId: _tripId,
                          );
                      Navigator.pop(context);
                    },
                    child: const Text('Применить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
