import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

class ExpenseDatabase {
  static final ExpenseDatabase instance = ExpenseDatabase._init();
  static Database? _database;

  ExpenseDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1, // Volver a versión 1
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE expenses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      category TEXT NOT NULL DEFAULT 'Sin categoría',
      amount REAL NOT NULL,
      date TEXT NOT NULL
    )
  ''');
  }

  Future<Expense> create(Expense expense) async {
    final db = await instance.database;
    final id = await db.insert('expenses', expense.toMap());
    return expense.copyWith(id: id);
  }

  Future<Expense?> read(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'expenses',
      columns: ['id', 'title', 'category', 'amount', 'date'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Expense.fromMap(maps.first);
    } else {
      return null;
    }
  }
  Future<List<Expense>> readAll() async {
    final db = await instance.database;
    const orderBy = 'date DESC';
    final result = await db.query('expenses', orderBy: orderBy);
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  Future<int> update(Expense expense) async {
    final db = await instance.database;
    return db.update(
      'expenses',
      {
        'title': expense.title,
        'category': expense.category,
        'amount': expense.amount,
        'date': expense.date.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
  }
}