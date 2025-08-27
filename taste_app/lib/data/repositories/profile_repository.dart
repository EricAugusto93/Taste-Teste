import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/error/exceptions.dart';

/// Repository para gerenciar dados do perfil do usuário
class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository(this._supabase);

  /// Obtém as estatísticas do usuário
  Future<UserStats> getUserStats(String userId) async {
    try {
      // Buscar contagem de favoritos
      final favoritesResponse = await _supabase
          .from('favorites')
          .select('id')
          .eq('user_id', userId);

      // Buscar contagem de avaliações
      final reviewsResponse = await _supabase
          .from('reviews')
          .select('id')
          .eq('user_id', userId);

      // Buscar contagem de pedidos (assumindo que existe uma tabela orders)
      final ordersResponse = await _supabase
          .from('orders')
          .select('id')
          .eq('user_id', userId)
          .catchError((error) {
        // Se a tabela orders não existir, retorna lista vazia
        return <Map<String, dynamic>>[];
      });

      return UserStats(
        totalFavorites: (favoritesResponse as List).length,
        totalReviews: (reviewsResponse as List).length,
        totalOrders: (ordersResponse as List).length,
      );
    } catch (e) {
      throw ServerException('Erro ao buscar estatísticas do usuário: $e');
    }
  }

  /// Atualiza o perfil do usuário
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final updates = <String, dynamic>{};
      
      if (displayName != null) {
        updates['display_name'] = displayName;
      }
      
      if (avatarUrl != null) {
        updates['avatar_url'] = avatarUrl;
      }
      
      if (metadata != null) {
        updates['raw_user_meta_data'] = metadata;
      }

      await _supabase.auth.updateUser(
        UserAttributes(
          data: updates,
        ),
      );
    } catch (e) {
      throw ServerException('Erro ao atualizar perfil: $e');
    }
  }

  /// Obtém as configurações do usuário
  Future<UserSettings> getUserSettings(String userId) async {
    try {
      final response = await _supabase
          .from('user_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response == null) {
        // Criar configurações padrão se não existirem
        return await _createDefaultSettings(userId);
      }
      
      return UserSettings(
        notificationsEnabled: response['notifications_enabled'] ?? true,
        emailNotifications: response['email_notifications'] ?? true,
        pushNotifications: response['push_notifications'] ?? true,
        locationEnabled: response['location_enabled'] ?? true,
        theme: response['theme'] ?? 'system',
        language: response['language'] ?? 'pt',
      );
    } catch (e) {
      throw ServerException('Erro ao buscar configurações: $e');
    }
  }

  /// Atualiza as configurações do usuário
  Future<void> updateUserSettings(String userId, UserSettings settings) async {
    try {
      final data = {
        'notifications_enabled': settings.notificationsEnabled,
        'email_notifications': settings.emailNotifications,
        'push_notifications': settings.pushNotifications,
        'location_enabled': settings.locationEnabled,
        'theme': settings.theme,
        'language': settings.language,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      await _supabase
          .from('user_settings')
          .upsert({
            'user_id': userId,
            ...data,
          });
    } catch (e) {
      throw ServerException('Erro ao atualizar configurações: $e');
    }
  }

  /// Cria configurações padrão para um usuário
  Future<UserSettings> _createDefaultSettings(String userId) async {
    const defaultSettings = UserSettings();
    await updateUserSettings(userId, defaultSettings);
    return defaultSettings;
  }

  /// Deleta a conta do usuário
  Future<void> deleteUserAccount(String userId) async {
    try {
      // Deletar dados relacionados primeiro
      await Future.wait([
        _supabase.from('favorites').delete().eq('user_id', userId),
        _supabase.from('reviews').delete().eq('user_id', userId),
        _supabase.from('user_settings').delete().eq('user_id', userId),
      ]);

      // Deletar conta do usuário
      await _supabase.auth.admin.deleteUser(userId);
    } catch (e) {
      throw ServerException('Erro ao deletar conta: $e');
    }
  }

  /// Obtém o histórico de atividades do usuário
  Future<List<UserActivity>> getUserActivities(String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Buscar avaliações recentes
      final reviewsResponse = await _supabase
          .from('reviews')
          .select('*, restaurants(name, image_url)')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      final activities = <UserActivity>[];

      for (final review in reviewsResponse) {
        activities.add(UserActivity(
          id: review['id'],
          type: ActivityType.review,
          title: 'Avaliou ${review['restaurants']['name']}',
          subtitle: 'Nota: ${review['rating']}/5',
          imageUrl: review['restaurants']['image_url'],
          createdAt: DateTime.parse(review['created_at']),
        ));
      }

      // Ordenar por data
      activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return activities;
    } catch (e) {
      throw ServerException('Erro ao buscar atividades: $e');
    }
  }
}

/// Estatísticas do usuário
class UserStats {
  final int totalFavorites;
  final int totalReviews;
  final int totalOrders;

  const UserStats({
    this.totalFavorites = 0,
    this.totalReviews = 0,
    this.totalOrders = 0,
  });

  Map<String, dynamic> toJson() => {
        'total_favorites': totalFavorites,
        'total_reviews': totalReviews,
        'total_orders': totalOrders,
      };

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
        totalFavorites: json['total_favorites'] ?? 0,
        totalReviews: json['total_reviews'] ?? 0,
        totalOrders: json['total_orders'] ?? 0,
      );
}

/// Configurações do usuário
class UserSettings {
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool locationEnabled;
  final String theme; // 'light', 'dark', 'system'
  final String language; // 'pt', 'en', 'es'

  const UserSettings({
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.locationEnabled = true,
    this.theme = 'system',
    this.language = 'pt',
  });

  UserSettings copyWith({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? locationEnabled,
    String? theme,
    String? language,
  }) {
    return UserSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      theme: theme ?? this.theme,
      language: language ?? this.language,
    );
  }
}

/// Atividade do usuário
class UserActivity {
  final String id;
  final ActivityType type;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final DateTime createdAt;

  const UserActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.createdAt,
  });
}

/// Tipos de atividade
enum ActivityType {
  review,
  favorite,
  order,
  visit,
}