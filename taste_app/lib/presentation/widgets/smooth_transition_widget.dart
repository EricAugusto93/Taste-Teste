import 'package:flutter/material.dart';
import '../../core/services/ui/interaction_service.dart';

/// Widget para transições suaves entre diferentes estados
class SmoothTransitionWidget extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Widget Function(Widget child, Animation<double> animation)? transitionBuilder;

  const SmoothTransitionWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.transitionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      transitionBuilder: transitionBuilder ?? _defaultTransitionBuilder,
      child: child,
    );
  }

  Widget _defaultTransitionBuilder(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        )),
        child: child,
      ),
    );
  }
}

/// Widget para transições de loading com shimmer
class LoadingTransitionWidget extends StatelessWidget {
  final bool isLoading;
  final Widget loadingWidget;
  final Widget contentWidget;
  final Duration duration;

  const LoadingTransitionWidget({
    super.key,
    required this.isLoading,
    required this.loadingWidget,
    required this.contentWidget,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  Widget build(BuildContext context) {
    return SmoothTransitionWidget(
      duration: duration,
      child: isLoading 
          ? KeyedSubtree(
              key: const ValueKey('loading'),
              child: loadingWidget,
            )
          : KeyedSubtree(
              key: const ValueKey('content'),
              child: contentWidget,
            ),
    );
  }
}

/// Widget para transições de estado com animação personalizada
class StateTransitionWidget extends StatelessWidget {
  final String currentState;
  final Map<String, Widget> stateWidgets;
  final Duration duration;
  final Curve curve;

  const StateTransitionWidget({
    super.key,
    required this.currentState,
    required this.stateWidgets,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    final currentWidget = stateWidgets[currentState];
    
    if (currentWidget == null) {
      return const SizedBox.shrink();
    }

    return SmoothTransitionWidget(
      duration: duration,
      curve: curve,
      child: KeyedSubtree(
        key: ValueKey(currentState),
        child: currentWidget,
      ),
    );
  }
}

/// Widget para animação de entrada escalonada em listas
class StaggeredListTransition extends StatelessWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration animationDuration;
  final Curve curve;
  final Axis scrollDirection;

  const StaggeredListTransition({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.animationDuration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return TweenAnimationBuilder<double>(
          duration: animationDuration + (staggerDelay * index),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: curve,
          builder: (context, value, child) {
            return Transform.translate(
              offset: scrollDirection == Axis.vertical
                  ? Offset(0, 20 * (1 - value))
                  : Offset(20 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: child,
        );
      }).toList(),
    );
  }
}

/// Widget para animação de bounce em botões
class BounceAnimationWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final Duration duration;
  final bool enableHaptic;

  const BounceAnimationWidget({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.95,
    this.duration = const Duration(milliseconds: 150),
    this.enableHaptic = false,
  });

  @override
  State<BounceAnimationWidget> createState() => _BounceAnimationWidgetState();
}

class _BounceAnimationWidgetState extends State<BounceAnimationWidget>
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

  void _handleTap() {
    if (widget.enableHaptic) {
      InteractionService.lightHaptic();
    }
    
    _controller.forward().then((_) {
      _controller.reverse();
    });
    
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap != null ? _handleTap : null,
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

/// Widget para animação de slide entre páginas
class SlidePageTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final SlideDirection direction;

  const SlidePageTransition({
    super.key,
    required this.child,
    required this.animation,
    this.direction = SlideDirection.rightToLeft,
  });

  @override
  Widget build(BuildContext context) {
    Offset begin;
    
    switch (direction) {
      case SlideDirection.rightToLeft:
        begin = const Offset(1.0, 0.0);
        break;
      case SlideDirection.leftToRight:
        begin = const Offset(-1.0, 0.0);
        break;
      case SlideDirection.topToBottom:
        begin = const Offset(0.0, -1.0);
        break;
      case SlideDirection.bottomToTop:
        begin = const Offset(0.0, 1.0);
        break;
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    );
  }
}

enum SlideDirection {
  rightToLeft,
  leftToRight,
  topToBottom,
  bottomToTop,
}

/// Route personalizada com animação de slide
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SlideDirection direction;
  final Duration duration;

  SlidePageRoute({
    required this.page,
    this.direction = SlideDirection.rightToLeft,
    this.duration = const Duration(milliseconds: 300),
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          settings: settings,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlidePageTransition(
              animation: animation,
              direction: direction,
              child: child,
            );
          },
        );
}