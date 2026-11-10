import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initializeDatabase();
    return _database!;
  }

  Future<File> get databaseFile async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'expensex.db');

    return File(path);
  }

  Future<Database> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'expensex.db');

    return openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> reopenDatabase() async {
    _database = await _initializeDatabase();
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createExpensesTable(db);
    await _createIncomesTable(db);
    await _createBudgetsTable(db);
    await _createRecurringTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createIncomesTable(db);
    }

    if (oldVersion < 3) {
      await _createBudgetsTable(db);
    }

    if (oldVersion < 4) {
      await _createRecurringTable(db);
    }
  }

  Future<void> _createExpensesTable(Database db) async {
    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date INTEGER NOT NULL,
        note TEXT
      )
    ''');
  }

  Future<void> _createIncomesTable(Database db) async {
    await db.execute('''
      CREATE TABLE incomes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date INTEGER NOT NULL,
        note TEXT
      )
    ''');
  }

  Future<void> _createBudgetsTable(Database db) async {
    await db.execute('''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        amount REAL NOT NULL
      )
    ''');
  }

  Future<void> _createRecurringTable(Database db) async {
    await db.execute('''
      CREATE TABLE recurring_transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        type TEXT NOT NULL,
        frequency TEXT NOT NULL,
        next_date INTEGER NOT NULL,
        note TEXT,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }
}
