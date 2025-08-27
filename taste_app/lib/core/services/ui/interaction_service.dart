import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Serviço para gerenciar micro-interações e feedback háptico
class InteractionService {
  static const Duration _fastDuration = Duration(milliseconds: 150);
  static const Duration _mediumDuration = Duration(milliseconds: 250);

  /// Feedback háptico leve para interações sutis
  static Future<void> lightHaptic() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Ignora erros de haptic em dispositivos que não suportam
    }
  }

  /// Feedback háptico médio para ações importantes
  static Future<void> mediumHaptic() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Ignora erros de haptic em dispositivos que não suportam
    }
  }

  /// Feedback háptico forte para ações críticas
  static Future<void> heavyHaptic() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Ignora erros de haptic em dispositivos que não suportam
    }
  }

  /// Feedback de seleção para elementos de interface
  static Future<void> selectionHaptic() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Ignora erros de haptic em dispositivos que não suportam
    }
  }

  /// Animação de tap com escala para cards
  static Widget tapAnimation({
    required Widget child,
    required VoidCallback onTap,
    double scaleDown = 0.95,
    Duration duration = _fastDuration,
    bool enableHaptic = true,
  }) {
    return TapAnimationWidget(
      onTap: onTap,
      scaleDown: scaleDown,
      duration: duration,
      enableHaptic: enableHaptic,
      child: child,
    );
  }

  /// Animação de entrada escalonada para listas
  static Widget staggeredListAnimation({
    required Widget child,
    required int index,
    Duration delay = const Duration(milliseconds: 50),
    Duration duration = _mediumDuration,
  }) {
    return StaggeredAnimationWidget(
      index: index,
      delay: delay,
      duration: duration,
      child: child,
    );
  }

  /// Animação de slide para transições de página
  static Widget slideTransition({
    required Widget child,
    required Animation<double> animation,
    SlideDirection direction = SlideDirection.fromRight,
  }) {
    Offset begin;
    switch (direction) {
      case SlideDirection.fromLeft:
        begin = const Offset(-1.0, 0.0);
        break;
      case SlideDirection.fromRight:
        begin = const Offset(1.0, 0.0);
        break;
      case SlideDirection.fromTop:
        begin = const Offset(0.0, -1.0);
        break;
      case SlideDirection.fromBottom:
        begin = const Offset(0.0, 1.0);
        break;
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }

  /// Animação de fade para transições suaves
  static Widget fadeTransition({
    required Widget child,
    required Animation<double> animation,
    Duration duration = _mediumDuration,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
      child: child,
    );
  }

  /// Animação de bounce para feedback visual
  static Widget bounceAnimation({
    required Widget child,
    required AnimationController controller,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (controller.value * 0.1),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Widget para animação de tap com escala
class TapAnimationWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleDown;
  final Duration duration;
  final bool enableHaptic;

  const TapAnimationWidget({
    super.key,
    required this.child,
    required this.onTap,
    this.scaleDown = 0.95,
    this.duration = const Duration(milliseconds: 150),
    this.enableHaptic = true,
  });

  @override
  State<TapAnimationWidget> createState() => _TapAnimationWidgetState();
}

class _TapAnimationWidgetState extends State<TapAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.enableHaptic) {
      await InteractionService.lightHaptic();
    }
    
    await _controller.forward();
    await _controller.reverse();
    
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Widget para animação escalonada em listas
class StaggeredAnimationWidget extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;

  const StaggeredAnimationWidget({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 250),
  });

  @override
  State<StaggeredAnimationWidget> createState() => _StaggeredAnimationWidgetState();
}

class _StaggeredAnimationWidgetState extends State<StaggeredAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    // Inicia a animação com delay baseado no índice
    Future.delayed(
      Duration(milliseconds: widget.index * widget.delay.inMilliseconds),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Direções para animação de slide
enum SlideDirection {
  fromLeft,
  fromRight,
  fromTop,
  fromBottom,
}

/// Extension para facilitar o uso de animações em widgets
extension WidgetAnimationExtension on Widget {
  /// Adiciona animação de tap ao widget
  Widget withTapAnimation({
    required VoidCallback onTap,
    double scaleDown = 0.95,
    Duration duration = const Duration(milliseconds: 150),
    bool enableHaptic = true,
  }) {
    return InteractionService.tapAnimation(
      onTap: onTap,
      scaleDown: scaleDown,
      duration: duration,
      enableHaptic: enableHaptic,
      child: this,
    );
  }

  /// Adiciona animação escalonada ao widget
  Widget withStaggeredAnimation({
    required int index,
    Duration delay = const Duration(milliseconds: 50),
    Duration duration = const Duration(milliseconds: 250),
  }) {
    return InteractionService.staggeredListAnimation(
      index: index,
      delay: delay,
      duration: duration,
      child: this,
    );
  }
}