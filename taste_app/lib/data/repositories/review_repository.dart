import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/review_model.dart';

class ReviewRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _localReviewsKey = 'local_reviews';

  Future<List<ReviewModel>> getReviewsByRestaurant(String restaurantId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('*')
          .eq('restaurant_id', restaurantId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((review) => ReviewModel.fromJson(review))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar avaliações: $e');
    }
  }

  Future<ReviewModel> createReview(ReviewModel review) async {
    try {
      // Primeiro, salva localmente
      await _saveReviewLocally(review);
      
      // Tenta salvar no Supabase (pode falhar se offline)
      try {
        final response = await _supabase
            .from('reviews')
            .insert(review.toCreateJson())
            .select()
            .single();

        return ReviewModel.fromJson(response);
      } catch (supabaseError) {
        // Se falhar no Supabase, retorna a review local
        print('Erro no Supabase, salvando localmente: $supabaseError');
        return review.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
      }
    } catch (e) {
      throw Exception('Erro ao criar avaliação: $e');
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _supabase
          .from('reviews')
          .delete()
          .eq('id', reviewId);
    } catch (e) {
      throw Exception('Erro ao deletar avaliação: $e');
    }
  }

  Future<double> getAverageRating(String restaurantId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('rating')
          .eq('restaurant_id', restaurantId);

      if (response.isEmpty) return 0.0;

      final ratings = (response as List)
          .map((review) => (review['rating'] as num).toDouble())
          .toList();

      return ratings.reduce((a, b) => a + b) / ratings.length;
    } catch (e) {
      throw Exception('Erro ao calcular média de avaliações: $e');
    }
  }

  Future<int> getReviewCount(String restaurantId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('id')
          .eq('restaurant_id', restaurantId);

      return response.length;
    } catch (e) {
      throw Exception('Erro ao contar avaliações: $e');
    }
  }

  Future<List<ReviewModel>> getReviewsByRating(String restaurantId, int rating) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('*')
          .eq('restaurant_id', restaurantId)
          .eq('rating', rating)
          .order('created_at', ascending: false);

      return (response as List)
          .map((review) => ReviewModel.fromJson(review))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar avaliações por rating: $e');
    }
  }

  Future<List<ReviewModel>> getReviewsByUser(String userId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('*, restaurant:restaurants(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((review) => ReviewModel.fromJson(review))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar avaliações do usuário: $e');
    }
  }

  /// Salva review localmente para persistência offline
  Future<void> _saveReviewLocally(ReviewModel review) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingReviews = await _getLocalReviews();
      
      final reviewWithId = review.copyWith(
        id: review.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : review.id,
      );
      
      existingReviews.add(reviewWithId);
      
      final reviewsJson = existingReviews.map((r) => r.toJson()).toList();
      await prefs.setString(_localReviewsKey, jsonEncode(reviewsJson));
    } catch (e) {
      print('Erro ao salvar review localmente: $e');
    }
  }

  /// Recupera reviews do armazenamento local
  Future<List<ReviewModel>> _getLocalReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reviewsData = prefs.getString(_localReviewsKey);
      
      if (reviewsData == null) return [];
      
      final List<dynamic> reviewsJson = jsonDecode(reviewsData);
      return reviewsJson.map((json) => ReviewModel.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao recuperar reviews locais: $e');
      return [];
    }
  }

  /// Busca reviews combinando locais e do servidor
  Future<List<ReviewModel>> getReviewsByRestaurantCombined(String restaurantId) async {
    final localReviews = await _getLocalReviews();
    final localRestaurantReviews = localReviews
        .where((review) => review.restaurantId == restaurantId)
        .toList();

    try {
      final serverReviews = await getReviewsByRestaurant(restaurantId);
      
      // Combina reviews, evitando duplicatas
      final allReviews = <ReviewModel>[];
      allReviews.addAll(serverReviews);
      
      for (final localReview in localRestaurantReviews) {
        final exists = serverReviews.any((r) => r.id == localReview.id);
        if (!exists) {
          allReviews.add(localReview);
        }
      }
      
      // Ordena por data de criação
      allReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return allReviews;
    } catch (e) {
      // Se falhar no servidor, retorna apenas reviews locais
      return localRestaurantReviews;
    }
  }

  Future<void> markReviewAsHelpful(String reviewId) async {
    try {
      // Incrementar contador de útil
      await _supabase.rpc('increment_helpful_count', params: {
        'review_id': reviewId,
      });
    } catch (e) {
      throw Exception('Erro ao marcar avaliação como útil: $e');
    }
  }

  Future<ReviewModel> updateReview(ReviewModel review) async {
    try {
      final response = await _supabase
          .from('reviews')
          .update({
            'rating': review.rating,
            'comment': review.comment,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', review.id)
          .select()
          .single();

      return ReviewModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar avaliação: $e');
    }
  }

  Future<Map<int, int>> getRatingDistribution(String restaurantId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('rating')
          .eq('restaurant_id', restaurantId);

      final distribution = <int, int>{};
      for (final review in response) {
        final rating = review['rating'] as int;
        distribution[rating] = (distribution[rating] ?? 0) + 1;
      }

      return distribution;
    } catch (e) {
      throw Exception('Erro ao obter distribuição de ratings: $e');
    }
  }

  Future<bool> hasUserReviewed(String userId, String restaurantId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('id')
          .eq('user_id', userId)
          .eq('restaurant_id', restaurantId)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      throw Exception('Erro ao verificar se usuário já avaliou: $e');
    }
  }

  /// Busca as avaliações mais úteis de um restaurante
  Future<List<ReviewModel>> getTopReviews(String restaurantId, {int limit = 10}) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('*')
          .eq('restaurant_id', restaurantId)
          .order('helpful_count', ascending: false)
          .limit(limit);

      return (response as List<dynamic>)
          .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar avaliações mais úteis: $e');
    }
  }

  /// Cria uma resposta a uma avaliação
  Future<ReviewReply> createReply(ReviewReply reply) async {
    try {
      final response = await _supabase
          .from('review_replies')
          .insert(reply.toJson())
          .select()
          .single();

      return ReviewReply.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erro ao criar resposta: $e');
    }
  }

  /// Busca respostas de uma avaliação
  Future<List<ReviewReply>> getRepliesByReview(String reviewId) async {
    try {
      final response = await _supabase
          .from('review_replies')
          .select('*')
          .eq('review_id', reviewId)
          .order('created_at', ascending: true);

      return (response as List<dynamic>)
          .map((json) => ReviewReply.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar respostas: $e');
    }
  }

  /// Deleta uma resposta
  Future<void> deleteReply(String replyId) async {
    try {
      await _supabase
          .from('review_replies')
          .delete()
          .eq('id', replyId);
    } catch (e) {
      throw Exception('Erro ao deletar resposta: $e');
    }
  }

  /// Reporta uma avaliação
  Future<void> reportReview(String reviewId, String reason) async {
    try {
      await _supabase
          .from('review_reports')
          .insert({
            'review_id': reviewId,
            'reason': reason,
            'created_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Erro ao reportar avaliação: $e');
    }
  }

  /// Reporta uma resposta
  Future<void> reportReply(String replyId, String reason) async {
    try {
      await _supabase
          .from('reply_reports')
          .insert({
            'reply_id': replyId,
            'reason': reason,
            'created_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Erro ao reportar resposta: $e');
    }
  }

  /// Busca estatísticas detalhadas de avaliações
  Future<ReviewStats> getDetailedStats(String restaurantId) async {
    try {
      // Buscar todas as avaliações para calcular estatísticas
      final reviews = await getReviewsByRestaurant(restaurantId);
      
      if (reviews.isEmpty) {
        return ReviewStats(
          averageRating: 0.0,
          totalReviews: 0,
          ratingDistribution: {},
        );
      }

      // Calcular média
      final totalRating = reviews.fold<int>(0, (sum, review) => sum + review.rating);
      final averageRating = totalRating / reviews.length;

      // Calcular distribuição
      final distribution = <int, int>{};
      for (int i = 1; i <= 5; i++) {
        distribution[i] = reviews.where((r) => r.rating == i).length;
      }

      return ReviewStats(
        averageRating: averageRating,
        totalReviews: reviews.length,
        ratingDistribution: distribution,
      );
    } catch (e) {
      throw Exception('Erro ao buscar estatísticas detalhadas: $e');
    }
  }
}