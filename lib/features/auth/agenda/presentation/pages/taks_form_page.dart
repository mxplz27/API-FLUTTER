import 'package:flutter/material.dart';

import '../../../../../core/state/agenda_store.dart';
import '../../../../../core/state/sales_store.dart' show formatDate;
import '../../../../../core/theme/app_theme.dart';
import '../../../data/presentation/widgets/auth_widgets.dart';
import '../widgets/task_card.dart';

/// Alta y edición de una cita de la agenda.
/// Si [appointment] es nulo se crea una nueva.
class TaskFormPage extends StatefulWidget {
  const TaskFormPage({super.key, this.appointment});

  final Appointment? appointment;

  bool get isEditing => appointment != null;

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _clientController;
  late final TextEditingController _propertyController;
  late final TextEditingController _notesController;

  late AppointmentType _type;
  late AppointmentStatus _status;
  late DateTime _date;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    final appointment = widget.appointment;
    final start =
        appointment?.dateTime ??
        DateTime.now().add(const Duration(hours: 1));

    _titleController = TextEditingController(text: appointment?.title ?? '');
    _clientController = TextEditingController(text: appointment?.client ?? '');
    _propertyController = TextEditingController(
      text: appointment?.property ?? '',
    );
    _notesController = TextEditingController(text: appointment?.notes ?? '');
    _type = appointment?.type ?? AppointmentType.visit;
    _status = appointment?.status ?? AppointmentStatus.pending;
    _date = DateTime(start.year, start.month, start.day);
    _time = TimeOfDay(hour: start.hour, minute: start.minute);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _clientController.dispose();
    _propertyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      helpText: 'Fecha de la cita',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      helpText: 'Hora de la cita',
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final dateTime = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );

    final store = AgendaStore.instance;
    final existing = widget.appointment;

    if (existing == null) {
      store.add(
        title: _titleController.text.trim(),
        client: _clientController.text.trim(),
        property: _propertyController.text.trim(),
        dateTime: dateTime,
        type: _type,
        status: _status,
        notes: _notesController.text.trim(),
      );
    } else {
      store.update(
        existing.copyWith(
          title: _titleController.text.trim(),
          client: _clientController.text.trim(),
          property: _propertyController.text.trim(),
          dateTime: dateTime,
          type: _type,
          status: _status,
          notes: _notesController.text.trim(),
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existing == null ? 'Cita agendada.' : 'Cita actualizada.',
        ),
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar cita' : 'Nueva cita'),
      ),
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
                      'Datos de la gestión',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Agenda visitas, firmas, llamadas y avalúos.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    AuthTextField(
                      label: 'Título de la cita',
                      controller: _titleController,
                      hintText: 'Ej. Visita con familia Gómez',
                      prefixIcon: Icons.event_note_outlined,
                      validator: (value) =>
                          AuthValidators.notEmpty(value, 'Ingresa un título'),
                    ),
                    const SizedBox(height: 18),

                    AuthTextField(
                      label: 'Cliente',
                      controller: _clientController,
                      hintText: 'Ej. María Gómez',
                      prefixIcon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.name,
                      validator: (value) =>
                          AuthValidators.notEmpty(value, 'Ingresa el cliente'),
                    ),
                    const SizedBox(height: 18),

                    AuthTextField(
                      label: 'Propiedad',
                      controller: _propertyController,
                      hintText: 'Ej. Casa Campestre Lote 45',
                      prefixIcon: Icons.location_city_outlined,
                      validator: (value) => AuthValidators.notEmpty(
                        value,
                        'Ingresa la propiedad',
                      ),
                    ),
                    const SizedBox(height: 18),

                    _FieldLabel('Tipo de gestión'),
                    DropdownButtonFormField<AppointmentType>(
                      initialValue: _type,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.category_outlined, size: 20),
                      ),
                      items: AppointmentType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    TaskCard.iconForType(type),
                                    size: 17,
                                    color: AppColors.copper,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      type.label,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _type = value ?? _type),
                    ),
                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: _PickerField(
                            label: 'Fecha',
                            icon: Icons.calendar_today_outlined,
                            value: formatDate(_date),
                            onTap: _pickDate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PickerField(
                            label: 'Hora',
                            icon: Icons.schedule_outlined,
                            value: _time.format(context),
                            onTap: _pickTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    _FieldLabel('Estado'),
                    DropdownButtonFormField<AppointmentStatus>(
                      initialValue: _status,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.flag_outlined, size: 20),
                      ),
                      items: AppointmentStatus.values
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _status = value ?? _status),
                    ),
                    const SizedBox(height: 18),

                    _FieldLabel('Notas (opcional)'),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: 'Documentos a llevar, acuerdos, recordatorios…',
                      ),
                    ),
                    const SizedBox(height: 28),

                    AuthPrimaryButton(
                      label: widget.isEditing
                          ? 'Guardar cambios'
                          : 'Agendar cita',
                      icon: Icons.check_rounded,
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Campo de solo lectura que abre un selector al pulsarlo.
class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusField),
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20),
              suffixIcon: const Icon(Icons.expand_more_rounded, size: 20),
            ),
            child: Text(value, style: const TextStyle(fontSize: 15)),
          ),
        ),
      ],
    );
  }
}
