/// Utility class for mapping restaurant categories to emojis
class CategoryEmojiMapper {
  // Default emoji mapping based on category IDs from the database
  static const Map<String, String> _categoryIdToEmoji = {
    '32555c5c-b206-4c31-9e4d-1cf5d68d1e8d': '🍝', // Date night - Italiana
    '948a606b-78ff-4bcd-9d37-f14ec5654e25': '☕', // Happy Hour de Firma - Café
    '0a575266-ee8e-4c72-82e9-2a85359682cb': '🥗', // Com vibe leve - Saudável
    '875498c4-1853-4b84-aa5e-a05a3a902574': '🏛️', // Clássicos POA
    'a945c6bb-0554-4181-831c-17928864ee52': '🍰', // Vontade de Doce - Doceria
    'c9fdb068-aff4-4fe1-84ff-10974d62fba9': '🍽️', // Almoço de Domingo - Buffet
    '3b9168dc-f187-40e3-8921-7780d5195d8b': '🍸', // Happy Hour alternativo - Updated to cocktail
    '1417ab7f-338c-4dd4-96d7-87bcaa8099bf': '🍣', // Sushi fresh - Japonesa
    '45a122d2-d5fd-4e20-ab17-2d1a1699c3e0': '🍔', // Para curar ressaca - Hambúrguer
    'dfadf4da-3c7b-4d85-b6da-5b0bddd60195': '🍕', // Clássicos Curitiba - Pizzaria
  };

  // Updated emoji mapping based on your specifications (no duplicates)
  static const Map<String, String> _categoryNameToEmoji = {
    // Coffee & Café
    'café': '☕',
    'cafe': '☕',
    'coffee': '☕',
    'cafeteria': '☕',
    
    // Bar & Drinks
    'bar': '🍸',
    'happy hour': '🍸',
    'pub': '🍸',
    'cervejaria': '🍸',
    'brewery': '🍸',
    'drinks': '🍸',
    'cocktail': '🍸',
    
    // Bakery & Bread
    'padaria': '🥐',
    'bakery': '🥐',
    'confeitaria': '🧁',
    
    // General Restaurant
    'restaurante': '🍽️',
    'restaurant': '🍽️',
    'buffet': '🍽️',
    'self-service': '🍽️',
    
    // Shopping
    'shopping': '🛍️',
    'mall': '🛍️',
    'loja': '🛍️',
    'store': '🛍️',
    
    // Italian
    'italiana': '🍝',
    'italian': '🍝',
    'italiano': '🍝',
    
    // Healthy & Salads
    'saudável': '🥗',
    'healthy': '🥗',
    'salada': '🥗',
    'salads': '🥗',
    'natural': '🥗',
    'vegano': '🌱',
    'vegan': '🌱',
    'vegetariano': '🌱',
    'vegetarian': '🌱',
    
    // Traditional/Classic
    'clássico': '🏛️',
    'classic': '🏛️',
    'tradicional': '🏛️',
    'traditional': '🏛️',
    
    // Desserts & Sweets
    'doceria': '🍰',
    'dessert': '🍰',
    'doce': '🍰',
    'sweet': '🍰',
    'sobremesa': '🍰',
    
    // Japanese
    'japonesa': '🍣',
    'japanese': '🍣',
    'sushi': '🍣',
    'oriental': '🥢',
    
    // Burgers
    'hambúrguer': '🍔',
    'hamburger': '🍔',
    'burger': '🍔',
    'lanche': '🍔',
    'sandwich': '🥪',
    
    // Pizza
    'pizza': '🍕',
    'pizzaria': '🍕',
    
    // Mexican
    'mexicana': '🌮',
    'mexican': '🌮',
    'tex-mex': '🌮',
    
    // Chinese
    'chinesa': '🥡',
    'chinese': '🥡',
    
    // Brazilian
    'brasileira': '🇧🇷',
    'brazilian': '🇧🇷',
    'churrasco': '🥩',
    'barbecue': '🥩',
    'churrascaria': '🥩',
    
    // Seafood
    'frutos do mar': '🦐',
    'seafood': '🦐',
    'peixe': '🐟',
    'fish': '🐟',
    
    // Fast Food
    'fast food': '🍟',
    'lanchonete': '🍟',
    'delivery': '🛵',
    
    // Ice cream & Frozen
    'sorveteria': '🍦',
    'ice cream': '🍦',
    'açaí': '🍇',
    
    // Regional cuisines
    'árabe': '🥙',
    'arabic': '🥙',
    'indiana': '🍛',
    'indian': '🍛',
    'francesa': '🥖',
    'french': '🥖',
    'alemã': '🍺',
    'german': '🍺',
  };

  /// Default emoji for unknown categories
  static const String defaultEmoji = '🍽️';

  /// Gets emoji for a restaurant category by ID
  static String getEmojiByCategory({
    String? categoryId,
    String? categoryName,
    String? restaurantEmoji,
  }) {
    // 1. First priority: restaurant's own emoji field
    if (restaurantEmoji != null && restaurantEmoji.isNotEmpty) {
      return restaurantEmoji;
    }

    // 2. Second priority: category ID mapping
    if (categoryId != null && _categoryIdToEmoji.containsKey(categoryId)) {
      return _categoryIdToEmoji[categoryId]!;
    }

    // 3. Third priority: category name mapping
    if (categoryName != null && categoryName.isNotEmpty) {
      final normalizedName = categoryName.toLowerCase().trim();
      
      // Try exact match first
      if (_categoryNameToEmoji.containsKey(normalizedName)) {
        return _categoryNameToEmoji[normalizedName]!;
      }
      
      // Try partial matches for compound names
      for (final entry in _categoryNameToEmoji.entries) {
        if (normalizedName.contains(entry.key) || entry.key.contains(normalizedName)) {
          return entry.value;
        }
      }
    }

    // 4. Fallback to default
    return defaultEmoji;
  }

  /// Gets all available category emojis
  static List<String> getAllEmojis() {
    final allEmojis = <String>{};
    allEmojis.addAll(_categoryIdToEmoji.values);
    allEmojis.addAll(_categoryNameToEmoji.values);
    allEmojis.add(defaultEmoji);
    return allEmojis.toList();
  }

  /// Validates if an emoji is supported
  static bool isEmojiSupported(String emoji) {
    return getAllEmojis().contains(emoji);
  }

  /// Gets a map of all category ID mappings
  static Map<String, String> getCategoryIdMappings() {
    return Map.unmodifiable(_categoryIdToEmoji);
  }

  /// Gets a map of all category name mappings
  static Map<String, String> getCategoryNameMappings() {
    return Map.unmodifiable(_categoryNameToEmoji);
  }

  /// Updates category mapping (useful for dynamic categories from API)
  static final Map<String, String> _dynamicMappings = <String, String>{};
  
  static void addDynamicMapping(String categoryId, String emoji) {
    _dynamicMappings[categoryId] = emoji;
  }

  static void clearDynamicMappings() {
    _dynamicMappings.clear();
  }

  /// Gets emoji including dynamic mappings
  static String getEmojiWithDynamic({
    String? categoryId,
    String? categoryName,
    String? restaurantEmoji,
  }) {
    // Check dynamic mappings first
    if (categoryId != null && _dynamicMappings.containsKey(categoryId)) {
      return _dynamicMappings[categoryId]!;
    }

    return getEmojiByCategory(
      categoryId: categoryId,
      categoryName: categoryName,
      restaurantEmoji: restaurantEmoji,
    );
  }
}