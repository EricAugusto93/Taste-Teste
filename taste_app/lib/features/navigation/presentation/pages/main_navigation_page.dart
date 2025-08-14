import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class MainNavigationPage extends StatefulWidget {
  final Widget child;
  
  const MainNavigationPage({super.key, required this.child});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentIndex();
  }
  
  void _updateCurrentIndex() {
    final location = GoRouterState.of(context).uri.path;
    setState(() {
      if (location.startsWith('/home')) {
        _currentIndex = 0;
      } else if (location.startsWith('/search')) {
        _currentIndex = 1;
      } else if (location.startsWith('/profile')) {
        _currentIndex = 2;
      }
    });
  }
  
  void _onTabTapped(int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      // Removida a bottomNavigationBar branca - a navegação agora é feita pela própria HomePage
    );
  }
}