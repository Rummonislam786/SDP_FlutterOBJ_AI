import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../AppConst.dart';
import '../models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create Users Table
    await db.execute('''
      CREATE TABLE ${AppConstants.usersTable} (
        ${AppConstants.userIdColumn} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AppConstants.usernameColumn} TEXT UNIQUE,
        ${AppConstants.passwordHashColumn} TEXT
      )
    ''');

    // Create Notes Table
    await db.execute('''
      CREATE TABLE ${AppConstants.notesTable} (
        ${AppConstants.noteIdColumn} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AppConstants.noteUserIdColumn} INTEGER,
        ${AppConstants.noteTitleColumn} TEXT,
        ${AppConstants.noteContentColumn} TEXT,
        ${AppConstants.noteCategoryColumn} TEXT,
        ${AppConstants.noteCreatedAtColumn} TEXT,
        FOREIGN KEY (${AppConstants.noteUserIdColumn}) REFERENCES ${AppConstants.usersTable} (${AppConstants.userIdColumn})
      )
    ''');
  }

  // User Operations
  Future<User> insertUser(User user) async {
    final db = await database;
    final id = await db.insert(AppConstants.usersTable, user.toMap());
    return user.copyWith(id: id);
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.usersTable,
      where: '${AppConstants.usernameColumn} = ?',
      whereArgs: [username],
    );
    return maps.isNotEmpty ? User.fromMap(maps.first) : null;
  }

  // Note Operations
  Future<Note> insertNote(Note note) async {
    final db = await database;
    final id = await db.insert(AppConstants.notesTable, note.toMap());
    return note.copyWith(id: id);
  }

  Future<List<Note>> getNotesByUser(int userId, {String? category}) async {
    final db = await database;
    final where = category != null
        ? '${AppConstants.noteUserIdColumn} = ? AND ${AppConstants.noteCategoryColumn} = ?'
        : '${AppConstants.noteUserIdColumn} = ?';

    final whereArgs = category != null ? [userId, category] : [userId];

    final maps = await db.query(
      AppConstants.notesTable,
      where: where,
      whereArgs: whereArgs,
      orderBy: '${AppConstants.noteCreatedAtColumn} DESC',
    );

    return maps.map((map) => Note.fromMap(map)).toList();
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      AppConstants.notesTable,
      note.toMap(),
      where: '${AppConstants.noteIdColumn} = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int noteId) async {
    final db = await database;
    return await db.delete(
      AppConstants.notesTable,
      where: '${AppConstants.noteIdColumn} = ?',
      whereArgs: [noteId],
    );
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}

// Extension method to help with creating a copy of User with updated id
extension UserCopyWith on User {
  User copyWith({int? id}) {
    return User(
      id: id ?? this.id,
      username: username,
      passwordHash: passwordHash,
    );
  }
}

// Extension method to help with creating a copy of Note with updated id
extension NoteCopyWith on Note {
  Note copyWith({int? id}) {
    return Note(
      id: id ?? this.id,
      userId: userId,
      title: title,
      content: content,
      category: category,
      createdAt: createdAt,
    );
  }
}
