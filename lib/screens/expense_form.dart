import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../models/payment_method.dart';
import '../services/receipts.dart';
import '../state/app_state.dart';

class ExpenseFormScreen extends StatefulWidget {
  const ExpenseFormScreen({super.key, this.initial});

  final Expense? initial;

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();
  final _payeeCtrl = TextEditingController();

  String? _categoryId;
  DateTime _date = DateTime.now();
  String _method = 'other';
  String? _tripId;
  List<String> _receipts = <String>[];

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final e = widget.initial;
    if (e != null) {
      _amountCtrl.text = e.amount.toString();
      _commentCtrl.text = e.comment;
      _payeeCtrl.text = e.payee;
      _categoryId = e.categoryId;
      _date = e.date;
      _method = e.paymentMethod;
      _tripId = e.tripId;
      _receipts = List<String>.of(e.receiptPaths);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _commentCtrl.dispose();
    _payeeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _attach(ImageSource source) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: source);
    if (x == null) return;
    final saved = await Receipts.save(File(x.path));
    if (!mounted) return;
    setState(() => _receipts = [..._receipts, saved]);
  }

  Future<void> _removeReceipt(String path) async {
    await Receipts.delete(path);
    if (!mounted) return;
    setState(() => _receipts = _receipts.where((p) => p != path).toList());
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите категорию')),
      );
      return;
    }
    final s = context.read<AppState>();
    final amount = double.parse(_amountCtrl.text.replaceAll(',', '.'));
    if (_isEdit) {
      final updated = widget.initial!.copyWith(
        amount: amount,
        categoryId: _categoryId,
        date: _date,
        comment: _commentCtrl.text,
        payee: _payeeCtrl.text,
        paymentMethod: _method,
        tripId: _tripId,
        clearTrip: _tripId == null,
        receiptPaths: _receipts,
      );
      await s.updateExpense(updated);
    } else {
      await s.addExpense(Expense(
        id: s.newId(),
        amount: amount,
        categoryId: _categoryId!,
        date: _date,
        comment: _commentCtrl.text,
        payee: _payeeCtrl.text,
        paymentMethod: _method,
        tripId: _tripId,
        receiptPaths: _receipts,
      ));
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить трату?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    await context.read<AppState>().deleteExpense(widget.initial!.id);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final df = DateFormat('yyyy-MM-dd');
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Редактировать' : 'Новая трата'),
        actions: [
          if (_isEdit)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Сумма'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Введите сумму';
                final n = double.tryParse(v.replaceAll(',', '.'));
                if (n == null || n <= 0) return 'Некорректная сумма';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _categoryId,
              decoration: const InputDecoration(labelText: 'Категория'),
              items: s.categories
                  .map((c) => DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(c.name),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(df.format(_date)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _payeeCtrl,
              decoration: const InputDecoration(
                labelText: 'Получатель платежа',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _method,
              decoration: const InputDecoration(labelText: 'Способ оплаты'),
              items: PaymentMethod.values
                  .map((m) => DropdownMenuItem<String>(
                        value: m.id,
                        child: Text(m.label),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _method = v ?? 'other'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _tripId,
              decoration: const InputDecoration(labelText: 'Командировка'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('—'),
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
            const SizedBox(height: 12),
            TextFormField(
              controller: _commentCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Комментарий'),
            ),
            const SizedBox(height: 16),
            Text('Чеки', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in _receipts)
                  Chip(
                    avatar: const Icon(Icons.receipt, size: 18),
                    label: Text(p.split('/').last, overflow: TextOverflow.ellipsis),
                    onDeleted: () => _removeReceipt(p),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _attach(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Камера'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _attach(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Галерея'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(_isEdit ? 'Сохранить' : 'Добавить'),
            ),
          ],
        ),
      ),
    );
  }
}
