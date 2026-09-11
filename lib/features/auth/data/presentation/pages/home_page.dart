import 'package:flutter/material.dart';

import '../../../agenda/presentation/pages/property_sales_page.dart';

/// El panel real de la aplicación es [PropertySalesPage], que incluye Perfil,
/// Agenda, Ventas y Configuración. Este archivo se conserva como alias para
/// no romper navegaciones existentes hacia `HomePage`.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const PropertySalesPage();
}
