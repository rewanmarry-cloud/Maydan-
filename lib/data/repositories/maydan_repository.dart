import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MaydanRepository {
  Database? _database;

  Future<void> initialize() async {
    final path = join(await getDatabasesPath(), 'maydan.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE projects(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT, location TEXT, budget REAL, start_date TEXT, end_date TEXT, status TEXT DEFAULT "ongoing", progress INTEGER DEFAULT 0, archived INTEGER DEFAULT 0)',
        );
        await db.execute(
          'CREATE TABLE transactions(id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT NOT NULL, amount REAL NOT NULL, category TEXT, description TEXT, date TEXT, project_id INTEGER, currency TEXT)',
        );
        await db.execute(
          'CREATE TABLE visits(id INTEGER PRIMARY KEY AUTOINCREMENT, project_id INTEGER, responsible TEXT, date TEXT, notes TEXT, progress INTEGER DEFAULT 0)',
        );
        await db.execute(
          'CREATE TABLE reports(id INTEGER PRIMARY KEY AUTOINCREMENT, visit_id INTEGER, project_id INTEGER, responsible TEXT, date TEXT, observations TEXT, challenges TEXT, progress INTEGER DEFAULT 0)',
        );
        await db.execute(
          'CREATE TABLE employees(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, role TEXT NOT NULL, email TEXT, phone TEXT)',
        );
        await db.execute(
          'CREATE INDEX idx_transactions_project ON transactions(project_id)',
        );
        await db.execute(
          'CREATE INDEX idx_visits_project ON visits(project_id)',
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> list(String table) async =>
      _database!.query(table, orderBy: 'id DESC');

  Future<int> insert(String table, Map<String, dynamic> values) =>
      _database!.insert(table, values);

  Future<int> update(String table, int id, Map<String, dynamic> values) =>
      _database!.update(table, values, where: 'id = ?', whereArgs: [id]);

  Future<int> delete(String table, int id) =>
      _database!.delete(table, where: 'id = ?', whereArgs: [id]);
}
