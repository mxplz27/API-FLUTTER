import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/core/widgets/app_tab_bar.dart';
import 'package:flutter_application_2/features/auth/agenda/presentation/pages/property_sales_page.dart';

import 'support/fake_api.dart';

void main() {
  setUp(() async {
    final api = await installFakeApi();
    await signInDemoUser(api);
  });

  Future<void> pumpDashboard(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const PropertySalesPage()),
    );
    await tester.pumpAndSettle();
  }

  void expectSelected(WidgetTester tester, String label, bool selected) {
    final tab = find.descendant(
      of: find.byType(AppTabBar),
      matching: find.bySemanticsLabel(label),
    );
    expect(
      tester.getSemantics(tab),
      isSemantics(isButton: true, isSelected: selected),
    );
  }

  testWidgets('el panel abre en Agenda y cambia de seccion con el tab bar', (
    tester,
  ) async {
    await pumpDashboard(tester, const Size(360, 780));
    expect(tester.takeException(), isNull);

    expect(find.text('Tus visitas, firmas y seguimientos.'), findsOneWidget);
    expectSelected(tester, 'Agenda', true);

    await tester.tap(find.text('Ventas'));
    await tester.pumpAndSettle();
    expect(find.text('Ventas e inmuebles'), findsOneWidget);
    expectSelected(tester, 'Ventas', true);
    expectSelected(tester, 'Agenda', false);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Editar información'), findsOneWidget);

    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
    expect(find.text('Configuración'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cada pestana conserva su estado al volver a ella', (
    tester,
  ) async {
    await pumpDashboard(tester, const Size(390, 1400));

    await tester.tap(find.text('Ventas'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Andrea Ruiz');

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ventas'));
    await tester.pumpAndSettle();

    expect(find.text('Andrea Ruiz'), findsOneWidget);
  });

  testWidgets('en pantalla ancha (web) el tab bar mantiene ancho de telefono', (
    tester,
  ) async {
    await pumpDashboard(tester, const Size(1400, 900));
    expect(tester.takeException(), isNull);

    final agenda = tester.getCenter(find.text('Agenda').last);
    final ajustes = tester.getCenter(find.text('Ajustes'));
    expect(ajustes.dx - agenda.dx, lessThan(520));
    expect(tester.getBottomLeft(find.byType(AppTabBar)).dy, 900);
  });
}
