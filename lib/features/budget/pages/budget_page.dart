import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expensex/core/utils/currency_helper.dart';
import 'package:expensex/features/budget/pages/add_budget_page.dart';
import 'package:expensex/features/budget/providers/budget_provider.dart';
import 'package:expensex/features/expenses/providers/expense_provider.dart';
import 'package:expensex/shared/widgets/app_card.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    String currency(double amount) => context.currency(amount);
    final budgetProvider = context.watch<BudgetProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();

    final budget = budgetProvider.currentBudget;

    final spent = expenseProvider.totalExpense;
    final remaining = budgetProvider.remainingBudget(spent);
    final progress = budgetProvider.budgetUsedPercentage(spent);
    final exceeded = budgetProvider.isBudgetExceeded(spent);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Monthly Budget',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'budget_fab',
        icon: Icon(budget == null ? Icons.add_rounded : Icons.edit_rounded),
        label: Text(
          budget == null ? 'Set Budget' : 'Edit Budget',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddBudgetPage(budget: budget)),
          );

          if (!context.mounted) return;

          await budgetProvider.loadBudgets();
        },
      ),
      body: RefreshIndicator(
        onRefresh: budgetProvider.loadBudgets,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
          children: [
            if (budget == null)
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.pie_chart_outline_rounded,
                          size: 64,
                          color: Theme.of(context).hintColor.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Budget Set Yet',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Set a monthly limit to track your spending and stay in control.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).hintColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current Month Target',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: (exceeded ? Colors.red : const Color(0xFF10B981))
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            exceeded ? 'Exceeded' : 'On Track',
                            style: TextStyle(
                              color: exceeded ? Colors.red : const Color(0xFF10B981),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      currency(budget.amount),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Metrics Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.arrow_downward_rounded, size: 14, color: Colors.red),
                                    SizedBox(width: 4),
                                    Text('Spent', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    currency(spent),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: (remaining >= 0 ? const Color(0xFF10B981) : Colors.red)
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      remaining >= 0
                                          ? Icons.account_balance_wallet_rounded
                                          : Icons.warning_amber_rounded,
                                      size: 14,
                                      color: remaining >= 0 ? const Color(0xFF10B981) : Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Remaining',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: remaining >= 0 ? const Color(0xFF10B981) : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    currency(remaining),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: remaining >= 0 ? const Color(0xFF10B981) : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor:
                            Theme.of(context).dividerColor.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          exceeded
                              ? Colors.red
                              : progress > 0.8
                                  ? Colors.amber
                                  : const Color(0xFF4F46E5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress * 100).toStringAsFixed(1)}% Used',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          exceeded ? 'Budget Exceeded!' : '${((1 - progress) * 100).clamp(0, 100).toStringAsFixed(1)}% Left',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: exceeded ? Colors.red : Theme.of(context).hintColor,
                          ),
                        ),
                      ],
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
