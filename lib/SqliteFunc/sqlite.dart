import 'package:flutter_demo/Models/users.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  final databaseName = "users.db";
  String userTable =
      "CREATE TABLE users (userID INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL, email TEXT NOT NULL, password TEXT NOT NULL)";
  Future<Database> initDB() async {
    final databasepath = await getDatabasesPath();
    final path = join(databasepath, databaseName);

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(userTable);
    });
  }

  Future<int> createUser(Users user) async {
    final Database db = await initDB();
    return db.insert('users', user.toMap());
  }

  Future<List<Users>> getUsers() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.query('users');
    return result.map((e) => Users.fromMap(e)).toList();
  }

  Future<int> deleteUser(int id) async {
    final Database db = await initDB();
    return db.delete('users', where: 'userID = ?', whereArgs: [id]);
  }

  Future<int> updateUser(username, email, password) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update users set username = ?, email = ?, password = ?',
        [username, email, password]);
  }
}
