import 'package:Attendance_System/Models/users.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  final databaseName = "ObjAI.db";

  //Now we must create our user table into our sqlite db

  String users =
      "create table users (UserID INTEGER PRIMARY KEY AUTOINCREMENT, UserName TEXT UNIQUE, UserEmail Text, UserPassword TEXT)";

  //We are done in this section

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(users);
    });
  }

  //Now we create login and sign up method
  //as we create sqlite other functionality in our previous video

  //IF you didn't watch my previous videos, check part 1 and part 2

  //Login Method

  Future<bool> login(Users user) async {
    final Database db = await initDB();

    // I forgot the password to check
    var result = await db.rawQuery(
        "select * from users where UserName = '${user.username}' AND UserPassword = '${user.password}'");
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  //Sign up
  Future<int> signup(Users user) async {
    final Database db = await initDB();
    return db.insert('users', user.toMap());
  }

  //Search Method
  Future<List<Users>> searchUsers(String keyword) async {
    final Database db = await initDB();
    List<Map<String, Object?>> searchResult = await db.rawQuery(
        "select * from users where UserName LIKE ${"%$keyword%"} or UserEmail LIKE ${"%$keyword%"} or UserID LIKE ${"%$keyword%"}");
    return searchResult.map((e) => Users.fromMap(e)).toList();
  }

  //CRUD Methods

  //Create Note
  Future<int> createUser(Users user) async {
    final Database db = await initDB();
    return db.insert('users', user.toMap());
  }

  //Get notes
  Future<List<Users>> getUsers() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.query('users');
    return result.map((e) => Users.fromMap(e)).toList();
  }

  //Delete Notes
  Future<int> deleteUser(int id) async {
    final Database db = await initDB();
    return db.delete('users', where: 'UserID = ?', whereArgs: [id]);
  }

  //Update Notes
  Future<int> updateUser(username, password, email) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update users set UserName = ?, UserPassword = ?, UserEmail where noteId = ?',
        [username, password, email]);
  }
}
