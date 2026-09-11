import 'package:flutter/foundation.dart';

/// Tipo de gestión agendada por el asesor.
enum AppointmentType {
  visit('Visita a inmueble'),
  signing('Firma de contrato'),
  call('Llamada de seguimiento'),
  appraisal('Avalúo / peritaje');

  const AppointmentType(this.label);

  final String label;
}

enum AppointmentStatus {
  pending('Pendiente'),
  done('Completada'),
  cancelled('Cancelada');

  const AppointmentStatus(this.label);

  final String label;
}

/// Una cita de la agenda.
@immutable
class Appointment {
  const Appointment({
    required this.id,
    required this.title,
    required this.client,
    required this.property,
    required this.dateTime,
    required this.type,
    required this.status,
    this.notes = '',
  });

  final String id;
  final String title;
  final String client;
  final String property;
  final DateTime dateTime;
  final AppointmentType type;
  final AppointmentStatus status;
  final String notes;

  /// Día sin hora, para agrupar el listado.
  DateTime get day => DateTime(dateTime.year, dateTime.month, dateTime.day);

  bool get isPending => status == AppointmentStatus.pending;

  Appointment copyWith({
    String? title,
    String? client,
    String? property,
    DateTime? dateTime,
    AppointmentType? type,
    AppointmentStatus? status,
    String? notes,
  }) {
    return Appointment(
      id: id,
      title: title ?? this.title,
      client: client ?? this.client,
      property: property ?? this.property,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

/// Store en memoria de la agenda. Se reemplazará por la API cuando exista.
class AgendaStore extends ChangeNotifier {
  AgendaStore._();

  static final AgendaStore instance = AgendaStore._();

  int _nextId = 1;

  late final List<Appointment> _appointments = _seed();

  List<Appointment> _seed() {
    final today = DateTime.now();
    DateTime at(int daysFromNow, int hour, int minute) => DateTime(
      today.year,
      today.month,
      today.day + daysFromNow,
      hour,
      minute,
    );

    return [
      Appointment(
        id: 'A-${_nextId++}',
        title: 'Visita con familia Gómez',
        client: 'María Gómez',
        property: 'Apartamento Torre Vista 802',
        dateTime: at(0, 10, 30),
        type: AppointmentType.visit,
        status: AppointmentStatus.pending,
        notes: 'Confirmar parqueadero de visitantes.',
      ),
      Appointment(
        id: 'A-${_nextId++}',
        title: 'Firma de promesa de compraventa',
        client: 'Carlos Rendón',
        property: 'Casa Campestre Lote 45',
        dateTime: at(1, 9, 0),
        type: AppointmentType.signing,
        status: AppointmentStatus.pending,
        notes: 'Llevar copia de la escritura y el paz y salvo.',
      ),
      Appointment(
        id: 'A-${_nextId++}',
        title: 'Seguimiento de oferta',
        client: 'Inversiones Del Río S.A.S.',
        property: 'Local Comercial Plaza Norte',
        dateTime: at(2, 15, 0),
        type: AppointmentType.call,
        status: AppointmentStatus.pending,
      ),
      Appointment(
        id: 'A-${_nextId++}',
        title: 'Avalúo comercial',
        client: 'Banco Central',
        property: 'Casa Los Almendros 21',
        dateTime: at(-1, 11, 0),
        type: AppointmentType.appraisal,
        status: AppointmentStatus.done,
      ),
    ];
  }

  /// Citas ordenadas cronológicamente.
  List<Appointment> get appointments => List.unmodifiable(
    List.of(_appointments)..sort((a, b) => a.dateTime.compareTo(b.dateTime)),
  );

  List<Appointment> get pending =>
      appointments.where((item) => item.isPending).toList();

  List<Appointment> get today {
    final now = DateTime.now();
    final todayDay = DateTime(now.year, now.month, now.day);
    return appointments.where((item) => item.day == todayDay).toList();
  }

  /// Próxima cita pendiente a partir de este momento.
  Appointment? get nextAppointment {
    final now = DateTime.now();
    for (final item in appointments) {
      if (item.isPending && item.dateTime.isAfter(now)) return item;
    }
    return null;
  }

  Appointment add({
    required String title,
    required String client,
    required String property,
    required DateTime dateTime,
    required AppointmentType type,
    AppointmentStatus status = AppointmentStatus.pending,
    String notes = '',
  }) {
    final created = Appointment(
      id: 'A-${_nextId++}',
      title: title,
      client: client,
      property: property,
      dateTime: dateTime,
      type: type,
      status: status,
      notes: notes,
    );
    _appointments.add(created);
    notifyListeners();
    return created;
  }

  void update(Appointment updated) {
    final index = _appointments.indexWhere((item) => item.id == updated.id);
    if (index == -1) return;
    _appointments[index] = updated;
    notifyListeners();
  }

  void setStatus(String id, AppointmentStatus status) {
    final index = _appointments.indexWhere((item) => item.id == id);
    if (index == -1) return;
    _appointments[index] = _appointments[index].copyWith(status: status);
    notifyListeners();
  }

  void remove(String id) {
    _appointments.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}

/// "09:05" en formato de 24 horas.
String formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// "Hoy", "Mañana", "Ayer" o "lun 14 sep" según la cercanía con el día actual.
String formatDayLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  final difference = day.difference(today).inDays;

  if (difference == 0) return 'Hoy';
  if (difference == 1) return 'Mañana';
  if (difference == -1) return 'Ayer';

  const weekdays = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
  const months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  return '${weekdays[day.weekday - 1]} ${day.day} ${months[day.month - 1]}';
}
