import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../state/app_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final all = s.expenses;

    return Scaffold(
      appBar: AppBar(title: const Text('Дашборд')),
      body: all.isEmpty
          ? const Center(child: Text('Нет данных'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Итого: ${s.totalOf(all).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 24),
                Text('По месяцам',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                SizedBox(height: 220, child: _MonthlyBars(expenses: all)),
                const SizedBox(height: 24),
                Text('По категориям',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                SizedBox(height: 240, child: _CategoryPie(state: s)),
                const SizedBox(height: 24),
                Text('По командировкам',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                ..._tripBreakdown(context, s),
              ],
            ),
    );
  }

  List<Widget> _tripBreakdown(BuildContext context, AppState s) {
    final totals = <String, double>{};
    for (final e in s.expenses) {
      final key = e.tripId ?? '__none__';
      totals[key] = (totals[key] ?? 0) + e.amount;
    }
    if (totals.isEmpty) return const [Text('Нет данных')];
    return totals.entries.map((e) {
      final name = e.key == '__none__' ? 'Без командировки' : (s.tripById(e.key)?.name ?? '—');
      return ListTile(
        title: Text(name),
        trailing: Text(e.value.toStringAsFixed(2)),
      );
    }).toList();
  }
}

class _MonthlyBars extends StatelessWidget {
  const _MonthlyBars({required this.expenses});
  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    final byMonth = <String, double>{};
    final df = DateFormat('yyyy-MM');
    for (final e in expenses) {
      final k = df.format(e.date);
      byMonth[k] = (byMonth[k] ?? 0) + e.amount;
    }
    final keys = byMonth.keys.toList()..sort();
    if (keys.isEmpty) return const SizedBox.shrink();
    final maxY = byMonth.values.reduce((a, b) => a > b ? a : b) * 1.2;

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= keys.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(keys[i], style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < keys.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: byMonth[keys[i]]!,
                width: 14,
                borderRadius: BorderRadius.circular(4),
              ),
            ]),
        ],
      ),
    );
  }
}

class _CategoryPie extends StatelessWidget {
  const _CategoryPie({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final totals = <String, double>{};
    for (final e in state.expenses) {
      totals[e.categoryId] = (totals[e.categoryId] ?? 0) + e.amount;
    }
    if (totals.isEmpty) return const SizedBox.shrink();
    final total = totals.values.fold(0.0, (a, b) => a + b);
    final palette = <Color>[
      Colors.blue,
      Colors.teal,
      Colors.orange,
      Colors.purple,
      Colors.green,
      Colors.red,
      Colors.amber,
      Colors.indigo,
    ];
    var i = 0;
    final sections = <PieChartSectionData>[];
    for (final e in totals.entries) {
      final cat = state.categoryById(e.key);
      final color = palette[i++ % palette.length];
      sections.add(PieChartSectionData(
        value: e.value,
        color: color,
        title:
            '${((e.value / total) * 100).toStringAsFixed(0)}%\n${cat?.name ?? '—'}',
        titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
        radius: 90,
      ));
    }
    return PieChart(PieChartData(sections: sections));
  }
}
