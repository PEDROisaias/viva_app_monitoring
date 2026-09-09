import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
 
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
 
  @override
  String toString() => message;
}
 
class AuthService {
  static const _keyUsers = 'auth_users';
  static const _keyCurrentUserId = 'auth_current_user_id';

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<Map<String, UserProfile>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUsers);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(
        key,
        UserProfile.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  Future<void> _saveUsers(Map<String, UserProfile> users) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      users.map((key, value) => MapEntry(key, value.toJson())),
    );
    await prefs.setString(_keyUsers, encoded);
  }

  Future<UserProfile> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty) throw const AuthException('Nome é obrigatório.');
    if (!_isValidEmail(email)) throw const AuthException('E-mail inválido.');
    if (password.length < 6) {
      throw const AuthException('A senha deve ter pelo menos 6 caracteres.');
    }
 
    final users = await _loadUsers();
 
    final alreadyExists = users.values
        .any((u) => u.email.toLowerCase() == email.toLowerCase());
    if (alreadyExists) {
      throw const AuthException('Este e-mail já está cadastrado.');
    }
 
    final id = _generateId();
    final profile = UserProfile(
      id: id,
      name: name.trim(),
      email: email.toLowerCase().trim(),
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
 
    users[id] = profile;
    await _saveUsers(users);
    await _persistSession(id);
 
    return profile;
  }
 
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    final users = await _loadUsers();
 
    final profile = users.values.firstWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase().trim(),
      orElse: () => throw const AuthException('E-mail não encontrado.'),
    );
 
    if (profile.passwordHash != _hashPassword(password)) {
      throw const AuthException('Senha incorreta.');
    }
 
    await _persistSession(profile.id);
    return profile;
  }

  Future<void> _persistSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrentUserId, userId);
  }

  Future<UserProfile?> getActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_keyCurrentUserId);
    if (userId == null) return null;
 
    final users = await _loadUsers();
    return users[userId];
  }
 
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentUserId);
  }

  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-z]{2,}$').hasMatch(email);
  }
 
  static String _generateId() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}