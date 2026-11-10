import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expensex/core/services/budget_alert_service.dart';
import 'package:expensex/core/utils/currency_helper.dart';
import 'package:expensex/features/budget/pages/add_budget_page.dart';
import 'package:expensex/features/budget/providers/budget_provider.dart';
import 'package:expensex/features/dashboard/widgets/balance_card.dart';
import 'package:expensex/features/expenses/pages/add_expense_page.dart';
import 'package:expensex/features/expenses/providers/expense_provider.dart';
import 'package:expensex/features/income/pages/add_income_page.dart';
import 'package:expensex/features/income/providers/income_provider.dart';
import 'package:expensex/features/recurring/pages/recurring_page.dart';
import 'package:expensex/features/recurring/providers/recurring_provider.dart';
import 'package:expensex/features/settings/pages/settings_page.dart';
import 'package:expensex/shared/widgets/app_card.dart';
import 'package:expensex/shared/widgets/app_section_title.dart';
import 'package:expensex/shared/widgets/app_stat_card.dart';
import 'package:expensex/shared/widgets/budget_alert_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  Widget _buildQuickActionItem({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: color.withValues(alpha: isDark ? 0.35 : 0.22),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    letterSpacing: 0.1,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String currency(double amount) => context.currency(amount);
    final expenseProvider = context.watch<ExpenseProvider>();
    final incomeProvider = context.watch<IncomeProvider>();
    final budgetProvider = context.watch<BudgetProvider>();

    final totalIncome = incomeProvider.totalIncome;
    final totalExpense = expenseProvider.totalExpense;
    final balance = totalIncome - totalExpense;

    final currentBudget = budgetProvider.currentBudget;
    final budgetAmount = budgetProvider.currentBudgetAmount;
    final spent = totalExpense;
    final remaining = budgetAmount - spent;

    final budgetProgress = budgetAmount > 0
        ? (spent / budgetAmount).clamp(0.0, 1.0)
        : 0.0;

    final budgetExceeded = budgetAmount > 0 && spent > budgetAmount;

    const budgetAlertService = BudgetAlertService();
    final budgetAlert = budgetAlertService.evaluate(
      budget: budgetAmount,
      spent: spent,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_graph_rounded, color: Color(0xFF4F46E5), size: 26),
            SizedBox(width: 8),
            Text(
              'Spendigo',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await expenseProvider.loadExpenses();
          await incomeProvider.loadIncomes();
          await budgetProvider.loadBudgets();
          if (context.mounted) {
            await context.read<RecurringProvider>().loadTransactions();
          }
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            // Greeting & Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Here is your financial pulse today',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Hero Balance Card
            BalanceCard(
              balance: currency(balance),
              transactionCount:
                  incomeProvider.incomeCount + expenseProvider.expenseCount,
            ),

            const SizedBox(height: 16),

            // Income / Expense Stats
            Row(
              children: [
                Expanded(
                  child: AppStatCard(
                    title: 'Income',
                    amount: currency(totalIncome),
                    icon: Icons.arrow_upward_rounded,
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: AppStatCard(
                    title: 'Expense',
                    amount: currency(totalExpense),
                    icon: Icons.arrow_downward_rounded,
                    color: const Color(0xFFF43F5E),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            BudgetAlertCard(alert: budgetAlert),

            const SizedBox(height: 24),

            // Redesigned Sleek Quick Actions
            const AppSectionTitle(title: 'Quick Actions'),

            const SizedBox(height: 12),

            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickActionItem(
                    context: context,
                    label: 'Expense',
                    icon: Icons.remove_circle_outline_rounded,
                    color: const Color(0xFFF43F5E), // Rose red
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddExpensePage(),
                        ),
                      );
                      if (!context.mounted) return;
                      await expenseProvider.loadExpenses();
                    },
                  ),
                  _buildQuickActionItem(
                    context: context,
                    label: 'Income',
                    icon: Icons.add_circle_outline_rounded,
                    color: const Color(0xFF10B981), // Emerald green
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddIncomePage(),
                        ),
                      );
                      if (!context.mounted) return;
                      await incomeProvider.loadIncomes();
                    },
                  ),
                  _buildQuickActionItem(
                    context: context,
                    label: 'Budget',
                    icon: Icons.pie_chart_outline_rounded,
                    color: const Color(0xFF8B5CF6), // Violet
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddBudgetPage(budget: currentBudget),
                        ),
                      );
                      if (!context.mounted) return;
                      await budgetProvider.loadBudgets();
                    },
                  ),
                  _buildQuickActionItem(
                    context: context,
                    label: 'Recurring',
                    icon: Icons.autorenew_rounded,
                    color: const Color(0xFFF59E0B), // Amber
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RecurringPage(),
                        ),
                      );
                      if (!context.mounted) return;
                      await expenseProvider.loadExpenses();
                      await incomeProvider.loadIncomes();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Budget Overview
            const AppSectionTitle(title: 'Monthly Budget'),

            const SizedBox(height: 12),

            AppCard(
              child: currentBudget == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'No budget set for this month',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Set a monthly limit to track your spending and avoid exceeding goals.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.tonalIcon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddBudgetPage(),
                              ),
                            );
                            if (!context.mounted) return;
                            await budgetProvider.loadBudgets();
                          },
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Create Monthly Budget'),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Spending Limit',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: (budgetExceeded
                                        ? Colors.red
                                        : const Color(0xFF4F46E5))
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                currency(budgetAmount),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: budgetExceeded
                                      ? Colors.red
                                      : const Color(0xFF4F46E5),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Spent: ${currency(spent)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            Text(
                              budgetExceeded
                                  ? 'Over Budget by ${currency(spent - budgetAmount)}'
                                  : 'Remaining: ${currency(remaining)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: budgetExceeded
                                    ? Colors.red
                                    : const Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: budgetProgress,
                            minHeight: 10,
                            backgroundColor:
                                Theme.of(context).dividerColor.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              budgetExceeded
                                  ? Colors.red
                                  : budgetProgress > 0.8
                                      ? Colors.amber
                                      : const Color(0xFF4F46E5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          '${(budgetProgress * 100).toStringAsFixed(0)}% of monthly budget utilized',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 28),

            // Recent Expenses Section
            const AppSectionTitle(title: 'Recent Expenses'),

            const SizedBox(height: 12),

            if (expenseProvider.expenses.isEmpty)
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: Theme.of(context).hintColor.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No expenses logged yet',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...expenseProvider.expenses.take(5).map((expense) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.arrow_downward_rounded,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        expense.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${expense.category} • ${expense.date.day}/${expense.date.month}/${expense.date.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      trailing: Text(
                        '-${currency(expense.amount)}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
        heroTag: 'dashboard_fab',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpensePage()),
          );
          if (!context.mounted) return;
          await expenseProvider.loadExpenses();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
