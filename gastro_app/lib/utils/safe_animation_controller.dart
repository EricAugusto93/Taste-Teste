import 'package:flutter/material.dart';

/// Wrapper seguro para AnimationController que previne erros PersistedOffset
/// no Flutter Web
class SafeAnimationController {
  AnimationController? _controller;
  bool _disposed = false;
  
  SafeAnimationController({
    required Duration duration,
    required TickerProvider vsync,
    Duration? reverseDuration,
    String? debugLabel,
    double? lowerBound,
    double? upperBound,
    AnimationBehavior? animationBehavior,
  }) {
    try {
      _controller = AnimationController(
        duration: duration,
        reverseDuration: reverseDuration,
        debugLabel: debugLabel,
        lowerBound: lowerBound ?? 0.0,
        upperBound: upperBound ?? 1.0,
        animationBehavior: animationBehavior ?? AnimationBehavior.normal,
        vsync: vsync,
      );
    } catch (e) {
      debugPrint('⚠️ Erro ao criar AnimationController: $e');
    }
  }
  
  /// Getter seguro para o controller
  AnimationController? get controller => _disposed ? null : _controller;
  
  /// Verifica se o controller está disponível e não foi descartado
  bool get isAvailable => !_disposed && _controller != null;
  
  /// Verifica se está animando
  bool get isAnimating {
    if (!isAvailable) return false;
    try {
      return _controller!.isAnimating;
    } catch (e) {
      debugPrint('⚠️ Erro ao verificar isAnimating: $e');
      return false;
    }
  }
  
  /// Forward seguro
  TickerFuture? forward({double? from}) {
    if (!isAvailable) return null;
    try {
      return _controller!.forward(from: from);
    } catch (e) {
      debugPrint('⚠️ Erro ao executar forward: $e');
      return null;
    }
  }
  
  /// Reverse seguro
  TickerFuture? reverse({double? from}) {
    if (!isAvailable) return null;
    try {
      return _controller!.reverse(from: from);
    } catch (e) {
      debugPrint('⚠️ Erro ao executar reverse: $e');
      return null;
    }
  }
  
  /// Stop seguro
  void stop({bool canceled = true}) {
    if (!isAvailable) return;
    try {
      _controller!.stop(canceled: canceled);
    } catch (e) {
      debugPrint('⚠️ Erro ao executar stop: $e');
    }
  }
  
  /// Reset seguro
  void reset() {
    if (!isAvailable) return;
    try {
      _controller!.reset();
    } catch (e) {
      debugPrint('⚠️ Erro ao executar reset: $e');
    }
  }
  
  /// Dispose seguro
  void dispose() {
    if (_disposed) return;
    
    _disposed = true;
    
    if (_controller != null) {
      try {
        if (_controller!.isAnimating) {
          _controller!.stop();
        }
        _controller!.dispose();
      } catch (e) {
        debugPrint('⚠️ Erro ao descartar AnimationController: $e');
      } finally {
        _controller = null;
      }
    }
  }
  
  /// Getter para value
  double get value {
    if (!isAvailable) return 0.0;
    try {
      return _controller!.value;
    } catch (e) {
      debugPrint('⚠️ Erro ao obter value: $e');
      return 0.0;
    }
  }
  
  /// Setter para value
  set value(double newValue) {
    if (!isAvailable) return;
    try {
      _controller!.value = newValue;
    } catch (e) {
      debugPrint('⚠️ Erro ao definir value: $e');
    }
  }
}

/// Mixin para facilitar o uso do SafeAnimationController
mixin SafeAnimationMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  final List<SafeAnimationController> _controllers = [];
  
  /// Cria um SafeAnimationController e o adiciona à lista para dispose automático
  SafeAnimationController createSafeController({
    required Duration duration,
    Duration? reverseDuration,
    String? debugLabel,
    double? lowerBound,
    double? upperBound,
    AnimationBehavior? animationBehavior,
  }) {
    final controller = SafeAnimationController(
      duration: duration,
      reverseDuration: reverseDuration,
      debugLabel: debugLabel,
      lowerBound: lowerBound,
      upperBound: upperBound,
      animationBehavior: animationBehavior,
      vsync: this,
    );
    
    _controllers.add(controller);
    return controller;
  }
  
  /// Dispose automático de todos os controllers
  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }
}