import 'package:flutter/material.dart';

/// A Flutter widget that displays a balloon-style marker similar to Pinterest/Airbnb
class BalloonMarkerWidget extends StatefulWidget {
  final String emoji;
  final double size;
  final bool isSelected;
  final bool isCluster;
  final String? clusterCount;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final Color selectedBorderColor;
  final double borderWidth;
  final double shadowBlurRadius;
  final Color shadowColor;
  final bool enableHoverEffect;
  final Duration animationDuration;

  const BalloonMarkerWidget({
    super.key,
    required this.emoji,
    this.size = 40.0,
    this.isSelected = false,
    this.isCluster = false,
    this.clusterCount,
    this.onTap,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE5E7EB),
    this.selectedBorderColor = const Color(0xFF6B73D9),
    this.borderWidth = 2.0,
    this.shadowBlurRadius = 4.0,
    this.shadowColor = Colors.black26,
    this.enableHoverEffect = true,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<BalloonMarkerWidget> createState() => _BalloonMarkerWidgetState();
}

class _BalloonMarkerWidgetState extends State<BalloonMarkerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _shadowAnimation = Tween<double>(
      begin: widget.shadowBlurRadius,
      end: widget.shadowBlurRadius * 1.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isSelected) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(BalloonMarkerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovering) {
    if (!widget.enableHoverEffect) return;
    
    setState(() {
      _isHovering = isHovering;
    });

    if (isHovering && !widget.isSelected) {
      _animationController.forward();
    } else if (!isHovering && !widget.isSelected) {
      _animationController.reverse();
    }
  }

  void _handleTap() {
    if (widget.onTap != null) {
      // Feedback animation
      _animationController.forward().then((_) {
        if (!widget.isSelected && !_isHovering) {
          _animationController.reverse();
        }
      });
      
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _handleHover(true),
            onExit: (_) => _handleHover(false),
            child: GestureDetector(
              onTap: _handleTap,
              child: CustomPaint(
                size: Size(
                  widget.size + 4, // Account for shadow
                  widget.size + 12, // Account for tail and shadow
                ),
                painter: _BalloonMarkerPainter(
                  emoji: widget.emoji,
                  size: widget.size,
                  isSelected: widget.isSelected,
                  isCluster: widget.isCluster,
                  clusterCount: widget.clusterCount,
                  backgroundColor: widget.backgroundColor,
                  borderColor: widget.isSelected 
                      ? widget.selectedBorderColor 
                      : widget.borderColor,
                  borderWidth: widget.borderWidth,
                  shadowBlurRadius: _shadowAnimation.value,
                  shadowColor: widget.shadowColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BalloonMarkerPainter extends CustomPainter {
  final String emoji;
  final double size;
  final bool isSelected;
  final bool isCluster;
  final String? clusterCount;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double shadowBlurRadius;
  final Color shadowColor;

  static const double _tailHeight = 8.0;
  static const double _tailWidth = 12.0;

  _BalloonMarkerPainter({
    required this.emoji,
    required this.size,
    required this.isSelected,
    required this.isCluster,
    this.clusterCount,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.shadowBlurRadius,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, size / 2);
    final radius = size / 2;

    // Draw shadow
    _drawShadow(canvas, center, radius);
    
    // Draw balloon circle
    _drawBalloon(canvas, center, radius);
    
    // Draw tail
    _drawTail(canvas, center, radius);
    
    // Draw content (emoji or cluster count)
    if (isCluster && clusterCount != null) {
      _drawClusterText(canvas, center, radius);
    } else {
      _drawEmoji(canvas, center, radius);
    }
  }

  void _drawShadow(Canvas canvas, Offset center, double radius) {
    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlurRadius);

    // Shadow for circle
    canvas.drawCircle(
      center.translate(2, 2),
      radius,
      shadowPaint,
    );

    // Shadow for tail
    final tailCenterX = center.dx;
    final tailStartY = center.dy + radius;
    
    final shadowTailPath = Path();
    shadowTailPath.moveTo(tailCenterX - _tailWidth / 2 + 2, tailStartY + 2);
    shadowTailPath.lineTo(tailCenterX + 2, tailStartY + _tailHeight + 2);
    shadowTailPath.lineTo(tailCenterX + _tailWidth / 2 + 2, tailStartY + 2);
    shadowTailPath.close();
    
    canvas.drawPath(shadowTailPath, shadowPaint);
  }

  void _drawBalloon(Canvas canvas, Offset center, double radius) {
    // Background circle
    final backgroundPaint = Paint()
      ..color = isCluster ? const Color(0xFF6B73D9) : backgroundColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, backgroundPaint);

    // Border circle
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    
    canvas.drawCircle(center, radius - borderWidth / 2, borderPaint);
  }

  void _drawTail(Canvas canvas, Offset center, double radius) {
    final tailPaint = Paint()
      ..color = isCluster ? const Color(0xFF6B73D9) : backgroundColor
      ..style = PaintingStyle.fill;

    final tailBorderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final tailCenterX = center.dx;
    final tailStartY = center.dy + radius;
    
    // Tail fill
    final tailPath = Path();
    tailPath.moveTo(tailCenterX - _tailWidth / 2, tailStartY);
    tailPath.lineTo(tailCenterX, tailStartY + _tailHeight);
    tailPath.lineTo(tailCenterX + _tailWidth / 2, tailStartY);
    tailPath.close();
    
    canvas.drawPath(tailPath, tailPaint);
    canvas.drawPath(tailPath, tailBorderPaint);
  }

  void _drawEmoji(Canvas canvas, Offset center, double radius) {
    final textStyle = TextStyle(
      fontSize: radius * 1.0, // Emoji should fill most of the circle
      fontFamily: 'NotoColorEmoji',
    );
    
    final textSpan = TextSpan(
      text: emoji,
      style: textStyle,
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout();
    
    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    
    textPainter.paint(canvas, textOffset);
  }

  void _drawClusterText(Canvas canvas, Offset center, double radius) {
    final textStyle = TextStyle(
      fontSize: radius * 0.7,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    
    final textSpan = TextSpan(
      text: clusterCount!,
      style: textStyle,
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout();
    
    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant _BalloonMarkerPainter oldDelegate) {
    return emoji != oldDelegate.emoji ||
           size != oldDelegate.size ||
           isSelected != oldDelegate.isSelected ||
           isCluster != oldDelegate.isCluster ||
           clusterCount != oldDelegate.clusterCount ||
           backgroundColor != oldDelegate.backgroundColor ||
           borderColor != oldDelegate.borderColor ||
           borderWidth != oldDelegate.borderWidth ||
           shadowBlurRadius != oldDelegate.shadowBlurRadius ||
           shadowColor != oldDelegate.shadowColor;
  }
}