import 'package:flutter/material.dart';

import '../../../../../core/api/api_client.dart';
import '../../../../../core/state/agenda_store.dart';
import '../../../../../core/state/settings_store.dart';
import '../../../../../core/theme/app_theme.dart';
import '../widgets/task_card.dart';
import 'taks_form_page.dart';

/// Filtros disponibles sobre el listado de citas.
enum AgendaFilter {
  all('Todas'),
  today('Hoy'),
  pending('Pendientes'),
  done('Completadas');

  const AgendaFilter(this.label);

  final String label;
}

/// Agenda como pantalla completa.
class AgendaListPage extends StatelessWidget {
  const AgendaListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SafeArea(child: AgendaView(showTitle: true)));
  }
}

/// Agenda reutilizable: listado agrupado por día, filtros y alta de citas.
class AgendaView extends StatefulWidget {
  const AgendaView({super.key, this.showTitle = true});

  final bool showTitle;

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  AgendaFilter _filter = AgendaFilter.all;

  @override
  void initState() {
    super.initState();
    AgendaStore.instance.load();
  }

  /// Ejecuta una acción contra la API y avisa si falla.
  Future<void> _run(Future<void> Function() action, {String? success}) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      if (success != null) {
        messenger.showSnackBar(SnackBar(content: Text(success)));
      }
    } on ApiException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _openForm({Appointment? appointment}) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormPage(appointment: appointment),
      ),
    );
  }

  Future<void> _confirmDelete(Appointment appointment) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        title: const Text('Eliminar cita'),
        content: Text('Se eliminará "${appointment.title}" de tu agenda.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;
    await _run(
      () => AgendaStore.instance.remove(appointment.id),
      success: 'Cita eliminada.',
    );
  }

  List<Appointment> _applyFilter(List<Appointment> all) {
    final now = DateTime.now();
    final todayDay = DateTime(now.year, now.month, now.day);

    return switch (_filter) {
      AgendaFilter.all => all,
      AgendaFilter.today => all.where((item) => item.day == todayDay).toList(),
      AgendaFilter.pending => all.where((item) => item.isPending).toList(),
      AgendaFilter.done =>
        all.where((item) => item.status == AppointmentStatus.done).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final store = AgendaStore.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([store, SettingsStore.instance]),
      builder: (context, _) {
        final visible = _applyFilter(store.appointments);
        final compact = SettingsStore.instance.compactList;

        return Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.maxContentWidth,
                ),
                child: RefreshIndicator(
                  onRefresh: store.load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                    children: [
                      if (widget.showTitle) ...[
                        const Text(
                          'Agenda',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tus visitas, firmas y seguimientos.',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],

                      _NextAppointmentCard(appointment: store.nextAppointment),
                      const SizedBox(height: 18),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: AgendaFilter.values.map((filter) {
                            final isSelected = _filter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(filter.label),
                                selected: isSelected,
                                showCheckmark: false,
                                onSelected: (_) =>
                                    setState(() => _filter = filter),
                                labelStyle: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                                backgroundColor: AppColors.field,
                                selectedColor: AppColors.graphite,
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.graphite
                                      : AppColors.border,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (store.error != null) ...[
                        _LoadError(message: store.error!, onRetry: store.load),
                        const SizedBox(height: 16),
                      ],

                      if (store.isLoading && !store.hasLoaded)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (visible.isEmpty && store.hasLoaded)
                        _EmptyAgenda(filter: _filter)
                      else
                        ..._buildGroupedList(visible, compact),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton.extended(
                onPressed: _openForm,
                backgroundColor: AppColors.graphite,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Nueva cita'),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Inserta una cabecera por cada día del listado.
  List<Widget> _buildGroupedList(List<Appointment> items, bool compact) {
    final widgets = <Widget>[];
    DateTime? currentDay;

    for (final appointment in items) {
      if (currentDay != appointment.day) {
        currentDay = appointment.day;
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: widgets.isEmpty ? 0 : 10, bottom: 10),
            child: Row(
              children: [
                Text(
                  formatDayLabel(appointment.day),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(child: Divider(height: 1)),
              ],
            ),
          ),
        );
      }

      widgets.add(
        TaskCard(
          appointment: appointment,
          compact: compact,
          onEdit: () => _openForm(appointment: appointment),
          onToggleDone: () => _run(
            () => AgendaStore.instance.setStatus(
              appointment.id,
              appointment.status == AppointmentStatus.done
                  ? AppointmentStatus.pending
                  : AppointmentStatus.done,
            ),
          ),
          onCancel: () => _run(
            () => AgendaStore.instance.setStatus(
              appointment.id,
              AppointmentStatus.cancelled,
            ),
          ),
          onDelete: () => _confirmDelete(appointment),
        ),
      );
    }

    return widgets;
  }
}

/// Resalta la siguiente cita pendiente.
class _NextAppointmentCard extends StatelessWidget {
  const _NextAppointmentCard({required this.appointment});

  final Appointment? appointment;

  @override
  Widget build(BuildContext context) {
    final next = appointment;

    return Container(
      padding: const EdgeInsets.all(18),
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
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: AppColors.copperSoft.withValues(alpha: 0.5),
              ),
            ),
            child: Icon(
              next == null
                  ? Icons.event_available_outlined
                  : TaskCard.iconForType(next.type),
              color: AppColors.copperSoft,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PRÓXIMA CITA',
                  style: TextStyle(
                    color: AppColors.copperSoft,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  next?.title ?? 'No tienes citas pendientes',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (next != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${formatDayLabel(next.day)} · ${formatTime(next.dateTime)} · ${next.client}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Aviso cuando la agenda no se pudo cargar desde la API.
class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 20, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

class _EmptyAgenda extends StatelessWidget {
  const _EmptyAgenda({required this.filter});

  final AgendaFilter filter;

  @override
  Widget build(BuildContext context) {
    final message = switch (filter) {
      AgendaFilter.today => 'No tienes citas para hoy.',
      AgendaFilter.pending => 'No tienes citas pendientes.',
      AgendaFilter.done => 'Aún no has completado citas.',
      AgendaFilter.all => 'Tu agenda está vacía.',
    };

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_note_outlined,
            size: 38,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Usa "Nueva cita" para agendar una gestión.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
