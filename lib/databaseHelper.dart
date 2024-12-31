import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../AppConst.dart';
import '../Models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.databaseName);
    return _database!;
  }

  Future<void> clearNoteTagsRelations(int noteId) async {
    final db = await database;
    await db.delete(
      'note_tags',
      where: 'note_id = ?',
      whereArgs: [noteId],
    );
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
    // Create Tags Table
    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE
      )
    ''');

    // Create Note-Tags relationship table
    await db.execute('''
      CREATE TABLE note_tags (
        note_id INTEGER,
        tag_id INTEGER,
        PRIMARY KEY (note_id, tag_id),
        FOREIGN KEY (note_id) REFERENCES ${AppConstants.notesTable} (${AppConstants.noteIdColumn}),
        FOREIGN KEY (tag_id) REFERENCES tags (id)
      )
    ''');
  }

  // Tag operations
  Future<Tag> insertTag(Tag tag) async {
    final db = await database;
    final id = await db.insert('tags', tag.toMap());
    return Tag(id: id, name: tag.name);
  }

  Future<void> addTagToNote(int noteId, int tagId) async {
    final db = await database;
    try {
      await db.insert('note_tags', {
        'note_id': noteId,
        'tag_id': tagId,
      });
    } catch (e) {
      // If the relationship already exists, ignore the error
      if (!e.toString().contains('UNIQUE constraint failed')) {
        rethrow;
      }
    }
  }

  Future<List<Tag>> getTagsForNote(int noteId) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT t.* FROM tags t
      INNER JOIN note_tags nt ON t.id = nt.tag_id
      WHERE nt.note_id = ?
    ''', [noteId]);
    return results.map((map) => Tag.fromMap(map)).toList();
  }

  Future<List<Note>> getNotesByTags(int userId, List<String> tagNames) async {
    final db = await database;
    final questionMarks = List.filled(tagNames.length, '?').join(',');

    final results = await db.rawQuery('''
      SELECT DISTINCT n.* FROM ${AppConstants.notesTable} n
      INNER JOIN note_tags nt ON n.${AppConstants.noteIdColumn} = nt.note_id
      INNER JOIN tags t ON nt.tag_id = t.id
      WHERE n.${AppConstants.noteUserIdColumn} = ?
      AND t.name IN ($questionMarks)
    ''', [userId, ...tagNames]);

    final notes = results.map((map) => Note.fromMap(map)).toList();

    // Load tags for each note
    for (var note in notes) {
      final tags = await getTagsForNote(note.id!);
      note.tags.addAll(tags);
    }

    return notes;
  }

  Future<void> removeTagFromNote(int noteId, int tagId) async {
    final db = await database;
    await db.delete(
      'note_tags',
      where: 'note_id = ? AND tag_id = ?',
      whereArgs: [noteId, tagId],
    );
  }

  Future<List<Tag>> getAllTags() async {
    final db = await database;
    final results = await db.query('tags');
    return results.map((map) => Tag.fromMap(map)).toList();
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
      tags: tags,
      createdAt: createdAt,
    );
  }
}
