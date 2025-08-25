import 'package:flutter/material.dart';
import '../cache_service.dart';
import '../connectivity_service.dart';
import '../supabase_service.dart';

/// Tipos de item do menu
enum MenuItemType {
  appetizer,
  mainCourse,
  dessert,
  beverage,
  combo,
  special,
}

/// Status de disponibilidade do item
enum ItemAvailability {
  available,
  unavailable,
  limitedQuantity,
  seasonal,
}

/// Informações nutricionais
class NutritionalInfo {
  final int? calories;
  final double? protein; // gramas
  final double? carbs; // gramas
  final double? fat; // gramas
  final double? fiber; // gramas
  final double? sugar; // gramas
  final double? sodium; // miligramas
  final List<String> allergens;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final bool isDairyFree;

  const NutritionalInfo({
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.fiber,
    this.sugar,
    this.sodium,
    this.allergens = const [],
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.isDairyFree = false,
  });

  factory NutritionalInfo.fromJson(Map<String, dynamic> json) {
    return NutritionalInfo(
      calories: json['calories'] as int?,
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble(),
      sugar: (json['sugar'] as num?)?.toDouble(),
      sodium: (json['sodium'] as num?)?.toDouble(),
      allergens: List<String>.from(json['allergens'] as List? ?? []),
      isVegetarian: json['is_vegetarian'] as bool? ?? false,
      isVegan: json['is_vegan'] as bool? ?? false,
      isGlutenFree: json['is_gluten_free'] as bool? ?? false,
      isDairyFree: json['is_dairy_free'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'allergens': allergens,
      'is_vegetarian': isVegetarian,
      'is_vegan': isVegan,
      'is_gluten_free': isGlutenFree,
      'is_dairy_free': isDairyFree,
    };
  }
}

/// Item do menu
class MenuItem {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final MenuItemType type;
  final ItemAvailability availability;
  final List<String> ingredients;
  final NutritionalInfo? nutritionalInfo;
  final Map<String, dynamic>? customizations; // opções de personalização
  final List<String> tags;
  final int preparationTime; // minutos
  final bool isPopular;
  final bool isNew;
  final double? discountPercentage;
  final DateTime? discountValidUntil;
  final int orderCount;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.type,
    this.availability = ItemAvailability.available,
    this.ingredients = const [],
    this.nutritionalInfo,
    this.customizations,
    this.tags = const [],
    this.preparationTime = 0,
    this.isPopular = false,
    this.isNew = false,
    this.discountPercentage,
    this.discountValidUntil,
    this.orderCount = 0,
    this.rating = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      type: MenuItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MenuItemType.mainCourse,
      ),
      availability: ItemAvailability.values.firstWhere(
        (e) => e.name == json['availability'],
        orElse: () => ItemAvailability.available,
      ),
      ingredients: List<String>.from(json['ingredients'] as List? ?? []),
      nutritionalInfo: json['nutritional_info'] != null
          ? NutritionalInfo.fromJson(json['nutritional_info'])
          : null,
      customizations: json['customizations'] as Map<String, dynamic>?,
      tags: List<String>.from(json['tags'] as List? ?? []),
      preparationTime: json['preparation_time'] as int? ?? 0,
      isPopular: json['is_popular'] as bool? ?? false,
      isNew: json['is_new'] as bool? ?? false,
      discountPercentage: (json['discount_percentage'] as num?)?.toDouble(),
      discountValidUntil: json['discount_valid_until'] != null
          ? DateTime.parse(json['discount_valid_until'])
          : null,
      orderCount: json['order_count'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'type': type.name,
      'availability': availability.name,
      'ingredients': ingredients,
      'nutritional_info': nutritionalInfo?.toJson(),
      'customizations': customizations,
      'tags': tags,
      'preparation_time': preparationTime,
      'is_popular': isPopular,
      'is_new': isNew,
      'discount_percentage': discountPercentage,
      'discount_valid_until': discountValidUntil?.toIso8601String(),
      'order_count': orderCount,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Preço com desconto aplicado
  double get finalPrice {
    if (discountPercentage != null && 
        discountValidUntil != null && 
        DateTime.now().isBefore(discountValidUntil!)) {
      return price * (1 - discountPercentage! / 100);
    }
    return price;
  }

  /// Verifica se tem desconto ativo
  bool get hasActiveDiscount {
    return discountPercentage != null && 
           discountValidUntil != null && 
           DateTime.now().isBefore(discountValidUntil!);
  }

  /// Verifica se está disponível
  bool get isAvailable => availability == ItemAvailability.available;

  MenuItem copyWith({
    String? id,
    String? restaurantId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    MenuItemType? type,
    ItemAvailability? availability,
    List<String>? ingredients,
    NutritionalInfo? nutritionalInfo,
    Map<String, dynamic>? customizations,
    List<String>? tags,
    int? preparationTime,
    bool? isPopular,
    bool? isNew,
    double? discountPercentage,
    DateTime? discountValidUntil,
    int? orderCount,
    double? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItem(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      availability: availability ?? this.availability,
      ingredients: ingredients ?? this.ingredients,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      customizations: customizations ?? this.customizations,
      tags: tags ?? this.tags,
      preparationTime: preparationTime ?? this.preparationTime,
      isPopular: isPopular ?? this.isPopular,
      isNew: isNew ?? this.isNew,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountValidUntil: discountValidUntil ?? this.discountValidUntil,
      orderCount: orderCount ?? this.orderCount,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Seção do menu
class MenuSection {
  final String id;
  final String restaurantId;
  final String name;
  final String? description;
  final int order;
  final List<MenuItem> items;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MenuSection({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.description,
    required this.order,
    this.items = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuSection.fromJson(Map<String, dynamic> json) {
    return MenuSection(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      order: json['order'] as int,
      items: (json['items'] as List? ?? [])
          .map((item) => MenuItem.fromJson(item))
          .toList(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'description': description,
      'order': order,
      'items': items.map((item) => item.toJson()).toList(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Menu completo do restaurante
class RestaurantMenu {
  final String id;
  final String restaurantId;
  final String name;
  final String? description;
  final List<MenuSection> sections;
  final DateTime lastUpdated;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  const RestaurantMenu({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.description,
    this.sections = const [],
    required this.lastUpdated,
    this.isActive = true,
    this.metadata,
  });

  factory RestaurantMenu.fromJson(Map<String, dynamic> json) {
    return RestaurantMenu(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      sections: (json['sections'] as List? ?? [])
          .map((section) => MenuSection.fromJson(section))
          .toList(),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      isActive: json['is_active'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'description': description,
      'sections': sections.map((section) => section.toJson()).toList(),
      'last_updated': lastUpdated.toIso8601String(),
      'is_active': isActive,
      'metadata': metadata,
    };
  }

  /// Obter todos os itens do menu
  List<MenuItem> get allItems {
    return sections
        .where((section) => section.isActive)
        .expand((section) => section.items)
        .toList();
  }

  /// Obter itens por tipo
  List<MenuItem> getItemsByType(MenuItemType type) {
    return allItems.where((item) => item.type == type).toList();
  }

  /// Obter itens populares
  List<MenuItem> get popularItems {
    return allItems.where((item) => item.isPopular).toList();
  }

  /// Obter itens novos
  List<MenuItem> get newItems {
    return allItems.where((item) => item.isNew).toList();
  }

  /// Obter itens com desconto
  List<MenuItem> get discountedItems {
    return allItems.where((item) => item.hasActiveDiscount).toList();
  }
}

/// Configurações do menu
class MenuConfig {
  final bool enableCache;
  final Duration cacheDuration;
  final bool showNutritionalInfo;
  final bool showAllergens;
  final bool enableFilters;
  final bool showPreparationTime;
  final String currency;
  final String locale;

  const MenuConfig({
    this.enableCache = true,
    this.cacheDuration = const Duration(hours: 6),
    this.showNutritionalInfo = true,
    this.showAllergens = true,
    this.enableFilters = true,
    this.showPreparationTime = true,
    this.currency = 'BRL',
    this.locale = 'pt_BR',
  });

  factory MenuConfig.fromJson(Map<String, dynamic> json) {
    return MenuConfig(
      enableCache: json['enable_cache'] as bool? ?? true,
      cacheDuration: Duration(
        milliseconds: json['cache_duration_ms'] as int? ?? 6 * 60 * 60 * 1000,
      ),
      showNutritionalInfo: json['show_nutritional_info'] as bool? ?? true,
      showAllergens: json['show_allergens'] as bool? ?? true,
      enableFilters: json['enable_filters'] as bool? ?? true,
      showPreparationTime: json['show_preparation_time'] as bool? ?? true,
      currency: json['currency'] as String? ?? 'BRL',
      locale: json['locale'] as String? ?? 'pt_BR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enable_cache': enableCache,
      'cache_duration_ms': cacheDuration.inMilliseconds,
      'show_nutritional_info': showNutritionalInfo,
      'show_allergens': showAllergens,
      'enable_filters': enableFilters,
      'show_preparation_time': showPreparationTime,
      'currency': currency,
      'locale': locale,
    };
  }
}

/// Serviço de menu
class MenuService {
  static MenuService? _instance;
  static MenuService get instance => _instance ??= MenuService._();
  MenuService._();

  final CacheService _cacheService = CacheService.instance;
  final ConnectivityService _connectivityService = ConnectivityService.instance;
  final SupabaseService _supabaseService = SupabaseService.instance;

  MenuConfig _config = const MenuConfig();
  final Map<String, RestaurantMenu> _menuCache = {};
  bool _isInitialized = false;

  /// Inicializar o serviço
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Carregar configurações
      await _loadConfig();

      // Carregar cache de menus
      await _loadMenuCache();

      _isInitialized = true;
      debugPrint('MenuService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing MenuService: $e');
      rethrow;
    }
  }

  /// Carregar configurações
  Future<void> _loadConfig() async {
    try {
      final configData = await _cacheService.get('menu_config');
      if (configData != null) {
        _config = MenuConfig.fromJson(configData);
      }
    } catch (e) {
      debugPrint('Error loading menu config: $e');
    }
  }

  /// Salvar configurações
  Future<void> _saveConfig() async {
    try {
      await _cacheService.set(
        'menu_config',
        _config.toJson(),
        duration: const Duration(days: 30),
      );
    } catch (e) {
      debugPrint('Error saving menu config: $e');
    }
  }

  /// Carregar cache de menus
  Future<void> _loadMenuCache() async {
    try {
      final cacheData = await _cacheService.get('menu_cache');
      if (cacheData != null) {
        final Map<String, dynamic> cache = cacheData;
        for (final entry in cache.entries) {
          _menuCache[entry.key] = RestaurantMenu.fromJson(entry.value);
        }
      }
    } catch (e) {
      debugPrint('Error loading menu cache: $e');
    }
  }

  /// Salvar cache de menus
  Future<void> _saveMenuCache() async {
    try {
      final cacheData = <String, dynamic>{};
      for (final entry in _menuCache.entries) {
        cacheData[entry.key] = entry.value.toJson();
      }
      await _cacheService.set(
        'menu_cache',
        cacheData,
        duration: _config.cacheDuration,
      );
    } catch (e) {
      debugPrint('Error saving menu cache: $e');
    }
  }

  /// Obter menu de um restaurante
  Future<RestaurantMenu?> getRestaurantMenu(String restaurantId) async {
    try {
      // Verificar cache primeiro
      if (_config.enableCache && _menuCache.containsKey(restaurantId)) {
        final cachedMenu = _menuCache[restaurantId]!;
        // Verificar se o cache não está muito antigo
        if (DateTime.now().difference(cachedMenu.lastUpdated) < _config.cacheDuration) {
          return cachedMenu;
        }
      }

      // Buscar do servidor se online
      if (_connectivityService.isOnline) {
        final menu = await _fetchMenuFromServer(restaurantId);
        
        if (menu != null) {
          // Atualizar cache
          if (_config.enableCache) {
            _menuCache[restaurantId] = menu;
            await _saveMenuCache();
          }
          
          return menu;
        }
      }

      // Retornar cache mesmo que antigo, se disponível
      return _menuCache[restaurantId];
    } catch (e) {
      debugPrint('Error getting restaurant menu: $e');
      return _menuCache[restaurantId];
    }
  }

  /// Buscar menu do servidor
  Future<RestaurantMenu?> _fetchMenuFromServer(String restaurantId) async {
    try {
      // Simular busca do servidor (implementar com Supabase)
      await Future.delayed(const Duration(milliseconds: 800));
      
      // TODO: Implementar busca real do Supabase
      // final response = await _supabaseService.client
      //     .from('restaurant_menus')
      //     .select('*, sections:menu_sections(*, items:menu_items(*))')
      //     .eq('restaurant_id', restaurantId)
      //     .eq('is_active', true)
      //     .single();
      
      // return RestaurantMenu.fromJson(response);
      
      // Retornar menu de exemplo para demonstração
      return _createSampleMenu(restaurantId);
    } catch (e) {
      debugPrint('Error fetching menu from server: $e');
      return null;
    }
  }

  /// Criar menu de exemplo
  RestaurantMenu _createSampleMenu(String restaurantId) {
    final now = DateTime.now();
    
    return RestaurantMenu(
      id: 'menu_$restaurantId',
      restaurantId: restaurantId,
      name: 'Menu Principal',
      description: 'Nosso delicioso menu com pratos especiais',
      lastUpdated: now,
      sections: [
        MenuSection(
          id: 'section_appetizers',
          restaurantId: restaurantId,
          name: 'Entradas',
          description: 'Deliciosas opções para começar',
          order: 1,
          createdAt: now,
          updatedAt: now,
          items: [
            MenuItem(
              id: 'item_1',
              restaurantId: restaurantId,
              name: 'Bruschetta Italiana',
              description: 'Pão italiano tostado com tomate, manjericão e azeite',
              price: 18.90,
              type: MenuItemType.appetizer,
              ingredients: ['Pão italiano', 'Tomate', 'Manjericão', 'Azeite'],
              tags: ['Vegetariano'],
              preparationTime: 10,
              isPopular: true,
              rating: 4.5,
              createdAt: now,
              updatedAt: now,
              nutritionalInfo: const NutritionalInfo(
                calories: 150,
                isVegetarian: true,
              ),
            ),
            MenuItem(
              id: 'item_2',
              restaurantId: restaurantId,
              name: 'Camarão Empanado',
              description: 'Camarões frescos empanados com molho especial',
              price: 32.90,
              type: MenuItemType.appetizer,
              ingredients: ['Camarão', 'Farinha de rosca', 'Molho especial'],
              tags: ['Frutos do mar'],
              preparationTime: 15,
              rating: 4.8,
              createdAt: now,
              updatedAt: now,
              nutritionalInfo: const NutritionalInfo(
                calories: 280,
                protein: 25,
              ),
            ),
          ],
        ),
        MenuSection(
          id: 'section_mains',
          restaurantId: restaurantId,
          name: 'Pratos Principais',
          description: 'Nossos pratos mais especiais',
          order: 2,
          createdAt: now,
          updatedAt: now,
          items: [
            MenuItem(
              id: 'item_3',
              restaurantId: restaurantId,
              name: 'Salmão Grelhado',
              description: 'Salmão fresco grelhado com legumes e arroz',
              price: 45.90,
              type: MenuItemType.mainCourse,
              ingredients: ['Salmão', 'Legumes', 'Arroz', 'Molho de ervas'],
              tags: ['Peixe', 'Saudável'],
              preparationTime: 25,
              isPopular: true,
              rating: 4.7,
              createdAt: now,
              updatedAt: now,
              nutritionalInfo: const NutritionalInfo(
                calories: 420,
                protein: 35,
                fat: 18,
              ),
            ),
            MenuItem(
              id: 'item_4',
              restaurantId: restaurantId,
              name: 'Risotto de Cogumelos',
              description: 'Risotto cremoso com mix de cogumelos frescos',
              price: 38.90,
              type: MenuItemType.mainCourse,
              ingredients: ['Arroz arbóreo', 'Cogumelos', 'Queijo parmesão', 'Vinho branco'],
              tags: ['Vegetariano', 'Italiano'],
              preparationTime: 30,
              isNew: true,
              rating: 4.6,
              createdAt: now,
              updatedAt: now,
              nutritionalInfo: const NutritionalInfo(
                calories: 380,
                carbs: 45,
                isVegetarian: true,
              ),
            ),
          ],
        ),
        MenuSection(
          id: 'section_desserts',
          restaurantId: restaurantId,
          name: 'Sobremesas',
          description: 'Doces finais perfeitos',
          order: 3,
          createdAt: now,
          updatedAt: now,
          items: [
            MenuItem(
              id: 'item_5',
              restaurantId: restaurantId,
              name: 'Tiramisu',
              description: 'Clássico tiramisu italiano com café e mascarpone',
              price: 16.90,
              type: MenuItemType.dessert,
              ingredients: ['Mascarpone', 'Café', 'Biscoito', 'Cacau'],
              tags: ['Italiano', 'Café'],
              preparationTime: 5,
              isPopular: true,
              rating: 4.9,
              createdAt: now,
              updatedAt: now,
              nutritionalInfo: const NutritionalInfo(
                calories: 320,
                sugar: 25,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Buscar itens do menu
  Future<List<MenuItem>> searchMenuItems(
    String restaurantId,
    String query, {
    MenuItemType? type,
    bool? isVegetarian,
    bool? isVegan,
    bool? isGlutenFree,
    double? maxPrice,
  }) async {
    try {
      final menu = await getRestaurantMenu(restaurantId);
      if (menu == null) return [];

      var items = menu.allItems;

      // Filtrar por texto
      if (query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        items = items.where((item) {
          return item.name.toLowerCase().contains(lowerQuery) ||
                 item.description.toLowerCase().contains(lowerQuery) ||
                 item.ingredients.any((ingredient) => 
                     ingredient.toLowerCase().contains(lowerQuery)) ||
                 item.tags.any((tag) => 
                     tag.toLowerCase().contains(lowerQuery));
        }).toList();
      }

      // Filtrar por tipo
      if (type != null) {
        items = items.where((item) => item.type == type).toList();
      }

      // Filtrar por restrições alimentares
      if (isVegetarian == true) {
        items = items.where((item) => 
            item.nutritionalInfo?.isVegetarian == true).toList();
      }

      if (isVegan == true) {
        items = items.where((item) => 
            item.nutritionalInfo?.isVegan == true).toList();
      }

      if (isGlutenFree == true) {
        items = items.where((item) => 
            item.nutritionalInfo?.isGlutenFree == true).toList();
      }

      // Filtrar por preço
      if (maxPrice != null) {
        items = items.where((item) => item.finalPrice <= maxPrice).toList();
      }

      return items;
    } catch (e) {
      debugPrint('Error searching menu items: $e');
      return [];
    }
  }

  /// Obter item específico do menu
  Future<MenuItem?> getMenuItem(String restaurantId, String itemId) async {
    try {
      final menu = await getRestaurantMenu(restaurantId);
      if (menu == null) return null;

      return menu.allItems.firstWhere(
        (item) => item.id == itemId,
        orElse: () => throw StateError('Item not found'),
      );
    } catch (e) {
      debugPrint('Error getting menu item: $e');
      return null;
    }
  }

  /// Atualizar configurações
  Future<void> updateConfig(MenuConfig config) async {
    _config = config;
    await _saveConfig();
  }

  /// Obter configurações atuais
  MenuConfig get config => _config;

  /// Limpar cache de menus
  Future<void> clearCache() async {
    _menuCache.clear();
    await _cacheService.remove('menu_cache');
  }

  /// Obter estatísticas do menu
  Map<String, dynamic> getStatistics() {
    int totalMenus = _menuCache.length;
    int totalItems = 0;
    int totalSections = 0;
    
    for (final menu in _menuCache.values) {
      totalSections += menu.sections.length;
      totalItems += menu.allItems.length;
    }

    return {
      'total_menus': totalMenus,
      'total_sections': totalSections,
      'total_items': totalItems,
      'cache_size': _menuCache.length,
      'config': _config.toJson(),
    };
  }
}

/// Widget para exibir menu do restaurante
class RestaurantMenuWidget extends StatefulWidget {
  final String restaurantId;
  final bool showPrices;
  final bool showNutritionalInfo;
  final VoidCallback? onItemTap;

  const RestaurantMenuWidget({
    super.key,
    required this.restaurantId,
    this.showPrices = true,
    this.showNutritionalInfo = true,
    this.onItemTap,
  });

  @override
  State<RestaurantMenuWidget> createState() => _RestaurantMenuWidgetState();
}

class _RestaurantMenuWidgetState extends State<RestaurantMenuWidget> {
  final MenuService _menuService = MenuService.instance;
  RestaurantMenu? _menu;
  bool _isLoading = true;
  String _searchQuery = '';
  MenuItemType? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    try {
      final menu = await _menuService.getRestaurantMenu(widget.restaurantId);
      if (mounted) {
        setState(() {
          _menu = menu;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_menu == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Menu não disponível',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Barra de busca e filtros
        _buildSearchAndFilters(),
        
        // Lista de seções do menu
        Expanded(
          child: ListView.builder(
            itemCount: _menu!.sections.length,
            itemBuilder: (context, index) {
              final section = _menu!.sections[index];
              return _buildMenuSection(section);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Campo de busca
          TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar no menu...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          
          const SizedBox(height: 8),
          
          // Filtros por tipo
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Todos', null),
                _buildFilterChip('Entradas', MenuItemType.appetizer),
                _buildFilterChip('Principais', MenuItemType.mainCourse),
                _buildFilterChip('Sobremesas', MenuItemType.dessert),
                _buildFilterChip('Bebidas', MenuItemType.beverage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, MenuItemType? type) {
    final isSelected = _selectedType == type;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedType = selected ? type : null;
          });
        },
      ),
    );
  }

  Widget _buildMenuSection(MenuSection section) {
    // Filtrar itens da seção
    var items = section.items;
    
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      items = items.where((item) {
        return item.name.toLowerCase().contains(lowerQuery) ||
               item.description.toLowerCase().contains(lowerQuery);
      }).toList();
    }
    
    if (_selectedType != null) {
      items = items.where((item) => item.type == _selectedType).toList();
    }
    
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho da seção
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (section.description != null) ..[
                const SizedBox(height: 4),
                Text(
                  section.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Itens da seção
        ...items.map((item) => _buildMenuItem(item)),
        
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: item.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant),
                    );
                  },
                ),
              )
            : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.restaurant),
              ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (item.isNew)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'NOVO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (item.isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description),
            const SizedBox(height: 4),
            if (widget.showPrices)
              Row(
                children: [
                  if (item.hasActiveDiscount) ..[
                    Text(
                      'R\$ ${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    'R\$ ${item.finalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: item.hasActiveDiscount ? Colors.green : null,
                    ),
                  ),
                ],
              ),
            if (item.preparationTime > 0)
              Text(
                '⏱️ ${item.preparationTime} min',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            if (widget.showNutritionalInfo && item.nutritionalInfo != null)
              Wrap(
                spacing: 4,
                children: [
                  if (item.nutritionalInfo!.isVegetarian)
                    const Chip(
                      label: Text('Vegetariano'),
                      backgroundColor: Colors.green,
                      labelStyle: TextStyle(color: Colors.white, fontSize: 10),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  if (item.nutritionalInfo!.isVegan)
                    const Chip(
                      label: Text('Vegano'),
                      backgroundColor: Colors.lightGreen,
                      labelStyle: TextStyle(color: Colors.white, fontSize: 10),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  if (item.nutritionalInfo!.isGlutenFree)
                    const Chip(
                      label: Text('Sem Glúten'),
                      backgroundColor: Colors.blue,
                      labelStyle: TextStyle(color: Colors.white, fontSize: 10),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
          ],
        ),
        onTap: widget.onItemTap,
        isThreeLine: true,
      ),
    );
  }
}
