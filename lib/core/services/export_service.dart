import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:expensex/data/models/budget.dart';
import 'package:expensex/data/models/expense.dart';
import 'package:expensex/data/models/income.dart';

class ExportService {
  Future<File> exportExpenses(List<Expense> expenses) async {
    final rows = <List<dynamic>>[
      ['ID', 'Title', 'Amount', 'Category', 'Date'],
    ];

    for (final expense in expenses) {
      rows.add([
        expense.id,
        expense.title,
        expense.amount,
        expense.category,
        expense.date.toIso8601String(),
      ]);
    }

    return _createCsvFile(rows, 'expensex_expenses.csv');
  }

  Future<File> exportIncome(List<Income> incomes) async {
    final rows = <List<dynamic>>[
      ['ID', 'Title', 'Amount', 'Category', 'Date'],
    ];

    for (final income in incomes) {
      rows.add([
        income.id,
        income.title,
        income.amount,
        income.category,
        income.date.toIso8601String(),
      ]);
    }

    return _createCsvFile(rows, 'expensex_income.csv');
  }

  Future<File> exportBudgets(List<Budget> budgets) async {
    final rows = <List<dynamic>>[
      ['ID', 'Month', 'Amount'],
    ];

    for (final budget in budgets) {
      rows.add([budget.id, budget.month, budget.amount]);
    }

    return _createCsvFile(rows, 'expensex_budgets.csv');
  }

  Future<File> _createCsvFile(List<List<dynamic>> rows, String fileName) async {
    final csvData = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();

    final file = File('${directory.path}/$fileName');

    await file.writeAsString(csvData);

    return file;
  }

  Future<void> shareFile(File file) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: 'ExpenseX Export'),
    );
  }
}
