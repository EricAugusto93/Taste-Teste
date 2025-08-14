import 'package:equatable/equatable.dart';
import 'cart_item_model.dart';
import 'restaurant_model.dart';

/// Modelo para representar o carrinho de compras
class CartModel extends Equatable {
  final String id;
  final String? userId;
  final RestaurantModel? restaurant;
  final String? restaurantId;
  final List<CartItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double discount;
  final double total;
  final String? promoCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const CartModel({
    required this.id,
    this.userId,
    this.restaurant,
    this.restaurantId,
    this.items = const [],
    this.subtotal = 0.0,
    this.deliveryFee = 0.0,
    this.serviceFee = 0.0,
    this.discount = 0.0,
    this.total = 0.0,
    this.promoCode,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  /// Cria um carrinho vazio
  factory CartModel.empty() {
    final now = DateTime.now();
    return CartModel(
      id: 'cart_${now.millisecondsSinceEpoch}',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Cria um carrinho para um restaurante específico
  factory CartModel.forRestaurant({
    required RestaurantModel restaurant,
    String? userId,
  }) {
    final now = DateTime.now();
    return CartModel(
      id: 'cart_${restaurant.id}_${now.millisecondsSinceEpoch}',
      userId: userId,
      restaurant: restaurant,
      restaurantId: restaurant.id,
      deliveryFee: restaurant.deliveryFee,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Cria uma cópia do carrinho com novos valores
  CartModel copyWith({
    String? id,
    String? userId,
    RestaurantModel? restaurant,
    String? restaurantId,
    List<CartItemModel>? items,
    double? subtotal,
    double? deliveryFee,
    double? serviceFee,
    double? discount,
    double? total,
    String? promoCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurant: restaurant ?? this.restaurant,
      restaurantId: restaurantId ?? this.restaurantId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      serviceFee: serviceFee ?? this.serviceFee,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      promoCode: promoCode ?? this.promoCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Adiciona um item ao carrinho
  CartModel addItem(CartItemModel item) {
    // Verifica se o item é do mesmo restaurante
    if (restaurantId != null && item.restaurantId != restaurantId) {
      throw ArgumentError('Item deve ser do mesmo restaurante');
    }

    // Verifica se já existe um item igual
    final existingItemIndex = items.indexWhere(
      (cartItem) => 
          cartItem.menuItem.id == item.menuItem.id &&
          cartItem.specialInstructions == item.specialInstructions &&
          _listsEqual(cartItem.selectedOptions, item.selectedOptions),
    );

    List<CartItemModel> newItems;
    if (existingItemIndex >= 0) {
      // Atualiza a quantidade do item existente
      final existingItem = items[existingItemIndex];
      final updatedItem = existingItem.updateQuantity(
        existingItem.quantity + item.quantity,
      );
      newItems = List.from(items);
      newItems[existingItemIndex] = updatedItem;
    } else {
      // Adiciona novo item
      newItems = [...items, item];
    }

    return _recalculateAndUpdate(newItems);
  }

  /// Remove um item do carrinho
  CartModel removeItem(String itemId) {
    final newItems = items.where((item) => item.id != itemId).toList();
    return _recalculateAndUpdate(newItems);
  }

  /// Atualiza a quantidade de um item
  CartModel updateItemQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      return removeItem(itemId);
    }

    final newItems = items.map((item) {
      if (item.id == itemId) {
        return item.updateQuantity(newQuantity);
      }
      return item;
    }).toList();

    return _recalculateAndUpdate(newItems);
  }

  /// Limpa o carrinho
  CartModel clear() {
    return copyWith(
      items: [],
      subtotal: 0.0,
      serviceFee: 0.0,
      discount: 0.0,
      total: 0.0,
      promoCode: null,
      updatedAt: DateTime.now(),
    );
  }

  /// Aplica um código promocional
  CartModel applyPromoCode(String code, double discountAmount) {
    return _recalculateAndUpdate(
      items,
      promoCode: code,
      discount: discountAmount,
    );
  }

  /// Remove código promocional
  CartModel removePromoCode() {
    return _recalculateAndUpdate(
      items,
      promoCode: null,
      discount: 0.0,
    );
  }

  /// Recalcula os valores e atualiza o carrinho
  CartModel _recalculateAndUpdate(
    List<CartItemModel> newItems, {
    String? promoCode,
    double? discount,
  }) {
    final newSubtotal = newItems.fold<double>(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );

    final newServiceFee = newSubtotal * 0.05; // 5% de taxa de serviço
    final newDiscount = discount ?? this.discount;
    final newTotal = newSubtotal + deliveryFee + newServiceFee - newDiscount;

    return copyWith(
      items: newItems,
      subtotal: newSubtotal,
      serviceFee: newServiceFee,
      discount: newDiscount,
      total: newTotal > 0 ? newTotal : 0.0,
      promoCode: promoCode ?? this.promoCode,
      updatedAt: DateTime.now(),
    );
  }

  /// Verifica se duas listas são iguais
  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  /// Cria um CartModel a partir de JSON
  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      restaurant: json['restaurant'] != null
          ? RestaurantModel.fromJson(json['restaurant'] as Map<String, dynamic>)
          : null,
      restaurantId: json['restaurant_id'] as String?,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      serviceFee: (json['service_fee'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      promoCode: json['promo_code'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Converte o CartModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'restaurant': restaurant?.toJson(),
      'restaurant_id': restaurantId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'service_fee': serviceFee,
      'discount': discount,
      'total': total,
      'promo_code': promoCode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Verifica se o carrinho está vazio
  bool get isEmpty => items.isEmpty;

  /// Verifica se o carrinho não está vazio
  bool get isNotEmpty => items.isNotEmpty;

  /// Retorna o número total de itens
  int get itemCount => items.fold<int>(0, (sum, item) => sum + item.quantity);

  /// Verifica se o carrinho atende ao valor mínimo do pedido
  bool get meetsMinimumOrder {
    if (restaurant?.minOrderValue == null) return true;
    return subtotal >= restaurant!.minOrderValue!;
  }

  /// Retorna o valor restante para atingir o pedido mínimo
  double get remainingForMinimumOrder {
    if (restaurant?.minOrderValue == null) return 0.0;
    final remaining = restaurant!.minOrderValue! - subtotal;
    return remaining > 0 ? remaining : 0.0;
  }

  /// Verifica se todos os itens estão disponíveis
  bool get allItemsAvailable => items.every((item) => item.isAvailable);

  /// Retorna os itens indisponíveis
  List<CartItemModel> get unavailableItems => 
      items.where((item) => !item.isAvailable).toList();

  @override
  List<Object?> get props => [
        id,
        userId,
        restaurant,
        restaurantId,
        items,
        subtotal,
        deliveryFee,
        serviceFee,
        discount,
        total,
        promoCode,
        createdAt,
        updatedAt,
        isActive,
      ];

  @override
  String toString() {
    return 'CartModel(id: $id, itemCount: $itemCount, total: $total, restaurant: ${restaurant?.name})';
  }
}