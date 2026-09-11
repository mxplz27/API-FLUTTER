import 'package:flutter/material.dart';

import '../../../../../core/state/sales_store.dart';
import '../../../../../core/state/user_store.dart';
import '../../../../../core/theme/app_theme.dart';
import '../widgets/auth_widgets.dart';
import 'change_password_page.dart';
import 'edit_profile_page.dart';
import 'my_sales_page.dart';

/// Perfil como pantalla completa (con AppBar y botón de cerrar sesión).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de usuario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar sesión',
            onPressed: () => confirmAndSignOut(context),
          ),
        ],
      ),
      body: const SafeArea(child: ProfileView()),
    );
  }
}

/// Contenido del perfil sin Scaffold, reutilizable dentro de otros layouts
/// (por ejemplo la pestaña "Perfil" del panel principal).
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final userStore = UserStore.instance;
    final salesStore = SalesStore.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([userStore, salesStore]),
      builder: (context, _) {
        final profile = userStore.profile;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxContentWidth,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfileHeader(profile: profile),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          label: 'Ventas cerradas',
                          value: '${salesStore.closedCount}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          label: 'Total facturado',
                          value: formatCurrency(salesStore.closedAmount),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const _SectionLabel('Cuenta'),
                  const SizedBox(height: 10),
                  _OptionsCard(
                    children: [
                      _ProfileOption(
                        icon: Icons.edit_outlined,
                        title: 'Editar información',
                        subtitle: 'Nombre, correo, teléfono y oficina',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfilePage(),
                          ),
                        ),
                      ),
                      _ProfileOption(
                        icon: Icons.lock_outline_rounded,
                        title: 'Cambiar contraseña',
                        subtitle: 'Actualiza tus credenciales de acceso',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordPage(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  const _SectionLabel('Actividad comercial'),
                  const SizedBox(height: 10),
                  _OptionsCard(
                    children: [
                      _ProfileOption(
                        icon: Icons.home_work_outlined,
                        title: 'Mis ventas y propiedades',
                        subtitle:
                            '${salesStore.totalCount} operaciones registradas',
                        trailingBadge: '${salesStore.closedCount}',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MySalesPage(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  OutlinedButton.icon(
                    onPressed: () => confirmAndSignOut(context),
                    icon: const Icon(Icons.logout_rounded, size: 19),
                    label: const Text('Cerrar sesión'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.graphiteDark, AppColors.graphite],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
      ),
      child: Row(
        children: [
          Container(
            height: 64,
            width: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.copperSoft.withValues(alpha: 0.6),
                width: 1.4,
              ),
            ),
            child: Text(
              profile.initials,
              style: const TextStyle(
                color: AppColors.copperSoft,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${profile.role} · ${profile.office}',
                  style: const TextStyle(
                    color: AppColors.copperSoft,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profile.email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 12.5,
                  ),
                ),
                Text(
                  profile.phone,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _OptionsCard extends StatelessWidget {
  const _OptionsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // El Material va dentro del borde: los ListTile pintan ahí su tinta,
    // que un DecoratedBox con color intermedio ocultaría.
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: AppColors.surface,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const Divider(height: 1, indent: 60),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingBadge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? trailingBadge;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      leading: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 19, color: AppColors.graphite),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingBadge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.copper.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                trailingBadge!,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.copper,
                ),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
