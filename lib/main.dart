import 'package:flutter/material.dart';

import 'core/api/api_client.dart';
import 'core/state/user_store.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/agenda/presentation/pages/property_sales_page.dart';
import 'features/auth/data/presentation/pages/login_page.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  // Si el token vence en plena sesión, se cierra y se vuelve al login.
  ApiClient.instance.onUnauthorized = () async {
    await UserStore.instance.logout();
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Gestor Inmobiliario',
      theme: AppTheme.light,
      home: const SessionGate(),
    );
  }
}

/// Abre el panel directamente si hay una sesión guardada ("Recordarme").
class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  late final Future<bool> _restored = UserStore.instance.restoreSession();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _restored,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.graphite,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.copperSoft),
            ),
          );
        }
        return snapshot.data == true
            ? const PropertySalesPage()
            : const LoginPage();
      },
    );
  }
}
