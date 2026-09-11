import 'package:flutter/foundation.dart';

/// Estado comercial de una operación.
enum SaleStatus {
  closed('Vendida'),
  reserved('Reservada'),
  inProcess('En proceso');

  const SaleStatus(this.label);

  final String label;
}

/// Una venta o asignación de propiedad registrada por el asesor.
@immutable
class Sale {
  const Sale({
    required this.id,
    required this.client,
    required this.propertyName,
    required this.propertyType,
    required this.price,
    required this.date,
    required this.status,
  });

  final String id;
  final String client;
  final String propertyName;
  final String propertyType;
  final double price;
  final DateTime date;
  final SaleStatus status;
}

/// Store en memoria de las ventas del asesor.
/// El formulario de "Ventas y Propiedades" escribe aquí y el perfil lo lee.
class SalesStore extends ChangeNotifier {
  SalesStore._();

  static final SalesStore instance = SalesStore._();

  final List<Sale> _sales = [
    Sale(
      id: 'S-1024',
      client: 'María Gómez',
      propertyName: 'Apartamento Torre Vista 802',
      propertyType: 'Apartamento',
      price: 320000000,
      date: DateTime(2026, 7, 18),
      status: SaleStatus.closed,
    ),
    Sale(
      id: 'S-1031',
      client: 'Carlos Rendón',
      propertyName: 'Casa Campestre Lote 45',
      propertyType: 'Casa',
      price: 610000000,
      date: DateTime(2026, 8, 2),
      status: SaleStatus.closed,
    ),
    Sale(
      id: 'S-1037',
      client: 'Inversiones Del Río S.A.S.',
      propertyName: 'Local Comercial Plaza Norte',
      propertyType: 'Local Comercial',
      price: 485000000,
      date: DateTime(2026, 8, 26),
      status: SaleStatus.reserved,
    ),
  ];

  /// Ventas de la más reciente a la más antigua.
  List<Sale> get sales =>
      List.unmodifiable(List.of(_sales)..sort((a, b) => b.date.compareTo(a.date)));

  int get closedCount =>
      _sales.where((sale) => sale.status == SaleStatus.closed).length;

  int get totalCount => _sales.length;

  /// Monto total de las operaciones ya cerradas.
  double get closedAmount => _sales
      .where((sale) => sale.status == SaleStatus.closed)
      .fold(0, (total, sale) => total + sale.price);

  void addSale({
    required String client,
    required String propertyName,
    required String propertyType,
    required double price,
    SaleStatus status = SaleStatus.closed,
  }) {
    _sales.add(
      Sale(
        id: 'S-${1040 + _sales.length}',
        client: client,
        propertyName: propertyName,
        propertyType: propertyType,
        price: price,
        date: DateTime.now(),
        status: status,
      ),
    );
    notifyListeners();
  }
}

/// Formatea montos como "$ 320.000.000" sin depender del paquete intl.
String formatCurrency(double amount) {
  final digits = amount.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '\$ $buffer';
}

/// Formatea fechas como "26/08/2026".
String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
