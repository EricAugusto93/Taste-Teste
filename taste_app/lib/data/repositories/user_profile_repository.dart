import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../domain/entities/user_profile.dart';
import '../services/auth_service.dart';

/// Repositório para gerenciar dados do perfil do usuário
class UserProfileRepository {
  static UserProfileRepository? _instance;
  static UserProfileRepository get instance => _instance ??= UserProfileRepository._();
  UserProfileRepository._();

  /// Cliente Supabase
  SupabaseClient get _client => SupabaseConfig.client;

  /// Serviço de autenticação
  AuthService get _authService => AuthService.instance;

  /// Obtém o perfil do usuário atual
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final userId = _authService.userId;
      if (userId == null) {
        debugPrint('❌ Usuário não autenticado');
        return null;
      }

      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ Perfil não encontrado para o usuário $userId');
        return null;
      }

      debugPrint('✅ Perfil carregado para o usuário $userId');
      return UserProfile.fromJson(response);
    } catch (e) {
      debugPrint('❌ Erro ao carregar perfil: $e');
      return null;
    }
  }

  /// Obtém perfil de um usuário específico por ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ Perfil não encontrado para o usuário $userId');
        return null;
      }

      return UserProfile.fromJson(response);
    } catch (e) {
      debugPrint('❌ Erro ao carregar perfil do usuário $userId: $e');
      return null;
    }
  }

  /// Cria um novo perfil de usuário
  Future<UserProfile?> createUserProfile({
    required String userId,
    required String fullName,
    String? phone,
    DateTime? birthDate,
    String? city,
    String? bio,
    String? avatarUrl,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final profileData = {
        'id': userId,
        'full_name': fullName,
        'phone': phone,
        'birth_date': birthDate?.toIso8601String(),
        'city': city,
        'bio': bio,
        'avatar_url': avatarUrl,
        'preferences': preferences ?? {},
      };

      final response = await _client
          .from('user_profiles')
          .insert(profileData)
          .select()
          .single();

      debugPrint('✅ Perfil criado para o usuário $userId');
      return UserProfile.fromJson(response);
    } catch (e) {
      debugPrint('❌ Erro ao criar perfil: $e');
      return null;
    }
  }

  /// Atualiza o perfil do usuário atual
  Future<UserProfile?> updateCurrentUserProfile({
    String? fullName,
    String? phone,
    DateTime? birthDate,
    String? city,
    String? bio,
    String? avatarUrl,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final userId = _authService.userId;
      if (userId == null) {
        debugPrint('❌ Usuário não autenticado');
        return null;
      }

      final updateData = <String, dynamic>{};
      
      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (birthDate != null) updateData['birth_date'] = birthDate.toIso8601String();
      if (city != null) updateData['city'] = city;
      if (bio != null) updateData['bio'] = bio;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (preferences != null) updateData['preferences'] = preferences;

      if (updateData.isEmpty) {
        debugPrint('⚠️ Nenhum dado para atualizar');
        return await getCurrentUserProfile();
      }

      final response = await _client
          .from('user_profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      debugPrint('✅ Perfil atualizado para o usuário $userId');
      return UserProfile.fromJson(response);
    } catch (e) {
      debugPrint('❌ Erro ao atualizar perfil: $e');
      return null;
    }
  }

  /// Deleta o perfil do usuário atual
  Future<bool> deleteCurrentUserProfile() async {
    try {
      final userId = _authService.userId;
      if (userId == null) {
        debugPrint('❌ Usuário não autenticado');
        return false;
      }

      await _client
          .from('user_profiles')
          .delete()
          .eq('id', userId);

      debugPrint('✅ Perfil deletado para o usuário $userId');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao deletar perfil: $e');
      return false;
    }
  }

  /// Obtém estatísticas do usuário
  Future<UserStats?> getUserStats() async {
    try {
      final userId = _authService.userId;
      if (userId == null) {
        debugPrint('❌ Usuário não autenticado');
        return null;
      }

      // Buscar estatísticas em paralelo
      final futures = await Future.wait([
        _client.from('reviews').select('id').eq('user_id', userId),
        _client.from('favorites').select('id').eq('user_id', userId),
        _client.from('search_history').select('id').eq('user_id', userId),
      ]);

      final reviewsCount = futures[0].length;
      final favoritesCount = futures[1].length;
      final searchesCount = futures[2].length;

      // Calcular média de avaliações
      final ratingsResponse = await _client
          .from('reviews')
          .select('rating')
          .eq('user_id', userId);

      double averageRating = 0.0;
      if (ratingsResponse.isNotEmpty) {
        final ratings = ratingsResponse.map((r) => r['rating'] as int).toList();
        averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
      }

      return UserStats(
        reviewsCount: reviewsCount,
        favoritesCount: favoritesCount,
        searchesCount: searchesCount,
        averageRating: averageRating,
      );
    } catch (e) {
      debugPrint('❌ Erro ao carregar estatísticas: $e');
      return null;
    }
  }

  /// Verifica se o perfil do usuário existe
  Future<bool> profileExists(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('❌ Erro ao verificar existência do perfil: $e');
      return false;
    }
  }

  /// Busca perfis por nome
  Future<List<UserProfile>> searchProfiles(String query) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .ilike('full_name', '%$query%')
          .limit(20);

      return response.map((json) => UserProfile.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar perfis: $e');
      return [];
    }
  }
}

/// Classe para estatísticas do usuário
class UserStats {
  final int reviewsCount;
  final int favoritesCount;
  final int searchesCount;
  final double averageRating;

  const UserStats({
    required this.reviewsCount,
    required this.favoritesCount,
    required this.searchesCount,
    required this.averageRating,
  });

  Map<String, dynamic> toJson() => {
    'reviews_count': reviewsCount,
    'favorites_count': favoritesCount,
    'searches_count': searchesCount,
    'average_rating': averageRating,
  };

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    reviewsCount: json['reviews_count'] ?? 0,
    favoritesCount: json['favorites_count'] ?? 0,
    searchesCount: json['searches_count'] ?? 0,
    averageRating: (json['average_rating'] ?? 0.0).toDouble(),
  );
}