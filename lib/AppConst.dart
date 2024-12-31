class AppConstants {
  // Database constants
  static const String databaseName = 'notes_keeper.db';

  // Table names
  static const String usersTable = 'users';
  static const String notesTable = 'notes';

  // User table columns
  static const String userIdColumn = 'id';
  static const String usernameColumn = 'username';
  static const String passwordHashColumn = 'password_hash';

  // Notes table columns
  static const String noteIdColumn = 'id';
  static const String noteUserIdColumn = 'user_id';
  static const String noteTitleColumn = 'title';
  static const String noteContentColumn = 'content';
  static const String noteCategoryColumn = 'category';
  static const String noteCreatedAtColumn = 'created_at';

  // Note categories
  static const List<String> noteCategories = [
    'Work',
    'Personal',
    'Study',
    'Other'
  ];
}
