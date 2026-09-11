import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/core/state/agenda_store.dart';
import 'package:flutter_application_2/core/state/settings_store.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/features/auth/agenda/presentation/pages/agenda_list_page.dart';
import 'package:flutter_application_2/features/auth/data/presentation/pages/login_page.dart';
import 'package:flutter_application_2/features/auth/data/presentation/pages/settings_page.dart';
import 'package:flutter_application_2/main.dart';

import 'support/fake_api.dart';

void usePhone(WidgetTester tester, {Size size = const Size(400, 900)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Widget wrap(Widget home) => MaterialApp(theme: AppTheme.light, home: home);

void main() {
  setUp(installFakeApi);

  testWidgets('la app aterriza en el inicio de sesion', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
  });

  testWidgets('la agenda lista citas y filtra por estado', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(wrap(const AgendaListPage()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    expect(find.text('Visita con familia Gómez'), findsOneWidget);
    expect(find.text('Avalúo comercial'), findsOneWidget);

    final chip = find.text('Completadas');
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pumpAndSettle();

    expect(find.text('Avalúo comercial'), findsOneWidget);
    expect(find.text('Visita con familia Gómez'), findsNothing);
  });

  testWidgets('el formulario de agenda crea una cita', (tester) async {
    usePhone(tester, size: const Size(400, 1400));
    final antes = AgendaStore.instance.appointments.length;

    await tester.pumpWidget(wrap(const AgendaListPage()));
    await tester.pumpAndSettle();

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

    expect(AgendaStore.instance.appointments.length, antes + 1);
    expect(find.text('Entrega de llaves'), findsWidgets);
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
