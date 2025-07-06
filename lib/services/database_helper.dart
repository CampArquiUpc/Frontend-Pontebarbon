import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'auth.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            fullName TEXT,
            dateOfBirth TEXT,
            gender TEXT,
            isSaving INTEGER,
            incomeRange TEXT,
            financialGoals TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE users ADD COLUMN fullName TEXT');
          await db.execute('ALTER TABLE users ADD COLUMN dateOfBirth TEXT');
          await db.execute('ALTER TABLE users ADD COLUMN gender TEXT');
          await db.execute('ALTER TABLE users ADD COLUMN isSaving INTEGER');
          await db.execute('ALTER TABLE users ADD COLUMN incomeRange TEXT');
          await db.execute('ALTER TABLE users ADD COLUMN financialGoals TEXT');
        }
      },
    );
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    final existingUser = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [user['email']],
    );
    if (existingUser.isNotEmpty) return -1;
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<bool> validateUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }
}
