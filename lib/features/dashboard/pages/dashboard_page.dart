import 'package:provider/provider.dart';
import 'package:expensex/features/expenses/pages/add_expense_page.dart';
import 'package:expensex/features/expenses/providers/expense_provider.dart';

import 'package:flutter/material.dart';


import 'package:expensex/shared/widgets/app_card.dart';
import 'package:expensex/shared/widgets/app_section_title.dart';
import 'package:expensex/shared/widgets/app_stat_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  String _currency(double amount) => '৳ ${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ExpenseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ExpenseX'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const AddExpensePage(),
    ),
  );

  if (!context.mounted) return;

  await context.read<ExpenseProvider>().loadExpenses();
},
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.loadExpenses,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Good Evening 👋',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Track your finances with confidence.',
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 24),

              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Expense'),

                    const SizedBox(height: 12),

                    Text(
                      _currency(provider.totalExpense),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${provider.expenses.length} Transactions',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  AppStatCard(
                    title: 'Income',
                    amount: 'Coming Soon',
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),

                  const SizedBox(width: 16),

                  AppStatCard(
                    title: 'Expense',
                    amount: _currency(provider.totalExpense),
                    icon: Icons.trending_down,
                    color: Colors.red,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const AppSectionTitle(
                title: 'Budget',
              ),

              const SizedBox(height: 12),

              const AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget module will be added later',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 12),

                    LinearProgressIndicator(value: 0),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const AppSectionTitle(
                title: 'Recent Transactions',
              ),

              const SizedBox(height: 12),

              if (provider.expenses.isEmpty)
                const AppCard(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'No transactions yet',
                      ),
                    ),
                  ),
                )
              else
                ...provider.expenses.take(5).map(
                  (expense) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          child: Icon(Icons.receipt_long),
                        ),
                        title: Text(expense.title),
                        subtitle: Text(expense.category),
                        trailing: Text(
                          _currency(expense.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}