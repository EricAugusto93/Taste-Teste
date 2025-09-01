import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/cart_model.dart';
import '../../models/cart_item_model.dart';
import '../../models/restaurant_model.dart';
import '../../../core/enums/delivery_type.dart';

/// Serviço para gerenciar o carrinho de compras
class CartService {
  static const String _cartKey = 'user_cart';
  static const String _cartHistoryKey = 'cart_history';
  static const String _deliveryTypeKey = 'delivery_type';
  
  DeliveryType _currentDeliveryType = DeliveryType.delivery;
  
  /// Códigos promocionais disponíveis (simulação)
  static const Map<String, double> _promoCodes = {
    'PRIMEIRA10': 10.0,
    'DESCONTO15': 15.0,
    'FRETEGRATIS': 0.0, // Desconto no frete
    'SABADO20': 20.0,
    'BEMVINDO': 5.0,
  };

  /// Obtém o carrinho atual
  Future<CartModel> getCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);
      
      if (cartJson != null) {
        final cartData = jsonDecode(cartJson) as Map<String, dynamic>;
        return CartModel.fromJson(cartData);
      }
      
      return CartModel.empty();
    } catch (e) {
      // Se houver erro ao carregar, retorna carrinho vazio
      return CartModel.empty();
    }
  }

  /// Salva o carrinho
  Future<void> saveCart(CartModel cart) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(cart.toJson());
      await prefs.setString(_cartKey, cartJson);
      
      // Salva no histórico se o carrinho não estiver vazio
      if (cart.isNotEmpty) {
        await _saveToHistory(cart);
      }
    } catch (e) {
      throw Exception('Erro ao salvar carrinho: $e');
    }
  }

  /// Limpa o carrinho
  Future<void> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartKey);
    } catch (e) {
      throw Exception('Erro ao limpar carrinho: $e');
    }
  }

  /// Valida um código promocional
  Future<double> validatePromoCode(String code, double subtotal) async {
    // Simula delay de validação
    await Future.delayed(const Duration(milliseconds: 500));
    
    final upperCode = code.toUpperCase();
    
    if (!_promoCodes.containsKey(upperCode)) {
      throw Exception('Código promocional inválido');
    }
    
    final discountValue = _promoCodes[upperCode]!;
    
    // Códigos especiais
    switch (upperCode) {
      case 'FRETEGRATIS':
        return 0.0; // Será tratado separadamente para o frete
      case 'PRIMEIRA10':
        // 10% de desconto, máximo R$ 20
        return (subtotal * 0.10).clamp(0.0, 20.0);
      case 'DESCONTO15':
        // 15% de desconto, máximo R$ 30
        return (subtotal * 0.15).clamp(0.0, 30.0);
      case 'SABADO20':
        // Válido apenas aos sábados
        if (DateTime.now().weekday != DateTime.saturday) {
          throw Exception('Este código é válido apenas aos sábados');
        }
        return (subtotal * 0.20).clamp(0.0, 50.0);
      case 'BEMVINDO':
        // Desconto fixo de R$ 5 para pedidos acima de R$ 30
        if (subtotal < 30.0) {
          throw Exception('Pedido mínimo de R\$ 30,00 para este código');
        }
        return 5.0;
      default:
        return discountValue;
    }
  }

  /// Verifica se um código promocional oferece frete grátis
  bool isDeliveryFreeCode(String code) {
    return code.toUpperCase() == 'FRETEGRATIS';
  }

  /// Obtém sugestões de códigos promocionais
  List<String> getPromoCodeSuggestions() {
    return _promoCodes.keys.toList();
  }

  /// Calcula o tempo estimado de entrega
  String calculateDeliveryTime(RestaurantModel restaurant) {
    // Simula cálculo baseado na distância e horário
    final now = DateTime.now();
    final hour = now.hour;
    
    // Horário de pico (12h-14h e 19h-21h)
    final isPeakHour = (hour >= 12 && hour <= 14) || (hour >= 19 && hour <= 21);
    
    // Tempo base do restaurante
    final baseTime = restaurant.deliveryTime;
    
    if (isPeakHour) {
      return '${_addMinutes(baseTime, 10)} (horário de pico)';
    }
    
    return baseTime;
  }

  /// Adiciona minutos ao tempo de entrega
  String _addMinutes(String timeRange, int additionalMinutes) {
    // Extrai os números do formato "30-45 min"
    final regex = RegExp(r'(\d+)-(\d+)');
    final match = regex.firstMatch(timeRange);
    
    if (match != null) {
      final minTime = int.parse(match.group(1)!) + additionalMinutes;
      final maxTime = int.parse(match.group(2)!) + additionalMinutes;
      return '$minTime-$maxTime min';
    }
    
    return timeRange;
  }

  /// Verifica se o restaurante está aberto
  bool isRestaurantOpen(RestaurantModel restaurant) {
    final now = DateTime.now();
    final currentHour = now.hour;
    
    // Simula horário de funcionamento (8h às 23h)
    return currentHour >= 8 && currentHour < 23;
  }

  /// Calcula a taxa de entrega baseada na distância
  double calculateDeliveryFee(double? distance) {
    if (distance == null) return 5.0; // Taxa padrão
    
    if (distance <= 2.0) return 3.0;
    if (distance <= 5.0) return 5.0;
    if (distance <= 10.0) return 8.0;
    
    return 12.0; // Distâncias maiores
  }

  /// Salva o carrinho no histórico
  Future<void> _saveToHistory(CartModel cart) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_cartHistoryKey);
      
      List<Map<String, dynamic>> history = [];
      if (historyJson != null) {
        final historyData = jsonDecode(historyJson) as List<dynamic>;
        history = historyData.cast<Map<String, dynamic>>();
      }
      
      // Adiciona o carrinho atual ao histórico
      history.insert(0, cart.toJson());
      
      // Mantém apenas os últimos 10 carrinhos
      if (history.length > 10) {
        history = history.take(10).toList();
      }
      
      await prefs.setString(_cartHistoryKey, jsonEncode(history));
    } catch (e) {
      // Falha silenciosa no histórico
    }
  }

  /// Obtém o histórico de carrinhos
  Future<List<CartModel>> getCartHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_cartHistoryKey);
      
      if (historyJson != null) {
        final historyData = jsonDecode(historyJson) as List<dynamic>;
        return historyData
            .cast<Map<String, dynamic>>()
            .map((cartData) => CartModel.fromJson(cartData))
            .toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Restaura um carrinho do histórico
  Future<void> restoreFromHistory(CartModel cart) async {
    await saveCart(cart.copyWith(
      id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
      updatedAt: DateTime.now(),
      isActive: true,
    ));
  }

  /// Verifica se há itens indisponíveis no carrinho
  Future<List<CartItemModel>> checkItemAvailability(CartModel cart) async {
    // Simula verificação de disponibilidade
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Por enquanto, retorna lista vazia (todos disponíveis)
    // Em uma implementação real, consultaria a API do restaurante
    return [];
  }

  /// Estima o valor total com impostos
  double calculateTotalWithTax(CartModel cart) {
    // Simula cálculo de impostos (5% sobre o subtotal)
    final tax = cart.subtotal * 0.05;
    return cart.total + tax;
  }

  /// Verifica se o pedido pode ser processado
  Future<bool> canProcessOrder(CartModel cart) async {
    if (cart.isEmpty) return false;
    if (!cart.meetsMinimumOrder) return false;
    if (!cart.allItemsAvailable) return false;
    
    // Verifica se o restaurante está aberto
    if (cart.restaurant != null && !isRestaurantOpen(cart.restaurant!)) {
      return false;
    }
    
    return true;
  }

  /// Define o tipo de entrega
  Future<void> setDeliveryType(DeliveryType type) async {
    try {
      _currentDeliveryType = type;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_deliveryTypeKey, type.value);
    } catch (e) {
      throw Exception('Erro ao definir tipo de entrega: $e');
    }
  }

  /// Obtém o tipo de entrega atual
  Future<DeliveryType> getDeliveryType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final typeValue = prefs.getString(_deliveryTypeKey);
      
      if (typeValue != null) {
        _currentDeliveryType = DeliveryType.fromString(typeValue);
      }
      
      return _currentDeliveryType;
    } catch (e) {
      return DeliveryType.delivery; // Padrão
    }
  }

  /// Obtém o tipo de entrega atual (síncrono)
  DeliveryType get currentDeliveryType => _currentDeliveryType;

  /// Obtém informações de entrega
  Map<String, dynamic> getDeliveryInfo(CartModel cart) {
    if (cart.restaurant == null) {
      return {
        'canDeliver': false,
        'reason': 'Restaurante não selecionado',
      };
    }
    
    final restaurant = cart.restaurant!;
    final isOpen = isRestaurantOpen(restaurant);
    
    return {
      'canDeliver': isOpen,
      'reason': isOpen ? null : 'Restaurante fechado',
      'estimatedTime': calculateDeliveryTime(restaurant),
      'deliveryFee': _currentDeliveryType.isPickup ? 0.0 : cart.deliveryFee,
      'minimumOrder': restaurant.minOrderValue,
      'meetsMinimum': cart.meetsMinimumOrder,
      'deliveryType': _currentDeliveryType,
    };
  }
}
