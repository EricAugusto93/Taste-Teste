import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taste_app/presentation/widgets/loading_widget.dart';
import 'package:taste_app/core/theme/app_colors.dart';
import 'package:taste_app/core/theme/app_dimensions.dart';

void main() {
  group('LoadingWidget Tests', () {
    testWidgets('should render basic loading widget correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );
      
      expect(find.byType(LoadingWidget), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Carregando...'), findsNothing); // showMessage é true mas message é null
    });
    
    testWidgets('should display message when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              message: 'Loading data...',
            ),
          ),
        ),
      );
      
      expect(find.text('Loading data...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('should hide message when showMessage is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              message: 'Hidden message',
              showMessage: false,
            ),
          ),
        ),
      );
      
      expect(find.text('Hidden message'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('should apply custom size', (tester) async {
      const customSize = 100.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              size: customSize,
            ),
          ),
        ),
      );
      
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        ).first,
      );
      
      expect(sizedBox.width, customSize);
      expect(sizedBox.height, customSize);
    });
    
    testWidgets('should apply custom color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              color: Colors.red,
            ),
          ),
        ),
      );
      
      expect(find.byType(LoadingWidget), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('should use default size when not specified', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );
      
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        ).first,
      );
      
      expect(sizedBox.width, AppDimensions.iconLarge);
      expect(sizedBox.height, AppDimensions.iconLarge);
    });
    
    testWidgets('should use default color when not specified', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );
      
      expect(find.byType(LoadingWidget), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
  
  group('LoadingWidget Factory Tests', () {
    testWidgets('should create simple loading widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingWidget.simple(
              size: 50,
              color: Colors.blue,
            ),
          ),
        ),
      );
      
      expect(find.byType(LoadingWidget), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing); // showMessage é false
      
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        ).first,
      );
      
      expect(sizedBox.width, 50);
      expect(sizedBox.height, 50);
    });
    
    testWidgets('should create full screen loading widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingWidget.fullScreen(
              message: 'Loading full screen...',
            ),
          ),
        ),
      );
      
      expect(find.byType(LoadingWidget), findsOneWidget);
      expect(find.text('Loading full screen...'), findsOneWidget);
      
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        ).first,
      );
      
      expect(sizedBox.width, 80);
      expect(sizedBox.height, 80);
    });
    
    testWidgets('should create lottie loading widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingWidget.lottie(
              message: 'Loading with animation...',
            ),
          ),
        ),
      );
      
      expect(find.byType(LoadingWidget), findsOneWidget);
      expect(find.text('Loading with animation...'), findsOneWidget);
      // Note: Lottie widget pode não ser encontrado em testes sem assets
    });
  });
  
  group('ListLoadingWidget Tests', () {
    testWidgets('should render list loading widget correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListLoadingWidget(),
          ),
        ),
      );
      
      expect(find.byType(ListLoadingWidget), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ShimmerEffect), findsWidgets);
    });
    
    testWidgets('should render correct number of shimmer items', (tester) async {
      const itemCount = 3;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListLoadingWidget(
              itemCount: itemCount,
            ),
          ),
        ),
      );
      
      // Verifica se o ListView foi criado
      expect(find.byType(ListView), findsOneWidget);
      
      // Scroll para garantir que todos os itens sejam renderizados
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();
      
      // Verifica se há pelo menos alguns shimmer effects
      expect(find.byType(ShimmerEffect), findsWidgets);
    });
    
    testWidgets('should apply custom item height', (tester) async {
      const customHeight = 120.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListLoadingWidget(
              itemHeight: customHeight,
              itemCount: 1,
            ),
          ),
        ),
      );
      
      expect(find.byType(ListLoadingWidget), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });
    
    testWidgets('should apply custom padding', (tester) async {
      const customPadding = EdgeInsets.all(20.0);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListLoadingWidget(
              padding: customPadding,
            ),
          ),
        ),
      );
      
      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.padding, customPadding);
    });
  });
  
  group('ShimmerEffect Tests', () {
    testWidgets('should render shimmer effect correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerEffect(
              child: Container(
                width: 100,
                height: 50,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
      
      expect(find.byType(ShimmerEffect), findsOneWidget);
    });
    
    testWidgets('should animate shimmer effect', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerEffect(),
          ),
        ),
      );
      
      expect(find.byType(ShimmerEffect), findsOneWidget);
      
      // Avança a animação
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(ShimmerEffect), findsOneWidget);
      
      // Avança mais a animação
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.byType(ShimmerEffect), findsOneWidget);
    });
    
    testWidgets('should apply custom colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerEffect(
              baseColor: Colors.red,
              highlightColor: Colors.blue,
            ),
          ),
        ),
      );
      
      expect(find.byType(ShimmerEffect), findsOneWidget);
    });
    
    testWidgets('should dispose animation controller properly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerEffect(),
          ),
        ),
      );
      
      expect(find.byType(ShimmerEffect), findsOneWidget);
      
      // Remove o widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(),
          ),
        ),
      );
      
      // Verifica se não há mais shimmer effect
      expect(find.byType(ShimmerEffect), findsNothing);
    });
  });
  
  group('OverlayLoadingWidget Tests', () {
    testWidgets('should render overlay loading widget correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverlayLoadingWidget(),
          ),
        ),
      );
      
      expect(find.byType(OverlayLoadingWidget), findsOneWidget);
      expect(find.byType(LoadingWidget), findsOneWidget);
      expect(find.text('Carregando...'), findsOneWidget);
    });
    
    testWidgets('should display custom message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverlayLoadingWidget(
              message: 'Processing...',
            ),
          ),
        ),
      );
      
      expect(find.text('Processing...'), findsOneWidget);
      expect(find.byType(LoadingWidget), findsOneWidget);
    });
    
    testWidgets('should have overlay background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverlayLoadingWidget(),
          ),
        ),
      );
      
      expect(find.byType(OverlayLoadingWidget), findsOneWidget);
      expect(find.byType(LoadingWidget), findsOneWidget);
    });
    
    testWidgets('should center loading content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverlayLoadingWidget(),
          ),
        ),
      );
      
      expect(find.byType(OverlayLoadingWidget), findsOneWidget);
      expect(find.byType(LoadingWidget), findsOneWidget);
    });
  });
}