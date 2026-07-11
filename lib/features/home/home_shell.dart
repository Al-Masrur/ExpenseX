import 'package:flutter/material.dart';

import 'package:expensex/features/budget/pages/budget_page.dart';
import 'package:expensex/features/dashboard/pages/dashboard_page.dart';
import 'package:expensex/features/expenses/pages/expenses_page.dart';
import 'package:expensex/features/income/pages/income_page.dart';
import 'package:expensex/features/settings/pages/settings_page.dart';
import 'package:expensex/features/statistics/pages/statistics_page.dart';

import 'widgets/bottom_nav_bar.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const DashboardPage(),
    const ExpensesPage(),
    const IncomePage(),
    const StatisticsPage(),
    const BudgetPage(),
    const SettingsPage(),
  ];

  void _changePage(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onDestinationSelected: _changePage,
      ),
    );
  }
}