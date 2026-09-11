import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/core/state/sales_store.dart';
import 'package:flutter_application_2/core/state/user_store.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/features/auth/data/presentation/pages/login_page.dart';
import 'package:flutter_application_2/features/auth/data/presentation/pages/profile_page.dart';

void main() {
  Widget app() => MaterialApp(theme: AppTheme.light, home: const ProfilePage());

  testWidgets('editar informacion guarda y se refleja en el perfil', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app());
    await tester.tap(find.text('Editar información'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Laura Ospina');
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(UserStore.instance.profile.fullName, 'Laura Ospina');
    expect(find.text('Laura Ospina'), findsOneWidget);
  });

  testWidgets('cambiar contrasena valida la actual y la actualiza', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app());
    await tester.tap(find.text('Cambiar contraseña'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'incorrecta');
    await tester.enterText(fields.at(1), 'nueva1234');
    await tester.enterText(fields.at(2), 'nueva1234');
    await tester.tap(find.text('Actualizar contraseña'));
    await tester.pumpAndSettle();

    expect(find.text('La contraseña actual no es correcta'), findsOneWidget);

    await tester.enterText(fields.at(0), '123456');
    await tester.tap(find.text('Actualizar contraseña'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(UserStore.instance.isCurrentPassword('nueva1234'), isTrue);
  });

  testWidgets('mis ventas muestra las operaciones registradas', (tester) async {
    tester.view.physicalSize = const Size(500, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SalesStore.instance.addSale(
      client: 'Cliente Test',
      propertyName: 'Apartamento Test 101',
      propertyType: 'Apartamento',
      price: 100000000,
    );

    await tester.pumpWidget(app());
    await tester.tap(find.text('Mis ventas y propiedades'));
    await tester.pumpAndSettle();

    expect(find.text('Apartamento Test 101'), findsOneWidget);
    expect(find.text('Historial de operaciones'), findsOneWidget);
  });

  testWidgets('cerrar sesion pide confirmacion y vuelve al login', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app());
    await tester.tap(find.byIcon(Icons.logout_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Se cerrará tu sesión y volverás a la pantalla de inicio.'),
        findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Cancelar'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsNothing);

    await tester.tap(find.byIcon(Icons.logout_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });
}
