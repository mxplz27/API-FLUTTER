import 'dart:convert';

import 'package:flutter_application_2/core/api/api_client.dart';
import 'package:flutter_application_2/core/state/user_store.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Imitación en memoria de la API REST del backend (mismas rutas y
/// respuestas) para probar las pantallas sin servidor.
class FakeApi {
  final Map<String, Map<String, dynamic>> _usersByEmail = {};
  final Map<String, String> _passwords = {};
  final Map<String, String> _resetCodes = {};
  final List<Map<String, dynamic>> tasks = [];
  int _nextId = 1;

  /// Último código de recuperación "enviado por correo".
  String? lastResetCode;

  late final http.Client client = MockClient(_handle);

  String? passwordFor(String email) => _passwords[email];

  Map<String, dynamic> addUser({
    String fullName = 'Aprendiz SENA',
    String email = 'aprendiz@sena.edu.co',
    String phone = '+57 300 000 0000',
    String password = '123456',
  }) {
    final user = {
      'id': 'u${_nextId++}',
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': 'Asesor inmobiliario',
      'office': 'Oficina Centro',
    };
    _usersByEmail[email] = user;
    _passwords[email] = password;
    return user;
  }

  Map<String, dynamic> addTask(Map<String, dynamic> ownerUser, Map<String, dynamic> data) {
    final task = {
      'id': 't${_nextId++}',
      'owner': ownerUser['id'],
      'type': 'visit',
      'status': 'pending',
      'notes': '',
      ...data,
    };
    tasks.add(task);
    return task;
  }

  Future<http.Response> _handle(http.Request request) async {
    final path = request.url.path.replaceFirst('/api', '');
    final body = request.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(request.body) as Map<String, dynamic>;
    final route = '${request.method} $path';

    switch (route) {
      case 'POST /auth/register':
        if (_usersByEmail.containsKey(body['email'])) {
          return _error(409, 'El correo ya está registrado');
        }
        final user = addUser(
          fullName: body['fullName'],
          email: body['email'],
          phone: body['phone'],
          password: body['password'],
        );
        return _json(201, {'token': 'token-${user['id']}', 'user': user});

      case 'POST /auth/login':
        final user = _usersByEmail[body['email']];
        if (user == null || _passwords[body['email']] != body['password']) {
          return _error(401, 'Correo o contraseña incorrectos');
        }
        return _json(200, {'token': 'token-${user['id']}', 'user': user});

      case 'POST /auth/forgot-password':
        if (_usersByEmail.containsKey(body['email'])) {
          lastResetCode = '482913';
          _resetCodes[body['email']] = lastResetCode!;
        }
        return _json(200, {'message': 'Si el correo está registrado, recibirás un código.'});

      case 'POST /auth/reset-password':
        if (_resetCodes[body['email']] != body['code']) {
          return _error(400, 'El código no es válido o ya venció');
        }
        _resetCodes.remove(body['email']);
        _passwords[body['email']] = body['password'];
        return _json(200, {'message': 'Contraseña restablecida.'});
    }

    final user = _authenticate(request);
    if (user == null) return _error(401, 'Debes iniciar sesión');

    switch (route) {
      case 'GET /users/me':
        return _json(200, user);

      case 'PUT /users/me':
        final oldEmail = user['email'] as String;
        for (final field in ['fullName', 'email', 'phone', 'role', 'office']) {
          if (body[field] != null) user[field] = body[field];
        }
        _usersByEmail.remove(oldEmail);
        _usersByEmail[user['email']] = user;
        _passwords[user['email']] = _passwords.remove(oldEmail)!;
        return _json(200, user);

      case 'PUT /users/me/password':
        final email = user['email'] as String;
        if (_passwords[email] != body['currentPassword']) {
          return _error(400, 'La contraseña actual no es correcta');
        }
        _passwords[email] = body['newPassword'];
        return _json(200, {'message': 'Contraseña actualizada correctamente'});
    }

    return _error(404, 'Ruta no encontrada: $route');
  }

  Map<String, dynamic>? _authenticate(http.Request request) {
    final header = request.headers['Authorization'] ?? '';
    if (!header.startsWith('Bearer token-')) return null;
    final id = header.substring('Bearer token-'.length);
    for (final user in _usersByEmail.values) {
      if (user['id'] == id) return user;
    }
    return null;
  }

  http.Response _json(int status, Object body) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );

  http.Response _error(int status, String message) =>
      _json(status, {'message': message});
}

/// Conecta [ApiClient] al backend falso y cierra cualquier sesión previa.
Future<FakeApi> installFakeApi() async {
  SharedPreferences.setMockInitialValues({});
  final api = FakeApi();
  ApiClient.instance.configure(client: api.client, baseUrl: 'http://fake/api');
  await UserStore.instance.logout();
  return api;
}

/// Crea el usuario de demo e inicia sesión con él.
Future<Map<String, dynamic>> signInDemoUser(FakeApi api) async {
  final user = api.addUser();
  await UserStore.instance.login(email: user['email'], password: '123456');
  return user;
}
