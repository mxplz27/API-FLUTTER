import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../widgets/auth_widgets.dart';

class SingupPage extends StatefulWidget {
  const SingupPage({super.key});

  @override
  State<SingupPage> createState() => _SingupPageState();
}

class _SingupPageState extends State<SingupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordObscured = true;
  bool _isConfirmObscured = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    final isFormValid = _formKey.currentState!.validate();
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y la política de datos.'),
        ),
      );
      return;
    }
    if (!isFormValid) return;

    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cuenta creada correctamente.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      icon: Icons.business_center_outlined,
      showBackButton: true,
      title: 'Crear cuenta',
      subtitle: 'Registra tu perfil de asesor y empieza a gestionar cartera.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Datos del asesor',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Completa la información para habilitar tu acceso.',
              style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 26),

            AuthTextField(
              label: 'Nombre completo',
              controller: _nameController,
              hintText: 'Ana Martínez',
              prefixIcon: Icons.person_outline_rounded,
              keyboardType: TextInputType.name,
              validator: (value) =>
                  AuthValidators.notEmpty(value, 'Ingresa tu nombre completo'),
            ),
            const SizedBox(height: 18),

            AuthTextField(
              label: 'Correo electrónico',
              controller: _emailController,
              hintText: 'nombre@inmobiliaria.com',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: AuthValidators.email,
            ),
            const SizedBox(height: 18),

            AuthTextField(
              label: 'Teléfono de contacto',
              controller: _phoneController,
              hintText: '+52 55 0000 0000',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) => AuthValidators.notEmpty(
                value,
                'Ingresa un teléfono de contacto',
              ),
            ),
            const SizedBox(height: 18),

            AuthTextField(
              label: 'Contraseña',
              controller: _passwordController,
              hintText: 'Mínimo 6 caracteres',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _isPasswordObscured,
              validator: AuthValidators.password,
              suffixIcon: PasswordVisibilityButton(
                isObscured: _isPasswordObscured,
                onPressed: () => setState(
                  () => _isPasswordObscured = !_isPasswordObscured,
                ),
              ),
            ),
            const SizedBox(height: 18),

            AuthTextField(
              label: 'Confirmar contraseña',
              controller: _confirmPasswordController,
              hintText: 'Repite tu contraseña',
              prefixIcon: Icons.lock_reset_outlined,
              obscureText: _isConfirmObscured,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirma tu contraseña';
                }
                if (value != _passwordController.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
              suffixIcon: PasswordVisibilityButton(
                isObscured: _isConfirmObscured,
                onPressed: () =>
                    setState(() => _isConfirmObscured = !_isConfirmObscured),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  onChanged: (value) =>
                      setState(() => _acceptedTerms = value ?? false),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'Acepto los términos de servicio y la política de tratamiento de datos.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            AuthPrimaryButton(
              label: 'Crear cuenta',
              icon: Icons.arrow_forward_rounded,
              onPressed: _submit,
            ),
            const SizedBox(height: 10),

            AuthFooterLink(
              message: '¿Ya tienes cuenta?',
              actionLabel: 'Inicia sesión',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
