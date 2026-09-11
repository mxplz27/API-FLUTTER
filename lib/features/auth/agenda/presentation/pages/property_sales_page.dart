import 'package:flutter/material.dart';

import '../../../../../core/state/sales_store.dart';
import '../../../../../core/state/user_store.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../data/presentation/pages/my_sales_page.dart';
import '../../../data/presentation/pages/settings_page.dart';
import '../../../data/presentation/pages/profile_page.dart';
import '../../../data/presentation/widgets/auth_widgets.dart';
import 'agenda_list_page.dart';

class PropertySalesPage extends StatefulWidget {
  const PropertySalesPage({super.key});

  @override
  State<PropertySalesPage> createState() => _PropertySalesPageState();
}

class _PropertySalesPageState extends State<PropertySalesPage> {
  // 0 = Perfil, 1 = Agenda, 2 = Ventas/Propiedades, 3 = Configuración
  int _selectedIndex = 0;
  final _formKey = GlobalKey<FormState>();

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
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Container(
              color: AppColors.background,
              child: _buildMainContent(),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // MENÚ LATERAL
  // ----------------------------------------------------
  Widget _buildSidebar() {
    return Container(
      width: 268,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.graphiteDark, AppColors.graphite],
        ),
      ),
      child: SafeArea(
        // Material transparente: los ListTile del menú necesitan un Material
        // por encima del degradado para pintar su tinta.
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Cabecera de marca
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: AppColors.copperSoft.withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Icon(
                        Icons.real_estate_agent_rounded,
                        color: AppColors.copperSoft,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GRUPO INMOBILIARIO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Panel de gestión',
                            style: TextStyle(
                              color: AppColors.copperSoft,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Tarjeta de usuario
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: AnimatedBuilder(
                  animation: UserStore.instance,
                  builder: (context, _) {
                    final profile = UserStore.instance.profile;
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => setState(() => _selectedIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.10),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 19,
                              backgroundColor: AppColors.copper.withValues(
                                alpha: 0.22,
                              ),
                              child: Text(
                                profile.initials,
                                style: const TextStyle(
                                  color: AppColors.copperSoft,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.fullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  Text(
                                    'Mi perfil',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: Colors.white.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              _buildMenuItem(
                icon: Icons.person_outline,
                label: 'Perfil',
                index: 0,
              ),
              _buildMenuItem(
                icon: Icons.calendar_month_outlined,
                label: 'Agenda',
                index: 1,
              ),
              _buildMenuItem(
                icon: Icons.home_work_outlined,
                label: 'Ventas y Propiedades',
                index: 2,
              ),
              _buildMenuItem(
                icon: Icons.settings_outlined,
                label: 'Configuración',
                index: 3,
              ),

              const Spacer(),
              Divider(color: Colors.white.withValues(alpha: 0.10), height: 1),

              // Cerrar sesión
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFE57373),
                    size: 21,
                  ),
                  title: const Text(
                    'Cerrar sesión',
                    style: TextStyle(
                      color: Color(0xFFE57373),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () => confirmAndSignOut(context),
                ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: isSelected ? Colors.white.withValues(alpha: 0.10) : null,
        leading: Icon(
          icon,
          size: 21,
          color: isSelected
              ? AppColors.copperSoft
              : Colors.white.withValues(alpha: 0.62),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.72),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onTap: () => setState(() => _selectedIndex = index),
      ),
    );
  }

  // ----------------------------------------------------
  // CONTENIDO
  // ----------------------------------------------------
  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 1:
        return const AgendaView();
      case 2:
        return _buildPropertyFormView();
      case 3:
        return const SettingsView();
      default:
        return const ProfileView();
    }
  }

  Widget _buildPropertyFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registro de ventas e inmuebles',
                style: TextStyle(
                  fontSize: 24,
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
                padding: const EdgeInsets.all(24),
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

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
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
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _propertyPriceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Valor de venta (\$)',
                                hintText: 'Ej. 250000000',
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              validator: (value) {
                                final digits =
                                    value?.replaceAll(
                                      RegExp(r'[^0-9]'),
                                      '',
                                    ) ??
                                    '';
                                if (digits.isEmpty) return 'Ingresa el monto';
                                if (int.parse(digits) <= 0) {
                                  return 'El monto debe ser mayor a cero';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
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
                        label: const Text('Registrar venta / asignar propiedad'),
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
              const SizedBox(
                height: 620,
                child: MySalesView(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
