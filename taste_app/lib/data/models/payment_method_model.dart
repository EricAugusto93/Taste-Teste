import 'package:equatable/equatable.dart';

/// Modelo de dados para métodos de pagamento
class PaymentMethodModel extends Equatable {
  final String id;
  final String type; // credit_card, debit_card, pix, cash, etc.
  final String name;
  final String? description;
  final String? icon;
  final bool isEnabled;
  final Map<String, dynamic>? metadata; // Dados específicos do método
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentMethodModel({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    this.icon,
    this.isEnabled = true,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria uma cópia com novos valores
  PaymentMethodModel copyWith({
    String? id,
    String? type,
    String? name,
    String? description,
    String? icon,
    bool? isEnabled,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isEnabled: isEnabled ?? this.isEnabled,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Cria um método de pagamento a partir de JSON
  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      isEnabled: json['is_enabled'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'description': description,
      'icon': icon,
      'is_enabled': isEnabled,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Verifica se é cartão de crédito
  bool get isCreditCard => type == PaymentMethodType.creditCard;

  /// Verifica se é cartão de débito
  bool get isDebitCard => type == PaymentMethodType.debitCard;

  /// Verifica se é PIX
  bool get isPix => type == PaymentMethodType.pix;

  /// Verifica se é dinheiro
  bool get isCash => type == PaymentMethodType.cash;

  /// Verifica se requer processamento online
  bool get requiresOnlineProcessing {
    return isCreditCard || isDebitCard || isPix;
  }

  /// Verifica se aceita troco
  bool get acceptsChange => isCash;

  @override
  List<Object?> get props => [
        id,
        type,
        name,
        description,
        icon,
        isEnabled,
        metadata,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'PaymentMethodModel(id: $id, type: $type, name: $name)';
  }
}

/// Tipos de método de pagamento predefinidos
class PaymentMethodType {
  static const String creditCard = 'credit_card';
  static const String debitCard = 'debit_card';
  static const String pix = 'pix';
  static const String cash = 'cash';
  static const String voucher = 'voucher';
  static const String bankTransfer = 'bank_transfer';

  static const List<String> all = [
    creditCard,
    debitCard,
    pix,
    cash,
    voucher,
    bankTransfer,
  ];

  static String getLabel(String type) {
    switch (type) {
      case creditCard:
        return 'Cartão de Crédito';
      case debitCard:
        return 'Cartão de Débito';
      case pix:
        return 'PIX';
      case cash:
        return 'Dinheiro';
      case voucher:
        return 'Vale Refeição';
      case bankTransfer:
        return 'Transferência Bancária';
      default:
        return 'Outro';
    }
  }

  static String getDescription(String type) {
    switch (type) {
      case creditCard:
        return 'Pagamento com cartão de crédito';
      case debitCard:
        return 'Pagamento com cartão de débito';
      case pix:
        return 'Pagamento instantâneo via PIX';
      case cash:
        return 'Pagamento em dinheiro na entrega';
      case voucher:
        return 'Vale refeição ou alimentação';
      case bankTransfer:
        return 'Transferência bancária';
      default:
        return 'Método de pagamento';
    }
  }
}

/// Factory para criar métodos de pagamento padrão
class PaymentMethodFactory {
  static List<PaymentMethodModel> getDefaultMethods() {
    final now = DateTime.now();
    
    return [
      PaymentMethodModel(
        id: 'pix',
        type: PaymentMethodType.pix,
        name: 'PIX',
        description: 'Pagamento instantâneo via PIX',
        icon: 'pix',
        createdAt: now,
        updatedAt: now,
      ),
      PaymentMethodModel(
        id: 'credit_card',
        type: PaymentMethodType.creditCard,
        name: 'Cartão de Crédito',
        description: 'Visa, Mastercard, Elo',
        icon: 'credit_card',
        createdAt: now,
        updatedAt: now,
      ),
      PaymentMethodModel(
        id: 'debit_card',
        type: PaymentMethodType.debitCard,
        name: 'Cartão de Débito',
        description: 'Débito na máquina',
        icon: 'debit_card',
        createdAt: now,
        updatedAt: now,
      ),
      PaymentMethodModel(
        id: 'cash',
        type: PaymentMethodType.cash,
        name: 'Dinheiro',
        description: 'Pagamento na entrega',
        icon: 'money',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  static PaymentMethodModel createCustom({
    required String id,
    required String type,
    required String name,
    String? description,
    String? icon,
    bool isEnabled = true,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    
    return PaymentMethodModel(
      id: id,
      type: type,
      name: name,
      description: description ?? PaymentMethodType.getDescription(type),
      icon: icon,
      isEnabled: isEnabled,
      metadata: metadata,
      createdAt: now,
      updatedAt: now,
    );
  }
}