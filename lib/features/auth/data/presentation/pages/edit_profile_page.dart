import 'package:flutter/material.dart';

import '../../../../../core/state/user_store.dart';
import '../../../../../core/theme/app_theme.dart';
import '../widgets/auth_widgets.dart';

/// Formulario de edición del perfil. Guarda en [UserStore] y notifica a
/// todas las pantallas que muestran los datos del asesor.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _roleController;
  late final TextEditingController _officeController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = UserStore.instance.profile;
    _nameController = TextEditingController(text: profile.fullName);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
    _roleController = TextEditingController(text: profile.role);
    _officeController = TextEditingController(text: profile.office);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    _officeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isSaving = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    UserStore.instance.updateProfile(
      UserStore.instance.profile.copyWith(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        role: _roleController.text.trim(),
        office: _officeController.text.trim(),
      ),
    );

    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Información actualizada correctamente.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar información')),
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
                      'Datos del asesor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Estos datos se muestran en tu perfil y en los reportes.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    AuthTextField(
                      label: 'Nombre completo',
                      controller: _nameController,
                      prefixIcon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.name,
                      validator: (value) => AuthValidators.notEmpty(
                        value,
                        'Ingresa tu nombre completo',
                      ),
                    ),
                    const SizedBox(height: 18),

                    AuthTextField(
                      label: 'Correo electrónico',
                      controller: _emailController,
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: AuthValidators.email,
                    ),
                    const SizedBox(height: 18),

                    AuthTextField(
                      label: 'Teléfono',
                      controller: _phoneController,
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          AuthValidators.notEmpty(value, 'Ingresa tu teléfono'),
                    ),
                    const SizedBox(height: 18),

                    AuthTextField(
                      label: 'Cargo',
                      controller: _roleController,
                      prefixIcon: Icons.badge_outlined,
                      validator: (value) =>
                          AuthValidators.notEmpty(value, 'Ingresa tu cargo'),
                    ),
                    const SizedBox(height: 18),

                    AuthTextField(
                      label: 'Oficina',
                      controller: _officeController,
                      prefixIcon: Icons.location_on_outlined,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _save(),
                      validator: (value) =>
                          AuthValidators.notEmpty(value, 'Ingresa tu oficina'),
                    ),
                    const SizedBox(height: 28),

                    AuthPrimaryButton(
                      label: 'Guardar cambios',
                      icon: Icons.check_rounded,
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
