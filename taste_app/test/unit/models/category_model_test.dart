import 'package:flutter_test/flutter_test.dart';
import 'package:taste_app/data/models/category_model.dart';

void main() {
  group('CategoryModel Tests', () {
    late Map<String, dynamic> mockJson;

    setUp(() {
      mockJson = {
        'id': '1',
        'name': 'Italian',
        'icon': 'restaurant',
        'color': '#FF6B47',
        'is_active': true,
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };
    });

    test('should create CategoryModel from JSON', () {
      // Act
      final category = CategoryModel.fromJson(mockJson);

      // Assert
      expect(category.id, '1');
      expect(category.name, 'Italian');
      expect(category.icon, 'restaurant');
      expect(category.color, '#FF6B47');
      expect(category.isActive, true);
    });

    test('should convert CategoryModel to JSON', () {
      // Arrange
      final category = CategoryModel.fromJson(mockJson);

      // Act
      final json = category.toJson();

      // Assert
      expect(json['id'], '1');
      expect(json['name'], 'Italian');
      expect(json['icon'], 'restaurant');
      expect(json['color'], '#FF6B47');
      expect(json['is_active'], true);
    });

    test('should create copy with modified fields', () {
      // Arrange
      final category = CategoryModel.fromJson(mockJson);

      // Act
      final modifiedCategory = category.copyWith(
        name: 'Mexican',
        color: '#4CAF50',
        isActive: false,
      );

      // Assert
      expect(modifiedCategory.name, 'Mexican');
      expect(modifiedCategory.color, '#4CAF50');
      expect(modifiedCategory.isActive, false);
      // Other fields should remain the same
      expect(modifiedCategory.id, category.id);
      expect(modifiedCategory.icon, category.icon);
    });

    test('should check equality correctly', () {
      // Arrange
      final category1 = CategoryModel.fromJson(mockJson);
      final category2 = CategoryModel.fromJson(mockJson);
      final category3 = CategoryModel.fromJson({
        ...mockJson,
        'id': '2',
      });

      // Assert
      expect(category1, equals(category2));
      expect(category1, isNot(equals(category3)));
      expect(category1.hashCode, equals(category2.hashCode));
      expect(category1.hashCode, isNot(equals(category3.hashCode)));
    });

    test('should handle default color', () {
      // Arrange
      final jsonWithoutColor = Map<String, dynamic>.from(mockJson);
      jsonWithoutColor.remove('color');

      // Act
      final category = CategoryModel.fromJson(jsonWithoutColor);

      // Assert
      expect(category.color, '#FF6B47'); // Default color
    });

    test('should handle default values', () {
      // Arrange
      final minimalJson = {
        'id': '1',
        'name': 'Test Category',
        'icon': 'test',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };

      // Act
      final category = CategoryModel.fromJson(minimalJson);

      // Assert
      expect(category.id, '1');
      expect(category.name, 'Test Category');
      expect(category.icon, 'test');
      expect(category.color, '#FF6B47'); // Default color
      expect(category.isActive, true); // Default value
    });
  });
}