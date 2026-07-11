import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expensex/features/budget/pages/add_budget_page.dart';
import 'package:expensex/features/budget/providers/budget_provider.dart';
import 'package:expensex/features/expenses/providers/expense_provider.dart';
import 'package:expensex/shared/widgets/app_card.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  String currency(double amount) => '৳ ${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();

    final budget = budgetProvider.currentBudget;

    final spent = expenseProvider.totalExpense;
    final remaining = budgetProvider.remainingBudget(spent);
    final progress = budgetProvider.budgetUsedPercentage(spent);
    final exceeded = budgetProvider.isBudgetExceeded(spent);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Budget'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddBudgetPage(
                budget: budget,
              ),
            ),
          );

          if (!context.mounted) return;

          await budgetProvider.loadBudgets();
        },
      ),
      body: RefreshIndicator(
        onRefresh: budgetProvider.loadBudgets,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (budget == null)
              const AppCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'No Budget Set\nTap + to create one.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Month Budget',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      currency(budget.amount),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 28),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.money_off),
                      title: const Text('Spent'),
                      trailing: Text(currency(spent)),
                    ),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.account_balance_wallet),
                      title: const Text('Remaining'),
                      trailing: Text(
                        currency(remaining),
                        style: TextStyle(
                          color: remaining >= 0
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      '${(progress * 100).toStringAsFixed(1)}% Used',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Icon(
                          exceeded
                              ? Icons.warning
                              : Icons.check_circle,
                          color:
                              exceeded ? Colors.red : Colors.green,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          exceeded
                              ? 'Budget Exceeded'
                              : 'Within Budget',
                          style: TextStyle(
                            color: exceeded
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    FilledButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddBudgetPage(
                              budget: budget,
                            ),
                          ),
                        );

                        if (!context.mounted) return;

                        await budgetProvider.loadBudgets();
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Budget'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}