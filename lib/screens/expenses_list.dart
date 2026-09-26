import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/expense_tile.dart';
import '../widgets/filter_sheet.dart';
import 'expense_form.dart';

class ExpensesListScreen extends StatelessWidget {
  const ExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.filtered;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Траты'),
        actions: [
          IconButton(
            tooltip: 'Фильтры',
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => const FilterSheet(),
            ),
            icon: Badge(
              isLabelVisible: s.hasActiveFilter,
              child: const Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              onChanged: (v) =>
                  context.read<AppState>().setFilters(query: v),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Поиск по комментарию или получателю',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${list.length} записей'),
                Text(
                  'Итого: ${s.totalOf(list).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('Нет трат'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final e = list[i];
                      return ExpenseTile(
                        expense: e,
                        category: s.categoryById(e.categoryId),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ExpenseFormScreen(initial: e),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const ExpenseFormScreen(),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }
}
