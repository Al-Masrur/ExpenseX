import 'package:expensex/data/database/app_database.dart';
import 'package:expensex/data/models/expense.dart';
import 'package:sqflite/sqflite.dart';

class ExpenseRepository {
  ExpenseRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> insertExpense(Expense expense) async {
    final db = await _database.database;

    return db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Expense>> getExpenses() async {
    final db = await _database.database;

    final result = await db.query('expenses', orderBy: 'date DESC');

    return result.map(Expense.fromMap).toList();
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await _database.database;

    return db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await _database.database;

    return db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}
