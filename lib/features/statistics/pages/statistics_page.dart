import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expensex/core/utils/statistics_helper.dart';
import 'package:expensex/features/expenses/providers/expense_provider.dart';
import 'package:expensex/features/income/providers/income_provider.dart';
import 'package:expensex/features/statistics/widgets/expense_pie_chart.dart';
import 'package:expensex/features/statistics/widgets/monthly_line_chart.dart';
import 'package:expensex/features/statistics/widgets/summary_card.dart';
import 'package:expensex/features/statistics/widgets/top_category_card.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final incomeProvider = context.watch<IncomeProvider>();

    final expenses = expenseProvider.expenses;
    final incomes = incomeProvider.incomes;

    final totalExpense = StatisticsHelper.totalExpense(expenses);

    final totalIncome = StatisticsHelper.totalIncome(incomes);

    final savings = StatisticsHelper.savings(incomes, expenses);

    final categoryTotals = StatisticsHelper.categoryTotals(expenses);

    final topCategory = StatisticsHelper.topCategory(expenses);

    final topCategoryAmount = StatisticsHelper.topCategoryAmount(expenses);

    final monthlyTotals = StatisticsHelper.monthlyExpenseTotals(expenses);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: RefreshIndicator(
        onRefresh: () async {
          await expenseProvider.loadExpenses();
          await incomeProvider.loadIncomes();
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Financial Overview',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Income',
                    amount: totalIncome,
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: SummaryCard(
                    title: 'Expense',
                    amount: totalExpense,
                    icon: Icons.trending_down,
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SummaryCard(
              title: 'Savings',
              amount: savings,
              icon: Icons.savings,
              color: Colors.blue,
            ),

            const SizedBox(height: 24),

            TopCategoryCard(category: topCategory, amount: topCategoryAmount),

            const SizedBox(height: 24),

            ExpensePieChart(categoryTotals: categoryTotals),

            const SizedBox(height: 24),

            MonthlyLineChart(monthlyTotals: monthlyTotals),

            const SizedBox(height: 24),

            _ExpenseCountCard(
              expenseCount: expenses.length,
              incomeCount: incomes.length,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ExpenseCountCard extends StatelessWidget {
  const _ExpenseCountCard({
    required this.expenseCount,
    required this.incomeCount,
  });

  final int expenseCount;
  final int incomeCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _CountItem(
              label: 'Expenses',
              count: expenseCount,
              icon: Icons.receipt_long,
            ),
            _CountItem(
              label: 'Income Records',
              count: incomeCount,
              icon: Icons.account_balance_wallet,
            ),
          ],
        ),
      ),
    );
  }
}

class _CountItem extends StatelessWidget {
  const _CountItem({
    required this.label,
    required this.count,
    required this.icon,
  });

  final String label;
  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28),

        const SizedBox(height: 8),

        Text(
          '$count',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 4),

        Text(label),
      ],
    );
  }
}
