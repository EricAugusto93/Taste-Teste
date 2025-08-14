import 'package:flutter/material.dart';

/// Sistema de animações e micro-interações para o aplicativo Taste
class AppAnimations {
  // Privado para evitar instanciação
  AppAnimations._();
  
  // ==========================================
  // DURAÇÕES PADRÃO
  // ==========================================
  
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
  
  // ==========================================
  // CURVAS DE ANIMAÇÃO
  // ==========================================
  
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceIn = Curves.bounceIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticIn = Curves.elasticIn;
  static const Curve elasticOut = Curves.elasticOut;
  
  // ==========================================
  // ANIMAÇÕES DE ENTRADA
  // ==========================================
  
  /// Animação de fade in
  static Widget fadeIn({
    required Widget child,
    Duration duration = normal,
    Curve curve = easeInOut,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// Animação de slide in da esquerda
  static Widget slideInLeft({
    required Widget child,
    Duration duration = normal,
    Curve curve = easeOut,
    double offset = -1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: offset, end: 0.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value * MediaQuery.of(context).size.width, 0),
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// Animação de slide in da direita
  static Widget slideInRight({
    required Widget child,
    Duration duration = normal,
    Curve curve = easeOut,
    double offset = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: offset, end: 0.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value * MediaQuery.of(context).size.width, 0),
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// Animação de slide in de cima
  static Widget slideInTop({
    required Widget child,
    Duration duration = normal,
    Curve curve = easeOut,
    double offset = -1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: offset, end: 0.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value * MediaQuery.of(context).size.height),
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// Animação de slide in de baixo
  static Widget slideInBottom({
    required Widget child,
    Duration duration = normal,
    Curve curve = easeOut,
    double offset = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: offset, end: 0.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value * MediaQuery.of(context).size.height),
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// Animação de scale in
  static Widget scaleIn({
    required Widget child,
    Duration duration = normal,
    Curve curve = elasticOut,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: begin, end: end),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }
  
  // ==========================================
  // ANIMAÇÕES DE INTERAÇÃO
  // ==========================================
  
  /// Animação de bounce para botões
  static Widget bounceOnTap({
    required Widget child,
    required VoidCallback onTap,
    Duration duration = fast,
    double scale = 0.95,
  }) {
    return _BounceWidget(
      onTap: onTap,
      duration: duration,
      scale: scale,
      child: child,
    );
  }
  
  /// Animação de pulse (pulsação)
  static Widget pulse({
    required Widget child,
    Duration duration = slow,
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return _PulseWidget(
      duration: duration,
      minScale: minScale,
      maxScale: maxScale,
      child: child,
    );
  }
  
  /// Animação de shake (tremor)
  static Widget shake({
    required Widget child,
    Duration duration = fast,
    double offset = 10.0,
    int count = 3,
  }) {
    return _ShakeWidget(
      duration: duration,
      offset: offset,
      count: count,
      child: child,
    );
  }
  
  // ==========================================
  // ANIMAÇÕES DE LOADING
  // ==========================================
  
  /// Animação de rotação contínua
  static Widget rotate({
    required Widget child,
    Duration duration = slow,
  }) {
    return _RotateWidget(
      duration: duration,
      child: child,
    );
  }
  
  /// Animação de shimmer para loading
  static Widget shimmer({
    required Widget child,
    Duration duration = slow,
    Color baseColor = const Color(0xFFE0E0E0),
    Color highlightColor = const Color(0xFFF5F5F5),
  }) {
    return _ShimmerWidget(
      duration: duration,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
  
  // ==========================================
  // TRANSIÇÕES DE PÁGINA
  // ==========================================
  
  /// Transição de slide horizontal
  static PageRouteBuilder slideTransition({
    required Widget page,
    Duration duration = normal,
    bool rightToLeft = true,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: rightToLeft ? begin : -begin, end: end);
        final offsetAnimation = animation.drive(tween.chain(
          CurveTween(curve: easeInOut),
        ));
        
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
  
  /// Transição de fade
  static PageRouteBuilder fadeTransition({
    required Widget page,
    Duration duration = normal,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
  
  /// Transição de scale
  static PageRouteBuilder scaleTransition({
    required Widget page,
    Duration duration = normal,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
    );
  }
}

// ==========================================
// WIDGETS AUXILIARES
// ==========================================

class _BounceWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Duration duration;
  final double scale;
  
  const _BounceWidget({
    required this.child,
    required this.onTap,
    required this.duration,
    required this.scale,
  });
  
  @override
  State<_BounceWidget> createState() => _BounceWidgetState();
}

class _BounceWidgetState extends State<_BounceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
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
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

class _PulseWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  
  const _PulseWidget({
    required this.child,
    required this.duration,
    required this.minScale,
    required this.maxScale,
  });
  
  @override
  State<_PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<_PulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

class _ShakeWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double offset;
  final int count;
  
  const _ShakeWidget({
    required this.child,
    required this.duration,
    required this.offset,
    required this.count,
  });
  
  @override
  State<_ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<_ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticIn,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void shake() {
    _controller.forward().then((_) => _controller.reverse());
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value * widget.offset, 0),
          child: widget.child,
        );
      },
    );
  }
}

class _RotateWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  
  const _RotateWidget({
    required this.child,
    required this.duration,
  });
  
  @override
  State<_RotateWidget> createState() => _RotateWidgetState();
}

class _RotateWidgetState extends State<_RotateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.repeat();
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
        return Transform.rotate(
          angle: _controller.value * 2.0 * 3.14159,
          child: widget.child,
        );
      },
    );
  }
}

class _ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;
  
  const _ShimmerWidget({
    required this.child,
    required this.duration,
    required this.baseColor,
    required this.highlightColor,
  });
  
  @override
  State<_ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.repeat();
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
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                0.0,
                _controller.value,
                1.0,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}