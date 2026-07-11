import 'package:expensex/data/database/app_database.dart';
import 'package:expensex/data/models/budget.dart';
import 'package:sqflite/sqflite.dart';

class BudgetRepository {
  BudgetRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> insertBudget(Budget budget) async {
    final db = await _database.database;

    return db.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Budget>> getBudgets() async {
    final db = await _database.database;

    final result = await db.query(
      'budgets',
      orderBy: 'year DESC, month DESC',
    );

    return result.map(Budget.fromMap).toList();
  }

  Future<int> updateBudget(Budget budget) async {
    final db = await _database.database;

    return db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteBudget(int id) async {
    final db = await _database.database;

    return db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Budget?> getCurrentMonthBudget() async {
    final db = await _database.database;

    final now = DateTime.now();

    final result = await db.query(
      'budgets',
      where: 'month = ? AND year = ?',
      whereArgs: [now.month, now.year],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Budget.fromMap(result.first);
  }
}