import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/review_model.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/error/exceptions.dart' as app_exceptions;
import '../auth/auth_service.dart';

/// Serviço para gerenciar reviews de restaurantes
class ReviewService {
  static ReviewService? _instance;
  static ReviewService get instance => _instance ??= ReviewService._();
  ReviewService._();

  /// Cliente Supabase
  SupabaseClient get _client => SupabaseConfig.client;

  /// Cria uma nova review
  Future<ReviewModel> createReview({
    required String restaurantId,
    required int rating,
    required String comment,
  }) async {
    try {
      final userId = AuthService.instance.userId;
      final user = AuthService.instance.currentUser;
      
      if (userId == null || user == null) {
        throw const AuthException('Usuário não autenticado');
      }

      // Verificar se já existe um comentário idêntico do mesmo usuário para este restaurante
      final existingComment = await _client
          .from('reviews')
          .select('id')
          .eq('user_id', userId)
          .eq('restaurant_id', restaurantId)
          .eq('comment', comment)
          .maybeSingle();

      if (existingComment != null) {
        throw const app_exceptions.CacheException('Você já fez este comentário para este restaurante');
      }

      // Buscar dados do perfil do usuário para incluir na review
      final userProfile = await _client
          .from('user_profiles')
          .select('full_name, avatar_url')
          .eq('id', userId)
          .maybeSingle();

      final userName = userProfile?['full_name'] ?? user.email ?? 'Usuário Anônimo';
      final userAvatar = userProfile?['avatar_url'] as String?;

      // Criar nova review
      final response = await _client
          .from('reviews')
          .insert({
            'user_id': userId,
            'restaurant_id': restaurantId,
            'rating': rating,
            'comment': comment,
            'user_name': userName,
            'user_avatar': userAvatar,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('''
            id,
            user_id,
            restaurant_id,
            rating,
            comment,
            user_name,
            user_avatar,
            helpful_count,
            is_verified,
            created_at,
            updated_at
          ''')
          .single();

      // Atualizar estatísticas do restaurante
      await _updateRestaurantRating(restaurantId);

      return ReviewModel.fromJson(response);
    } on PostgrestException catch (e) {
      debugPrint('Erro PostgreSQL ao criar review: ${e.message}');
      throw app_exceptions.ServerException('Erro ao criar avaliação: ${e.message}');
    } catch (e) {
      if (e is AuthException || e is app_exceptions.CacheException) rethrow;
      debugPrint('Erro ao criar review: $e');
      throw const app_exceptions.ServerException('Erro inesperado ao criar avaliação');
    }
  }

  /// Busca reviews de um restaurante
  Future<List<ReviewModel>> getRestaurantReviews(
    String restaurantId, {
    int limit = 20,
    int offset = 0,
    String orderBy = 'created_at',
    bool ascending = false,
  }) async {
    try {
      final response = await _client
          .from('reviews')
          .select('''
            id,
            user_id,
            restaurant_id,
            rating,
            comment,
            user_name,
            user_avatar,
            helpful_count,
            is_verified,
            created_at,
            updated_at
          ''')
          .eq('restaurant_id', restaurantId)
          .order(orderBy, ascending: ascending)
          .range(offset, offset + limit - 1);

      return response
          .map<ReviewModel>((item) => ReviewModel.fromJson(item))
          .toList();
    } on PostgrestException catch (e) {
      debugPrint('Erro PostgreSQL ao buscar reviews: ${e.message}');
      throw app_exceptions.ServerException('Erro ao buscar avaliações: ${e.message}');
    } catch (e) {
      debugPrint('Erro ao buscar reviews: $e');
      throw const app_exceptions.ServerException('Erro inesperado ao buscar avaliações');
    }
  }

  /// Busca reviews de um usuário
  Future<List<ReviewModel>> getUserReviews([String? userId]) async {
    try {
      final targetUserId = userId ?? AuthService.instance.userId;
      if (targetUserId == null) {
        throw const AuthException('Usuário não autenticado');
      }

      final response = await _client
          .from('reviews')
          .select('''
            id,
            user_id,
            restaurant_id,
            rating,
            comment,
            created_at,
            updated_at,
            restaurants (
              id,
              name,
              image_url
            )
          ''')
          .eq('user_id', targetUserId)
          .order('created_at', ascending: false);

      return response
          .map<ReviewModel>((item) => ReviewModel.fromJson(item))
          .toList();
    } on PostgrestException catch (e) {
      debugPrint('Erro PostgreSQL ao buscar reviews do usuário: ${e.message}');
      throw app_exceptions.ServerException('Erro ao buscar suas avaliações: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      debugPrint('Erro ao buscar reviews do usuário: $e');
      throw const app_exceptions.ServerException('Erro inesperado ao buscar suas avaliações');
    }
  }

  /// Atualiza uma review
  Future<ReviewModel> updateReview({
    required String reviewId,
    int? rating,
    String? comment,
  }) async {
    try {
      final userId = AuthService.instance.userId;
      if (userId == null) {
        throw const AuthException('Usuário não autenticado');
      }

      // Verificar se a review pertence ao usuário
      final existingReview = await _client
          .from('reviews')
          .select('user_id, restaurant_id')
          .eq('id', reviewId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingReview == null) {
        throw const AuthException('Avaliação não encontrada ou não autorizada');
      }

      final updateData = <String, dynamic>{};
      if (rating != null) updateData['rating'] = rating;
      if (comment != null) updateData['comment'] = comment;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('reviews')
          .update(updateData)
          .eq('id', reviewId)
          .eq('user_id', userId)
          .select('''
            id,
            user_id,
            restaurant_id,
            rating,
            comment,
            created_at,
            updated_at
          ''')
          .single();

      // Atualizar estatísticas do restaurante se a nota mudou
      if (rating != null) {
        await _updateRestaurantRating(existingReview['restaurant_id']);
      }

      return ReviewModel.fromJson(response);
    } on PostgrestException catch (e) {
      debugPrint('Erro PostgreSQL ao atualizar review: ${e.message}');
      throw app_exceptions.ServerException('Erro ao atualizar avaliação: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      debugPrint('Erro ao atualizar review: $e');
      throw const app_exceptions.ServerException('Erro inesperado ao atualizar avaliação');
    }
  }

  /// Remove uma review
  Future<void> deleteReview(String reviewId) async {
    try {
      final userId = AuthService.instance.userId;
      if (userId == null) {
        throw const AuthException('Usuário não autenticado');
      }

      // Verificar se a review pertence ao usuário e obter o restaurant_id
      final existingReview = await _client
          .from('reviews')
          .select('user_id, restaurant_id')
          .eq('id', reviewId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingReview == null) {
        throw const AuthException('Avaliação não encontrada ou não autorizada');
      }

      await _client
          .from('reviews')
          .delete()
          .eq('id', reviewId)
          .eq('user_id', userId);

      // Atualizar estatísticas do restaurante
      await _updateRestaurantRating(existingReview['restaurant_id']);

      debugPrint('Review removida com sucesso');
    } on PostgrestException catch (e) {
      debugPrint('Erro PostgreSQL ao remover review: ${e.message}');
      throw app_exceptions.ServerException('Erro ao remover avaliação: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      debugPrint('Erro ao remover review: $e');
      throw const app_exceptions.ServerException('Erro inesperado ao remover avaliação');
    }
  }

  /// Busca estatísticas de reviews de um restaurante
  Future<Map<String, dynamic>> getRestaurantReviewStats(String restaurantId) async {
    try {
      final response = await _client
          .rpc('get_restaurant_review_stats', params: {
            'restaurant_id_param': restaurantId,
          });

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      debugPrint('Erro PostgreSQL ao buscar estatísticas: ${e.message}');
      // Fallback para cálculo manual se a função não existir
      return await _calculateReviewStatsManually(restaurantId);
    } catch (e) {
      debugPrint('Erro ao buscar estatísticas: $e');
      // Fallback para cálculo manual
      return await _calculateReviewStatsManually(restaurantId);
    }
  }

  /// Busca a última avaliação do usuário para um restaurante
  Future<ReviewModel?> getUserLatestReviewForRestaurant(String restaurantId) async {
    try {
      final userId = AuthService.instance.userId;
      if (userId == null) return null;

      final response = await _client
          .from('reviews')
          .select('''
            id,
            user_id,
            restaurant_id,
            rating,
            comment,
            created_at,
            updated_at
          ''')
          .eq('user_id', userId)
          .eq('restaurant_id', restaurantId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      return response != null ? ReviewModel.fromJson(response) : null;
    } catch (e) {
      debugPrint('Erro ao verificar review do usuário: $e');
      return null;
    }
  }

  /// Atualiza a nota média e contagem de reviews do restaurante
  Future<void> _updateRestaurantRating(String restaurantId) async {
    try {
      final stats = await _calculateReviewStatsManually(restaurantId);
      
      await _client
          .from('restaurants')
          .update({
            'rating': stats['average_rating'],
            'review_count': stats['total_reviews'],
          })
          .eq('id', restaurantId);

      debugPrint('Estatísticas do restaurante atualizadas');
    } catch (e) {
      debugPrint('Erro ao atualizar estatísticas do restaurante: $e');
    }
  }

  /// Calcula estatísticas de reviews manualmente
  Future<Map<String, dynamic>> _calculateReviewStatsManually(String restaurantId) async {
    try {
      final response = await _client
          .from('reviews')
          .select('rating')
          .eq('restaurant_id', restaurantId);

      if (response.isEmpty) {
        return {
          'total_reviews': 0,
          'average_rating': 0.0,
          'rating_distribution': <int, int>{},
        };
      }

      final ratings = response
          .map<int>((item) => item['rating'] as int)
          .toList();

      final totalReviews = ratings.length;
      final averageRating = ratings.fold<double>(0, (sum, rating) => sum + rating) / totalReviews;
      
      final ratingDistribution = <int, int>{};
      for (int i = 1; i <= 5; i++) {
        ratingDistribution[i] = ratings.where((rating) => rating == i).length;
      }

      return {
        'total_reviews': totalReviews,
        'average_rating': double.parse(averageRating.toStringAsFixed(1)),
        'rating_distribution': ratingDistribution,
      };
    } catch (e) {
      debugPrint('Erro ao calcular estatísticas manualmente: $e');
      return {
        'total_reviews': 0,
        'average_rating': 0.0,
        'rating_distribution': <int, int>{},
      };
    }
  }
}
