import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expensex/features/expenses/pages/add_expense_page.dart';
import 'package:expensex/features/expenses/providers/expense_provider.dart';
import 'package:expensex/features/income/pages/add_income_page.dart';
import 'package:expensex/features/income/providers/income_provider.dart';

import 'package:expensex/shared/widgets/app_card.dart';
import 'package:expensex/shared/widgets/app_section_title.dart';
import 'package:expensex/shared/widgets/app_stat_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  String currency(double amount) => '৳ ${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final incomeProvider = context.watch<IncomeProvider>();

    final totalIncome = incomeProvider.totalIncome;
    final totalExpense = expenseProvider.totalExpense;
    final balance = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(title: const Text('ExpenseX'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () async {
          await expenseProvider.loadExpenses();
          await incomeProvider.loadIncomes();
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Good Evening 👋',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              'Track your money like a pro.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Balance', style: TextStyle(fontSize: 16)),

                  const SizedBox(height: 10),

                  Text(
                    currency(balance),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${incomeProvider.incomeCount + expenseProvider.expenseCount} Total Transactions',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                AppStatCard(
                  title: 'Income',
                  amount: currency(totalIncome),
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),

                const SizedBox(width: 16),

                AppStatCard(
                  title: 'Expense',
                  amount: currency(totalExpense),
                  icon: Icons.trending_down,
                  color: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 30),

            const AppSectionTitle(title: 'Quick Actions'),

            const SizedBox(height: 15),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 2,
              children: [
                FilledButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddExpensePage()),
                    );

                    if (!context.mounted) return;

                    await expenseProvider.loadExpenses();
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  label: const Text('Expense'),
                ),

                FilledButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddIncomePage()),
                    );

                    if (!context.mounted) return;

                    await incomeProvider.loadIncomes();
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Income'),
                ),

                FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Budget module coming in the next milestone.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  label: const Text('Budget'),
                ),

                FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Statistics module coming soon.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Statistics'),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const AppSectionTitle(title: 'Budget Overview'),

            const SizedBox(height: 12),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'No budget created yet.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  LinearProgressIndicator(value: 0),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const AppSectionTitle(title: 'Recent Expenses'),

            const SizedBox(height: 12),

            if (expenseProvider.expenses.isEmpty)
              const AppCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(child: Text('No transactions available.')),
                ),
              )
            else
              ...expenseProvider.expenses.take(5).map((expense) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.red.withValues(alpha: 0.12),
                        child: const Icon(
                          Icons.arrow_downward,
                          color: Colors.red,
                        ),
                      ),
                      title: Text(expense.title),
                      subtitle: Text(
                        '${expense.category} • ${expense.date.day}/${expense.date.month}/${expense.date.year}',
                      ),
                      trailing: Text(
                        currency(expense.amount),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpensePage()),
          );

          if (!context.mounted) return;

          await expenseProvider.loadExpenses();
        },
        icon: const Icon(Icons.add),
        label: const Text('Expense'),
      ),
    );
  }
}
