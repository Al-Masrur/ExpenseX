import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expensex/core/services/export_service.dart';
import 'package:expensex/core/theme/theme_provider.dart';

import 'package:expensex/features/budget/providers/budget_provider.dart';
import 'package:expensex/features/expenses/providers/expense_provider.dart';
import 'package:expensex/features/income/providers/income_provider.dart';
import 'package:expensex/features/settings/providers/settings_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _themeModeLabel(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  String _currencyLabel(String currency) {
    switch (currency) {
      case 'USD':
        return 'US Dollar (\$)';
      case 'EUR':
        return 'Euro (€)';
      default:
        return 'Bangladeshi Taka (৳)';
    }
  }

  Future<void> _selectTheme() async {
    final themeProvider = context.read<ThemeProvider>();

    final selectedTheme = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: RadioGroup<ThemeMode>(
            groupValue: themeProvider.themeMode,
            onChanged: (value) {
              Navigator.pop(context, value);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Choose Theme',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const RadioListTile<ThemeMode>(
                  title: Text('System Default'),
                  subtitle: Text('Follow your device settings'),
                  value: ThemeMode.system,
                ),

                const RadioListTile<ThemeMode>(
                  title: Text('Light'),
                  value: ThemeMode.light,
                ),

                const RadioListTile<ThemeMode>(
                  title: Text('Dark'),
                  value: ThemeMode.dark,
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selectedTheme == null) return;

    await context.read<ThemeProvider>().setThemeMode(selectedTheme);
  }

  Future<void> _selectCurrency() async {
    final selectedCurrency = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose Currency',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              ListTile(
                title: const Text('Bangladeshi Taka (৳)'),
                onTap: () => Navigator.pop(context, 'BDT'),
              ),

              ListTile(
                title: const Text('US Dollar (\$)'),
                onTap: () => Navigator.pop(context, 'USD'),
              ),

              ListTile(
                title: const Text('Euro (€)'),
                onTap: () => Navigator.pop(context, 'EUR'),
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (!mounted || selectedCurrency == null) return;

    await context.read<SettingsProvider>().changeCurrency(selectedCurrency);
  }

  Future<void> _exportData() async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final exportService = ExportService();

      final expenseProvider = context.read<ExpenseProvider>();
      final incomeProvider = context.read<IncomeProvider>();
      final budgetProvider = context.read<BudgetProvider>();

      final expenseFile = await exportService.exportExpenses(
        expenseProvider.expenses,
      );

      final incomeFile = await exportService.exportIncome(
        incomeProvider.incomes,
      );

      final budgetFile = await exportService.exportBudgets(
        budgetProvider.budgets,
      );

      await exportService.shareFile(expenseFile);
      await exportService.shareFile(incomeFile);
      await exportService.shareFile(budgetFile);

      messenger.showSnackBar(
        const SnackBar(content: Text('Export completed successfully.')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Appearance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Theme'),
              subtitle: Text(_themeModeLabel(themeProvider.themeMode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectTheme,
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Preferences',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Card(
            child: Consumer<SettingsProvider>(
              builder: (context, settingsProvider, child) {
                return ListTile(
                  leading: const Icon(Icons.currency_exchange),
                  title: const Text('Currency'),
                  subtitle: Text(_currencyLabel(settingsProvider.currency)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _selectCurrency,
                );
              },
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Data Management',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: const Text('Export Data'),
                  subtitle: const Text(
                    'Export Expenses, Income & Budget to CSV',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _exportData,
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.backup_outlined),
                  title: Text('Backup Data'),
                  subtitle: Text('Create a backup of your SQLite database'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'About',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.account_balance_wallet),
                  title: Text('ExpenseX'),
                  subtitle: Text('Personal Finance & Budget Tracker'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  trailing: Text('1.0.0'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
