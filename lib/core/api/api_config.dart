import 'package:flutter/foundation.dart';

/// URL base de la API REST.
///
/// Se define al compilar con `--dart-define=API_URL=https://mi-api.up.railway.app/api`.
/// Sin ese valor apunta al backend local (el emulador de Android llega al
/// localhost del PC a través de 10.0.2.2).
class ApiConfig {
  const ApiConfig._();

  static const String _fromEnvironment = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_fromEnvironment.isNotEmpty) return _fromEnvironment;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  static const Duration timeout = Duration(seconds: 20);
}
