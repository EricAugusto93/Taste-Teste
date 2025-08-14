import '../models/menu_item_model.dart';
import '../../core/database/supabase_database.dart';
import '../../core/utils/logger.dart';
import '../../core/services/cache_service.dart';
import '../../core/models/cache_item.dart';
import '../../core/di/injection_container.dart';

/// Repositório para gerenciar itens do cardápio
class MenuRepository {
  static const String _logTag = 'MenuRepository';
  final _cacheService = InjectionContainer.get<CacheService>();

  /// Busca todas as categorias e itens do cardápio de um restaurante
  Future<List<MenuCategoryModel>> getMenuByRestaurant(String restaurantId) async {
    try {
      Logger.info('Buscando cardápio do restaurante: $restaurantId');

      // Gerar chave de cache
      final cacheKey = 'menu_$restaurantId';
      
      // Tentar buscar do cache primeiro
      final cachedData = await _cacheService.get(cacheKey);
      if (cachedData != null) {
        final categories = (cachedData as List<dynamic>)
            .map((json) => MenuCategoryModel.fromJson(json))
            .toList();
        Logger.info('Cardápio carregado do cache');
        return categories;
      }

      // Por enquanto, retornar dados mock até implementar no Supabase
      final menu = _getMockMenuData(restaurantId);
      
      // Salvar no cache
      await _cacheService.set(
        cacheKey,
        menu.map((category) => category.toJson()).toList(),
        ttl: const Duration(hours: 2), // Menu não muda com frequência
      );
      
      return menu;
    } catch (e) {
      Logger.error('Erro ao buscar cardápio: $e');
      rethrow;
    }
  }

  /// Busca itens do cardápio por categoria
  Future<List<MenuItemModel>> getItemsByCategory(
    String restaurantId,
    String categoryId,
  ) async {
    try {
      Logger.info('Buscando itens da categoria: $categoryId');

      final menu = await getMenuByRestaurant(restaurantId);
      final category = menu.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => const MenuCategoryModel(
          id: '',
          name: '',
          sortOrder: 0,
          items: [],
        ),
      );

      return category.items;
    } catch (e) {
      Logger.error('Erro ao buscar itens da categoria: $e');
      rethrow;
    }
  }

  /// Busca um item específico do cardápio
  Future<MenuItemModel?> getMenuItem(String itemId) async {
    try {
      Logger.info('Buscando item do cardápio: $itemId');

      // Gerar chave de cache para o item específico
      final cacheKey = 'menu_item_$itemId';
      
      // Tentar buscar do cache primeiro
      final cachedData = await _cacheService.get(cacheKey);
      if (cachedData != null) {
        final item = MenuItemModel.fromJson(cachedData);
        Logger.info('Item do cardápio carregado do cache');
        return item;
      }

      // Por enquanto, buscar nos dados mock
      final allCategories = await getMenuByRestaurant('mock_restaurant');
      for (final category in allCategories) {
        for (final item in category.items) {
          if (item.id == itemId) {
            // Salvar no cache
            await _cacheService.set(
              cacheKey,
              item.toJson(),
              ttl: const Duration(hours: 2),
            );
            return item;
          }
        }
      }

      return null;
    } catch (e) {
      Logger.error('Erro ao buscar item do cardápio: $e');
      rethrow;
    }
  }

  /// Dados mock para demonstração
  List<MenuCategoryModel> _getMockMenuData(String restaurantId) {
    final now = DateTime.now();

    return [
      MenuCategoryModel(
        id: 'cat_1',
        name: 'Entradas',
        description: 'Deliciosas opções para começar sua refeição',
        sortOrder: 1,
        items: [
          MenuItemModel(
            id: 'item_1',
            restaurantId: restaurantId,
            name: 'Bruschetta Italiana',
            description: 'Pão italiano tostado com tomate, manjericão e azeite extra virgem',
            price: 18.90,
            imageUrl: null,
            categoryName: 'Entradas',
            isAvailable: true,
            allergens: ['glúten'],
            createdAt: now,
            updatedAt: now,
          ),
          MenuItemModel(
            id: 'item_2',
            restaurantId: restaurantId,
            name: 'Carpaccio de Salmão',
            description: 'Fatias finas de salmão fresco com alcaparras e molho de mostarda',
            price: 32.90,
            imageUrl: null,
            categoryName: 'Entradas',
            isAvailable: true,
            allergens: ['peixe'],
            createdAt: now,
            updatedAt: now,
          ),
        ],
      ),
      MenuCategoryModel(
        id: 'cat_2',
        name: 'Pratos Principais',
        description: 'Nossos pratos mais especiais',
        sortOrder: 2,
        items: [
          MenuItemModel(
            id: 'item_3',
            restaurantId: restaurantId,
            name: 'Risotto de Camarão',
            description: 'Arroz arbóreo cremoso com camarões frescos e ervas finas',
            price: 45.90,
            imageUrl: null,
            categoryName: 'Pratos Principais',
            isAvailable: true,
            allergens: ['crustáceos'],
            createdAt: now,
            updatedAt: now,
          ),
          MenuItemModel(
            id: 'item_4',
            restaurantId: restaurantId,
            name: 'Filé Mignon Grelhado',
            description: 'Filé mignon grelhado ao ponto com batatas rústicas e legumes',
            price: 52.90,
            imageUrl: null,
            categoryName: 'Pratos Principais',
            isAvailable: true,
            allergens: [],
            createdAt: now,
            updatedAt: now,
          ),
          MenuItemModel(
            id: 'item_5',
            restaurantId: restaurantId,
            name: 'Pasta Carbonara',
            description: 'Massa fresca com molho cremoso, bacon e queijo parmesão',
            price: 38.90,
            imageUrl: null,
            categoryName: 'Pratos Principais',
            isAvailable: false, // Indisponível para demonstrar
            allergens: ['glúten', 'lactose', 'ovos'],
            createdAt: now,
            updatedAt: now,
          ),
        ],
      ),
      MenuCategoryModel(
        id: 'cat_3',
        name: 'Sobremesas',
        description: 'Finalize sua refeição com doçura',
        sortOrder: 3,
        items: [
          MenuItemModel(
            id: 'item_6',
            restaurantId: restaurantId,
            name: 'Tiramisu',
            description: 'Clássica sobremesa italiana com café e mascarpone',
            price: 16.90,
            imageUrl: null,
            categoryName: 'Sobremesas',
            isAvailable: true,
            allergens: ['lactose', 'ovos', 'glúten'],
            createdAt: now,
            updatedAt: now,
          ),
          MenuItemModel(
            id: 'item_7',
            restaurantId: restaurantId,
            name: 'Petit Gateau',
            description: 'Bolinho de chocolate quente com sorvete de baunilha',
            price: 19.90,
            imageUrl: null,
            categoryName: 'Sobremesas',
            isAvailable: true,
            allergens: ['lactose', 'ovos', 'glúten'],
            createdAt: now,
            updatedAt: now,
          ),
        ],
      ),
      MenuCategoryModel(
        id: 'cat_4',
        name: 'Bebidas',
        description: 'Refrescantes opções para acompanhar',
        sortOrder: 4,
        items: [
          MenuItemModel(
            id: 'item_8',
            restaurantId: restaurantId,
            name: 'Suco Natural de Laranja',
            description: 'Suco fresco de laranja espremida na hora',
            price: 8.90,
            imageUrl: null,
            categoryName: 'Bebidas',
            isAvailable: true,
            allergens: [],
            createdAt: now,
            updatedAt: now,
          ),
          MenuItemModel(
            id: 'item_9',
            restaurantId: restaurantId,
            name: 'Água com Gás',
            description: 'Água mineral com gás gelada',
            price: 4.50,
            imageUrl: null,
            categoryName: 'Bebidas',
            isAvailable: true,
            allergens: [],
            createdAt: now,
            updatedAt: now,
          ),
        ],
      ),
    ];
  }
}