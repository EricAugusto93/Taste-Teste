import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart' as domain_category;
import '../../domain/usecases/category/get_all_categories_usecase.dart';
import '../../domain/usecases/category/get_active_categories_usecase.dart';
import '../../domain/usecases/category/get_category_by_id_usecase.dart';
import '../../domain/usecases/usecase.dart';
import '../../../core/di/injection_container.dart';

/// Provider do repositório de categorias (via GetIt)
final categoryRepositoryProvider = Provider<domain_category.CategoryRepository>((ref) {
  return getIt<domain_category.CategoryRepository>();
});

/// Provider para Use Cases de categoria
final getAllCategoriesUseCaseProvider = Provider<GetAllCategoriesUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return GetAllCategoriesUseCase(repository);
});

final getActiveCategoriesUseCaseProvider = Provider<GetActiveCategoriesUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return GetActiveCategoriesUseCase(repository);
});

final getCategoryByIdUseCaseProvider = Provider<GetCategoryByIdUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return GetCategoryByIdUseCase(repository);
});

/// Provider para todas as categorias
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final useCase = ref.watch(getAllCategoriesUseCaseProvider);
  final result = await useCase(NoParams());
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (categories) => categories,
  );
});

/// Provider para categorias ativas
final activeCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final useCase = ref.watch(getActiveCategoriesUseCaseProvider);
  final result = await useCase(NoParams());
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (categories) => categories,
  );
});

/// Provider para uma categoria específica por ID
final categoryByIdProvider = FutureProvider.family<Category, String>((ref, id) async {
  final useCase = ref.watch(getCategoryByIdUseCaseProvider);
  final result = await useCase(GetCategoryByIdParams(id: id));
  
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
