import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/core/state/sales_store.dart';
import 'package:flutter_application_2/core/state/user_store.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/features/auth/agenda/presentation/pages/property_sales_page.dart';
import 'package:flutter_application_2/features/auth/data/presentation/pages/forgot_password.dart';
import 'package:flutter_application_2/features/auth/data/presentation/pages/login_page.dart';
import 'package:flutter_application_2/features/auth/data/presentation/pages/singup_page.dart';

import 'support/fake_api.dart';

/// Tamano de un telefono estrecho: aqui es donde aparecen los desbordes.
void useNarrowPhone(WidgetTester tester, {double height = 780}) {
  tester.view.physicalSize = Size(360, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Widget wrap(Widget home) => MaterialApp(theme: AppTheme.light, home: home);

void main() {
  late FakeApi api;

  setUp(() async {
    api = await installFakeApi();
  });

  testWidgets('login se renderiza sin desbordes en movil estrecho', (
    tester,
  ) async {
    useNarrowPhone(tester);
    await tester.pumpWidget(wrap(const LoginPage()));
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('login con credenciales validas abre el panel', (tester) async {
    useNarrowPhone(tester);
    api.addUser(email: 'asesor@inmobiliaria.com', password: 'secreta123');

    await tester.pumpWidget(wrap(const LoginPage()));
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'asesor@inmobiliaria.com');
    await tester.enterText(fields.at(1), 'secreta123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.byType(PropertySalesPage), findsOneWidget);
    expect(UserStore.instance.isAuthenticated, isTrue);
  });

  testWidgets('login con contrasena incorrecta muestra el error de la API', (
    tester,
  ) async {
    useNarrowPhone(tester);
    api.addUser(email: 'asesor@inmobiliaria.com', password: 'secreta123');

    await tester.pumpWidget(wrap(const LoginPage()));
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'asesor@inmobiliaria.com');
    await tester.enterText(fields.at(1), 'otra-clave');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Correo o contraseña incorrectos'), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('registro se renderiza sin desbordes y valida', (tester) async {
    useNarrowPhone(tester);
    await tester.pumpWidget(wrap(const SingupPage()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Sin aceptar terminos no debe registrar.
    final boton = find.text('Crear cuenta').last;
    await tester.ensureVisible(boton);
    await tester.pumpAndSettle();
    await tester.tap(boton);
    await tester.pumpAndSettle();
    expect(
      find.text('Debes aceptar los términos y la política de datos.'),
      findsOneWidget,
    );
  });

  testWidgets('registro crea la cuenta en la API', (tester) async {
    useNarrowPhone(tester, height: 1600);
    await tester.pumpWidget(wrap(const SingupPage()));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Ana Martínez');
    await tester.enterText(fields.at(1), 'ana@inmobiliaria.com');
    await tester.enterText(fields.at(2), '3001234567');
    await tester.enterText(fields.at(3), 'secreta123');
    await tester.enterText(fields.at(4), 'secreta123');
    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.text('Crear cuenta').last);
    await tester.pumpAndSettle();

    expect(api.passwordFor('ana@inmobiliaria.com'), 'secreta123');
  });

  testWidgets('recuperar contrasena envia el codigo y restablece la clave', (
    tester,
  ) async {
    useNarrowPhone(tester, height: 1400);
    api.addUser(email: 'asesor@inmobiliaria.com', password: 'vieja123');

    await tester.pumpWidget(wrap(const ForgotPasswordPage()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.enterText(
      find.byType(TextFormField),
      'asesor@inmobiliaria.com',
    );
    await tester.tap(find.text('Enviar código'));
    await tester.pumpAndSettle();

    expect(find.text('Revisa tu correo'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), api.lastResetCode!);
    await tester.enterText(fields.at(1), 'nueva1234');
    await tester.enterText(fields.at(2), 'nueva1234');
    await tester.tap(find.text('Restablecer contraseña'));
    await tester.pumpAndSettle();

    expect(api.passwordFor('asesor@inmobiliaria.com'), 'nueva1234');
  });

  testWidgets('registrar una venta la anade al historial', (tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final antes = SalesStore.instance.totalCount;
    await tester.pumpWidget(wrap(const PropertySalesPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ventas y Propiedades'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Andrea Ruiz');
    await tester.enterText(fields.at(1), 'Casa Los Cedros 12');
    await tester.enterText(fields.at(2), '450000000');
    await tester.tap(find.text('Registrar venta / asignar propiedad'));
    await tester.pumpAndSettle();

    expect(SalesStore.instance.totalCount, antes + 1);
    expect(find.text('Casa Los Cedros 12'), findsOneWidget);
    expect(find.text('\$ 450.000.000'), findsOneWidget);
  });
}
