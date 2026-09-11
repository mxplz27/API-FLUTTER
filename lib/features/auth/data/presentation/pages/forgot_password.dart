import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../widgets/auth_widgets.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSending = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isSending = true);
    // Simula la llamada al servicio de recuperación.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _isSending = false;
      _emailSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      icon: Icons.key_outlined,
      showBackButton: true,
      title: 'Recuperar acceso',
      subtitle:
          'Te enviaremos un enlace seguro para restablecer tu contraseña.',
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
            label: 'Enviar instrucciones',
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
    return Column(
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
          'Enviamos las instrucciones a ${_emailController.text.trim()}. '
          'El enlace vence en 30 minutos.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13.5,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 26),

        AuthPrimaryButton(
          label: 'Volver a iniciar sesión',
          onPressed: () => Navigator.maybePop(context),
        ),
        const SizedBox(height: 10),

        TextButton(
          onPressed: () => setState(() => _emailSent = false),
          child: const Text('Usar otro correo'),
        ),
      ],
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
