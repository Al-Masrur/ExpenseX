import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expensex/core/services/backup_service.dart';
import 'package:expensex/core/services/export_service.dart';
import 'package:expensex/core/theme/theme_provider.dart';
import 'package:expensex/shared/widgets/day_night_switch.dart';

import 'package:expensex/features/budget/providers/budget_provider.dart';
import 'package:expensex/features/expenses/providers/expense_provider.dart';
import 'package:expensex/features/income/providers/income_provider.dart';
import 'package:expensex/features/recurring/pages/recurring_page.dart';
import 'package:expensex/features/settings/providers/settings_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _currencyLabel(String currency) {
    switch (currency) {
      case 'INR':
        return 'Indian Rupee (₹)';
      case 'USD':
        return 'US Dollar (\$)';
      case 'EUR':
        return 'Euro (€)';
      default:
        return 'Bangladeshi Taka (৳)';
    }
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
                trailing: Text(
                  '৳',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                onTap: () => Navigator.pop(context, 'BDT'),
              ),

              ListTile(
                title: const Text('Indian Rupee (₹)'),
                trailing: Text(
                  '₹',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                onTap: () => Navigator.pop(context, 'INR'),
              ),

              ListTile(
                title: const Text('US Dollar (\$)'),
                trailing: Text(
                  '\$',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                onTap: () => Navigator.pop(context, 'USD'),
              ),

              ListTile(
                title: const Text('Euro (€)'),
                trailing: Text(
                  '€',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
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

      await exportService.shareFiles([expenseFile, incomeFile, budgetFile]);

      messenger.showSnackBar(
        const SnackBar(content: Text('Export completed successfully.')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _backupData() async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      const backupService = BackupService();
      final backupFile = await backupService.createBackup();

      await backupService.shareBackup(backupFile);

      messenger.showSnackBar(
        const SnackBar(content: Text('Backup created and ready to share.')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Backup failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSystem = themeProvider.themeMode == ThemeMode.system;

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isDark
                                    ? Icons.nightlight_round
                                    : Icons.wb_sunny_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isDark ? 'Dark Theme' : 'Light Theme',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isSystem
                                        ? 'System Default (${isDark ? "Dark" : "Light"})'
                                        : (isDark
                                            ? 'Comfortable night contrast'
                                            : 'Bright daylight clarity'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      DayNightSwitch(
                        isDark: isDark,
                        onToggle: (bool setDark) {
                          themeProvider.setThemeMode(
                            setDark ? ThemeMode.dark : ThemeMode.light,
                          );
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Follow system setting',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      ChoiceChip(
                        label: const Text(
                          'Auto System',
                          style: TextStyle(fontSize: 12),
                        ),
                        selected: isSystem,
                        onSelected: (selected) {
                          if (selected) {
                            themeProvider.setThemeMode(ThemeMode.system);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Preferences',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                Consumer<SettingsProvider>(
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
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.repeat),
                  title: const Text('Recurring & Subscriptions'),
                  subtitle: const Text('Manage bills, subscriptions, and scheduled income'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RecurringPage()),
                    );
                  },
                ),
              ],
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
                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: const Text('Backup Data'),
                  subtitle: const Text('Create a backup of your SQLite database'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _backupData,
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
                  title: Text('Spendigo'),
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
