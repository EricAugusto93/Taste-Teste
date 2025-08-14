import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/datasources/category_remote_data_source.dart';
import '../../core/di/injection_container.dart';

/// Provider do data source remoto de categorias
final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((ref) {
  return CategoryRemoteDataSourceImpl();
});

/// Provider do repositório de categorias
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final remoteDataSource = ref.watch(categoryRemoteDataSourceProvider);
  return CategoryRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provider para todas as categorias
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  final result = await repository.getAllCategories();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (categories) => categories,
  );
});

/// Provider para categorias ativas
final activeCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  final result = await repository.getActiveCategories();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (categories) => categories,
  );
});

/// Provider para uma categoria específica por ID
final categoryByIdProvider = FutureProvider.family<Category, String>((ref, id) async {
  final repository = ref.watch(categoryRepositoryProvider);
  final result = await repository.getCategoryById(id);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (category) => category,
  );
});

/// Provider para categorias populares (primeiras 6 categorias ativas)
final popularCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final categories = await ref.watch(activeCategoriesProvider.future);
  return categories.take(6).toList();
});

/// Provider para verificar se uma categoria existe
final categoryExistsProvider = FutureProvider.family<bool, String>((ref, id) async {
  try {
    await ref.watch(categoryByIdProvider(id).future);
    return true;
  } catch (e) {
    return false;
  }
});