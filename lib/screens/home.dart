import 'package:flutter/material.dart';
import 'expenses_list.dart';
import 'dashboard.dart';
import 'categories.dart';
import 'trips.dart';
import 'settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _screens = <Widget>[
    ExpensesListScreen(),
    DashboardScreen(),
    CategoriesScreen(),
    TripsScreen(),
    SettingsScreen(),
  ];

  static const _railDest = <NavigationRailDestination>[
    NavigationRailDestination(
      icon: Icon(Icons.receipt_long),
      label: Text('Траты'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.pie_chart),
      label: Text('Дашборд'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.category),
      label: Text('Категории'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.flight_takeoff),
      label: Text('Командировки'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings),
      label: Text('Настройки'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 800;
    final body = IndexedStack(index: _index, children: _screens);

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelType: NavigationRailLabelType.all,
              destinations: _railDest,
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Траты',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart),
            label: 'Дашборд',
          ),
          NavigationDestination(
            icon: Icon(Icons.category),
            label: 'Категории',
          ),
          NavigationDestination(
            icon: Icon(Icons.flight_takeoff),
            label: 'Командировки',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}
