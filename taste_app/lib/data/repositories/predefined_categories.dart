import '../models/category_model.dart';

/// Classe com categorias predefinidas para fallback
class PredefinedCategories {
  static final List<CategoryModel> _categories = [
    CategoryModel(
      id: 'pizza',
      name: 'Pizza',
      description: 'Pizzarias e comida italiana',
      icon: 'pizza',
      color: '#FF6B47',
      isActive: true,
      sortOrder: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryModel(
      id: 'burger',
      name: 'Hambúrguer',
      description: 'Hambúrgueres e lanches',
      icon: 'burger',
      color: '#4CAF50',
      isActive: true,
      sortOrder: 2,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryModel(
      id: 'japanese',
      name: 'Japonesa',
      description: 'Culinária japonesa e sushi',
      icon: 'asian',
      color: '#2196F3',
      isActive: true,
      sortOrder: 3,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryModel(
      id: 'coffee',
      name: 'Café',
      description: 'Cafeterias e bebidas',
      icon: 'coffee',
      color: '#795548',
      isActive: true,
      sortOrder: 4,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryModel(
      id: 'dessert',
      name: 'Sobremesa',
      description: 'Doces e sobremesas',
      icon: 'dessert',
      color: '#E91E63',
      isActive: true,
      sortOrder: 5,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryModel(
      id: 'healthy',
      name: 'Saudável',
      description: 'Comida saudável e natural',
      icon: 'healthy',
      color: '#8BC34A',
      isActive: true,
      sortOrder: 6,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CategoryModel(
      id: '32555c5c-b206-4c31-9e4d-1cf5d68d1e8d',
      name: 'Date Night',
      description: 'Restaurantes românticos perfeitos para encontros',
      icon: 'romantic',
      color: '#E91E63',
      isActive: true,
      sortOrder: 7,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  /// Retorna todas as categorias predefinidas
  static List<CategoryModel> getAllCategories() {
    return List.from(_categories);
  }

  /// Busca uma categoria predefinida por ID
  static CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Busca categorias predefinidas por nome
  static List<CategoryModel> searchByName(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _categories.where((category) {
      return category.name.toLowerCase().contains(lowercaseQuery) ||
             (category.description?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  /// Retorna categorias ativas
  static List<CategoryModel> getActiveCategories() {
    return _categories.where((category) => category.isActive).toList();
  }
}