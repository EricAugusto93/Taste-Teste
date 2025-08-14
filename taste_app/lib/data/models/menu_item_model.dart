import 'package:equatable/equatable.dart';

/// Modelo de dados para item do cardápio
class MenuItemModel extends Equatable {
  final String id;
  final String restaurantId;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final String categoryName;
  final bool isAvailable;
  final List<String> allergens;
  final Map<String, dynamic>? nutritionalInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MenuItemModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.categoryName,
    this.isAvailable = true,
    this.allergens = const [],
    this.nutritionalInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria uma instância a partir de um Map (JSON)
  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      categoryName: json['category_name'] as String,
      isAvailable: json['is_available'] as bool? ?? true,
      allergens: (json['allergens'] as List<dynamic>?)?.cast<String>() ?? [],
      nutritionalInfo: json['nutritional_info'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converte para Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category_name': categoryName,
      'is_available': isAvailable,
      'allergens': allergens,
      'nutritional_info': nutritionalInfo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Cria uma cópia com valores alterados
  MenuItemModel copyWith({
    String? id,
    String? restaurantId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? categoryName,
    bool? isAvailable,
    List<String>? allergens,
    Map<String, dynamic>? nutritionalInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryName: categoryName ?? this.categoryName,
      isAvailable: isAvailable ?? this.isAvailable,
      allergens: allergens ?? this.allergens,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Formata o preço como string
  String get formattedPrice {
    return 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  List<Object?> get props => [
        id,
        restaurantId,
        name,
        description,
        price,
        imageUrl,
        categoryName,
        isAvailable,
        allergens,
        nutritionalInfo,
        createdAt,
        updatedAt,
      ];
}

/// Categoria de itens do cardápio
class MenuCategoryModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final int sortOrder;
  final List<MenuItemModel> items;

  const MenuCategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.sortOrder,
    this.items = const [],
  });

  /// Cria uma instância a partir de um Map (JSON)
  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) {
    return MenuCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      sortOrder: json['sort_order'] as int,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => MenuItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Converte para Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sort_order': sortOrder,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  /// Cria uma cópia com valores alterados
  MenuCategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    int? sortOrder,
    List<MenuItemModel>? items,
  }) {
    return MenuCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [id, name, description, sortOrder, items];
}