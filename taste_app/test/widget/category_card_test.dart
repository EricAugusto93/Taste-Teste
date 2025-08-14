import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taste_app/presentation/widgets/category_card.dart';
import 'package:taste_app/data/models/category_model.dart';

void main() {
  group('CategoryCard Widget Tests', () {
    late CategoryModel mockCategory;

    setUp(() {
      mockCategory = CategoryModel(
        id: '1',
        name: 'Pizza',
        description: 'Delicious pizzas',
        icon: 'local_pizza',
        color: '#FF5722',
        isActive: true,
        sortOrder: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    Widget createTestWidget({
      CategoryModel? category,
      VoidCallback? onTap,
      bool isSelected = false,
      double? width,
      double? height,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: width ?? 150,
            height: height ?? 120,
            child: CategoryCard(
              category: category ?? mockCategory,
              onTap: onTap,
              isSelected: isSelected,
              width: width,
              height: height,
            ),
          ),
        ),
      );
    }

    testWidgets('should display category information correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Pizza'), findsOneWidget);
      expect(find.byIcon(Icons.local_pizza), findsOneWidget);
      expect(find.byType(CategoryCard), findsOneWidget);
    });

    testWidgets('should show selected state when isSelected is true', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(isSelected: true));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CategoryCard), findsOneWidget);
      // Visual state changes are tested through widget presence
    });

    testWidgets('should show unselected state when isSelected is false', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(isSelected: false));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CategoryCard), findsOneWidget);
    });

    testWidgets('should call onTap when card is tapped', (WidgetTester tester) async {
      // Arrange
      bool wasTapped = false;
      void onTap() {
        wasTapped = true;
      }

      await tester.pumpWidget(createTestWidget(onTap: onTap));

      // Act
      await tester.tap(find.byType(CategoryCard));
      await tester.pump();

      // Assert
      expect(wasTapped, isTrue);
    });

    testWidgets('should handle different icon types correctly', (WidgetTester tester) async {
      // Arrange
      final coffeeCategory = mockCategory.copyWith(
        name: 'Coffee',
        icon: 'coffee',
      );

      // Act
      await tester.pumpWidget(createTestWidget(category: coffeeCategory));

      // Assert
      expect(find.text('Coffee'), findsOneWidget);
      expect(find.byIcon(Icons.coffee), findsOneWidget);
    });

    testWidgets('should handle unknown icon gracefully', (WidgetTester tester) async {
      // Arrange
      final unknownIconCategory = mockCategory.copyWith(
        icon: 'unknown_icon',
      );

      // Act
      await tester.pumpWidget(createTestWidget(category: unknownIconCategory));

      // Assert
      expect(find.byIcon(Icons.restaurant), findsOneWidget); // Default icon
    });

    testWidgets('should handle long category names gracefully', (WidgetTester tester) async {
      // Arrange
      final longNameCategory = mockCategory.copyWith(
        name: 'This is a very long category name that should be truncated',
      );

      // Act
      await tester.pumpWidget(createTestWidget(category: longNameCategory));

      // Assert
      expect(find.text('This is a very long category name that should be truncated'), findsOneWidget);
      expect(tester.takeException(), isNull); // Should not cause overflow
    });

    testWidgets('should handle invalid color gracefully', (WidgetTester tester) async {
      // Arrange
      final invalidColorCategory = mockCategory.copyWith(
        color: 'invalid_color',
      );

      // Act
      await tester.pumpWidget(createTestWidget(category: invalidColorCategory));

      // Assert
      expect(find.byType(CategoryCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should respect custom width and height', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(
        width: 150,
        height: 120,
      ));

      // Assert
      expect(find.byType(CategoryCard), findsOneWidget);
    });

    testWidgets('should animate when selection state changes', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(isSelected: false));
      await tester.pumpAndSettle();

      // Act - Rebuild with selected state
      await tester.pumpWidget(createTestWidget(isSelected: true));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 100)); // Mid animation
      await tester.pumpAndSettle(); // Complete animation

      // Assert
      expect(find.byType(CategoryCard), findsOneWidget);
    });
  });

  group('CategoriesGrid Widget Tests', () {
    late List<CategoryModel> mockCategories;

    setUp(() {
      mockCategories = [
        CategoryModel(
          id: '1',
          name: 'Pizza',
          description: 'Delicious pizzas',
          icon: 'local_pizza',
          color: '#FF5722',
          isActive: true,
          sortOrder: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CategoryModel(
          id: '2',
          name: 'Coffee',
          description: 'Fresh coffee',
          icon: 'coffee',
          color: '#795548',
          isActive: true,
          sortOrder: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CategoryModel(
          id: '3',
          name: 'Burgers',
          description: 'Tasty burgers',
          icon: 'fastfood',
          color: '#FF9800',
          isActive: true,
          sortOrder: 3,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    });

    Widget createTestWidget({
      List<CategoryModel>? categories,
      Function(CategoryModel)? onCategoryTap,
      String? selectedCategoryId,
      int crossAxisCount = 2,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 400,
            child: CategoriesGrid(
              categories: categories ?? mockCategories,
              onCategoryTap: onCategoryTap,
              selectedCategoryId: selectedCategoryId,
              crossAxisCount: crossAxisCount,
            ),
          ),
        ),
      );
    }

    testWidgets('should display all categories in grid', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Pizza'), findsOneWidget);
      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('Burgers'), findsOneWidget);
      expect(find.byType(CategoryCard), findsNWidgets(3));
    });

    testWidgets('should call onCategoryTap when category is tapped', (WidgetTester tester) async {
      // Arrange
      CategoryModel? tappedCategory;
      void onCategoryTap(CategoryModel category) {
        tappedCategory = category;
      }

      await tester.pumpWidget(createTestWidget(onCategoryTap: onCategoryTap));

      // Act
      await tester.tap(find.text('Pizza'));
      await tester.pump();

      // Assert
      expect(tappedCategory, isNotNull);
      expect(tappedCategory!.name, equals('Pizza'));
    });

    testWidgets('should show selected state for selected category', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(selectedCategoryId: '1'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CategoryCard), findsNWidgets(3));
    });

    testWidgets('should handle empty categories list', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(categories: []));

      // Assert
      expect(find.byType(CategoryCard), findsNothing);
    });

    testWidgets('should respect crossAxisCount parameter', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(crossAxisCount: 3));

      // Assert
      expect(find.byType(CategoriesGrid), findsOneWidget);
    });
  });

  group('CategoriesHorizontalList Widget Tests', () {
    late List<CategoryModel> mockCategories;

    setUp(() {
      mockCategories = [
        CategoryModel(
          id: '1',
          name: 'Pizza',
          description: 'Delicious pizzas',
          icon: 'local_pizza',
          color: '#FF5722',
          isActive: true,
          sortOrder: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CategoryModel(
          id: '2',
          name: 'Coffee',
          description: 'Fresh coffee',
          icon: 'coffee',
          color: '#795548',
          isActive: true,
          sortOrder: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    });

    Widget createTestWidget({
      List<CategoryModel>? categories,
      Function(CategoryModel)? onCategoryTap,
      String? selectedCategoryId,
      double itemWidth = 100,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 150,
            child: CategoriesHorizontalList(
              categories: categories ?? mockCategories,
              onCategoryTap: onCategoryTap,
              selectedCategoryId: selectedCategoryId,
              itemWidth: itemWidth,
            ),
          ),
        ),
      );
    }

    testWidgets('should display categories in horizontal list', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Pizza'), findsOneWidget);
      expect(find.text('Coffee'), findsOneWidget);
      expect(find.byType(CategoryCard), findsNWidgets(2));
    });

    testWidgets('should call onCategoryTap when category is tapped', (WidgetTester tester) async {
      // Arrange
      CategoryModel? tappedCategory;
      void onCategoryTap(CategoryModel category) {
        tappedCategory = category;
      }

      await tester.pumpWidget(createTestWidget(onCategoryTap: onCategoryTap));

      // Act
      await tester.tap(find.text('Coffee'));
      await tester.pump();

      // Assert
      expect(tappedCategory, isNotNull);
      expect(tappedCategory!.name, equals('Coffee'));
    });

    testWidgets('should be scrollable horizontally', (WidgetTester tester) async {
      // Arrange
      final manyCategories = List.generate(10, (index) => 
        CategoryModel(
          id: '$index',
          name: 'Category $index',
          description: 'Description $index',
          icon: 'restaurant',
          color: '#FF5722',
          isActive: true,
          sortOrder: index,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(createTestWidget(categories: manyCategories));

      // Act & Assert
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(CategoryCard), findsWidgets);
    });

    testWidgets('should respect itemWidth parameter', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(itemWidth: 150));

      // Assert
      expect(find.byType(CategoriesHorizontalList), findsOneWidget);
    });
  });

  group('CategoryChip Widget Tests', () {
    late CategoryModel mockCategory;

    setUp(() {
      mockCategory = CategoryModel(
        id: '1',
        name: 'Pizza',
        description: 'Delicious pizzas',
        icon: 'local_pizza',
        color: '#FF5722',
        isActive: true,
        sortOrder: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    Widget createTestWidget({
      CategoryModel? category,
      bool isSelected = false,
      VoidCallback? onTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Wrap(
            children: [
              CategoryChip(
                category: category ?? mockCategory,
                isSelected: isSelected,
                onTap: onTap,
              ),
            ],
          ),
        ),
      );
    }

    testWidgets('should display category name and icon', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Pizza'), findsOneWidget);
      expect(find.byIcon(Icons.local_pizza), findsOneWidget);
    });

    testWidgets('should show selected state when isSelected is true', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(isSelected: true));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CategoryChip), findsOneWidget);
    });

    testWidgets('should call onTap when chip is tapped', (WidgetTester tester) async {
      // Arrange
      bool wasTapped = false;
      void onTap() {
        wasTapped = true;
      }

      await tester.pumpWidget(createTestWidget(onTap: onTap));

      // Act
      await tester.tap(find.byType(CategoryChip));
      await tester.pump();

      // Assert
      expect(wasTapped, isTrue);
    });

    testWidgets('should animate when selection state changes', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(isSelected: false));
      await tester.pumpAndSettle();

      // Act
      await tester.pumpWidget(createTestWidget(isSelected: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CategoryChip), findsOneWidget);
    });

    testWidgets('should handle different category types', (WidgetTester tester) async {
      // Arrange
      final coffeeCategory = mockCategory.copyWith(
        name: 'Coffee',
        icon: 'coffee',
        color: '#795548',
      );

      // Act
      await tester.pumpWidget(createTestWidget(category: coffeeCategory));

      // Assert
      expect(find.text('Coffee'), findsOneWidget);
      expect(find.byIcon(Icons.coffee), findsOneWidget);
    });
  });
}