import 'package:flutter/material.dart';

import '../../../../../core/state/agenda_store.dart';
import '../../../../../core/theme/app_theme.dart';

/// Etiqueta de color para el estado de una cita o de una venta.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color});

  /// Construye la etiqueta a partir del estado de una cita de la agenda.
  factory StatusBadge.appointment(AppointmentStatus status, {Key? key}) {
    final color = switch (status) {
      AppointmentStatus.pending => AppColors.copper,
      AppointmentStatus.done => AppColors.success,
      AppointmentStatus.cancelled => AppColors.error,
    };
    return StatusBadge(key: key, label: status.label, color: color);
  }

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
