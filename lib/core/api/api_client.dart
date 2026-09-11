import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

/// Error devuelto por la API (o por la red) con un mensaje listo para mostrar.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;

  /// Código HTTP; nulo cuando no hubo respuesta del servidor.
  final int? statusCode;

  @override
  String toString() => message;
}

/// Cliente HTTP de la API REST: serializa JSON, agrega el token JWT y
/// convierte las respuestas de error en [ApiException].
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  // Perezoso: los tests lo reemplazan antes de que se cree el cliente real.
  late http.Client _http = http.Client();
  String _baseUrl = ApiConfig.baseUrl;

  /// Token JWT de la sesión actual; se envía en cada petición.
  String? token;

  /// Se invoca cuando una petición autenticada responde 401 (token vencido).
  VoidCallback? onUnauthorized;

  String get baseUrl => _baseUrl;

  /// Permite inyectar un cliente falso en los tests.
  @visibleForTesting
  void configure({http.Client? client, String? baseUrl}) {
    if (client != null) _http = client;
    if (baseUrl != null) _baseUrl = baseUrl;
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);

  Future<dynamic> post(String path, [Object? body]) =>
      _send('POST', path, body: body);

  Future<dynamic> put(String path, [Object? body]) =>
      _send('PUT', path, body: body);

  Future<dynamic> patch(String path, [Object? body]) =>
      _send('PATCH', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);
    final sentToken = token;

    final request = http.Request(method, uri)
      ..headers['Accept'] = 'application/json';
    if (sentToken != null) {
      request.headers['Authorization'] = 'Bearer $sentToken';
    }
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    final http.Response response;
    try {
      final streamed = await _http.send(request).timeout(ApiConfig.timeout);
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw const ApiException('El servidor tardó demasiado en responder.');
    } on http.ClientException {
      throw const ApiException(
        'No se pudo conectar con el servidor. Revisa tu conexión.',
      );
    }

    final decoded = _decode(response);

    if (response.statusCode >= 400) {
      if (response.statusCode == 401 && sentToken != null) {
        onUnauthorized?.call();
      }
      final message = decoded is Map && decoded['message'] is String
          ? decoded['message'] as String
          : 'Error inesperado (${response.statusCode}).';
      throw ApiException(message, statusCode: response.statusCode);
    }

    return decoded;
  }

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      return null;
    }
  }
}
