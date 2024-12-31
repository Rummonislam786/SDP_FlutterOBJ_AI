class User {
  final int? id;
  final String username;
  final String passwordHash;

  User({
    this.id,
    required this.username,
    required this.passwordHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password_hash': passwordHash,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      passwordHash: map['password_hash'],
    );
  }
}

class Note {
  final int? id;
  final int userId;
  final String title;
  final String content;
  final String category;
  final DateTime createdAt;

  Note({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.category,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      content: map['content'],
      category: map['category'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
