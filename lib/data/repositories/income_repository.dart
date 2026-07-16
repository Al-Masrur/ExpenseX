import 'package:expensex/data/database/app_database.dart';
import 'package:expensex/data/models/income.dart';
import 'package:sqflite/sqflite.dart';

class IncomeRepository {
  IncomeRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> insertIncome(Income income) async {
    final db = await _database.database;

    return db.insert(
      'incomes',
      income.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Income>> getIncomes() async {
    final db = await _database.database;

    final result = await db.query('incomes', orderBy: 'date DESC');

    return result.map(Income.fromMap).toList();
  }

  Future<int> updateIncome(Income income) async {
    final db = await _database.database;

    return db.update(
      'incomes',
      income.toMap(),
      where: 'id = ?',
      whereArgs: [income.id],
    );
  }

  Future<int> deleteIncome(int id) async {
    final db = await _database.database;

    return db.delete('incomes', where: 'id = ?', whereArgs: [id]);
  }
}
