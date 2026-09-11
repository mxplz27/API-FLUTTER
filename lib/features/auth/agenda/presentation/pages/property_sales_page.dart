import 'package:flutter/material.dart';

import '../../../../../core/state/sales_store.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/app_tab_bar.dart';
import '../../../data/presentation/pages/my_sales_page.dart';
import '../../../data/presentation/pages/settings_page.dart';
import '../../../data/presentation/pages/profile_page.dart';
import 'agenda_list_page.dart';

class PropertySalesPage extends StatefulWidget {
  const PropertySalesPage({super.key});

  @override
  State<PropertySalesPage> createState() => _PropertySalesPageState();
}

class _PropertySalesPageState extends State<PropertySalesPage> {
  // 0 = Agenda, 1 = Ventas, 2 = Perfil, 3 = Ajustes
  int _selectedIndex = 0;
  final _formKey = GlobalKey<FormState>();

  static const _tabs = [
    AppTabItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'Agenda',
    ),
    AppTabItem(
      icon: Icons.home_work_outlined,
      activeIcon: Icons.home_work_rounded,
      label: 'Ventas',
    ),
    AppTabItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Perfil',
    ),
    AppTabItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Ajustes',
    ),
  ];

  final _clientController = TextEditingController();
  final _propertyNameController = TextEditingController();
  final _propertyPriceController = TextEditingController();

  String _selectedPropertyType = 'Apartamento';
  SaleStatus _selectedStatus = SaleStatus.closed;

  final List<String> _propertyTypes = [
    'Apartamento',
    'Casa',
    'Terreno / Lote',
    'Local Comercial',
  ];

  @override
  void dispose() {
    _clientController.dispose();
    _propertyNameController.dispose();
    _propertyPriceController.dispose();
    super.dispose();
  }

  void _registerSale() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    // Acepta "250.000.000" o "250000000".
    final price =
        double.tryParse(
          _propertyPriceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;

    SalesStore.instance.addSale(
      client: _clientController.text.trim(),
      propertyName: _propertyNameController.text.trim(),
      propertyType: _selectedPropertyType,
      price: price,
      status: _selectedStatus,
    );

    _clientController.clear();
    _propertyNameController.clear();
    _propertyPriceController.clear();
    setState(() => _selectedStatus = SaleStatus.closed);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Operación registrada y añadida a tus ventas.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        // IndexedStack conserva el estado de cada pestaña (scroll, formularios).
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            const AgendaView(),
            _buildPropertyFormView(),
            const ProfileView(),
            const SettingsView(),
          ],
        ),
      ),
      bottomNavigationBar: AppTabBar(
        items: _tabs,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  // ----------------------------------------------------
  // PESTAÑA VENTAS
  // ----------------------------------------------------
  Widget _buildPropertyFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ventas e inmuebles',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Cada operación registrada aparece en tu perfil, dentro de '
                '"Mis ventas y propiedades".',
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 26),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusCard),
                  border: Border.all(color: AppColors.border),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _clientController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del usuario / comprador',
                          hintText: 'Ej. Juan Pérez',
                          prefixIcon: Icon(Icons.person_search_outlined),
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Ingresa el usuario o comprador'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _propertyNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre / identificador de la propiedad',
                          hintText: 'Ej. Casa Campestre Lote 45',
                          prefixIcon: Icon(Icons.location_city_outlined),
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Ingresa la propiedad'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue: _selectedPropertyType,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de inmueble',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: _propertyTypes
                            .map(
                              (type) => DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        onChanged: (newValue) => setState(
                          () => _selectedPropertyType =
                              newValue ?? _selectedPropertyType,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _propertyPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Valor de venta (\$)',
                          hintText: 'Ej. 250000000',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        validator: (value) {
                          final digits =
                              value?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
                          if (digits.isEmpty) return 'Ingresa el monto';
                          if (int.parse(digits) <= 0) {
                            return 'El monto debe ser mayor a cero';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<SaleStatus>(
                        initialValue: _selectedStatus,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Estado de la operación',
                          prefixIcon: Icon(Icons.flag_outlined),
                        ),
                        items: SaleStatus.values
                            .map(
                              (status) => DropdownMenuItem<SaleStatus>(
                                value: status,
                                child: Text(status.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(
                          () => _selectedStatus = value ?? _selectedStatus,
                        ),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        onPressed: _registerSale,
                        icon: const Icon(Icons.add_home_work_rounded),
                        label: const Text(
                          'Registrar venta / asignar propiedad',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Operaciones registradas',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const SizedBox(height: 620, child: MySalesView()),
            ],
          ),
        ),
      ),
    );
  }
}
