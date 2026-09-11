import 'package:flutter/material.dart';

import '../../../../../core/state/user_store.dart';
import '../../../../../core/theme/app_theme.dart';
import '../widgets/auth_widgets.dart';

/// Cambio de contraseña con verificación de la contraseña actual.
/// La contraseña inicial de la sesión de demo es "123456".
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isCurrentObscured = true;
  bool _isNewObscured = true;
  bool _isConfirmObscured = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Redibuja el medidor de seguridad mientras se escribe.
    _newController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isSaving = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    UserStore.instance.changePassword(_newController.text);
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contraseña actualizada correctamente.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cambiar contraseña')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxContentWidth,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Actualiza tu contraseña',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Por seguridad debes confirmar tu contraseña actual.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    AuthTextField(
                      label: 'Contraseña actual',
                      controller: _currentController,
                      hintText: '••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _isCurrentObscured,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu contraseña actual';
                        }
                        if (!UserStore.instance.isCurrentPassword(value)) {
                          return 'La contraseña actual no es correcta';
                        }
                        return null;
                      },
                      suffixIcon: PasswordVisibilityButton(
                        isObscured: _isCurrentObscured,
                        onPressed: () => setState(
                          () => _isCurrentObscured = !_isCurrentObscured,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    AuthTextField(
                      label: 'Nueva contraseña',
                      controller: _newController,
                      hintText: 'Mínimo 6 caracteres',
                      prefixIcon: Icons.lock_reset_outlined,
                      obscureText: _isNewObscured,
                      validator: (value) {
                        final base = AuthValidators.password(value);
                        if (base != null) return base;
                        if (value == _currentController.text) {
                          return 'Debe ser distinta a la contraseña actual';
                        }
                        return null;
                      },
                      suffixIcon: PasswordVisibilityButton(
                        isObscured: _isNewObscured,
                        onPressed: () =>
                            setState(() => _isNewObscured = !_isNewObscured),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PasswordStrengthBar(password: _newController.text),
                    const SizedBox(height: 18),

                    AuthTextField(
                      label: 'Confirmar nueva contraseña',
                      controller: _confirmController,
                      hintText: 'Repite la nueva contraseña',
                      prefixIcon: Icons.lock_person_outlined,
                      obscureText: _isConfirmObscured,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _save(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirma la nueva contraseña';
                        }
                        if (value != _newController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                      suffixIcon: PasswordVisibilityButton(
                        isObscured: _isConfirmObscured,
                        onPressed: () => setState(
                          () => _isConfirmObscured = !_isConfirmObscured,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    AuthPrimaryButton(
                      label: 'Actualizar contraseña',
                      icon: Icons.shield_outlined,
                      isLoading: _isSaving,
                      onPressed: _save,
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Indicador visual de robustez: longitud, mayúsculas, dígitos y símbolos.
class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.password});

  final String password;

  int get _score {
    if (password.isEmpty) return 0;
    var score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 10) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      score++;
    }
    return score;
  }

  @override
  Widget build(BuildContext context) {
    const labels = ['', 'Débil', 'Aceptable', 'Buena', 'Excelente'];
    const colors = [
      AppColors.border,
      AppColors.error,
      AppColors.copper,
      AppColors.success,
      AppColors.success,
    ];
    final score = _score;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: Container(
                  height: 5,
                  margin: EdgeInsets.only(right: index == 3 ? 0 : 5),
                  decoration: BoxDecoration(
                    color: index < score ? colors[score] : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 76,
          child: Text(
            labels[score],
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: score == 0 ? AppColors.textSecondary : colors[score],
            ),
          ),
        ),
      ],
    );
  }
}
