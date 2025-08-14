import 'package:equatable/equatable.dart';
import 'menu_item_model.dart';

/// Modelo para representar um item no carrinho
class CartItemModel extends Equatable {
  final String id;
  final MenuItemModel menuItem;
  final int quantity;
  final String? specialInstructions;
  final List<String> selectedOptions;
  final double unitPrice;
  final double totalPrice;
  final DateTime addedAt;
  final DateTime updatedAt;

  const CartItemModel({
    required this.id,
    required this.menuItem,
    required this.quantity,
    this.specialInstructions,
    this.selectedOptions = const [],
    required this.unitPrice,
    required this.totalPrice,
    required this.addedAt,
    required this.updatedAt,
  });

  /// Cria uma cópia do item com novos valores
  CartItemModel copyWith({
    String? id,
    MenuItemModel? menuItem,
    int? quantity,
    String? specialInstructions,
    List<String>? selectedOptions,
    double? unitPrice,
    double? totalPrice,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Cria um CartItemModel a partir de um MenuItemModel
  factory CartItemModel.fromMenuItem({
    required MenuItemModel menuItem,
    int quantity = 1,
    String? specialInstructions,
    List<String> selectedOptions = const [],
  }) {
    final now = DateTime.now();
    final unitPrice = menuItem.price;
    final totalPrice = unitPrice * quantity;
    
    return CartItemModel(
      id: '${menuItem.id}_${now.millisecondsSinceEpoch}',
      menuItem: menuItem,
      quantity: quantity,
      specialInstructions: specialInstructions,
      selectedOptions: selectedOptions,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      addedAt: now,
      updatedAt: now,
    );
  }

  /// Cria um CartItemModel a partir de JSON
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      menuItem: MenuItemModel.fromJson(json['menu_item'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      specialInstructions: json['special_instructions'] as String?,
      selectedOptions: (json['selected_options'] as List<dynamic>? ?? [])
          .map((option) => option as String)
          .toList(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      addedAt: DateTime.parse(json['added_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converte o CartItemModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menu_item': menuItem.toJson(),
      'quantity': quantity,
      'special_instructions': specialInstructions,
      'selected_options': selectedOptions,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'added_at': addedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Atualiza a quantidade do item
  CartItemModel updateQuantity(int newQuantity) {
    if (newQuantity <= 0) {
      throw ArgumentError('Quantidade deve ser maior que zero');
    }
    
    return copyWith(
      quantity: newQuantity,
      totalPrice: unitPrice * newQuantity,
      updatedAt: DateTime.now(),
    );
  }

  /// Adiciona instruções especiais
  CartItemModel addSpecialInstructions(String instructions) {
    return copyWith(
      specialInstructions: instructions,
      updatedAt: DateTime.now(),
    );
  }

  /// Verifica se o item está disponível
  bool get isAvailable => menuItem.isAvailable;

  /// Retorna o nome do item
  String get name => menuItem.name;

  /// Retorna a descrição do item
  String get description => menuItem.description ?? '';

  /// Retorna a URL da imagem do item
  String? get imageUrl => menuItem.imageUrl;

  /// Retorna o ID do restaurante
  String get restaurantId => menuItem.restaurantId;

  @override
  List<Object?> get props => [
        id,
        menuItem,
        quantity,
        specialInstructions,
        selectedOptions,
        unitPrice,
        totalPrice,
        addedAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'CartItemModel(id: $id, menuItem: ${menuItem.name}, quantity: $quantity, totalPrice: $totalPrice)';
  }
}