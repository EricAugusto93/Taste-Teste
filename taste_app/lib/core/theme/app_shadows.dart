import 'package:flutter/material.dart';

/// Sistema de sombras e elevações para o aplicativo Taste
class AppShadows {
  // Privado para evitar instanciação
  AppShadows._();
  
  // ==========================================
  // SOMBRAS PADRÃO
  // ==========================================
  
  /// Sombra muito sutil (1px)
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0A000000), // 4% opacity
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];
  
  /// Sombra suave (2px) - Padrão para cards
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x14000000), // 8% opacity
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000), // 4% opacity
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];
  
  /// Sombra média (4px)
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0F000000), // 6% opacity
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];
  
  /// Sombra forte (8px)
  static const List<BoxShadow> strong = [
    BoxShadow(
      color: Color(0x28000000), // 16% opacity
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x14000000), // 8% opacity
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  /// Sombra muito forte (16px)
  static const List<BoxShadow> veryStrong = [
    BoxShadow(
      color: Color(0x3D000000), // 24% opacity
      offset: Offset(0, 16),
      blurRadius: 32,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
  
  // ==========================================
  // SOMBRAS COLORIDAS
  // ==========================================
  
  /// Sombra com cor primária
  static List<BoxShadow> primaryColored({double opacity = 0.2}) {
    return [
      BoxShadow(
        color: const Color(0xFFFF6B35).withOpacity(opacity),
        offset: const Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ];
  }
  
  /// Sombra com cor secundária
  static List<BoxShadow> secondaryColored({double opacity = 0.2}) {
    return [
      BoxShadow(
        color: const Color(0xFF6BB6FF).withOpacity(opacity),
        offset: const Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ];
  }
  
  /// Sombra com cor de sucesso
  static List<BoxShadow> successColored({double opacity = 0.2}) {
    return [
      BoxShadow(
        color: const Color(0xFF10B981).withOpacity(opacity),
        offset: const Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ];
  }
  
  /// Sombra com cor de erro
  static List<BoxShadow> errorColored({double opacity = 0.2}) {
    return [
      BoxShadow(
        color: const Color(0xFFEF4444).withOpacity(opacity),
        offset: const Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ];
  }
  
  /// Sombra com cor de aviso
  static List<BoxShadow> warningColored({double opacity = 0.2}) {
    return [
      BoxShadow(
        color: const Color(0xFFF59E0B).withOpacity(opacity),
        offset: const Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ];
  }
  
  // ==========================================
  // SOMBRAS ESPECIAIS
  // ==========================================
  
  /// Sombra interna (inset)
  static const List<BoxShadow> inset = [
    BoxShadow(
      color: Color(0x14000000), // 8% opacity
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -2,
    ),
  ];
  
  /// Sombra de glow (brilho)
  static List<BoxShadow> glow({
    Color color = const Color(0xFFFF6B35),
    double opacity = 0.3,
    double blurRadius = 20,
  }) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        offset: const Offset(0, 0),
        blurRadius: blurRadius,
        spreadRadius: 0,
      ),
    ];
  }
  
  /// Sombra de neumorfismo (elevado)
  static const List<BoxShadow> neomorphismElevated = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity
      offset: Offset(4, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0xFFFFFFFF), // Branco
      offset: Offset(-4, -4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  /// Sombra de neumorfismo (pressionado)
  static const List<BoxShadow> neomorphismPressed = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity
      offset: Offset(2, 2),
      blurRadius: 4,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color(0xFFFFFFFF), // Branco
      offset: Offset(-2, -2),
      blurRadius: 4,
      spreadRadius: -2,
    ),
  ];
  
  // ==========================================
  // MÉTODOS UTILITÁRIOS
  // ==========================================
  
  /// Retorna sombra baseada no nível de elevação
  static List<BoxShadow> getElevationShadow(int elevation) {
    switch (elevation) {
      case 0:
        return [];
      case 1:
        return subtle;
      case 2:
        return soft;
      case 4:
        return medium;
      case 8:
        return strong;
      case 16:
        return veryStrong;
      default:
        if (elevation < 2) return subtle;
        if (elevation < 4) return soft;
        if (elevation < 8) return medium;
        if (elevation < 16) return strong;
        return veryStrong;
    }
  }
  
  /// Cria sombra personalizada
  static List<BoxShadow> custom({
    required Color color,
    required Offset offset,
    required double blurRadius,
    double spreadRadius = 0,
    double opacity = 1.0,
  }) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        offset: offset,
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
    ];
  }
  
  /// Combina múltiplas sombras
  static List<BoxShadow> combine(List<List<BoxShadow>> shadows) {
    final List<BoxShadow> combined = [];
    for (final shadowList in shadows) {
      combined.addAll(shadowList);
    }
    return combined;
  }
}

/// Widget para aplicar sombras facilmente
class ShadowContainer extends StatelessWidget {
  final Widget child;
  final List<BoxShadow>? boxShadow;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  
  const ShadowContainer({
    super.key,
    required this.child,
    this.boxShadow,
    this.color,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
  });
  
  /// Container com sombra sutil
  const ShadowContainer.subtle({
    super.key,
    required this.child,
    this.color,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
  }) : boxShadow = AppShadows.subtle;
  
  /// Container com sombra suave (padrão para cards)
  const ShadowContainer.soft({
    super.key,
    required this.child,
    this.color,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
  }) : boxShadow = AppShadows.soft;
  
  /// Container com sombra média
  const ShadowContainer.medium({
    super.key,
    required this.child,
    this.color,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
  }) : boxShadow = AppShadows.medium;
  
  /// Container com sombra forte
  const ShadowContainer.strong({
    super.key,
    required this.child,
    this.color,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
  }) : boxShadow = AppShadows.strong;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: alignment,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: boxShadow ?? AppShadows.soft,
      ),
      child: child,
    );
  }
}

/// Widget para cards com elevação animada
class ElevatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final int normalElevation;
  final int hoverElevation;
  final Duration animationDuration;
  
  const ElevatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.normalElevation = 2,
    this.hoverElevation = 4,
    this.animationDuration = const Duration(milliseconds: 200),
  });
  
  @override
  State<ElevatedCard> createState() => _ElevatedCardState();
}

class _ElevatedCardState extends State<ElevatedCard> {
  bool _isHovered = false;
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (mounted) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() => _isHovered = false);
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: widget.animationDuration,
          curve: Curves.easeInOut,
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.color ?? Colors.white,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            boxShadow: AppShadows.getElevationShadow(
              _isHovered ? widget.hoverElevation : widget.normalElevation,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}