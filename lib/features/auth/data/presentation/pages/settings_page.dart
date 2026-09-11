import 'package:flutter/material.dart';

import '../../../../../core/state/settings_store.dart';
import '../../../../../core/state/user_store.dart';
import '../../../../../core/theme/app_theme.dart';
import '../widgets/auth_widgets.dart';
import 'change_password_page.dart';
import 'edit_profile_page.dart';

/// Configuración como pantalla completa.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: const SafeArea(child: SettingsView(showTitle: false)),
    );
  }
}

/// Configuración reutilizable dentro de otro layout.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, this.showTitle = true});

  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final settings = SettingsStore.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([settings, UserStore.instance]),
      builder: (context, _) {
        final profile = UserStore.instance.profile;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxContentWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                if (showTitle) ...[
                  const Text(
                    'Configuración',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ajusta las preferencias de tu cuenta y de la agenda.',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                const _SectionLabel('Notificaciones'),
                const SizedBox(height: 10),
                _Card(
                  children: [
                    _SwitchRow(
                      icon: Icons.mark_email_unread_outlined,
                      title: 'Avisos por correo',
                      subtitle: 'Recibe novedades en ${profile.email}',
                      value: settings.emailNotifications,
                      onChanged: (value) =>
                          settings.emailNotifications = value,
                    ),
                    _SwitchRow(
                      icon: Icons.notifications_active_outlined,
                      title: 'Recordatorios de citas',
                      subtitle: 'Te avisamos antes de cada gestión agendada',
                      value: settings.appointmentReminders,
                      onChanged: (value) =>
                          settings.appointmentReminders = value,
                    ),
                    _SwitchRow(
                      icon: Icons.insights_outlined,
                      title: 'Resumen semanal de ventas',
                      subtitle: 'Un correo con tu cierre de la semana',
                      value: settings.weeklySummary,
                      onChanged: (value) => settings.weeklySummary = value,
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                const _SectionLabel('Agenda y presentación'),
                const SizedBox(height: 10),
                _Card(
                  children: [
                    _DropdownRow<int>(
                      icon: Icons.timer_outlined,
                      title: 'Antelación del recordatorio',
                      // Sin recordatorios activos el ajuste no aplica.
                      enabled: settings.appointmentReminders,
                      value: settings.reminderMinutes,
                      items: {
                        for (final minutes in SettingsStore.reminderOptions)
                          minutes: minutes < 60
                              ? '$minutes min'
                              : '${minutes ~/ 60} hora${minutes >= 120 ? 's' : ''}',
                      },
                      onChanged: (value) => settings.reminderMinutes = value,
                    ),
                    _DropdownRow<String>(
                      icon: Icons.payments_outlined,
                      title: 'Moneda de los importes',
                      value: settings.currency,
                      items: {
                        for (final code in SettingsStore.currencyOptions)
                          code: code,
                      },
                      onChanged: (value) => settings.currency = value,
                    ),
                    _SwitchRow(
                      icon: Icons.view_agenda_outlined,
                      title: 'Listado compacto',
                      subtitle: 'Muestra más citas por pantalla',
                      value: settings.compactList,
                      onChanged: (value) => settings.compactList = value,
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                const _SectionLabel('Cuenta'),
                const SizedBox(height: 10),
                _Card(
                  children: [
                    _NavRow(
                      icon: Icons.edit_outlined,
                      title: 'Editar información',
                      subtitle: profile.fullName,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      ),
                    ),
                    _NavRow(
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

                OutlinedButton.icon(
                  onPressed: () => _confirmRestore(context),
                  icon: const Icon(Icons.settings_backup_restore, size: 19),
                  label: const Text('Restaurar valores por defecto'),
                ),
                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: () => confirmAndSignOut(context),
                  icon: const Icon(Icons.logout_rounded, size: 19),
                  label: const Text('Cerrar sesión'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    'Gestor Inmobiliario · versión 0.1.0',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmRestore(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final shouldRestore = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        title: const Text('Restaurar configuración'),
        content: const Text(
          'Se devolverán todas las preferencias a sus valores por defecto.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (shouldRestore != true) return;
    SettingsStore.instance.restoreDefaults();
    messenger.showSnackBar(
      const SnackBar(content: Text('Configuración restaurada.')),
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

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
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

class _RowIcon extends StatelessWidget {
  const _RowIcon(this.icon, {this.enabled = true});

  final IconData icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      width: 38,
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(
        icon,
        size: 19,
        color: enabled ? AppColors.graphite : AppColors.textSecondary,
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      secondary: _RowIcon(icon),
      activeThumbColor: Colors.white,
      activeTrackColor: AppColors.graphite,
      title: Text(
        title,
        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    );
  }
}

class _DropdownRow<T> extends StatelessWidget {
  const _DropdownRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      leading: _RowIcon(icon, enabled: enabled),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
      trailing: DropdownButton<T>(
        value: value,
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(12),
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        items: items.entries
            .map(
              (entry) => DropdownMenuItem<T>(
                value: entry.key,
                child: Text(entry.value),
              ),
            )
            .toList(),
        onChanged: enabled
            ? (selected) {
                if (selected != null) onChanged(selected);
              }
            : null,
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      leading: _RowIcon(icon),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: AppColors.textSecondary,
      ),
    );
  }
}
