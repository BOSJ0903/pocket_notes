import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'plant.dart';

class DatabaseHelper {
  // 1. Create a private constructor and a single instance (Singleton)
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  // 2. Open the database ONCE and reuse it
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'plants_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE plants(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        wateringNotes TEXT
      )
    ''');
  }

  // --- CRUD OPERATIONS ---

  // Create
  Future<int> insertPlant(Plant plant) async {
    Database db = await instance.database;
    return await db.insert('plants', plant.toMap());
  }

  // Read
  // Read
  Future<List<Plant>> getPlants() async {
    Database db = await instance.database;
    final maps = await db.query('plants');
    
    // Add these lines for your screenshot proof!
    print('--- DATABASE PROOF ---');
    print(maps);
    
    return List.generate(maps.length, (i) => Plant.fromMap(maps[i]));
  }

  // Update (Strictly using where and whereArgs)
  Future<int> updatePlant(Plant plant) async {
    Database db = await instance.database;
    return await db.update(
      'plants',
      plant.toMap(),
      where: 'id = ?',
      whereArgs: [plant.id],
    );
  }

  // Delete (Strictly using where and whereArgs)
  Future<int> deletePlant(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'plants',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}