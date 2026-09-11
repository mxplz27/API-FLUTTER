import 'package:flutter/material.dart';

import '../../../../../core/state/agenda_store.dart';
import '../../../../../core/theme/app_theme.dart';
import 'tatus_badge.dart';

/// Tarjeta de una cita de la agenda, con acciones rápidas.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.appointment,
    required this.onEdit,
    required this.onToggleDone,
    required this.onCancel,
    required this.onDelete,
    this.compact = false,
  });

  final Appointment appointment;
  final VoidCallback onEdit;
  final VoidCallback onToggleDone;
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final bool compact;

  static IconData iconForType(AppointmentType type) {
    return switch (type) {
      AppointmentType.visit => Icons.meeting_room_outlined,
      AppointmentType.signing => Icons.draw_outlined,
      AppointmentType.call => Icons.phone_in_talk_outlined,
      AppointmentType.appraisal => Icons.straighten_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDone = appointment.status == AppointmentStatus.done;
    final isCancelled = appointment.status == AppointmentStatus.cancelled;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: AppColors.surface,
        child: InkWell(
          onTap: onEdit,
          child: Padding(
            padding: EdgeInsets.all(compact ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Franja de hora
                    Container(
                      width: 58,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.field,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Text(
                            formatTime(appointment.dateTime),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Icon(
                            iconForType(appointment.type),
                            size: 15,
                            color: AppColors.copper,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.title,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              decoration: isDone || isCancelled
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            appointment.client,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (appointment.property.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 13,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    appointment.property,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StatusBadge.appointment(appointment.status),
                        _ActionsMenu(
                          isDone: isDone,
                          isCancelled: isCancelled,
                          onEdit: onEdit,
                          onToggleDone: onToggleDone,
                          onCancel: onCancel,
                          onDelete: onDelete,
                        ),
                      ],
                    ),
                  ],
                ),

                if (!compact && appointment.notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.field,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      appointment.notes,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionsMenu extends StatelessWidget {
  const _ActionsMenu({
    required this.isDone,
    required this.isCancelled,
    required this.onEdit,
    required this.onToggleDone,
    required this.onCancel,
    required this.onDelete,
  });

  final bool isDone;
  final bool isCancelled;
  final VoidCallback onEdit;
  final VoidCallback onToggleDone;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Acciones',
      icon: const Icon(
        Icons.more_horiz_rounded,
        size: 20,
        color: AppColors.textSecondary,
      ),
      padding: EdgeInsets.zero,
      onSelected: (value) {
        switch (value) {
          case 'done':
            onToggleDone();
          case 'edit':
            onEdit();
          case 'cancel':
            onCancel();
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'done',
          child: Row(
            children: [
              Icon(
                isDone
                    ? Icons.radio_button_unchecked
                    : Icons.check_circle_outline,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(isDone ? 'Marcar pendiente' : 'Marcar completada'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18),
              SizedBox(width: 10),
              Text('Editar'),
            ],
          ),
        ),
        if (!isCancelled)
          const PopupMenuItem(
            value: 'cancel',
            child: Row(
              children: [
                Icon(Icons.event_busy_outlined, size: 18),
                SizedBox(width: 10),
                Text('Cancelar cita'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18, color: AppColors.error),
              SizedBox(width: 10),
              Text('Eliminar', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }
}
