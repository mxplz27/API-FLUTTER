import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../widgets/auth_widgets.dart';
import './forgot_password.dart';
import '../../../agenda/presentation/pages/property_sales_page.dart';
import './singup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordObscured = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PropertySalesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      icon: Icons.apartment_rounded,
      title: 'Bienvenido de nuevo',
      subtitle: 'Accede a tu cartera de propiedades, agenda y clientes.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Iniciar sesión',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Usa las credenciales de tu cuenta corporativa.',
              style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 26),

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
              label: 'Contraseña',
              controller: _passwordController,
              hintText: '••••••••',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _isPasswordObscured,
              textInputAction: TextInputAction.done,
              validator: AuthValidators.password,
              onFieldSubmitted: (_) => _submit(),
              suffixIcon: PasswordVisibilityButton(
                isObscured: _isPasswordObscured,
                onPressed: () => setState(
                  () => _isPasswordObscured = !_isPasswordObscured,
                ),
              ),
            ),
            const SizedBox(height: 6),

            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) =>
                      setState(() => _rememberMe = value ?? false),
                ),
                const Expanded(
                  child: Text(
                    'Recordarme',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            // En su propia línea: junto al check no cabe en pantallas estrechas.
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordPage(),
                  ),
                ),
                child: const Text('¿Olvidaste tu contraseña?'),
              ),
            ),
            const SizedBox(height: 14),

            AuthPrimaryButton(
              label: 'Iniciar sesión',
              icon: Icons.arrow_forward_rounded,
              onPressed: _submit,
            ),
            const SizedBox(height: 10),

            AuthFooterLink(
              message: '¿No tienes una cuenta?',
              actionLabel: 'Regístrate',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SingupPage()),
              ),
            ),
            const SizedBox(height: 8),

            const _TrustNote(),
          ],
        ),
      ),
    );
  }
}

/// Nota de confianza: refuerza la seriedad de la marca al pie del formulario.
class _TrustNote extends StatelessWidget {
  const _TrustNote();

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
          Icon(Icons.verified_user_outlined, size: 18, color: AppColors.graphite),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Conexión segura. Tus datos y los de tus clientes están protegidos.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
