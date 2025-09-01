import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      // Removida a bottomNavigationBar branca - a navegação agora é feita pela própria HomePage
    );
  }
}