import 'package:expensex/data/models/expense.dart';
import 'package:expensex/data/models/income.dart';

class StatisticsHelper {
  StatisticsHelper._();

  /// Total Expenses
  static double totalExpense(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Total Income
  static double totalIncome(List<Income> incomes) {
    return incomes.fold(0.0, (sum, income) => sum + income.amount);
  }

  /// Savings = Income - Expense
  static double savings(List<Income> incomes, List<Expense> expenses) {
    return totalIncome(incomes) - totalExpense(expenses);
  }

  /// Expense grouped by category
  static Map<String, double> categoryTotals(List<Expense> expenses) {
    final Map<String, double> data = {};

    for (final expense in expenses) {
      data.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return data;
  }

  /// Highest spending category
  static String topCategory(List<Expense> expenses) {
    final totals = categoryTotals(expenses);

    if (totals.isEmpty) {
      return 'No Data';
    }

    return totals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Highest category amount
  static double topCategoryAmount(List<Expense> expenses) {
    final totals = categoryTotals(expenses);

    if (totals.isEmpty) {
      return 0;
    }

    return totals.entries.reduce((a, b) => a.value > b.value ? a : b).value;
  }

  /// Monthly expense totals (Jan-Dec)
  static List<double> monthlyExpenseTotals(List<Expense> expenses) {
    final totals = List<double>.filled(12, 0);

    for (final expense in expenses) {
      totals[expense.date.month - 1] += expense.amount;
    }

    return totals;
  }
}
