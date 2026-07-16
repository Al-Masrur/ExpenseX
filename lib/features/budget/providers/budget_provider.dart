import 'package:flutter/foundation.dart';

import 'package:expensex/data/models/budget.dart';
import 'package:expensex/data/repositories/budget_repository.dart';

class BudgetProvider extends ChangeNotifier {
  BudgetProvider({BudgetRepository? repository})
    : _repository = repository ?? BudgetRepository();

  final BudgetRepository _repository;

  final List<Budget> _budgets = [];

  List<Budget> get budgets => List.unmodifiable(_budgets);

  Budget? get currentBudget {
    final now = DateTime.now();

    try {
      return _budgets.firstWhere(
        (budget) => budget.month == now.month && budget.year == now.year,
      );
    } catch (_) {
      return null;
    }
  }

  double get currentBudgetAmount => currentBudget?.amount ?? 0;

  Future<void> loadBudgets() async {
    _budgets
      ..clear()
      ..addAll(await _repository.getBudgets());

    notifyListeners();
  }

  Future<void> addBudget(Budget budget) async {
    await _repository.insertBudget(budget);
    await loadBudgets();
  }

  Future<void> updateBudget(Budget budget) async {
    await _repository.updateBudget(budget);
    await loadBudgets();
  }

  Future<void> deleteBudget(int id) async {
    await _repository.deleteBudget(id);
    await loadBudgets();
  }

  // ---------- Helper Methods ----------

  double remainingBudget(double spent) {
    return currentBudgetAmount - spent;
  }

  double budgetUsedPercentage(double spent) {
    if (currentBudgetAmount <= 0) return 0;

    final value = spent / currentBudgetAmount;

    return value.clamp(0.0, 1.0);
  }

  bool isBudgetExceeded(double spent) {
    return spent > currentBudgetAmount && currentBudgetAmount > 0;
  }

  bool hasBudget() {
    return currentBudget != null;
  }
}
