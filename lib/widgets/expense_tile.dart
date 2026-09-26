import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../models/expense.dart';
import '../models/payment_method.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({
    super.key,
    required this.expense,
    required this.category,
    required this.onTap,
  });

  final Expense expense;
  final Category? category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat('yyyy-MM-dd');
    final method = PaymentMethod.fromId(expense.paymentMethod);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Text(
          category?.name ?? '—',
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(df.format(expense.date)),
            if (expense.payee.isNotEmpty) Text(expense.payee),
            Text(method.label, style: theme.textTheme.bodySmall),
            if (expense.comment.isNotEmpty)
              Text(
                expense.comment,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (expense.receiptPaths.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.attach_file, size: 14),
                  const SizedBox(width: 4),
                  Text('${expense.receiptPaths.length}'),
                ],
              ),
          ],
        ),
        trailing: Text(
          expense.amount.toStringAsFixed(2),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
