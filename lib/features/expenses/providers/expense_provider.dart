import 'package:flutter/foundation.dart';

import 'package:expensex/data/models/expense.dart';
import 'package:expensex/data/repositories/expense_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider({ExpenseRepository? repository})
    : _repository = repository ?? ExpenseRepository();

  final ExpenseRepository _repository;

  final List<Expense> _expenses = [];

  List<Expense> get expenses => List.unmodifiable(_expenses);

  double get totalExpense =>
      _expenses.fold(0.0, (sum, item) => sum + item.amount);

  int get expenseCount => _expenses.length;

  Future<void> loadExpenses() async {
    _expenses
      ..clear()
      ..addAll(await _repository.getExpenses());

    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await _repository.insertExpense(expense);

    await loadExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    await _repository.updateExpense(expense);

    await loadExpenses();
  }

  Future<void> deleteExpense(int id) async {
    await _repository.deleteExpense(id);

    await loadExpenses();
  }
}
