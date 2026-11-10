import 'package:expensex/data/database/app_database.dart';
import 'package:expensex/features/recurring/models/recurring_transaction.dart';
import 'package:sqflite/sqflite.dart';

class RecurringRepository {
  RecurringRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> insertRecurring(RecurringTransaction transaction) async {
    final db = await _database.database;

    return db.insert(
      'recurring_transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<RecurringTransaction>> getRecurringTransactions() async {
    final db = await _database.database;

    final result = await db.query(
      'recurring_transactions',
      orderBy: 'next_date ASC',
    );

    return result.map(RecurringTransaction.fromMap).toList();
  }

  Future<List<RecurringTransaction>> getActiveRecurringTransactions() async {
    final db = await _database.database;

    final result = await db.query(
      'recurring_transactions',
      where: 'is_active = 1',
      orderBy: 'next_date ASC',
    );

    return result.map(RecurringTransaction.fromMap).toList();
  }

  Future<int> updateRecurring(RecurringTransaction transaction) async {
    final db = await _database.database;

    return db.update(
      'recurring_transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteRecurring(int id) async {
    final db = await _database.database;

    return db.delete(
      'recurring_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

