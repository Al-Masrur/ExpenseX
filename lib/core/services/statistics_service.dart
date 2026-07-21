import 'package:expensex/data/models/expense.dart';
import 'package:expensex/data/models/income.dart';

class StatisticsService {
  const StatisticsService();

  /// -----------------------------
  /// TOTALS
  /// -----------------------------

  double totalIncome(List<Income> incomes) {
    return incomes.fold(0.0, (sum, income) => sum + income.amount);
  }

  double totalExpense(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double netBalance(List<Income> incomes, List<Expense> expenses) {
    return totalIncome(incomes) - totalExpense(expenses);
  }

  /// -----------------------------
  /// CATEGORY TOTALS
  /// -----------------------------

  Map<String, double> expenseByCategory(List<Expense> expenses) {
    final Map<String, double> result = {};

    for (final expense in expenses) {
      result.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return result;
  }

  /// -----------------------------
  /// MONTHLY TOTALS
  /// -----------------------------

  Map<int, double> monthlyExpenses(List<Expense> expenses, int year) {
    final Map<int, double> monthly = {for (int i = 1; i <= 12; i++) i: 0};

    for (final expense in expenses) {
      if (expense.date.year == year) {
        monthly.update(expense.date.month, (value) => value + expense.amount);
      }
    }

    return monthly;
  }

  Map<int, double> monthlyIncome(List<Income> incomes, int year) {
    final Map<int, double> monthly = {for (int i = 1; i <= 12; i++) i: 0};

    for (final income in incomes) {
      if (income.date.year == year) {
        monthly.update(income.date.month, (value) => value + income.amount);
      }
    }

    return monthly;
  }

  /// -----------------------------
  /// TOP CATEGORY
  /// -----------------------------

  String? highestExpenseCategory(List<Expense> expenses) {
    final categories = expenseByCategory(expenses);

    if (categories.isEmpty) {
      return null;
    }

    return categories.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  /// -----------------------------
  /// AVERAGE DAILY SPENDING
  /// -----------------------------

  double averageDailyExpense(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return 0;
    }

    final total = totalExpense(expenses);

    final oldestDate = expenses
        .map((e) => e.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);

    final days = DateTime.now().difference(oldestDate).inDays + 1;

    return total / days;
  }
}
