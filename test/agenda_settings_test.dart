import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/core/api/api_client.dart';
import 'package:flutter_application_2/core/state/settings_store.dart';
import 'package:flutter_application_2/core/state/user_store.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/features/auth/agenda/presentation/pages/agenda_list_page.dart';
import 'package:flutter_application_2/features/auth/agenda/presentation/pages/property_sales_page.dart';
import 'package:flutter_application_2/features/auth/agenda/presentation/widgets/task_card.dart';
import 'package:flutter_application_2/features/auth/data/presentation/pages/login_page.dart';
import 'package:flutter_application_2/features/auth/data/presentation/pages/settings_page.dart';
import 'package:flutter_application_2/main.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'support/fake_api.dart';

void usePhone(WidgetTester tester, {Size size = const Size(400, 900)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Widget wrap(Widget home) => MaterialApp(theme: AppTheme.light, home: home);

/// Texto dentro de una tarjeta del listado (la tarjeta "Próxima cita"
/// también puede mostrar el mismo título).
Finder inCard(String text) =>
    find.descendant(of: find.byType(TaskCard), matching: find.text(text));

String isoIn(Duration offset) =>
    DateTime.now().add(offset).toUtc().toIso8601String();

void main() {
  late FakeApi api;
  late Map<String, dynamic> user;

  setUp(() async {
    api = await installFakeApi();
    user = await signInDemoUser(api);
  });

  void seedTasks() {
    api.addTask(user, {
      'title': 'Visita con familia Gómez',
      'client': 'María Gómez',
      'property': 'Apartamento Torre Vista 802',
      'dateTime': isoIn(const Duration(days: 1)),
    });
    api.addTask(user, {
      'title': 'Avalúo comercial',
      'client': 'Banco Central',
      'property': 'Casa Los Almendros 21',
      'dateTime': isoIn(const Duration(days: -1)),
      'type': 'appraisal',
      'status': 'done',
    });
  }

  testWidgets('sin sesion guardada la app aterriza en el login', (
    tester,
  ) async {
    usePhone(tester);
    await UserStore.instance.logout();
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
  });

  testWidgets('con sesion guardada ("Recordarme") abre el panel', (
    tester,
  ) async {
    usePhone(tester);
    // Simula reabrir la app: el token solo queda en el almacenamiento.
    ApiClient.instance.token = null;
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(PropertySalesPage), findsOneWidget);
    expect(UserStore.instance.profile.fullName, 'Aprendiz SENA');
  });

  testWidgets('la agenda carga las citas de la API y filtra por estado', (
    tester,
  ) async {
    usePhone(tester);
    seedTasks();
    await tester.pumpWidget(wrap(const AgendaListPage()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    expect(inCard('Visita con familia Gómez'), findsOneWidget);
    expect(inCard('Avalúo comercial'), findsOneWidget);

    final chip = find.text('Completadas');
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pumpAndSettle();

    expect(inCard('Avalúo comercial'), findsOneWidget);
    expect(inCard('Visita con familia Gómez'), findsNothing);
  });

  testWidgets('el formulario de agenda crea la cita en la API', (tester) async {
    usePhone(tester, size: const Size(400, 1400));

    await tester.pumpWidget(wrap(const AgendaListPage()));
    await tester.pumpAndSettle();
    expect(find.text('Tu agenda está vacía.'), findsOneWidget);

    await tester.tap(find.text('Nueva cita'), warnIfMissed: false);
    await tester.pumpAndSettle();

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Entrega de llaves');
    await tester.enterText(campos.at(1), 'Pedro Salas');
    await tester.enterText(campos.at(2), 'Apartamento Mirador 301');

    final guardar = find.text('Agendar cita');
    await tester.ensureVisible(guardar);
    await tester.pumpAndSettle();
    await tester.tap(guardar);
    await tester.pumpAndSettle();

    expect(api.tasks, hasLength(1));
    expect(api.tasks.single['title'], 'Entrega de llaves');
    expect(api.tasks.single['client'], 'Pedro Salas');
    expect(api.tasks.single['type'], 'visit');
    expect(inCard('Entrega de llaves'), findsOneWidget);
  });

  testWidgets('marcar completada y eliminar actualizan la API', (tester) async {
    usePhone(tester);
    seedTasks();
    await tester.pumpWidget(wrap(const AgendaListPage()));
    await tester.pumpAndSettle();

    final visitCard = find.ancestor(
      of: inCard('Visita con familia Gómez'),
      matching: find.byType(TaskCard),
    );
    await tester.tap(
      find.descendant(
        of: visitCard,
        matching: find.byIcon(Icons.more_horiz_rounded),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marcar completada'));
    await tester.pumpAndSettle();

    expect(api.tasks.first['status'], 'done');

    await tester.tap(
      find.descendant(
        of: visitCard,
        matching: find.byIcon(Icons.more_horiz_rounded),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();

    expect(api.tasks, hasLength(1));
    expect(inCard('Visita con familia Gómez'), findsNothing);
    expect(find.text('Cita eliminada.'), findsOneWidget);
  });

  testWidgets('sin conexion la agenda muestra el error y permite reintentar', (
    tester,
  ) async {
    usePhone(tester);
    ApiClient.instance.configure(
      client: MockClient((_) async => throw http.ClientException('offline')),
    );

    await tester.pumpWidget(wrap(const AgendaListPage()));
    await tester.pumpAndSettle();

    expect(
      find.text('No se pudo conectar con el servidor. Revisa tu conexión.'),
      findsOneWidget,
    );
    expect(find.text('Reintentar'), findsOneWidget);

    seedTasks();
    ApiClient.instance.configure(client: api.client);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Reintentar'), findsNothing);
    expect(inCard('Visita con familia Gómez'), findsOneWidget);
  });

  testWidgets('configuracion guarda preferencias y restaura', (tester) async {
    usePhone(tester, size: const Size(400, 1400));
    SettingsStore.instance.restoreDefaults();

    await tester.pumpWidget(wrap(const SettingsPage()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final resumen = find.widgetWithText(
      SwitchListTile,
      'Resumen semanal de ventas',
    );
    await tester.ensureVisible(resumen);
    await tester.pumpAndSettle();
    await tester.tap(resumen);
    await tester.pumpAndSettle();
    expect(SettingsStore.instance.weeklySummary, isTrue);

    final restaurar = find.text('Restaurar valores por defecto');
    await tester.ensureVisible(restaurar);
    await tester.pumpAndSettle();
    await tester.tap(restaurar);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Restaurar'));
    await tester.pumpAndSettle();

    expect(SettingsStore.instance.weeklySummary, isFalse);
  });
}
