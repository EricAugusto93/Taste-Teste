import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Serviço centralizado para animações da aplicação
class AnimationService {
  AnimationService._();

  // ===== DURAÇÕES PADRÃO =====
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // ===== CURVAS PADRÃO =====
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceIn = Curves.bounceIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticIn = Curves.elasticIn;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;

  // ===== ANIMAÇÕES DE PÁGINA =====
  
  /// Transição de slide da direita para esquerda
  static PageRouteBuilder<T> slideFromRight<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: normal,
      reverseTransitionDuration: normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween.chain(
          CurveTween(curve: fastOutSlowIn),
        ));

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  /// Transição de slide da esquerda para direita
  static PageRouteBuilder<T> slideFromLeft<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: normal,
      reverseTransitionDuration: normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween.chain(
          CurveTween(curve: fastOutSlowIn),
        ));

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  /// Transição de slide de baixo para cima
  static PageRouteBuilder<T> slideFromBottom<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: normal,
      reverseTransitionDuration: normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween.chain(
          CurveTween(curve: fastOutSlowIn),
        ));

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  /// Transição de fade
  static PageRouteBuilder<T> fadeTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: normal,
      reverseTransitionDuration: normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(
            CurveTween(curve: easeInOut),
          ),
          child: child,
        );
      },
    );
  }

  /// Transição de escala
  static PageRouteBuilder<T> scaleTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: normal,
      reverseTransitionDuration: normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation.drive(
            Tween(begin: 0.8, end: 1.0).chain(
              CurveTween(curve: fastOutSlowIn),
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  // ===== ANIMAÇÕES DE WIDGET =====

  /// Widget animado de fade in
  static Widget fadeIn({
    required Widget child,
    Duration duration = normal,
    Curve curve = easeInOut,
    Duration delay = Duration.zero,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: delay == Duration.zero
          ? child
          : Future.delayed(delay, () => child) as Widget,
    );
  }

  /// Widget animado de slide in
  static Widget slideIn({
    required Widget child,
    Offset begin = const Offset(0.0, 1.0),
    Duration duration = normal,
    Curve curve = fastOutSlowIn,
    Duration delay = Duration.zero,
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      tween: Tween(begin: begin, end: Offset.zero),
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: delay == Duration.zero
          ? child
          : Future.delayed(delay, () => child) as Widget,
    );
  }

  /// Widget animado de escala
  static Widget scaleIn({
    required Widget child,
    double begin = 0.8,
    Duration duration = normal,
    Curve curve = elasticOut,
    Duration delay = Duration.zero,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: begin, end: 1.0),
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: delay == Duration.zero
          ? child
          : Future.delayed(delay, () => child) as Widget,
    );
  }

  /// Widget animado de rotação
  static Widget rotateIn({
    required Widget child,
    double begin = 0.5,
    Duration duration = normal,
    Curve curve = elasticOut,
    Duration delay = Duration.zero,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: begin, end: 0.0),
      curve: curve,
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value,
          child: child,
        );
      },
      child: delay == Duration.zero
          ? child
          : Future.delayed(delay, () => child) as Widget,
    );
  }

  // ===== ANIMAÇÕES DE LISTA =====

  /// Animação escalonada para listas
  static Widget staggeredListItem({
    required Widget child,
    required int index,
    Duration duration = normal,
    Duration staggerDelay = const Duration(milliseconds: 100),
    Curve curve = fastOutSlowIn,
  }) {
    final delay = Duration(milliseconds: index * staggerDelay.inMilliseconds);
    
    return AnimatedBuilder(
      animation: AlwaysStoppedAnimation(0),
      builder: (context, _) {
        return TweenAnimationBuilder<double>(
          duration: duration + delay,
          tween: Tween(begin: 0.0, end: 1.0),
          curve: curve,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: child,
        );
      },
    );
  }

  // ===== ANIMAÇÕES DE FEEDBACK =====

  /// Animação de pulse (pulsação)
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: minScale, end: maxScale),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      onEnd: () {
        // Reinicia a animação
      },
      child: child,
    );
  }

  /// Animação de shake (tremor)
  static Widget shake({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double offset = 10.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticIn,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(offset * (0.5 - value).abs() * 4, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animação de bounce (salto)
  static Widget bounce({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    double height = 20.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.bounceOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -height * (1 - value)),
          child: child,
        );
      },
      child: child,
    );
  }

  // ===== FEEDBACK HÁPTICO =====

  /// Feedback háptico leve
  static void lightHaptic() {
    HapticFeedback.lightImpact();
  }

  /// Feedback háptico médio
  static void mediumHaptic() {
    HapticFeedback.mediumImpact();
  }

  /// Feedback háptico forte
  static void heavyHaptic() {
    HapticFeedback.heavyImpact();
  }

  /// Feedback de seleção
  static void selectionHaptic() {
    HapticFeedback.selectionClick();
  }

  /// Feedback de vibração
  static void vibrate() {
    HapticFeedback.vibrate();
  }

  // ===== UTILITÁRIOS =====

  /// Cria um controller de animação com duração personalizada
  static AnimationController createController({
    required TickerProvider vsync,
    Duration duration = normal,
  }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
    );
  }

  /// Cria uma animação com curva personalizada
  static Animation<T> createCurvedAnimation<T>({
    required AnimationController controller,
    required Tween<T> tween,
    Curve curve = easeInOut,
  }) {
    return tween.animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }

  /// Executa uma animação com callback
  static Future<void> runAnimation({
    required AnimationController controller,
    VoidCallback? onComplete,
  }) async {
    await controller.forward();
    onComplete?.call();
  }

  /// Reseta uma animação
  static void resetAnimation(AnimationController controller) {
    controller.reset();
  }

  /// Para uma animação
  static void stopAnimation(AnimationController controller) {
    controller.stop();
  }
}

/// Extensão para facilitar o uso de animações em widgets
extension AnimationExtension on Widget {
  /// Aplica animação de fade in
  Widget fadeIn({
    Duration duration = AnimationService.normal,
    Curve curve = AnimationService.easeInOut,
    Duration delay = Duration.zero,
  }) {
    return AnimationService.fadeIn(
      child: this,
      duration: duration,
      curve: curve,
      delay: delay,
    );
  }

  /// Aplica animação de slide in
  Widget slideIn({
    Offset begin = const Offset(0.0, 1.0),
    Duration duration = AnimationService.normal,
    Curve curve = AnimationService.fastOutSlowIn,
    Duration delay = Duration.zero,
  }) {
    return AnimationService.slideIn(
      child: this,
      begin: begin,
      duration: duration,
      curve: curve,
      delay: delay,
    );
  }

  /// Aplica animação de escala
  Widget scaleIn({
    double begin = 0.8,
    Duration duration = AnimationService.normal,
    Curve curve = AnimationService.elasticOut,
    Duration delay = Duration.zero,
  }) {
    return AnimationService.scaleIn(
      child: this,
      begin: begin,
      duration: duration,
      curve: curve,
      delay: delay,
    );
  }

  /// Aplica animação de rotação
  Widget rotateIn({
    double begin = 0.5,
    Duration duration = AnimationService.normal,
    Curve curve = AnimationService.elasticOut,
    Duration delay = Duration.zero,
  }) {
    return AnimationService.rotateIn(
      child: this,
      begin: begin,
      duration: duration,
      curve: curve,
      delay: delay,
    );
  }

  /// Aplica animação de pulse
  Widget pulse({
    Duration duration = const Duration(milliseconds: 1000),
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return AnimationService.pulse(
      child: this,
      duration: duration,
      minScale: minScale,
      maxScale: maxScale,
    );
  }

  /// Aplica animação de shake
  Widget shake({
    Duration duration = const Duration(milliseconds: 500),
    double offset = 10.0,
  }) {
    return AnimationService.shake(
      child: this,
      duration: duration,
      offset: offset,
    );
  }

  /// Aplica animação de bounce
  Widget bounce({
    Duration duration = const Duration(milliseconds: 600),
    double height = 20.0,
  }) {
    return AnimationService.bounce(
      child: this,
      duration: duration,
      height: height,
    );
  }
}