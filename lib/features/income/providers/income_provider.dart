import 'package:flutter/foundation.dart';

import 'package:expensex/data/models/income.dart';
import 'package:expensex/data/repositories/income_repository.dart';

class IncomeProvider extends ChangeNotifier {
  IncomeProvider({
    IncomeRepository? repository,
  }) : _repository = repository ?? IncomeRepository();

  final IncomeRepository _repository;

  final List<Income> _incomes = [];

  List<Income> get incomes => List.unmodifiable(_incomes);

  double get totalIncome =>
      _incomes.fold(0.0, (sum, item) => sum + item.amount);

      int get incomeCount => _incomes.length;

  Future<void> loadIncomes() async {
    _incomes
      ..clear()
      ..addAll(await _repository.getIncomes());

    notifyListeners();
  }

  Future<void> addIncome(Income income) async {
    await _repository.insertIncome(income);

    await loadIncomes();
  }

  Future<void> updateIncome(Income income) async {
    await _repository.updateIncome(income);

    await loadIncomes();
  }

  Future<void> deleteIncome(int id) async {
    await _repository.deleteIncome(id);

    await loadIncomes();
  }
}