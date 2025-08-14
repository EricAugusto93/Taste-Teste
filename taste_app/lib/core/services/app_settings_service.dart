import 'dart:async';
import 'package:flutter/material.dart';
import 'package:taste_app/core/services/cache_service.dart';

/// Tema do aplicativo
enum AppTheme {
  light,
  dark,
  system,
}

/// Idioma do aplicativo
enum AppLanguage {
  portuguese('pt', 'Português'),
  english('en', 'English'),
  spanish('es', 'Español'),
  system('system', 'Sistema');
  
  const AppLanguage(this.code, this.name);
  final String code;
  final String name;
}

/// Unidade de distância
enum DistanceUnit {
  kilometers('km', 'Quilômetros'),
  miles('mi', 'Milhas');
  
  const DistanceUnit(this.code, this.name);
  final String code;
  final String name;
}

/// Formato de moeda
enum CurrencyFormat {
  brl('BRL', 'R\$', 'Real Brasileiro'),
  usd('USD', '\$', 'Dólar Americano'),
  eur('EUR', '€', 'Euro');
  
  const CurrencyFormat(this.code, this.symbol, this.name);
  final String code;
  final String symbol;
  final String name;
}

/// Configurações de notificação
class NotificationSettings {
  final bool enabled;
  final bool pushNotifications;
  final bool emailNotifications;
  final bool promotionalNotifications;
  final bool favoriteRestaurantUpdates;
  final bool newRestaurantAlerts;
  final bool reviewReminders;
  final TimeOfDay? quietHoursStart;
  final TimeOfDay? quietHoursEnd;
  
  const NotificationSettings({
    this.enabled = true,
    this.pushNotifications = true,
    this.emailNotifications = false,
    this.promotionalNotifications = false,
    this.favoriteRestaurantUpdates = true,
    this.newRestaurantAlerts = false,
    this.reviewReminders = true,
    this.quietHoursStart,
    this.quietHoursEnd,
  });
  
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] as bool? ?? true,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      emailNotifications: json['emailNotifications'] as bool? ?? false,
      promotionalNotifications: json['promotionalNotifications'] as bool? ?? false,
      favoriteRestaurantUpdates: json['favoriteRestaurantUpdates'] as bool? ?? true,
      newRestaurantAlerts: json['newRestaurantAlerts'] as bool? ?? false,
      reviewReminders: json['reviewReminders'] as bool? ?? true,
      quietHoursStart: json['quietHoursStart'] != null
          ? TimeOfDay(
              hour: json['quietHoursStart']['hour'] as int,
              minute: json['quietHoursStart']['minute'] as int,
            )
          : null,
      quietHoursEnd: json['quietHoursEnd'] != null
          ? TimeOfDay(
              hour: json['quietHoursEnd']['hour'] as int,
              minute: json['quietHoursEnd']['minute'] as int,
            )
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'promotionalNotifications': promotionalNotifications,
      'favoriteRestaurantUpdates': favoriteRestaurantUpdates,
      'newRestaurantAlerts': newRestaurantAlerts,
      'reviewReminders': reviewReminders,
      'quietHoursStart': quietHoursStart != null
          ? {
              'hour': quietHoursStart!.hour,
              'minute': quietHoursStart!.minute,
            }
          : null,
      'quietHoursEnd': quietHoursEnd != null
          ? {
              'hour': quietHoursEnd!.hour,
              'minute': quietHoursEnd!.minute,
            }
          : null,
    };
  }
  
  NotificationSettings copyWith({
    bool? enabled,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? promotionalNotifications,
    bool? favoriteRestaurantUpdates,
    bool? newRestaurantAlerts,
    bool? reviewReminders,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      promotionalNotifications: promotionalNotifications ?? this.promotionalNotifications,
      favoriteRestaurantUpdates: favoriteRestaurantUpdates ?? this.favoriteRestaurantUpdates,
      newRestaurantAlerts: newRestaurantAlerts ?? this.newRestaurantAlerts,
      reviewReminders: reviewReminders ?? this.reviewReminders,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}

/// Configurações de privacidade
class PrivacySettings {
  final bool shareLocation;
  final bool shareUsageData;
  final bool personalizedAds;
  final bool crashReporting;
  final bool analyticsTracking;
  final bool profileVisibility;
  final bool reviewVisibility;
  
  const PrivacySettings({
    this.shareLocation = true,
    this.shareUsageData = false,
    this.personalizedAds = false,
    this.crashReporting = true,
    this.analyticsTracking = false,
    this.profileVisibility = true,
    this.reviewVisibility = true,
  });
  
  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      shareLocation: json['shareLocation'] as bool? ?? true,
      shareUsageData: json['shareUsageData'] as bool? ?? false,
      personalizedAds: json['personalizedAds'] as bool? ?? false,
      crashReporting: json['crashReporting'] as bool? ?? true,
      analyticsTracking: json['analyticsTracking'] as bool? ?? false,
      profileVisibility: json['profileVisibility'] as bool? ?? true,
      reviewVisibility: json['reviewVisibility'] as bool? ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'shareLocation': shareLocation,
      'shareUsageData': shareUsageData,
      'personalizedAds': personalizedAds,
      'crashReporting': crashReporting,
      'analyticsTracking': analyticsTracking,
      'profileVisibility': profileVisibility,
      'reviewVisibility': reviewVisibility,
    };
  }
  
  PrivacySettings copyWith({
    bool? shareLocation,
    bool? shareUsageData,
    bool? personalizedAds,
    bool? crashReporting,
    bool? analyticsTracking,
    bool? profileVisibility,
    bool? reviewVisibility,
  }) {
    return PrivacySettings(
      shareLocation: shareLocation ?? this.shareLocation,
      shareUsageData: shareUsageData ?? this.shareUsageData,
      personalizedAds: personalizedAds ?? this.personalizedAds,
      crashReporting: crashReporting ?? this.crashReporting,
      analyticsTracking: analyticsTracking ?? this.analyticsTracking,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      reviewVisibility: reviewVisibility ?? this.reviewVisibility,
    );
  }
}

/// Configurações do aplicativo
class AppSettings {
  final AppTheme theme;
  final AppLanguage language;
  final DistanceUnit distanceUnit;
  final CurrencyFormat currencyFormat;
  final NotificationSettings notifications;
  final PrivacySettings privacy;
  final bool offlineMode;
  final bool autoSync;
  final bool hapticFeedback;
  final bool soundEffects;
  final double mapZoomLevel;
  final int searchRadius;
  final bool showOnboarding;
  final DateTime? lastSyncTime;
  
  const AppSettings({
    this.theme = AppTheme.system,
    this.language = AppLanguage.system,
    this.distanceUnit = DistanceUnit.kilometers,
    this.currencyFormat = CurrencyFormat.brl,
    this.notifications = const NotificationSettings(),
    this.privacy = const PrivacySettings(),
    this.offlineMode = false,
    this.autoSync = true,
    this.hapticFeedback = true,
    this.soundEffects = true,
    this.mapZoomLevel = 15.0,
    this.searchRadius = 5000,
    this.showOnboarding = true,
    this.lastSyncTime,
  });
  
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      theme: AppTheme.values.firstWhere(
        (e) => e.name == json['theme'],
        orElse: () => AppTheme.system,
      ),
      language: AppLanguage.values.firstWhere(
        (e) => e.code == json['language'],
        orElse: () => AppLanguage.system,
      ),
      distanceUnit: DistanceUnit.values.firstWhere(
        (e) => e.code == json['distanceUnit'],
        orElse: () => DistanceUnit.kilometers,
      ),
      currencyFormat: CurrencyFormat.values.firstWhere(
        (e) => e.code == json['currencyFormat'],
        orElse: () => CurrencyFormat.brl,
      ),
      notifications: json['notifications'] != null
          ? NotificationSettings.fromJson(json['notifications'] as Map<String, dynamic>)
          : const NotificationSettings(),
      privacy: json['privacy'] != null
          ? PrivacySettings.fromJson(json['privacy'] as Map<String, dynamic>)
          : const PrivacySettings(),
      offlineMode: json['offlineMode'] as bool? ?? false,
      autoSync: json['autoSync'] as bool? ?? true,
      hapticFeedback: json['hapticFeedback'] as bool? ?? true,
      soundEffects: json['soundEffects'] as bool? ?? true,
      mapZoomLevel: (json['mapZoomLevel'] as num?)?.toDouble() ?? 15.0,
      searchRadius: json['searchRadius'] as int? ?? 5000,
      showOnboarding: json['showOnboarding'] as bool? ?? true,
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.parse(json['lastSyncTime'] as String)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'theme': theme.name,
      'language': language.code,
      'distanceUnit': distanceUnit.code,
      'currencyFormat': currencyFormat.code,
      'notifications': notifications.toJson(),
      'privacy': privacy.toJson(),
      'offlineMode': offlineMode,
      'autoSync': autoSync,
      'hapticFeedback': hapticFeedback,
      'soundEffects': soundEffects,
      'mapZoomLevel': mapZoomLevel,
      'searchRadius': searchRadius,
      'showOnboarding': showOnboarding,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
    };
  }
  
  AppSettings copyWith({
    AppTheme? theme,
    AppLanguage? language,
    DistanceUnit? distanceUnit,
    CurrencyFormat? currencyFormat,
    NotificationSettings? notifications,
    PrivacySettings? privacy,
    bool? offlineMode,
    bool? autoSync,
    bool? hapticFeedback,
    bool? soundEffects,
    double? mapZoomLevel,
    int? searchRadius,
    bool? showOnboarding,
    DateTime? lastSyncTime,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      currencyFormat: currencyFormat ?? this.currencyFormat,
      notifications: notifications ?? this.notifications,
      privacy: privacy ?? this.privacy,
      offlineMode: offlineMode ?? this.offlineMode,
      autoSync: autoSync ?? this.autoSync,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      soundEffects: soundEffects ?? this.soundEffects,
      mapZoomLevel: mapZoomLevel ?? this.mapZoomLevel,
      searchRadius: searchRadius ?? this.searchRadius,
      showOnboarding: showOnboarding ?? this.showOnboarding,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

/// Serviço de configurações do aplicativo
class AppSettingsService {
  static AppSettingsService? _instance;
  static AppSettingsService get instance => _instance ??= AppSettingsService._();
  
  AppSettingsService._();
  
  final CacheService _cacheService = CacheService.instance;
  static const String _settingsKey = 'app_settings';
  
  AppSettings _settings = const AppSettings();
  final StreamController<AppSettings> _settingsController = StreamController<AppSettings>.broadcast();
  
  /// Configurações atuais
  AppSettings get settings => _settings;
  
  /// Stream de mudanças nas configurações
  Stream<AppSettings> get settingsStream => _settingsController.stream;
  
  /// Inicializa o serviço
  Future<void> initialize() async {
    try {
      await _loadSettings();
      debugPrint('App settings service initialized');
    } catch (e) {
      debugPrint('Error initializing app settings service: $e');
    }
  }
  
  /// Carrega configurações salvas
  Future<void> _loadSettings() async {
    try {
      final data = await _cacheService.get(_settingsKey);
      if (data != null) {
        _settings = AppSettings.fromJson(data as Map<String, dynamic>);
        _settingsController.add(_settings);
      }
    } catch (e) {
      debugPrint('Error loading app settings: $e');
    }
  }
  
  /// Salva configurações
  Future<void> _saveSettings() async {
    try {
      await _cacheService.set(_settingsKey, _settings.toJson());
      _settingsController.add(_settings);
    } catch (e) {
      debugPrint('Error saving app settings: $e');
    }
  }
  
  /// Atualiza configurações
  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
    debugPrint('App settings updated');
  }
  
  /// Atualiza tema
  Future<void> setTheme(AppTheme theme) async {
    _settings = _settings.copyWith(theme: theme);
    await _saveSettings();
    debugPrint('Theme changed to: ${theme.name}');
  }
  
  /// Atualiza idioma
  Future<void> setLanguage(AppLanguage language) async {
    _settings = _settings.copyWith(language: language);
    await _saveSettings();
    debugPrint('Language changed to: ${language.name}');
  }
  
  /// Atualiza unidade de distância
  Future<void> setDistanceUnit(DistanceUnit unit) async {
    _settings = _settings.copyWith(distanceUnit: unit);
    await _saveSettings();
    debugPrint('Distance unit changed to: ${unit.name}');
  }
  
  /// Atualiza formato de moeda
  Future<void> setCurrencyFormat(CurrencyFormat format) async {
    _settings = _settings.copyWith(currencyFormat: format);
    await _saveSettings();
    debugPrint('Currency format changed to: ${format.name}');
  }
  
  /// Atualiza configurações de notificação
  Future<void> setNotificationSettings(NotificationSettings notifications) async {
    _settings = _settings.copyWith(notifications: notifications);
    await _saveSettings();
    debugPrint('Notification settings updated');
  }
  
  /// Atualiza configurações de privacidade
  Future<void> setPrivacySettings(PrivacySettings privacy) async {
    _settings = _settings.copyWith(privacy: privacy);
    await _saveSettings();
    debugPrint('Privacy settings updated');
  }
  
  /// Ativa/desativa modo offline
  Future<void> setOfflineMode(bool enabled) async {
    _settings = _settings.copyWith(offlineMode: enabled);
    await _saveSettings();
    debugPrint('Offline mode ${enabled ? 'enabled' : 'disabled'}');
  }
  
  /// Ativa/desativa sincronização automática
  Future<void> setAutoSync(bool enabled) async {
    _settings = _settings.copyWith(autoSync: enabled);
    await _saveSettings();
    debugPrint('Auto sync ${enabled ? 'enabled' : 'disabled'}');
  }
  
  /// Ativa/desativa feedback háptico
  Future<void> setHapticFeedback(bool enabled) async {
    _settings = _settings.copyWith(hapticFeedback: enabled);
    await _saveSettings();
    debugPrint('Haptic feedback ${enabled ? 'enabled' : 'disabled'}');
  }
  
  /// Ativa/desativa efeitos sonoros
  Future<void> setSoundEffects(bool enabled) async {
    _settings = _settings.copyWith(soundEffects: enabled);
    await _saveSettings();
    debugPrint('Sound effects ${enabled ? 'enabled' : 'disabled'}');
  }
  
  /// Define nível de zoom do mapa
  Future<void> setMapZoomLevel(double level) async {
    final clampedLevel = level.clamp(10.0, 20.0);
    _settings = _settings.copyWith(mapZoomLevel: clampedLevel);
    await _saveSettings();
    debugPrint('Map zoom level set to: $clampedLevel');
  }
  
  /// Define raio de busca
  Future<void> setSearchRadius(int radius) async {
    final clampedRadius = radius.clamp(1000, 50000);
    _settings = _settings.copyWith(searchRadius: clampedRadius);
    await _saveSettings();
    debugPrint('Search radius set to: $clampedRadius meters');
  }
  
  /// Marca onboarding como concluído
  Future<void> completeOnboarding() async {
    _settings = _settings.copyWith(showOnboarding: false);
    await _saveSettings();
    debugPrint('Onboarding completed');
  }
  
  /// Atualiza tempo da última sincronização
  Future<void> updateLastSyncTime() async {
    _settings = _settings.copyWith(lastSyncTime: DateTime.now());
    await _saveSettings();
    debugPrint('Last sync time updated');
  }
  
  /// Formata distância baseada na unidade configurada
  String formatDistance(double meters) {
    switch (_settings.distanceUnit) {
      case DistanceUnit.kilometers:
        if (meters < 1000) {
          return '${meters.round()} m';
        } else {
          return '${(meters / 1000).toStringAsFixed(1)} km';
        }
      case DistanceUnit.miles:
        final miles = meters * 0.000621371;
        if (miles < 1) {
          final feet = meters * 3.28084;
          return '${feet.round()} ft';
        } else {
          return '${miles.toStringAsFixed(1)} mi';
        }
    }
  }
  
  /// Formata preço baseado na moeda configurada
  String formatPrice(double price) {
    final format = _settings.currencyFormat;
    return '${format.symbol} ${price.toStringAsFixed(2)}';
  }
  
  /// Verifica se está no horário silencioso
  bool isQuietHours() {
    final notifications = _settings.notifications;
    if (notifications.quietHoursStart == null || notifications.quietHoursEnd == null) {
      return false;
    }
    
    final now = TimeOfDay.now();
    final start = notifications.quietHoursStart!;
    final end = notifications.quietHoursEnd!;
    
    // Converte para minutos para facilitar comparação
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    
    if (startMinutes <= endMinutes) {
      // Mesmo dia
      return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
    } else {
      // Atravessa meia-noite
      return nowMinutes >= startMinutes || nowMinutes <= endMinutes;
    }
  }
  
  /// Obtém tema baseado na configuração
  ThemeMode getThemeMode() {
    switch (_settings.theme) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.system:
        return ThemeMode.system;
    }
  }
  
  /// Obtém locale baseado na configuração
  Locale? getLocale() {
    if (_settings.language == AppLanguage.system) {
      return null; // Usa locale do sistema
    }
    return Locale(_settings.language.code);
  }
  
  /// Reseta configurações para padrão
  Future<void> resetToDefaults() async {
    _settings = const AppSettings();
    await _saveSettings();
    debugPrint('Settings reset to defaults');
  }
  
  /// Exporta configurações
  Map<String, dynamic> exportSettings() {
    return _settings.toJson();
  }
  
  /// Importa configurações
  Future<void> importSettings(Map<String, dynamic> data) async {
    try {
      _settings = AppSettings.fromJson(data);
      await _saveSettings();
      debugPrint('Settings imported successfully');
    } catch (e) {
      debugPrint('Error importing settings: $e');
      throw Exception('Erro ao importar configurações: $e');
    }
  }
  
  /// Obtém estatísticas das configurações
  Map<String, dynamic> getSettingsStats() {
    return {
      'settings': _settings.toJson(),
      'isQuietHours': isQuietHours(),
      'themeMode': getThemeMode().name,
      'locale': getLocale()?.languageCode,
      'lastSyncTime': _settings.lastSyncTime?.toIso8601String(),
    };
  }
  
  /// Finaliza o serviço
  void dispose() {
    _settingsController.close();
  }
}