import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavigationPage extends StatefulWidget {
  final Widget child;
  
  const MainNavigationPage({super.key, required this.child});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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