import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/session_storage.dart';
import 'agenda_store.dart';

/// Datos editables del asesor que ha iniciado sesión.
@immutable
class UserProfile {
  const UserProfile({
    this.id = '',
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.office,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? '',
      office: json['office'] as String? ?? '',
    );
  }

  /// Perfil vacío mientras no hay sesión.
  static const empty = UserProfile(
    fullName: '',
    email: '',
    phone: '',
    role: '',
    office: '',
  );

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String office;

  /// Iniciales para el avatar (maximo dos letras).
  String get initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final single = parts.first;
      return (single.length >= 2 ? single.substring(0, 2) : single)
          .toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'role': role,
    'office': office,
  };

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? role,
    String? office,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      office: office ?? this.office,
    );
  }
}

/// Sesión del asesor: autenticación y perfil contra la API REST.
class UserStore extends ChangeNotifier {
  UserStore._();

  static final UserStore instance = UserStore._();

  final ApiClient _api = ApiClient.instance;

  UserProfile _profile = UserProfile.empty;

  UserProfile get profile => _profile;

  bool get isAuthenticated => _api.token != null;

  /// Inicia sesión. Con [remember] el token sobrevive al cierre de la app.
  Future<void> login({
    required String email,
    required String password,
    bool remember = true,
  }) async {
    final data = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });
    await _startSession(data as Map<String, dynamic>, remember: remember);
  }

  /// Crea la cuenta. No abre sesión: el usuario vuelve al login.
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _api.post('/auth/register', {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
    });
  }

  /// Pide el código de recuperación que llega al correo.
  Future<void> requestPasswordReset(String email) async {
    await _api.post('/auth/forgot-password', {'email': email});
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _api.post('/auth/reset-password', {
      'email': email,
      'code': code,
      'password': newPassword,
    });
  }

  /// Recupera la sesión guardada al abrir la app. Devuelve si quedó activa.
  Future<bool> restoreSession() async {
    final token = await SessionStorage.readToken();
    if (token == null) return false;

    _api.token = token;
    try {
      await refreshProfile();
      return true;
    } on ApiException catch (error) {
      // Sin conexión el token guardado se conserva para el próximo arranque.
      if (error.statusCode == 401) await logout();
      _api.token = null;
      return false;
    }
  }

  Future<void> refreshProfile() async {
    final data = await _api.get('/users/me');
    _profile = UserProfile.fromJson(data as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile updated) async {
    final data = await _api.put('/users/me', updated.toJson());
    _profile = UserProfile.fromJson(data as Map<String, dynamic>);
    notifyListeners();
  }

  /// El servidor valida la contraseña actual; si no coincide lanza
  /// [ApiException] con código 400.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.put('/users/me/password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  Future<void> logout() async {
    _api.token = null;
    _profile = UserProfile.empty;
    AgendaStore.instance.clear();
    await SessionStorage.clear();
    notifyListeners();
  }

  Future<void> _startSession(
    Map<String, dynamic> data, {
    required bool remember,
  }) async {
    final token = data['token'] as String;
    _api.token = token;
    _profile = UserProfile.fromJson(data['user'] as Map<String, dynamic>);
    if (remember) {
      await SessionStorage.saveToken(token);
    } else {
      await SessionStorage.clear();
    }
    notifyListeners();
  }
}
