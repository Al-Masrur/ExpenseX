import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expensex/core/theme/theme_provider.dart';

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

    if (selectedTheme == null) return;

    if (!mounted) return;

    context.read<ThemeProvider>().setThemeMode(selectedTheme);
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
            child: ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: const Text('Currency'),
              subtitle: const Text('Bangladeshi Taka (৳)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Multiple currency support will be added later.',
                    ),
                  ),
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
                  subtitle: const Text('Export your financial records'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data export will be added next.'),
                      ),
                    );
                  },
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: const Text('Backup Data'),
                  subtitle: const Text('Create a backup of your data'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Backup feature will be added later.'),
                      ),
                    );
                  },
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

          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.account_balance_wallet),
                  title: Text('ExpenseX'),
                  subtitle: Text('Personal Finance & Budget Tracker'),
                ),

                const Divider(height: 1),

                const ListTile(
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
