import 'package:flutter/foundation.dart';

import 'package:expensex/core/services/notification_service.dart';
import 'package:expensex/data/models/expense.dart';
import 'package:expensex/data/models/income.dart';
import 'package:expensex/data/repositories/expense_repository.dart';
import 'package:expensex/data/repositories/income_repository.dart';
import 'package:expensex/data/repositories/recurring_repository.dart';
import 'package:expensex/features/recurring/models/recurring_transaction.dart';

class RecurringProvider extends ChangeNotifier {
  RecurringProvider({
    RecurringRepository? repository,
    ExpenseRepository? expenseRepository,
    IncomeRepository? incomeRepository,
  })  : _repository = repository ?? RecurringRepository(),
        _expenseRepository = expenseRepository ?? ExpenseRepository(),
        _incomeRepository = incomeRepository ?? IncomeRepository();

  final RecurringRepository _repository;
  final ExpenseRepository _expenseRepository;
  final IncomeRepository _incomeRepository;

  List<RecurringTransaction> _transactions = [];
  bool _isLoading = false;

  List<RecurringTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  int get activeCount => _transactions.where((t) => t.isActive).length;

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _repository.getRecurringTransactions();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(RecurringTransaction transaction) async {
    await _repository.insertRecurring(transaction);
    await loadTransactions();
  }

  Future<void> updateTransaction(RecurringTransaction transaction) async {
    await _repository.updateRecurring(transaction);
    await loadTransactions();
  }

  Future<void> toggleActive(RecurringTransaction transaction) async {
    final updated = transaction.copyWith(isActive: !transaction.isActive);
    await _repository.updateRecurring(updated);
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await _repository.deleteRecurring(id);
    await loadTransactions();
  }

  static DateTime calculateNextDate(DateTime from, RecurringFrequency freq) {
    switch (freq) {
      case RecurringFrequency.daily:
        return from.add(const Duration(days: 1));
      case RecurringFrequency.weekly:
        return from.add(const Duration(days: 7));
      case RecurringFrequency.monthly:
        return DateTime(from.year, from.month + 1, from.day, from.hour, from.minute);
      case RecurringFrequency.yearly:
        return DateTime(from.year + 1, from.month, from.day, from.hour, from.minute);
    }
  }

  /// Evaluates and auto-generates entries for transactions whose nextDate <= now
  Future<int> processDueTransactions() async {
    final now = DateTime.now();
    final all = await _repository.getActiveRecurringTransactions();
    int processedCount = 0;

    for (final item in all) {
      if (item.nextDate.isBefore(now) || item.nextDate.isAtSameMomentAs(now)) {
        if (item.type == RecurringType.expense) {
          await _expenseRepository.insertExpense(
            Expense(
              title: item.title,
              amount: item.amount,
              category: item.category,
              date: item.nextDate,
              note: item.note != null && item.note!.isNotEmpty
                  ? 'Recurring (${item.frequency.name}): ${item.note}'
                  : 'Auto-logged from Recurring',
            ),
          );
        } else {
          await _incomeRepository.insertIncome(
            Income(
              title: item.title,
              amount: item.amount,
              category: item.category,
              date: item.nextDate,
              note: item.note != null && item.note!.isNotEmpty
                  ? 'Recurring (${item.frequency.name}): ${item.note}'
                  : 'Auto-logged from Recurring',
            ),
          );
        }

        DateTime next = calculateNextDate(item.nextDate, item.frequency);
        // If next is still in the past, advance until future
        while (next.isBefore(now)) {
          next = calculateNextDate(next, item.frequency);
        }

        final updated = item.copyWith(nextDate: next);
        await _repository.updateRecurring(updated);
        processedCount++;
      }
    }

    if (processedCount > 0) {
      await loadTransactions();
      try {
        await NotificationService.instance.showNotification(
          title: 'Recurring Processed',
          body: '$processedCount recurring bill/income was automatically recorded.',
        );
      } catch (_) {}
    }

    return processedCount;
  }
}

