import 'package:flutter/material.dart';

/// Modelo de dados para categorias de restaurantes
class Category {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String? imageUrl;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.imageUrl,
    this.isActive = true,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria uma instância de Category a partir de um Map (JSON)
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: _parseIcon(json['icon'] as String?),
      color: _parseColor(json['color'] as String?),
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converte a instância de Category para um Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': _iconToString(icon),
      'color': _colorToString(color),
      'image_url': imageUrl,
      'is_active': isActive,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Cria uma cópia da categoria com campos atualizados
  Category copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    String? imageUrl,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Category(id: $id, name: $name, description: $description, isActive: $isActive)';
  }

  /// Converte string para IconData
  static IconData _parseIcon(String? iconString) {
    if (iconString == null) return Icons.restaurant;
    
    // Mapeamento de strings para ícones
    final iconMap = {
      'restaurant': Icons.restaurant,
      'local_pizza': Icons.local_pizza,
      'local_cafe': Icons.local_cafe,
      'local_bar': Icons.local_bar,
      'cake': Icons.cake,
      'fastfood': Icons.fastfood,
      'ramen_dining': Icons.ramen_dining,
      'lunch_dining': Icons.lunch_dining,
      'dinner_dining': Icons.dinner_dining,
      'breakfast_dining': Icons.breakfast_dining,
      'local_dining': Icons.local_dining,
      'food_bank': Icons.food_bank,
      'icecream': Icons.icecream,
      'wine_bar': Icons.wine_bar,
      'coffee': Icons.coffee,
      'emoji_food_beverage': Icons.emoji_food_beverage,
    };
    
    return iconMap[iconString] ?? Icons.restaurant;
  }

  /// Converte IconData para string
  static String _iconToString(IconData icon) {
    // Mapeamento reverso de ícones para strings
    final reverseIconMap = {
      Icons.restaurant: 'restaurant',
      Icons.local_pizza: 'local_pizza',
      Icons.local_cafe: 'local_cafe',
      Icons.local_bar: 'local_bar',
      Icons.cake: 'cake',
      Icons.fastfood: 'fastfood',
      Icons.ramen_dining: 'ramen_dining',
      Icons.lunch_dining: 'lunch_dining',
      Icons.dinner_dining: 'dinner_dining',
      Icons.breakfast_dining: 'breakfast_dining',
      Icons.local_dining: 'local_dining',
      Icons.food_bank: 'food_bank',
      Icons.icecream: 'icecream',
      Icons.wine_bar: 'wine_bar',
      Icons.coffee: 'coffee',
      Icons.emoji_food_beverage: 'emoji_food_beverage',
    };
    
    return reverseIconMap[icon] ?? 'restaurant';
  }

  /// Converte string hexadecimal para Color
  static Color _parseColor(String? colorString) {
    if (colorString == null) return Colors.orange;
    
    try {
      // Remove o # se presente
      final cleanColor = colorString.replaceAll('#', '');
      // Adiciona FF para opacidade total se não especificada
      final fullColor = cleanColor.length == 6 ? 'FF$cleanColor' : cleanColor;
      return Color(int.parse(fullColor, radix: 16));
    } catch (e) {
      return Colors.orange;
    }
  }

  /// Converte Color para string hexadecimal
  static String _colorToString(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}

/// Categorias predefinidas do sistema
class PredefinedCategories {
  static final List<Category> categories = [
    Category(
      id: 'pizza',
      name: 'Pizza',
      description: 'Pizzarias e restaurantes especializados em pizza',
      icon: Icons.local_pizza,
      color: Colors.red,
      sortOrder: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'hamburger',
      name: 'Hambúrguer',
      description: 'Hamburguerias e fast food',
      icon: Icons.fastfood,
      color: Colors.orange,
      sortOrder: 2,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'japanese',
      name: 'Japonesa',
      description: 'Culinária japonesa, sushi e ramen',
      icon: Icons.ramen_dining,
      color: Colors.pink,
      sortOrder: 3,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'italian',
      name: 'Italiana',
      description: 'Culinária italiana, massas e risotos',
      icon: Icons.dinner_dining,
      color: Colors.green,
      sortOrder: 4,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'coffee',
      name: 'Café',
      description: 'Cafeterias e casas de café',
      icon: Icons.local_cafe,
      color: Colors.brown,
      sortOrder: 5,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'dessert',
      name: 'Sobremesas',
      description: 'Docerias, sorveterias e confeitarias',
      icon: Icons.cake,
      color: Colors.purple,
      sortOrder: 6,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'bar',
      name: 'Bar',
      description: 'Bares e pubs',
      icon: Icons.local_bar,
      color: Colors.amber,
      sortOrder: 7,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'brazilian',
      name: 'Brasileira',
      description: 'Culinária brasileira tradicional',
      icon: Icons.lunch_dining,
      color: Colors.yellow,
      sortOrder: 8,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  /// Obtém uma categoria por ID
  static Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtém todas as categorias ativas ordenadas
  static List<Category> getActiveCategories() {
    return categories
        .where((category) => category.isActive)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}