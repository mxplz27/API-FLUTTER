import 'package:flutter/foundation.dart';

/// Datos editables del asesor que ha iniciado sesión.
@immutable
class UserProfile {
  const UserProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.office,
  });

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

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? role,
    String? office,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      office: office ?? this.office,
    );
  }
}

/// Store en memoria de la sesión: perfil + contraseña.
/// Se reemplazará por la API cuando exista backend.
class UserStore extends ChangeNotifier {
  UserStore._();

  static final UserStore instance = UserStore._();

  UserProfile _profile = const UserProfile(
    fullName: 'Aprendiz SENA',
    email: 'aprendiz@sena.edu.co',
    phone: '+57 300 000 0000',
    role: 'Asesor inmobiliario',
    office: 'Oficina Centro',
  );

  String _password = '123456';

  UserProfile get profile => _profile;

  void updateProfile(UserProfile updated) {
    _profile = updated;
    notifyListeners();
  }

  bool isCurrentPassword(String value) => value == _password;

  void changePassword(String newPassword) {
    _password = newPassword;
    notifyListeners();
  }
}
