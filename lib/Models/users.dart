// To parse this JSON data, do
//
//     final users = usersFromMap(jsonString);

class Users {
  final int? userId;
  final String username;
  final String email;
  final String password;

  Users({
    this.userId,
    required this.username,
    required this.email,
    required this.password,
  });

  factory Users.fromMap(Map<String, dynamic> json) => Users(
        userId: json["userID"],
        username: json["username"],
        email: json["email"],
        password: json["password"],
      );

  Map<String, dynamic> toMap() => {
        "userID": userId,
        "username": username,
        "email": email,
        "password": password,
      };
}
