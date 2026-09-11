import 'package:flutter/foundation.dart';

import '../api/api_client.dart';

/// Tipo de gestión agendada por el asesor.
enum AppointmentType {
  visit('Visita a inmueble'),
  signing('Firma de contrato'),
  call('Llamada de seguimiento'),
  appraisal('Avalúo / peritaje');

  const AppointmentType(this.label);

  final String label;

  static AppointmentType fromApi(String? value) => AppointmentType.values
      .firstWhere((type) => type.name == value, orElse: () => visit);
}

enum AppointmentStatus {
  pending('Pendiente'),
  done('Completada'),
  cancelled('Cancelada');

  const AppointmentStatus(this.label);

  final String label;

  static AppointmentStatus fromApi(String? value) => AppointmentStatus.values
      .firstWhere((status) => status.name == value, orElse: () => pending);
}

/// Una cita de la agenda (una "tarea" en la API).
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

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      client: json['client'] as String? ?? '',
      property: json['property'] as String? ?? '',
      // La API guarda UTC; la agenda se muestra en la hora local.
      dateTime: DateTime.parse(json['dateTime'] as String).toLocal(),
      type: AppointmentType.fromApi(json['type'] as String?),
      status: AppointmentStatus.fromApi(json['status'] as String?),
      notes: json['notes'] as String? ?? '',
    );
  }

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

  Map<String, dynamic> toJson() => {
    'title': title,
    'client': client,
    'property': property,
    'dateTime': dateTime.toUtc().toIso8601String(),
    'type': type.name,
    'status': status.name,
    'notes': notes,
  };

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

/// Agenda del asesor sincronizada con la API REST (/api/tasks).
class AgendaStore extends ChangeNotifier {
  AgendaStore._();

  static final AgendaStore instance = AgendaStore._();

  final ApiClient _api = ApiClient.instance;

  final List<Appointment> _appointments = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _error;

  bool get isLoading => _isLoading;

  /// Si ya se consultó la API al menos una vez en esta sesión.
  bool get hasLoaded => _hasLoaded;

  /// Mensaje del último fallo al cargar, o nulo.
  String? get error => _error;

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

  /// GET /tasks: trae todas las citas del usuario.
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.get('/tasks') as List<dynamic>;
      _appointments
        ..clear()
        ..addAll(
          data.map(
            (item) => Appointment.fromJson(item as Map<String, dynamic>),
          ),
        );
      _hasLoaded = true;
    } on ApiException catch (error) {
      _error = error.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// POST /tasks
  Future<Appointment> add({
    required String title,
    required String client,
    required String property,
    required DateTime dateTime,
    required AppointmentType type,
    AppointmentStatus status = AppointmentStatus.pending,
    String notes = '',
  }) async {
    final draft = Appointment(
      id: '',
      title: title,
      client: client,
      property: property,
      dateTime: dateTime,
      type: type,
      status: status,
      notes: notes,
    );
    final data = await _api.post('/tasks', draft.toJson());
    final created = Appointment.fromJson(data as Map<String, dynamic>);
    _appointments.add(created);
    notifyListeners();
    return created;
  }

  /// PUT /tasks/:id
  Future<void> update(Appointment updated) async {
    final data = await _api.put('/tasks/${updated.id}', updated.toJson());
    _replace(Appointment.fromJson(data as Map<String, dynamic>));
  }

  /// PATCH /tasks/:id/status
  Future<void> setStatus(String id, AppointmentStatus status) async {
    final data = await _api.patch('/tasks/$id/status', {'status': status.name});
    _replace(Appointment.fromJson(data as Map<String, dynamic>));
  }

  /// DELETE /tasks/:id
  Future<void> remove(String id) async {
    await _api.delete('/tasks/$id');
    _appointments.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  /// Vacía la agenda al cerrar sesión.
  void clear() {
    _appointments.clear();
    _hasLoaded = false;
    _error = null;
    notifyListeners();
  }

  void _replace(Appointment updated) {
    final index = _appointments.indexWhere((item) => item.id == updated.id);
    if (index == -1) {
      _appointments.add(updated);
    } else {
      _appointments[index] = updated;
    }
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
