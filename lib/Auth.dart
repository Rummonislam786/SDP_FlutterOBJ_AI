import 'dart:convert';

import '../models.dart';
import '../databasehelper.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Hash password using SHA-256
  String _hashPassword(String password) {
    final salt = 'NoteMateApp_';
    return (salt + password).hashCode.toString();
  }

  // User Registration
  Future<User?> registerUser(String username, String password) async {
    // Check if username already exists
    final existingUser = await _databaseHelper.getUserByUsername(username);
    if (existingUser != null) {
      return null; // Username already taken
    }

    // Hash the password
    final passwordHash = _hashPassword(password);

    // Create and insert new user
    final newUser = User(username: username, passwordHash: passwordHash);

    return await _databaseHelper.insertUser(newUser);
  }

  // User Login
  Future<User?> loginUser(String username, String password) async {
    // Retrieve user by username
    final user = await _databaseHelper.getUserByUsername(username);

    if (user == null) {
      return null; // User not found
    }

    // Hash the provided password and compare
    final hashedPassword = _hashPassword(password);

    return hashedPassword == user.passwordHash ? user : null;
  }
}

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  final AuthService _authService = AuthService();

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> register(String username, String password) async {
    try {
      final user = await _authService.registerUser(username, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final user = await _authService.loginUser(username, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
