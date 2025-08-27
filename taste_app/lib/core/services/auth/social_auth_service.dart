import 'package:flutter/material.dart';
import '../cache_service.dart';

/// Provedores de autenticação social
enum SocialProvider {
  google,
  apple,
  facebook,
  twitter,
}

/// Resultado da autenticação social
class SocialAuthResult {
  final bool success;
  final String? userId;
  final String? email;
  final String? name;
  final String? photoUrl;
  final String? accessToken;
  final String? error;
  final SocialProvider? provider;
  final Map<String, dynamic>? userData;

  const SocialAuthResult({
    required this.success,
    this.userId,
    this.email,
    this.name,
    this.photoUrl,
    this.accessToken,
    this.error,
    this.provider,
    this.userData,
  });

  factory SocialAuthResult.success({
    required String userId,
    required String email,
    required String name,
    required SocialProvider provider,
    String? photoUrl,
    String? accessToken,
    Map<String, dynamic>? userData,
  }) {
    return SocialAuthResult(
      success: true,
      userId: userId,
      email: email,
      name: name,
      photoUrl: photoUrl,
      accessToken: accessToken,
      provider: provider,
      userData: userData,
    );
  }

  factory SocialAuthResult.error(String error, [SocialProvider? provider]) {
    return SocialAuthResult(
      success: false,
      error: error,
      provider: provider,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'user_id': userId,
      'email': email,
      'name': name,
      'photo_url': photoUrl,
      'access_token': accessToken,
      'error': error,
      'provider': provider?.name,
      'user_data': userData,
    };
  }

  factory SocialAuthResult.fromJson(Map<String, dynamic> json) {
    return SocialAuthResult(
      success: json['success'] as bool,
      userId: json['user_id'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      photoUrl: json['photo_url'] as String?,
      accessToken: json['access_token'] as String?,
      error: json['error'] as String?,
      provider: json['provider'] != null
          ? SocialProvider.values.firstWhere(
              (e) => e.name == json['provider'],
              orElse: () => SocialProvider.google,
            )
          : null,
      userData: json['user_data'] as Map<String, dynamic>?,
    );
  }
}

/// Configurações de autenticação social
class SocialAuthConfig {
  final bool enableGoogle;
  final bool enableApple;
  final bool enableFacebook;
  final bool enableTwitter;
  final String? googleClientId;
  final String? appleClientId;
  final String? facebookAppId;
  final String? twitterApiKey;
  final bool autoCreateProfile;
  final bool cacheCredentials;
  final Duration cacheExpiration;
  final List<String> requiredScopes;

  const SocialAuthConfig({
    this.enableGoogle = true,
    this.enableApple = true,
    this.enableFacebook = false,
    this.enableTwitter = false,
    this.googleClientId,
    this.appleClientId,
    this.facebookAppId,
    this.twitterApiKey,
    this.autoCreateProfile = true,
    this.cacheCredentials = true,
    this.cacheExpiration = const Duration(days: 30),
    this.requiredScopes = const ['email', 'profile'],
  });

  factory SocialAuthConfig.fromJson(Map<String, dynamic> json) {
    return SocialAuthConfig(
      enableGoogle: json['enable_google'] as bool? ?? true,
      enableApple: json['enable_apple'] as bool? ?? true,
      enableFacebook: json['enable_facebook'] as bool? ?? false,
      enableTwitter: json['enable_twitter'] as bool? ?? false,
      googleClientId: json['google_client_id'] as String?,
      appleClientId: json['apple_client_id'] as String?,
      facebookAppId: json['facebook_app_id'] as String?,
      twitterApiKey: json['twitter_api_key'] as String?,
      autoCreateProfile: json['auto_create_profile'] as bool? ?? true,
      cacheCredentials: json['cache_credentials'] as bool? ?? true,
      cacheExpiration: Duration(
        milliseconds: json['cache_expiration_ms'] as int? ?? 30 * 24 * 60 * 60 * 1000,
      ),
      requiredScopes: List<String>.from(
        json['required_scopes'] as List? ?? ['email', 'profile'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enable_google': enableGoogle,
      'enable_apple': enableApple,
      'enable_facebook': enableFacebook,
      'enable_twitter': enableTwitter,
      'google_client_id': googleClientId,
      'apple_client_id': appleClientId,
      'facebook_app_id': facebookAppId,
      'twitter_api_key': twitterApiKey,
      'auto_create_profile': autoCreateProfile,
      'cache_credentials': cacheCredentials,
      'cache_expiration_ms': cacheExpiration.inMilliseconds,
      'required_scopes': requiredScopes,
    };
  }
}

/// Dados do usuário social
class SocialUserData {
  final String id;
  final String email;
  final String name;
  final String? firstName;
  final String? lastName;
  final String? photoUrl;
  final String? locale;
  final DateTime? birthday;
  final String? gender;
  final SocialProvider provider;
  final Map<String, dynamic>? rawData;
  final DateTime createdAt;

  const SocialUserData({
    required this.id,
    required this.email,
    required this.name,
    this.firstName,
    this.lastName,
    this.photoUrl,
    this.locale,
    this.birthday,
    this.gender,
    required this.provider,
    this.rawData,
    required this.createdAt,
  });

  factory SocialUserData.fromJson(Map<String, dynamic> json) {
    return SocialUserData(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      locale: json['locale'] as String?,
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'])
          : null,
      gender: json['gender'] as String?,
      provider: SocialProvider.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => SocialProvider.google,
      ),
      rawData: json['raw_data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'first_name': firstName,
      'last_name': lastName,
      'photo_url': photoUrl,
      'locale': locale,
      'birthday': birthday?.toIso8601String(),
      'gender': gender,
      'provider': provider.name,
      'raw_data': rawData,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Serviço de autenticação social
class SocialAuthService {
  static SocialAuthService? _instance;
  static SocialAuthService get instance => _instance ??= SocialAuthService._();
  SocialAuthService._();

  final CacheService _cacheService = CacheService.instance;

  SocialAuthConfig _config = const SocialAuthConfig();
  final Map<SocialProvider, SocialUserData> _userDataCache = {};
  bool _isInitialized = false;

  /// Inicializar o serviço
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Carregar configurações
      await _loadConfig();

      // Carregar cache de dados do usuário
      await _loadUserDataCache();

      _isInitialized = true;
      debugPrint('SocialAuthService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing SocialAuthService: $e');
      rethrow;
    }
  }

  /// Carregar configurações
  Future<void> _loadConfig() async {
    try {
      final configData = await _cacheService.get('social_auth_config');
      if (configData != null) {
        _config = SocialAuthConfig.fromJson(configData);
      }
    } catch (e) {
      debugPrint('Error loading social auth config: $e');
    }
  }

  /// Salvar configurações
  Future<void> _saveConfig() async {
    try {
      await _cacheService.set(
        'social_auth_config',
        _config.toJson(),
        ttl: const Duration(days: 30),
      );
    } catch (e) {
      debugPrint('Error saving social auth config: $e');
    }
  }

  /// Carregar cache de dados do usuário
  Future<void> _loadUserDataCache() async {
    try {
      final cacheData = await _cacheService.get('social_user_data_cache');
      if (cacheData != null) {
        final Map<String, dynamic> cache = cacheData;
        for (final entry in cache.entries) {
          final provider = SocialProvider.values.firstWhere(
            (e) => e.name == entry.key,
            orElse: () => SocialProvider.google,
          );
          _userDataCache[provider] = SocialUserData.fromJson(entry.value);
        }
      }
    } catch (e) {
      debugPrint('Error loading user data cache: $e');
    }
  }

  /// Salvar cache de dados do usuário
  Future<void> _saveUserDataCache() async {
    try {
      final cacheData = <String, dynamic>{};
      for (final entry in _userDataCache.entries) {
        cacheData[entry.key.name] = entry.value.toJson();
      }
      await _cacheService.set(
        'social_user_data_cache',
        cacheData,
        ttl: _config.cacheExpiration,
      );
    } catch (e) {
      debugPrint('Error saving user data cache: $e');
    }
  }

  /// Fazer login com Google
  Future<SocialAuthResult> signInWithGoogle() async {
    try {
      if (!_config.enableGoogle) {
        return SocialAuthResult.error(
          'Login com Google não está habilitado',
          SocialProvider.google,
        );
      }

      // TODO: Implementar integração real com Google Sign-In
      // Para agora, simular o processo
      await Future.delayed(const Duration(seconds: 2));
      
      // Simular dados do usuário do Google
      final userData = SocialUserData(
        id: 'google_${DateTime.now().millisecondsSinceEpoch}',
        email: 'usuario@gmail.com',
        name: 'Usuário Google',
        firstName: 'Usuário',
        lastName: 'Google',
        photoUrl: null,
        provider: SocialProvider.google,
        createdAt: DateTime.now(),
      );

      // Salvar no cache
      if (_config.cacheCredentials) {
        _userDataCache[SocialProvider.google] = userData;
        await _saveUserDataCache();
      }

      // Criar perfil automaticamente se configurado
      if (_config.autoCreateProfile) {
        await _createOrUpdateProfile(userData);
      }

      return SocialAuthResult.success(
        userId: userData.id,
        email: userData.email,
        name: userData.name,
        photoUrl: userData.photoUrl,
        provider: SocialProvider.google,
        userData: userData.toJson(),
      );
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      return SocialAuthResult.error(
        'Erro ao fazer login com Google: $e',
        SocialProvider.google,
      );
    }
  }

  /// Fazer login com Apple
  Future<SocialAuthResult> signInWithApple() async {
    try {
      if (!_config.enableApple) {
        return SocialAuthResult.error(
          'Login com Apple não está habilitado',
          SocialProvider.apple,
        );
      }

      // TODO: Implementar integração real com Sign in with Apple
      // Para agora, simular o processo
      await Future.delayed(const Duration(seconds: 2));
      
      // Simular dados do usuário do Apple
      final userData = SocialUserData(
        id: 'apple_${DateTime.now().millisecondsSinceEpoch}',
        email: 'usuario@icloud.com',
        name: 'Usuário Apple',
        firstName: 'Usuário',
        lastName: 'Apple',
        provider: SocialProvider.apple,
        createdAt: DateTime.now(),
      );

      // Salvar no cache
      if (_config.cacheCredentials) {
        _userDataCache[SocialProvider.apple] = userData;
        await _saveUserDataCache();
      }

      // Criar perfil automaticamente se configurado
      if (_config.autoCreateProfile) {
        await _createOrUpdateProfile(userData);
      }

      return SocialAuthResult.success(
        userId: userData.id,
        email: userData.email,
        name: userData.name,
        provider: SocialProvider.apple,
        userData: userData.toJson(),
      );
    } catch (e) {
      debugPrint('Error signing in with Apple: $e');
      return SocialAuthResult.error(
        'Erro ao fazer login com Apple: $e',
        SocialProvider.apple,
      );
    }
  }

  /// Fazer login com Facebook
  Future<SocialAuthResult> signInWithFacebook() async {
    try {
      if (!_config.enableFacebook) {
        return SocialAuthResult.error(
          'Login com Facebook não está habilitado',
          SocialProvider.facebook,
        );
      }

      // TODO: Implementar integração real com Facebook Login
      await Future.delayed(const Duration(seconds: 2));
      
      return SocialAuthResult.error(
        'Login com Facebook ainda não implementado',
        SocialProvider.facebook,
      );
    } catch (e) {
      debugPrint('Error signing in with Facebook: $e');
      return SocialAuthResult.error(
        'Erro ao fazer login com Facebook: $e',
        SocialProvider.facebook,
      );
    }
  }

  /// Fazer login com Twitter
  Future<SocialAuthResult> signInWithTwitter() async {
    try {
      if (!_config.enableTwitter) {
        return SocialAuthResult.error(
          'Login com Twitter não está habilitado',
          SocialProvider.twitter,
        );
      }

      // TODO: Implementar integração real com Twitter Login
      await Future.delayed(const Duration(seconds: 2));
      
      return SocialAuthResult.error(
        'Login com Twitter ainda não implementado',
        SocialProvider.twitter,
      );
    } catch (e) {
      debugPrint('Error signing in with Twitter: $e');
      return SocialAuthResult.error(
        'Erro ao fazer login com Twitter: $e',
        SocialProvider.twitter,
      );
    }
  }

  /// Criar ou atualizar perfil do usuário
  Future<void> _createOrUpdateProfile(SocialUserData userData) async {
    try {
      // TODO: Implementar criação/atualização do perfil no Supabase
      // final profileData = {
      //   'id': userData.id,
      //   'email': userData.email,
      //   'name': userData.name,
      //   'first_name': userData.firstName,
      //   'last_name': userData.lastName,
      //   'photo_url': userData.photoUrl,
      //   'provider': userData.provider.name,
      //   'created_at': userData.createdAt.toIso8601String(),
      // };
      
      // await _supabaseService.client
      //     .from('user_profiles')
      //     .upsert(profileData);
      
      debugPrint('Profile created/updated for ${userData.email}');
    } catch (e) {
      debugPrint('Error creating/updating profile: $e');
    }
  }

  /// Fazer logout de um provedor específico
  Future<bool> signOut(SocialProvider provider) async {
    try {
      // Remover do cache
      _userDataCache.remove(provider);
      await _saveUserDataCache();

      // TODO: Implementar logout específico de cada provedor
      switch (provider) {
        case SocialProvider.google:
          // await GoogleSignIn().signOut();
          break;
        case SocialProvider.apple:
          // Apple não tem logout explícito
          break;
        case SocialProvider.facebook:
          // await FacebookAuth.instance.logOut();
          break;
        case SocialProvider.twitter:
          // Implementar logout do Twitter
          break;
      }

      return true;
    } catch (e) {
      debugPrint('Error signing out from $provider: $e');
      return false;
    }
  }

  /// Fazer logout de todos os provedores
  Future<bool> signOutAll() async {
    try {
      final providers = List<SocialProvider>.from(_userDataCache.keys);
      
      for (final provider in providers) {
        await signOut(provider);
      }

      return true;
    } catch (e) {
      debugPrint('Error signing out from all providers: $e');
      return false;
    }
  }

  /// Obter dados do usuário de um provedor
  SocialUserData? getUserData(SocialProvider provider) {
    return _userDataCache[provider];
  }

  /// Verificar se está logado em um provedor
  bool isSignedIn(SocialProvider provider) {
    return _userDataCache.containsKey(provider);
  }

  /// Obter provedores disponíveis
  List<SocialProvider> getAvailableProviders() {
    final providers = <SocialProvider>[];
    
    if (_config.enableGoogle) providers.add(SocialProvider.google);
    if (_config.enableApple) providers.add(SocialProvider.apple);
    if (_config.enableFacebook) providers.add(SocialProvider.facebook);
    if (_config.enableTwitter) providers.add(SocialProvider.twitter);
    
    return providers;
  }

  /// Atualizar configurações
  Future<void> updateConfig(SocialAuthConfig config) async {
    _config = config;
    await _saveConfig();
  }

  /// Obter configurações atuais
  SocialAuthConfig get config => _config;

  /// Limpar cache
  Future<void> clearCache() async {
    _userDataCache.clear();
    await _cacheService.remove('social_user_data_cache');
  }

  /// Obter estatísticas
  Map<String, dynamic> getStatistics() {
    return {
      'cached_providers': _userDataCache.keys.map((e) => e.name).toList(),
      'available_providers': getAvailableProviders().map((e) => e.name).toList(),
      'config': _config.toJson(),
    };
  }
}

/// Widget para botões de login social
class SocialLoginButtons extends StatefulWidget {
  final Function(SocialAuthResult)? onResult;
  final bool showLabels;
  final double buttonHeight;
  final EdgeInsets padding;

  const SocialLoginButtons({
    super.key,
    this.onResult,
    this.showLabels = true,
    this.buttonHeight = 50,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  State<SocialLoginButtons> createState() => _SocialLoginButtonsState();
}

class _SocialLoginButtonsState extends State<SocialLoginButtons> {
  final SocialAuthService _socialAuthService = SocialAuthService.instance;
  final Map<SocialProvider, bool> _loadingStates = {};

  @override
  Widget build(BuildContext context) {
    final availableProviders = _socialAuthService.getAvailableProviders();
    
    if (availableProviders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: widget.padding,
      child: Column(
        children: [
          if (widget.showLabels) ...[
            const Text(
              'Ou continue com',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          ...availableProviders.map((provider) => 
              _buildSocialButton(provider)),
        ],
      ),
    );
  }

  Widget _buildSocialButton(SocialProvider provider) {
    final isLoading = _loadingStates[provider] ?? false;
    
    return Container(
      width: double.infinity,
      height: widget.buttonHeight,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : () => _handleSocialLogin(provider),
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProviderColor(provider),
                  ),
                ),
              )
            : Icon(
                _getProviderIcon(provider),
                color: Colors.white,
              ),
        label: Text(
          _getProviderLabel(provider),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getProviderColor(provider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSocialLogin(SocialProvider provider) async {
    setState(() {
      _loadingStates[provider] = true;
    });

    try {
      SocialAuthResult result;
      
      switch (provider) {
        case SocialProvider.google:
          result = await _socialAuthService.signInWithGoogle();
          break;
        case SocialProvider.apple:
          result = await _socialAuthService.signInWithApple();
          break;
        case SocialProvider.facebook:
          result = await _socialAuthService.signInWithFacebook();
          break;
        case SocialProvider.twitter:
          result = await _socialAuthService.signInWithTwitter();
          break;
      }

      if (mounted) {
        widget.onResult?.call(result);
        
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login realizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Erro no login'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingStates[provider] = false;
        });
      }
    }
  }

  IconData _getProviderIcon(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.google:
        return Icons.login; // Usar ícone genérico por enquanto
      case SocialProvider.apple:
        return Icons.apple;
      case SocialProvider.facebook:
        return Icons.facebook;
      case SocialProvider.twitter:
        return Icons.alternate_email;
    }
  }

  Color _getProviderColor(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.google:
        return const Color(0xFF4285F4);
      case SocialProvider.apple:
        return Colors.black;
      case SocialProvider.facebook:
        return const Color(0xFF1877F2);
      case SocialProvider.twitter:
        return const Color(0xFF1DA1F2);
    }
  }

  String _getProviderLabel(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.google:
        return 'Continuar com Google';
      case SocialProvider.apple:
        return 'Continuar com Apple';
      case SocialProvider.facebook:
        return 'Continuar com Facebook';
      case SocialProvider.twitter:
        return 'Continuar com Twitter';
    }
  }
}
