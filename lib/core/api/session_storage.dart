import 'package:shared_preferences/shared_preferences.dart';

/// Guarda el token JWT en el dispositivo cuando el usuario marca "Recordarme".
/// Si el almacenamiento no está disponible la sesión solo vive en memoria.
class SessionStorage {
  const SessionStorage._();

  static const _tokenKey = 'auth_token';

  static Future<String?> readToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (_) {}
  }

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (_) {}
  }
}
