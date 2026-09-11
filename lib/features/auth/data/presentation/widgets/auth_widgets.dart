import 'package:flutter/material.dart';

import '../../../../../core/state/user_store.dart';
import '../../../../../core/theme/app_theme.dart';
import '../pages/login_page.dart';

/// Encabezado de marca + hoja blanca redondeada, con el ancho limitado para
/// que en tablet/escritorio siga leyéndose como una pantalla de móvil.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.icon = Icons.apartment_rounded,
    this.showBackButton = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final IconData icon;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Al abrir el teclado compactamos el encabezado para dar aire al formulario.
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.graphite,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.graphiteDark, AppColors.graphite, AppColors.graphiteSoft],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -40,
              right: -30,
              child: _GlowCircle(size: 190, opacity: 0.10),
            ),
            const Positioned(
              top: 90,
              left: -60,
              child: _GlowCircle(size: 150, opacity: 0.06),
            ),
            SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.maxContentWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showBackButton)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, top: 4),
                            child: IconButton(
                              onPressed: () => Navigator.maybePop(context),
                              icon: const Icon(Icons.arrow_back_ios_new_rounded),
                              color: Colors.white,
                              tooltip: 'Volver',
                            ),
                          ),
                        ),
                      AnimatedPadding(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        padding: EdgeInsets.fromLTRB(
                          28,
                          isKeyboardOpen ? 4 : (showBackButton ? 8 : 32),
                          28,
                          isKeyboardOpen ? 16 : 28,
                        ),
                        child: _BrandHeader(
                          icon: icon,
                          title: title,
                          subtitle: subtitle,
                          compact: isKeyboardOpen,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(AppSizes.radiusSheet),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              24,
                              28,
                              24,
                              24 + MediaQuery.viewInsetsOf(context).bottom,
                            ),
                            child: DefaultTextStyle.merge(
                              style: theme.textTheme.bodyMedium!,
                              child: child,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.compact,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: compact ? 42 : 54,
              width: compact ? 42 : 54,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.copperSoft.withValues(alpha: 0.55),
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.copperSoft,
                size: compact ? 22 : 28,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'GRUPO INMOBILIARIO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Gestión profesional de propiedades',
                    style: TextStyle(color: AppColors.copperSoft, fontSize: 11.5),
                  ),
                ],
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.topLeft,
          child: compact
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.copperSoft.withValues(alpha: opacity),
      ),
    );
  }
}

/// Campo con etiqueta superior (patrón habitual en apps móviles).
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onFieldSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          textInputAction: textInputAction,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

/// Ojo para mostrar/ocultar contraseñas, con el mismo aspecto en los 3 formularios.
class PasswordVisibilityButton extends StatelessWidget {
  const PasswordVisibilityButton({
    super.key,
    required this.isObscured,
    required this.onPressed,
  });

  final bool isObscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      iconSize: 20,
      tooltip: isObscured ? 'Mostrar contraseña' : 'Ocultar contraseña',
      icon: Icon(
        isObscured
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
      ),
    );
  }
}

/// Botón principal con estado de carga.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(label, overflow: TextOverflow.ellipsis),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, size: 18),
                ],
              ],
            ),
    );
  }
}

/// Pie con enlace para cambiar entre login y registro.
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // Wrap y no Row: en pantallas estrechas el enlace baja de línea en vez
    // de desbordar.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        TextButton(onPressed: onPressed, child: Text(actionLabel)),
      ],
    );
  }
}

/// Validaciones compartidas por los tres formularios.
class AuthValidators {
  const AuthValidators._();

  static final RegExp _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static String? email(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Ingresa tu correo electrónico';
    if (!_emailPattern.hasMatch(input)) return 'Ingresa un correo válido';
    return null;
  }

  static String? password(String? value) {
    final input = value ?? '';
    if (input.isEmpty) return 'Ingresa tu contraseña';
    if (input.length < 6) return 'Debe tener al menos 6 caracteres';
    return null;
  }

  static String? notEmpty(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }
}

/// Pide confirmación y cierra la sesión: vacía la pila de navegación y deja
/// el login como única ruta, de modo que el botón "atrás" no vuelva a entrar.
Future<void> confirmAndSignOut(BuildContext context) async {
  final navigator = Navigator.of(context, rootNavigator: true);

  final shouldSignOut = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
      ),
      icon: const Icon(Icons.logout_rounded, color: AppColors.error),
      title: const Text('Cerrar sesión'),
      content: const Text(
        'Se cerrará tu sesión y volverás a la pantalla de inicio.',
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Cerrar sesión'),
        ),
      ],
    ),
  );

  if (shouldSignOut != true) return;

  await UserStore.instance.logout();
  navigator.pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const LoginPage()),
    (route) => false,
  );
}
