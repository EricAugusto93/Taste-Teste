/// Enum para tipos de entrega
enum DeliveryType {
  delivery('delivery', 'Entrega', 'Entrega no endereço'),
  pickup('pickup', 'Retirada', 'Retirar no restaurante');

  const DeliveryType(this.value, this.label, this.description);

  final String value;
  final String label;
  final String description;

  /// Converte string para enum
  static DeliveryType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'delivery':
        return DeliveryType.delivery;
      case 'pickup':
        return DeliveryType.pickup;
      default:
        throw ArgumentError('Tipo de entrega inválido: $value');
    }
  }

  /// Verifica se é entrega
  bool get isDelivery => this == DeliveryType.delivery;

  /// Verifica se é retirada
  bool get isPickup => this == DeliveryType.pickup;

  @override
  String toString() => value;
}