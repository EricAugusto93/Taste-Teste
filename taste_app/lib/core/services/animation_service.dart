// Re-export do AnimationService para compatibilidade
// TODO: Implementar AnimationService quando necessário

/// Serviço de animações (placeholder)
class AnimationService {
  static final AnimationService _instance = AnimationService._internal();
  factory AnimationService() => _instance;
  AnimationService._internal();

  /// Placeholder para futuras animações
  void playAnimation(String animationName) {
    // TODO: Implementar animações
  }
}