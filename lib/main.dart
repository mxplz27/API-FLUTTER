import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/data/presentation/pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestor Inmobiliario',
      theme: AppTheme.light,
      home: const LoginPage(),
    );
  }
}
