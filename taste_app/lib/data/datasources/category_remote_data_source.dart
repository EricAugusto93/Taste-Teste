import '../models/category_model.dart';
import '../../core/config/supabase_config.dart';
import '../../core/error/exceptions.dart';

/// Interface para operações remotas de categorias
abstract class CategoryRemoteDataSource {
  /// Busca todas as categorias disponíveis
  Future<List<CategoryModel>> getAllCategories();
}

/// Implementação do CategoryRemoteDataSource usando Supabase
class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  @override
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await SupabaseDatabase.categories
          .select()
          .order('sort_order', ascending: true);

      return (response)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Erro ao buscar categorias: $e');
    }
  }
}