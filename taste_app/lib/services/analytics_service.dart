import 'package:flutter/foundation.dart';
// TODO: Adicionar Firebase Analytics quando necessário
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Tipos de eventos de analytics
enum AnalyticsEventType {
  // Eventos de navegação
  screenView,
  pageView,
  navigation,
  
  // Eventos de interação
  buttonTap,
  search,
  filter,
  
  // Eventos de restaurante
  restaurantView,
  restaurantFavorite,
  restaurantShare,
  restaurantCall,
  restaurantDirections,
  
  // Eventos de usuário
  userLogin,
  userLogout,
  userRegister,
  profileUpdate,
  
  // Eventos de deep link
  deepLinkReceived,
  deepLinkProcessed,
  
  // Eventos de erro
  error,
  crash,
  
  // Eventos de performance
  loadTime,
  apiResponse,
  
  // Eventos personalizados
  custom,
}

/// Serviço centralizado para analytics e monitoring
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  static AnalyticsService get instance => _instance;
  AnalyticsService._internal();

  // FirebaseAnalytics? _analytics;
  // FirebaseCrashlytics? _crashlytics;
  bool _isInitialized = false;

  /// Inicializa o serviço de analytics
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // TODO: Inicializar Firebase Analytics quando disponível
      // _analytics = FirebaseAnalytics.instance;
      // _crashlytics = FirebaseCrashlytics.instance;
      
      _isInitialized = true;
      
      // Log de inicialização
      await logEvent('analytics_initialized', {
        'timestamp': DateTime.now().toIso8601String(),
        'platform': defaultTargetPlatform.name,
      });
      
      debugPrint('✅ AnalyticsService inicializado com sucesso (modo local)');
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao inicializar AnalyticsService: $e');
      await recordError(e, stackTrace);
    }
  }

  /// Registra um evento personalizado
  Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    if (!_isInitialized) return;

    try {
      // TODO: Integrar com Firebase Analytics quando disponível
      // await _analytics!.logEvent(name: name, parameters: parameters);
      
      if (kDebugMode) {
        debugPrint('📊 Analytics Event: $name - $parameters');
      }
    } catch (e) {
      debugPrint('❌ Erro ao registrar evento: $e');
    }
  }

  /// Registra login do usuário
  Future<void> logLogin(String method) async {
    await logEvent('login', {
      'method': method,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Registra logout do usuário
  Future<void> logLogout() async {
    await logEvent('logout', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Registra visualização de tela
  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    if (!_isInitialized) return;

    try {
      // TODO: Integrar com Firebase Analytics quando disponível
      // await _analytics!.logScreenView(screenName: screenName, screenClass: screenClass ?? screenName);
      
      if (kDebugMode) {
        debugPrint('📱 Screen View: $screenName');
      }
    } catch (e) {
      debugPrint('❌ Erro ao registrar visualização de tela: $e');
    }
  }

  /// Registra busca
  Future<void> logSearch(String searchTerm, {String? category}) async {
    await logEvent('search', {
      'search_term': searchTerm,
      'category': category,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Alias para logSearch para compatibilidade
  Future<void> trackSearch(String searchTerm, {String? category, Map<String, dynamic>? parameters}) async {
    await logSearch(searchTerm, category: category);
  }

  /// Registra seleção de restaurante
  Future<void> logSelectRestaurant(String restaurantId, String restaurantName) async {
    await logEvent('select_restaurant', {
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Registra adição ao carrinho
  Future<void> logAddToCart(String itemId, String itemName, double price) async {
    await logEvent('add_to_cart', {
      'item_id': itemId,
      'item_name': itemName,
      'price': price,
      'currency': 'BRL',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Registra remoção do carrinho
  Future<void> logRemoveFromCart(String itemId, String itemName) async {
    await logEvent('remove_from_cart', {
      'item_id': itemId,
      'item_name': itemName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Registra início do checkout
  Future<void> logBeginCheckout(double value, String currency) async {
    await logEvent('begin_checkout', {
      'value': value,
      'currency': currency,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Registra compra
  Future<void> logPurchase({
    required String transactionId,
    required double value,
    required String currency,
    required List<Map<String, dynamic>> items,
  }) async {
    await logEvent('purchase', {
      'transaction_id': transactionId,
      'value': value,
      'currency': currency,
      'items': items,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Registra avaliação
  Future<void> logRating(String itemId, String itemType, double rating) async {
    await logEvent('rate_item', {
      'item_id': itemId,
      'item_type': itemType,
      'rating': rating,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Registra compartilhamento
  Future<void> logShare(String contentType, String itemId) async {
    await logEvent('share', {
      'content_type': contentType,
      'item_id': itemId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Define propriedades do usuário
  Future<void> setUserProperties(Map<String, String> properties) async {
    if (!_isInitialized) return;

    try {
      // TODO: Integrar com Firebase Analytics quando disponível
      // for (final entry in properties.entries) {
      //   await _analytics!.setUserProperty(name: entry.key, value: entry.value);
      // }
      
      if (kDebugMode) {
        debugPrint('👤 User Properties: $properties');
      }
    } catch (e) {
      debugPrint('❌ Erro ao definir propriedades do usuário: $e');
    }
  }

  /// Define ID do usuário
  Future<void> setUserId(String userId) async {
    if (!_isInitialized) return;

    try {
      // TODO: Integrar com Firebase Analytics quando disponível
      // await _analytics!.setUserId(id: userId);
      // await _crashlytics?.setUserIdentifier(userId);
      
      if (kDebugMode) {
        debugPrint('👤 User ID definido: $userId');
      }
    } catch (e) {
      debugPrint('❌ Erro ao definir ID do usuário: $e');
    }
  }

  /// Registra erro personalizado
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? customKeys,
  }) async {
    if (!_isInitialized) return;

    try {
      // TODO: Integrar com Firebase Crashlytics quando disponível
      // if (customKeys != null) {
      //   for (final entry in customKeys.entries) {
      //     await _crashlytics!.setCustomKey(entry.key, entry.value);
      //   }
      // }
      // await _crashlytics!.recordError(exception, stackTrace, reason: reason, fatal: fatal);
      
      if (kDebugMode) {
        debugPrint('🐛 Erro registrado: $exception');
        if (stackTrace != null) {
          debugPrint('Stack trace: $stackTrace');
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao registrar erro: $e');
    }
  }

  /// Registra log personalizado
  Future<void> log(String message, {Map<String, dynamic>? data}) async {
    if (!_isInitialized) return;

    try {
      final logMessage = data != null 
          ? '$message - Data: $data'
          : message;
          
      // TODO: Integrar com Firebase Crashlytics quando disponível
      // await _crashlytics!.log(logMessage);
      
      if (kDebugMode) {
        debugPrint('📝 Log: $logMessage');
      }
    } catch (e) {
      debugPrint('❌ Erro ao registrar log: $e');
    }
  }

  /// Força envio de relatórios de crash pendentes
  Future<void> sendUnsentReports() async {
    if (!_isInitialized) return;

    try {
      // TODO: Integrar com Firebase Crashlytics quando disponível
      // await _crashlytics!.sendUnsentReports();
      debugPrint('📤 Relatórios de crash enviados (modo local)');
    } catch (e) {
      debugPrint('❌ Erro ao enviar relatórios: $e');
    }
  }

  /// Verifica se a coleta de crash está habilitada
  Future<bool> isCrashlyticsCollectionEnabled() async {
    if (!_isInitialized) return false;

    try {
      // TODO: Integrar com Firebase Crashlytics quando disponível
      // return await _crashlytics!.isCrashlyticsCollectionEnabled();
      return true; // Retorna true por padrão no modo local
    } catch (e) {
      debugPrint('❌ Erro ao verificar status do Crashlytics: $e');
      return false;
    }
  }

  /// Habilita/desabilita coleta de crash
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    if (!_isInitialized) return;

    try {
      // TODO: Integrar com Firebase Crashlytics quando disponível
      // await _crashlytics!.setCrashlyticsCollectionEnabled(enabled);
      debugPrint('🔧 Crashlytics collection: ${enabled ? "habilitado" : "desabilitado"}');
    } catch (e) {
      debugPrint('❌ Erro ao configurar Crashlytics: $e');
    }
  }

  /// Limpa dados do usuário (LGPD/GDPR)
  Future<void> clearUserData() async {
    try {
      await setUserId('');
      await setUserProperties({});
      
      debugPrint('🧹 Dados do usuário limpos');
    } catch (e) {
      debugPrint('❌ Erro ao limpar dados do usuário: $e');
    }
  }

  /// Getter para verificar se está inicializado
  bool get isInitialized => _isInitialized;
  
  /// Alias para logEvent (compatibilidade com código existente)
  Future<void> trackEvent(String name, {Map<String, dynamic>? parameters}) async {
    await logEvent(name, parameters);
  }
}