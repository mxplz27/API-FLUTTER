import 'package:flutter/material.dart';

import '../../../../../core/api/api_client.dart';
import '../../../../../core/state/user_store.dart';
import '../../../../../core/theme/app_theme.dart';
import '../widgets/auth_widgets.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  bool _isSending = false;
  bool _emailSent = false;
  bool _isResetting = false;
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showError(ApiException error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.message)));
  }

  Future<void> _submit() async {
    // Al reenviar el código el formulario del correo ya no está en pantalla.
    final isResend = _emailSent;
    if (!isResend && !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isSending = true);
    try {
      await UserStore.instance.requestPasswordReset(
        _emailController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _emailSent = true;
      });
      if (isResend) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Te enviamos un código nuevo.')),
        );
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _isSending = false);
      _showError(error);
    }
  }

  Future<void> _resetPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isResetting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await UserStore.instance.resetPassword(
        email: _emailController.text.trim(),
        code: _codeController.text.trim(),
        newPassword: _passwordController.text,
      );
      if (!mounted) return;
      setState(() => _isResetting = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Contraseña restablecida. Ya puedes iniciar sesión.'),
        ),
      );
      Navigator.maybePop(context);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _isResetting = false);
      _showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      icon: Icons.key_outlined,
      showBackButton: true,
      title: 'Recuperar acceso',
      subtitle:
          'Te enviaremos un código seguro para restablecer tu contraseña.',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        child: _emailSent ? _buildSuccessState() : _buildFormState(),
      ),
    );
  }

  Widget _buildFormState() {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('forgot-form'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Restablecer contraseña',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ingresa el correo con el que registraste tu cuenta.',
            style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 26),

          AuthTextField(
            label: 'Correo electrónico',
            controller: _emailController,
            hintText: 'nombre@inmobiliaria.com',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: AuthValidators.email,
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 22),

          AuthPrimaryButton(
            label: 'Enviar código',
            icon: Icons.send_rounded,
            isLoading: _isSending,
            onPressed: _submit,
          ),
          const SizedBox(height: 10),

          TextButton(
            onPressed: () => Navigator.maybePop(context),
            child: const Text('Volver a iniciar sesión'),
          ),
          const SizedBox(height: 8),

          const _HelpNote(),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Form(
      key: _resetFormKey,
      child: Column(
        key: const ValueKey('forgot-success'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              height: 84,
              width: 84,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                size: 38,
                color: AppColors.success,
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Revisa tu correo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Si ${_emailController.text.trim()} está registrado, recibirás un '
            'código de 6 dígitos. El código vence en 15 minutos.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 26),

          AuthTextField(
            label: 'Código de verificación',
            controller: _codeController,
            hintText: '123456',
            prefixIcon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (!RegExp(r'^\d{6}$').hasMatch(value?.trim() ?? '')) {
                return 'Ingresa el código de 6 dígitos';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          AuthTextField(
            label: 'Nueva contraseña',
            controller: _passwordController,
            hintText: 'Mínimo 6 caracteres',
            prefixIcon: Icons.lock_reset_outlined,
            obscureText: _isPasswordObscured,
            validator: AuthValidators.password,
            suffixIcon: PasswordVisibilityButton(
              isObscured: _isPasswordObscured,
              onPressed: () =>
                  setState(() => _isPasswordObscured = !_isPasswordObscured),
            ),
          ),
          const SizedBox(height: 18),

          AuthTextField(
            label: 'Confirmar contraseña',
            controller: _confirmController,
            hintText: 'Repite la nueva contraseña',
            prefixIcon: Icons.lock_person_outlined,
            obscureText: _isPasswordObscured,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _resetPassword(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirma la nueva contraseña';
              }
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
          const SizedBox(height: 26),

          AuthPrimaryButton(
            label: 'Restablecer contraseña',
            icon: Icons.shield_outlined,
            isLoading: _isResetting,
            onPressed: _resetPassword,
          ),
          const SizedBox(height: 10),

          TextButton(
            onPressed: _isSending ? null : _submit,
            child: const Text('Reenviar código'),
          ),
          TextButton(
            onPressed: () => setState(() => _emailSent = false),
            child: const Text('Usar otro correo'),
          ),
        ],
      ),
    );
  }
}

class _HelpNote extends StatelessWidget {
  const _HelpNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.support_agent_outlined, size: 18, color: AppColors.graphite),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '¿No recibes el correo? Contacta al administrador de tu oficina.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
