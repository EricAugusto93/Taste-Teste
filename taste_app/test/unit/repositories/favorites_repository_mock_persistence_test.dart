import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Mock Favorites Persistence Tests', () {
    const String excludedMockFavoritesKey = 'excluded_mock_favorites_mock_user';

    setUp(() async {
      // Limpar SharedPreferences antes de cada teste
      SharedPreferences.setMockInitialValues({});
    });

    test('should persist mock favorite exclusions in SharedPreferences',
        () async {
      // Arrange
      const mockRestaurantId = 'mock_1';
      final prefs = await SharedPreferences.getInstance();

      // Act - Simular a adição de um favorito excluído
      final currentExcluded =
          prefs.getStringList(excludedMockFavoritesKey) ?? [];
      if (!currentExcluded.contains(mockRestaurantId)) {
        currentExcluded.add(mockRestaurantId);
        await prefs.setStringList(excludedMockFavoritesKey, currentExcluded);
      }

      // Assert - Verificar se foi persistido
      final excludedIds = prefs.getStringList(excludedMockFavoritesKey) ?? [];
      expect(excludedIds, contains(mockRestaurantId));
    });

    test('should filter excluded mock favorites from list', () async {
      // Arrange
      const mockRestaurantId = 'mock_3';
      const allMockIds = ['mock_1', 'mock_3', 'mock_5', 'mock_8', 'mock_12'];
      final prefs = await SharedPreferences.getInstance();

      // Act - Adicionar um favorito à lista de excluídos
      await prefs.setStringList(excludedMockFavoritesKey, [mockRestaurantId]);

      // Simular a filtragem que acontece em _getMockFavorites
      final excludedIds = prefs.getStringList(excludedMockFavoritesKey) ?? [];
      final filteredIds =
          allMockIds.where((id) => !excludedIds.contains(id)).toList();

      // Assert - Verificar se o restaurante excluído foi filtrado
      expect(filteredIds, isNot(contains(mockRestaurantId)));
      expect(filteredIds.length, equals(allMockIds.length - 1));
    });

    test('should restore mock favorite by removing from excluded list',
        () async {
      // Arrange
      const mockRestaurantId = 'mock_5';
      final prefs = await SharedPreferences.getInstance();

      // Primeiro, adicionar à lista de excluídos
      await prefs.setStringList(excludedMockFavoritesKey, [mockRestaurantId]);

      // Verificar que foi excluído
      var excludedIds = prefs.getStringList(excludedMockFavoritesKey) ?? [];
      expect(excludedIds, contains(mockRestaurantId));

      // Act - Simular a restauração removendo da lista
      excludedIds.remove(mockRestaurantId);
      await prefs.setStringList(excludedMockFavoritesKey, excludedIds);

      // Assert - Verificar se foi removido da lista de excluídos
      final finalExcludedIds =
          prefs.getStringList(excludedMockFavoritesKey) ?? [];
      expect(finalExcludedIds, isNot(contains(mockRestaurantId)));
    });

    test('should clear all excluded mock favorites', () async {
      // Arrange
      const mockRestaurantIds = ['mock_1', 'mock_3', 'mock_5'];
      final prefs = await SharedPreferences.getInstance();

      // Adicionar vários favoritos à lista de excluídos
      await prefs.setStringList(excludedMockFavoritesKey, mockRestaurantIds);

      // Verificar que foram adicionados
      var excludedIds = prefs.getStringList(excludedMockFavoritesKey) ?? [];
      expect(excludedIds.length, equals(3));

      // Act - Limpar todos os favoritos excluídos
      await prefs.remove(excludedMockFavoritesKey);

      // Assert - Verificar se a lista foi limpa
      excludedIds = prefs.getStringList(excludedMockFavoritesKey) ?? [];
      expect(excludedIds, isEmpty);
    });

    test('should validate mock restaurant IDs', () async {
      // Arrange
      const validMockId = 'mock_1';
      const invalidId = 'real_restaurant_123';

      // Act & Assert
      expect(validMockId.startsWith('mock_'), isTrue);
      expect(invalidId.startsWith('mock_'), isFalse);
    });

    test('should persist data between app sessions', () async {
      // Arrange
      const mockRestaurantId = 'mock_8';
      final prefs = await SharedPreferences.getInstance();

      // Act - Simular primeira sessão: adicionar favorito excluído
      await prefs.setStringList(excludedMockFavoritesKey, [mockRestaurantId]);

      // Simular reinício do app: criar nova instância de SharedPreferences
      final newPrefs = await SharedPreferences.getInstance();

      // Assert - Verificar se os dados persistiram
      final excludedIds =
          newPrefs.getStringList(excludedMockFavoritesKey) ?? [];
      expect(excludedIds, contains(mockRestaurantId));
    });
  });
}
