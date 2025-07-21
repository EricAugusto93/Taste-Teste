import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class TagChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? selectedColor;
  final Color? unselectedColor;
  final IconData? icon;
  final String? emoji;
  final bool isFilter;

  const TagChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.selectedColor,
    this.unselectedColor,
    this.icon,
    this.emoji,
    this.isFilter = false,
  });

  @override
  State<TagChip> createState() => _TagChipState();
}

class _TagChipState extends State<TagChip> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: _getUnselectedColor(),
      end: _getSelectedColor(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isSelected) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TagChip oldWidget) {
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

  Color _getSelectedColor() {
    if (widget.selectedColor != null) return widget.selectedColor!;
    return widget.isFilter ? AppTheme.mostarda : AppTheme.mostardaClara;
  }

  Color _getUnselectedColor() {
    if (widget.unselectedColor != null) return widget.unselectedColor!;
    return AppTheme.mostardaClara.withOpacity(0.2);
  }

  Color _getTextColor() {
    return widget.isSelected 
        ? Colors.white 
        : AppTheme.mostardaEscura;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: () {
              if (widget.onTap != null) {
                // Animação rápida de tap
                _animationController.forward().then((_) {
                  _animationController.reverse();
                });
                widget.onTap!();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: widget.isFilter ? 16 : 12,
                vertical: widget.isFilter ? 10 : 6,
              ),
              decoration: BoxDecoration(
                color: _colorAnimation.value ?? _getUnselectedColor(),
                borderRadius: BorderRadius.circular(
                  widget.isFilter ? AppTheme.radiusMedio : 20,
                ),
                border: widget.isSelected && widget.isFilter
                    ? Border.all(color: AppTheme.mostardaEscura, width: 2)
                    : null,
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: _getSelectedColor().withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Emoji ou ícone
                  if (widget.emoji != null) ...[
                    Text(
                      widget.emoji!,
                      style: TextStyle(
                        fontSize: widget.isFilter ? 16 : 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ] else if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: widget.isFilter ? 18 : 16,
                      color: _getTextColor(),
                    ),
                    const SizedBox(width: 4),
                  ],
                  
                  // Texto
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: widget.isFilter ? 14 : 12,
                      fontWeight: widget.isSelected 
                          ? FontWeight.w600 
                          : FontWeight.w500,
                      color: _getTextColor(),
                    ),
                  ),
                  
                  // Ícone de close para filtros selecionados
                  if (widget.isSelected && widget.isFilter && widget.onTap != null) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.close,
                      size: 16,
                      color: _getTextColor(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Chips especializados para diferentes usos
class CuisineTypeChip extends StatelessWidget {
  final String type;
  final bool isSelected;
  final VoidCallback? onTap;

  const CuisineTypeChip({
    super.key,
    required this.type,
    this.isSelected = false,
    this.onTap,
  });

  String _getEmoji(String type) {
    final emojiMap = {
      'Italiana': '🍝',
      'Japonesa': '🍱',
      'Chinesa': '🥢',
      'Brasileira': '🇧🇷',
      'Mexicana': '🌮',
      'Indiana': '🍛',
      'Fast Food': '🍔',
      'Pizzaria': '🍕',
      'Churrascaria': '🥩',
      'Vegetariana': '🥗',
      'Vegana': '🌱',
      'Frutos do Mar': '🦐',
      'Café': '☕',
      'Sorveteria': '🍦',
      'Padaria': '🥖',
    };
    return emojiMap[type] ?? '🍽️';
  }

  @override
  Widget build(BuildContext context) {
    return TagChip(
      label: type,
      emoji: _getEmoji(type),
      isSelected: isSelected,
      onTap: onTap,
    );
  }
}

class FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;

  const FilterChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TagChip(
      label: label,
      icon: icon,
      isSelected: isSelected,
      onTap: onTap,
      isFilter: true,
      selectedColor: AppTheme.mostarda,
      unselectedColor: Colors.white,
    );
  }
}

class RatingChip extends StatelessWidget {
  final String emoji;
  final int count;
  final bool isSelected;
  final VoidCallback? onTap;

  const RatingChip({
    super.key,
    required this.emoji,
    required this.count,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TagChip(
      label: count.toString(),
      emoji: emoji,
      isSelected: isSelected,
      onTap: onTap,
      selectedColor: AppTheme.terracota,
    );
  }
} 