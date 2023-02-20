import 'dart:convert';

import 'User.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:http/http.dart' as http;

class UserApi {
  static const String apiUrl = 'https://reqres.in/api/users';
  static const String dbPath = 'users.db';

  static Future<void> createUserTable() async {
    final db = sqlite3.open(dbPath);

    db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        email TEXT NOT NULL
      );
    ''');

    db.dispose();
  }

  static Future<Map<String, dynamic>> createUser(User user) async {
    final fullName = '${user.firstName} ${user.lastName}';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'last_name': fullName,
        'job': user.email,
      },
    );

    if (response.statusCode == 201) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      return jsonData;
    } else {
      throw Exception('Failed to create user');
    }
  }

  static Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final userList =
          (jsonData['data'] as List).map((e) => User.fromJson(e)).toList();

      return userList;
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  static Future<void> insertUsers(List<User> users) async {
    final db = sqlite3.open(dbPath);

    db.execute('BEGIN TRANSACTION');

    for (final user in users) {
      final userMap = user.toMap();
      final userExists = db
          .select(
              'SELECT COUNT(*) as count FROM users WHERE id = ${userMap['id']}')
          .map((row) => row['count'] as int)
          .first;

      if (userExists == 0) {
        db.execute(
          'INSERT INTO users (id, firstName, lastName, email) VALUES (?, ?, ?, ?)',
          [user.id, user.firstName, user.lastName, user.email],
        );
      } else {
        db.execute(
          'UPDATE users SET firstName = ?, lastName = ?, email = ? WHERE id = ?',
          [user.firstName, user.lastName, user.email, user.id],
        );
      }
    }

    db.execute('COMMIT');

    db.dispose();
  }

  static Future<void> deleteUsers(List<User> users) async {
    final db = sqlite3.open(dbPath);

    db.execute('BEGIN TRANSACTION');

    for (final user in users) {
      db.execute('DELETE FROM users WHERE id = ?', [user.id]);
    }

    db.execute('COMMIT');

    db.dispose();
  }
}
