import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  AuthStorage._();

  static final AuthStorage instance = AuthStorage._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _sessionKey = 'smartcommerce_session';

  // SAVE LOGIN SESSION
  Future<void> saveSession({
    required String token,
    required String role,
    required Map<String, dynamic> user,
  }) async {
    final session = {'token': token, 'role': role, 'user': user};

    await _storage.write(key: _sessionKey, value: jsonEncode(session));
  }

  // RESTORE LOGIN SESSION
  Future<Map<String, dynamic>?> readSession() async {
    final saved = await _storage.read(key: _sessionKey);

    if (saved == null || saved.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(saved);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  // DELETE LOGIN SESSION
  Future<void> clearSession() async {
    await _storage.delete(key: _sessionKey);
  }
}
