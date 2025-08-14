import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_icons.dart';

/// Widget de campo de busca com debounce otimizado
class DebouncedSearchField extends StatefulWidget {
  final String? initialValue;
  final String? hintText;
  final Duration debounceDuration;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final bool autofocus;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final Color? fillColor;
  final bool filled;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool showClearButton;
  final bool showSearchIcon;
  final double? borderRadius;
  final FocusNode? focusNode;

  const DebouncedSearchField({
    super.key,
    this.initialValue,
    this.hintText = 'Buscar...',
    this.debounceDuration = const Duration(milliseconds: 500),
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.controller,
    this.autofocus = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.border,
    this.fillColor,
    this.filled = true,
    this.textStyle,
    this.hintStyle,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.search,
    this.showClearButton = true,
    this.showSearchIcon = true,
    this.borderRadius,
    this.focusNode,
  });

  @override
  State<DebouncedSearchField> createState() => _DebouncedSearchFieldState();
}

class _DebouncedSearchFieldState extends State<DebouncedSearchField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  Timer? _debounceTimer;
  String _lastSearchTerm = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
      _lastSearchTerm = widget.initialValue!;
    }
    
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final currentText = _controller.text;
    
    // Cancelar timer anterior
    _debounceTimer?.cancel();
    
    // Se o texto não mudou, não fazer nada
    if (currentText == _lastSearchTerm) return;
    
    setState(() {
      _isSearching = currentText.isNotEmpty;
    });
    
    // Configurar novo timer
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (mounted && currentText != _lastSearchTerm) {
        _lastSearchTerm = currentText;
        widget.onChanged?.call(currentText);
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _onSubmitted(String value) {
    _debounceTimer?.cancel();
    _lastSearchTerm = value;
    widget.onSubmitted?.call(value);
    setState(() {
      _isSearching = false;
    });
  }

  void _onClear() {
    _debounceTimer?.cancel();
    _controller.clear();
    _lastSearchTerm = '';
    widget.onClear?.call();
    widget.onChanged?.call('');
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onSubmitted: _onSubmitted,
      style: widget.textStyle ?? AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: widget.hintStyle ?? AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textLight,
        ),
        prefixIcon: widget.prefixIcon ?? (widget.showSearchIcon
            ? Icon(
                AppIcons.search,
                color: _focusNode.hasFocus ? AppColors.primary : AppColors.textLight,
                size: 20,
              )
            : null),
        suffixIcon: _buildSuffixIcon(),
        contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        border: widget.border ?? OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            widget.borderRadius ?? AppDimensions.radiusMedium,
          ),
          borderSide: BorderSide.none,
        ),
        enabledBorder: widget.border ?? OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            widget.borderRadius ?? AppDimensions.radiusMedium,
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: widget.border ?? OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            widget.borderRadius ?? AppDimensions.radiusMedium,
          ),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        filled: widget.filled,
        fillColor: widget.fillColor ?? AppColors.surface,
        counterText: '', // Remove contador de caracteres
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }

    if (!widget.showClearButton) {
      return null;
    }

    // Mostrar indicador de loading durante debounce
    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    // Mostrar botão de limpar se há texto
    if (_controller.text.isNotEmpty) {
      return IconButton(
        icon: const Icon(
          Icons.clear,
          size: 20,
        ),
        color: AppColors.textLight,
        onPressed: _onClear,
        tooltip: 'Limpar busca',
      );
    }

    return null;
  }
}

/// Widget de busca avançada com filtros e sugestões
class AdvancedSearchField extends StatefulWidget {
  final String? initialValue;
  final String? hintText;
  final Duration debounceDuration;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final List<String>? suggestions;
  final Function(String)? onSuggestionTap;
  final Widget? filtersWidget;
  final bool showFilters;
  final VoidCallback? onFiltersToggle;
  final TextEditingController? controller;
  final bool autofocus;
  final FocusNode? focusNode;

  const AdvancedSearchField({
    super.key,
    this.initialValue,
    this.hintText = 'Buscar restaurantes, pratos...',
    this.debounceDuration = const Duration(milliseconds: 500),
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.suggestions,
    this.onSuggestionTap,
    this.filtersWidget,
    this.showFilters = false,
    this.onFiltersToggle,
    this.controller,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  State<AdvancedSearchField> createState() => _AdvancedSearchFieldState();
}

class _AdvancedSearchFieldState extends State<AdvancedSearchField> {
  late FocusNode _focusNode;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus && 
                        widget.suggestions != null && 
                        widget.suggestions!.isNotEmpty;
    });
  }

  void _onSuggestionTap(String suggestion) {
    widget.onSuggestionTap?.call(suggestion);
    _focusNode.unfocus();
    setState(() {
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DebouncedSearchField(
                initialValue: widget.initialValue,
                hintText: widget.hintText,
                debounceDuration: widget.debounceDuration,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                onClear: widget.onClear,
                controller: widget.controller,
                autofocus: widget.autofocus,
                focusNode: _focusNode,
              ),
            ),
            if (widget.onFiltersToggle != null) ...[
              const SizedBox(width: AppDimensions.paddingSmall),
              IconButton(
                icon: Icon(
                  AppIcons.filter,
                  color: widget.showFilters ? AppColors.primary : AppColors.textLight,
                ),
                onPressed: widget.onFiltersToggle,
                tooltip: 'Filtros',
              ),
            ]
          ],
        ),
        
        // Sugestões
        if (_showSuggestions && widget.suggestions != null)
          Container(
            margin: const EdgeInsets.only(top: AppDimensions.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.suggestions!.length,
              itemBuilder: (context, index) {
                final suggestion = widget.suggestions![index];
                return ListTile(
                  dense: true,
                  leading: const Icon(
                    AppIcons.search,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                  title: Text(
                    suggestion,
                    style: AppTextStyles.bodyMedium,
                  ),
                  onTap: () => _onSuggestionTap(suggestion),
                );
              },
            ),
          ),
        
        // Filtros
        if (widget.showFilters && widget.filtersWidget != null)
          Container(
            margin: const EdgeInsets.only(top: AppDimensions.paddingMedium),
            child: widget.filtersWidget,
          ),
      ],
    );
  }
}