import 'package:equatable/equatable.dart';
import 'restaurant_model.dart';
import 'cart_item_model.dart';
import 'address_model.dart';
import 'payment_method_model.dart';

/// Status do pedido
enum OrderStatus {
  pending('pending', 'Pendente', 'Aguardando confirmação'),
  confirmed('confirmed', 'Confirmado', 'Pedido confirmado pelo restaurante'),
  preparing('preparing', 'Preparando', 'Seu pedido está sendo preparado'),
  ready('ready', 'Pronto', 'Pedido pronto para entrega'),
  outForDelivery('out_for_delivery', 'Saiu para entrega', 'Pedido a caminho'),
  delivered('delivered', 'Entregue', 'Pedido entregue com sucesso'),
  cancelled('cancelled', 'Cancelado', 'Pedido cancelado'),
  refunded('refunded', 'Reembolsado', 'Pedido reembolsado');

  const OrderStatus(this.value, this.label, this.description);

  final String value;
  final String label;
  final String description;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }

  bool get isPending => this == OrderStatus.pending;
  bool get isConfirmed => this == OrderStatus.confirmed;
  bool get isPreparing => this == OrderStatus.preparing;
  bool get isReady => this == OrderStatus.ready;
  bool get isOutForDelivery => this == OrderStatus.outForDelivery;
  bool get isDelivered => this == OrderStatus.delivered;
  bool get isCancelled => this == OrderStatus.cancelled;
  bool get isRefunded => this == OrderStatus.refunded;

  bool get isActive => !isCancelled && !isDelivered && !isRefunded;
  bool get isCompleted => isDelivered;
  bool get canBeCancelled => isPending || isConfirmed;
}

/// Modelo de dados para pedidos
class OrderModel extends Equatable {
  final String id;
  final String userId;
  final RestaurantModel restaurant;
  final List<CartItemModel> items;
  final AddressModel deliveryAddress;
  final PaymentMethodModel paymentMethod;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double discount;
  final double total;
  final String? notes;
  final String? promoCode;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? preparedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final DateTime estimatedDeliveryTime;
  final String? cancellationReason;
  final String? trackingCode;
  final Map<String, dynamic>? metadata;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.restaurant,
    required this.items,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.discount,
    required this.total,
    this.notes,
    this.promoCode,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
    this.preparedAt,
    this.deliveredAt,
    this.cancelledAt,
    required this.estimatedDeliveryTime,
    this.cancellationReason,
    this.trackingCode,
    this.metadata,
  });

  /// Cria uma cópia com novos valores
  OrderModel copyWith({
    String? id,
    String? userId,
    RestaurantModel? restaurant,
    List<CartItemModel>? items,
    AddressModel? deliveryAddress,
    PaymentMethodModel? paymentMethod,
    double? subtotal,
    double? deliveryFee,
    double? serviceFee,
    double? discount,
    double? total,
    String? notes,
    String? promoCode,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? confirmedAt,
    DateTime? preparedAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    DateTime? estimatedDeliveryTime,
    String? cancellationReason,
    String? trackingCode,
    Map<String, dynamic>? metadata,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurant: restaurant ?? this.restaurant,
      items: items ?? this.items,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      serviceFee: serviceFee ?? this.serviceFee,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      notes: notes ?? this.notes,
      promoCode: promoCode ?? this.promoCode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      preparedAt: preparedAt ?? this.preparedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      trackingCode: trackingCode ?? this.trackingCode,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Cria um pedido a partir de JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      restaurant: RestaurantModel.fromJson(json['restaurant'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      deliveryAddress: AddressModel.fromJson(json['delivery_address'] as Map<String, dynamic>),
      paymentMethod: PaymentMethodModel.fromJson(json['payment_method'] as Map<String, dynamic>),
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      serviceFee: (json['service_fee'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      notes: json['notes'] as String?,
      promoCode: json['promo_code'] as String?,
      status: OrderStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.parse(json['confirmed_at'] as String)
          : null,
      preparedAt: json['prepared_at'] != null
          ? DateTime.parse(json['prepared_at'] as String)
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      estimatedDeliveryTime: DateTime.parse(json['estimated_delivery_time'] as String),
      cancellationReason: json['cancellation_reason'] as String?,
      trackingCode: json['tracking_code'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'restaurant': restaurant.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'delivery_address': deliveryAddress.toJson(),
      'payment_method': paymentMethod.toJson(),
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'service_fee': serviceFee,
      'discount': discount,
      'total': total,
      'notes': notes,
      'promo_code': promoCode,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'confirmed_at': confirmedAt?.toIso8601String(),
      'prepared_at': preparedAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'estimated_delivery_time': estimatedDeliveryTime.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'tracking_code': trackingCode,
      'metadata': metadata,
    };
  }

  /// Retorna o número total de itens
  int get itemCount => items.fold<int>(0, (sum, item) => sum + item.quantity);

  /// Retorna o tempo estimado de entrega em minutos
  int get estimatedDeliveryMinutes {
    final now = DateTime.now();
    if (estimatedDeliveryTime.isBefore(now)) return 0;
    return estimatedDeliveryTime.difference(now).inMinutes;
  }

  /// Retorna o tempo decorrido desde a criação em minutos
  int get elapsedMinutes {
    return DateTime.now().difference(createdAt).inMinutes;
  }

  /// Verifica se o pedido está atrasado
  bool get isLate {
    return DateTime.now().isAfter(estimatedDeliveryTime) && status.isActive;
  }

  /// Retorna o tempo de atraso em minutos (se houver)
  int get lateMinutes {
    if (!isLate) return 0;
    return DateTime.now().difference(estimatedDeliveryTime).inMinutes;
  }

  /// Retorna uma descrição do status atual
  String get statusDescription {
    if (isLate) {
      return '${status.description} (${lateMinutes}min de atraso)';
    }
    return status.description;
  }

  /// Retorna o próximo status esperado
  OrderStatus? get nextExpectedStatus {
    switch (status) {
      case OrderStatus.pending:
        return OrderStatus.confirmed;
      case OrderStatus.confirmed:
        return OrderStatus.preparing;
      case OrderStatus.preparing:
        return OrderStatus.ready;
      case OrderStatus.ready:
        return OrderStatus.outForDelivery;
      case OrderStatus.outForDelivery:
        return OrderStatus.delivered;
      default:
        return null;
    }
  }

  /// Atualiza o status do pedido
  OrderModel updateStatus(OrderStatus newStatus, {String? reason}) {
    final now = DateTime.now();
    
    return copyWith(
      status: newStatus,
      confirmedAt: newStatus.isConfirmed && confirmedAt == null ? now : confirmedAt,
      preparedAt: newStatus.isPreparing && preparedAt == null ? now : preparedAt,
      deliveredAt: newStatus.isDelivered && deliveredAt == null ? now : deliveredAt,
      cancelledAt: newStatus.isCancelled && cancelledAt == null ? now : cancelledAt,
      cancellationReason: newStatus.isCancelled ? reason : cancellationReason,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        restaurant,
        items,
        deliveryAddress,
        paymentMethod,
        subtotal,
        deliveryFee,
        serviceFee,
        discount,
        total,
        notes,
        promoCode,
        status,
        createdAt,
        confirmedAt,
        preparedAt,
        deliveredAt,
        cancelledAt,
        estimatedDeliveryTime,
        cancellationReason,
        trackingCode,
        metadata,
      ];

  @override
  String toString() {
    return 'OrderModel(id: $id, status: $status, total: $total)';
  }
}