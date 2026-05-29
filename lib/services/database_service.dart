import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/electronics_item.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'electronics_manager.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE electronics_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        wholesalerName TEXT,
        costPrice REAL,
        sellingPrice REAL,
        markupMultiplier REAL,
        location TEXT,
        quantity INTEGER
      )
    ''');
  }

  Future<int> insertItem(ElectronicsItem item) async {
    final db = await database;
    return await db.insert('electronics_items', item.toMap());
  }

  Future<List<ElectronicsItem>> getItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('electronics_items');
    return List.generate(maps.length, (i) {
      return ElectronicsItem.fromMap(maps[i], maps[i]['id'].toString());
    });
  }

  Future<int> updateItem(ElectronicsItem item) async {
    final db = await database;
    return await db.update(
      'electronics_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      'electronics_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ElectronicsItem>> searchItems(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'electronics_items',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    return List.generate(maps.length, (i) {
      return ElectronicsItem.fromMap(maps[i], maps[i]['id'].toString());
    });
  }
}
