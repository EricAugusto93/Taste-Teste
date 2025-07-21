import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class FiltroSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final String label;
  final String unit;
  final Function(double) onChanged;
  final int divisions;
  final bool showValue;
  final IconData? icon;

  const FiltroSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 10,
    this.label = 'Distância',
    this.unit = 'km',
    this.divisions = 20,
    this.showValue = true,
    this.icon,
  });

  @override
  State<FiltroSlider> createState() => _FiltroSliderState();
}

class _FiltroSliderState extends State<FiltroSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatValue(double value) {
    if (value < 1) {
      return '${(value * 1000).round()}m';
    } else {
      return '${value.toStringAsFixed(1)}${widget.unit}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(AppTheme.espacoGrande),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusGrande),
              boxShadow: AppTheme.sombraCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header do filtro
                Row(
                  children: [
                    if (widget.icon != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.mostardaClara.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.icon,
                          color: AppTheme.mostarda,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppTheme.espacoMedio),
                    ],
                    
                    Expanded(
                      child: Text(
                        widget.label,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cinzaEscuro,
                        ),
                      ),
                    ),
                    
                    if (widget.showValue)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppTheme.gradientPrimario,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _formatValue(widget.value),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: AppTheme.espacoMedio),
                
                // Slider customizado
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.mostarda,
                    inactiveTrackColor: AppTheme.mostardaClara.withOpacity(0.3),
                    thumbColor: AppTheme.mostarda,
                    overlayColor: AppTheme.mostarda.withOpacity(0.2),
                    thumbShape: CustomSliderThumb(),
                    trackHeight: 6,
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                  ),
                  child: Slider(
                    value: widget.value,
                    min: widget.min,
                    max: widget.max,
                    divisions: widget.divisions,
                    onChanged: (value) {
                      widget.onChanged(value);
                      
                      // Animação de feedback
                      _animationController.forward().then((_) {
                        _animationController.reverse();
                      });
                    },
                  ),
                ),
                
                // Labels de min e max
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatValue(widget.min),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.cinzaMedio,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatValue(widget.max),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.cinzaMedio,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CustomSliderThumb extends SliderComponentShape {
  final double thumbRadius;

  const CustomSliderThumb({this.thumbRadius = 12});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(thumbRadius * 2, thumbRadius * 2);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Sombra do thumb
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    canvas.drawCircle(
      center + const Offset(0, 2),
      thumbRadius,
      shadowPaint,
    );

    // Círculo externo (branco)
    final outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, thumbRadius, outerPaint);

    // Círculo interno (gradient)
    final gradient = LinearGradient(
      colors: [AppTheme.mostarda, AppTheme.mostardaEscura],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    
    final gradientPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: thumbRadius - 3),
      );
    
    canvas.drawCircle(center, thumbRadius - 3, gradientPaint);

    // Ponto central
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 2, centerPaint);
  }
}

// Slider especializado para diferentes tipos de filtros
class DistanceSlider extends StatelessWidget {
  final double distance;
  final Function(double) onChanged;

  const DistanceSlider({
    super.key,
    required this.distance,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FiltroSlider(
      value: distance,
      onChanged: onChanged,
      min: 0.5,
      max: 20,
      label: 'Distância máxima',
      unit: 'km',
      icon: Icons.location_on,
      divisions: 39,
    );
  }
}

class PriceRangeSlider extends StatelessWidget {
  final double minPrice;
  final double maxPrice;
  final Function(double, double) onChanged;

  const PriceRangeSlider({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.espacoGrande),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusGrande),
        boxShadow: AppTheme.sombraCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.mostardaClara.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: AppTheme.mostarda,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.espacoMedio),
              Expanded(
                child: Text(
                  'Faixa de preço',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cinzaEscuro,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientPrimario,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'R\$ ${minPrice.round()} - R\$ ${maxPrice.round()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.espacoMedio),
          
          RangeSlider(
            values: RangeValues(minPrice, maxPrice),
            min: 10,
            max: 200,
            divisions: 19,
            onChanged: (values) {
              onChanged(values.start, values.end);
            },
            activeColor: AppTheme.mostarda,
            inactiveColor: AppTheme.mostardaClara.withOpacity(0.3),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'R\$ 10',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.cinzaMedio,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'R\$ 200+',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.cinzaMedio,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 