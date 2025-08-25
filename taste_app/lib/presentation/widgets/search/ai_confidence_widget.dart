import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../data/services/search/ai_search_service.dart';
import '../../../services/analytics_service.dart';
import '../../../core/animations/animation_service.dart';
import '../../extensions/widget_extensions.dart';

/// Widget para exibir a confiança da IA e coletar feedback do usuário
class AIConfidenceWidget extends StatefulWidget {
  final SearchInterpretation interpretation;
  final int resultsCount;
  final VoidCallback? onFeedbackSubmitted;

  const AIConfidenceWidget({
    super.key,
    required this.interpretation,
    required this.resultsCount,
    this.onFeedbackSubmitted,
  });

  @override
  State<AIConfidenceWidget> createState() => _AIConfidenceWidgetState();
}

class _AIConfidenceWidgetState extends State<AIConfidenceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _showFeedback = false;
  bool _feedbackSubmitted = false;
  String? _selectedFeedback;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Só exibir se a confiança for significativa ou houver interpretação especial
    if (widget.interpretation.confidence < 0.3 && 
        widget.interpretation.intention == SearchIntention.general &&
        widget.interpretation.entities.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingSmall,
              ),
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getConfidenceColor().withOpacity(0.1),
                    _getConfidenceColor().withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(
                  color: _getConfidenceColor().withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  if (widget.interpretation.entities.isNotEmpty) ...
                    _buildEntitiesInfo(),
                  if (_showFeedback && !_feedbackSubmitted) ...
                    _buildFeedbackSection(),
                  if (_feedbackSubmitted) ...
                    _buildThankYouMessage(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          _getConfidenceIcon(),
          color: _getConfidenceColor(),
          size: AppDimensions.iconSmall,
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getConfidenceText(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _getConfidenceColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _getIntentionText(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
        _buildConfidenceIndicator(),
        const SizedBox(width: AppDimensions.paddingSmall),
        if (!_feedbackSubmitted)
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _showFeedback = !_showFeedback;
              });
            },
            child: Icon(
              _showFeedback ? AppIcons.close : AppIcons.help,
              color: AppColors.textLight,
              size: AppDimensions.iconSmall,
            ),
          ),
      ],
    );
  }

  Widget _buildConfidenceIndicator() {
    return Container(
      width: 40,
      height: 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: AppColors.divider,
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: widget.interpretation.confidence,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: _getConfidenceColor(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEntitiesInfo() {
    return [
      const SizedBox(height: AppDimensions.paddingSmall),
      Wrap(
        spacing: AppDimensions.paddingSmall,
        runSpacing: AppDimensions.paddingXSmall,
        children: widget.interpretation.entities.entries.map((entry) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingSmall,
              vertical: AppDimensions.paddingXSmall,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Text(
              '${entry.key}: ${entry.value.join(", ")}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    ];
  }

  List<Widget> _buildFeedbackSection() {
    return [
      const SizedBox(height: AppDimensions.paddingMedium),
      const Divider(color: AppColors.divider),
      const SizedBox(height: AppDimensions.paddingSmall),
      Text(
        'Os resultados foram úteis?',
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: AppDimensions.paddingSmall),
      Row(
        children: [
          _buildFeedbackButton(
            'Sim, perfeito!',
            'positive',
            AppColors.success,
            AppIcons.thumbsUp,
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          _buildFeedbackButton(
            'Não muito',
            'negative',
            AppColors.error,
            AppIcons.thumbsDown,
          ),
        ],
      ),
    ];
  }

  Widget _buildFeedbackButton(
    String text,
    String value,
    Color color,
    IconData icon,
  ) {
    final isSelected = _selectedFeedback == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          _submitFeedback(value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingSmall,
          ),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            border: Border.all(
              color: isSelected ? color : AppColors.divider,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? color : AppColors.textLight,
                size: AppDimensions.iconSmall,
              ),
              const SizedBox(width: AppDimensions.paddingXSmall),
              Text(
                text,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? color : AppColors.textLight,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildThankYouMessage() {
    return [
      const SizedBox(height: AppDimensions.paddingMedium),
      const Divider(color: AppColors.divider),
      const SizedBox(height: AppDimensions.paddingSmall),
      Row(
        children: [
          Icon(
            Icons.check,
            color: AppColors.success,
            size: AppDimensions.iconSmall,
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          Text(
            'Obrigado pelo feedback!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ];
  }

  Color _getConfidenceColor() {
    final confidence = widget.interpretation.confidence;
    if (confidence >= 0.8) return AppColors.success;
    if (confidence >= 0.6) return AppColors.warning;
    return AppColors.error;
  }

  IconData _getConfidenceIcon() {
    final confidence = widget.interpretation.confidence;
    if (confidence >= 0.8) return Icons.check;
    if (confidence >= 0.6) return AppIcons.info;
    return AppIcons.warning;
  }

  String _getConfidenceText() {
    final confidence = widget.interpretation.confidence;
    if (confidence >= 0.8) return 'Busca interpretada com alta confiança';
    if (confidence >= 0.6) return 'Busca interpretada com confiança média';
    return 'Busca interpretada com baixa confiança';
  }

  String _getIntentionText() {
    switch (widget.interpretation.intention) {
      case SearchIntention.cuisine:
        return 'Detectamos que você está buscando por tipo de culinária';
      case SearchIntention.dish:
        return 'Detectamos que você está buscando por um prato específico';
      case SearchIntention.location:
        return 'Detectamos que você está buscando por localização';
      case SearchIntention.dietary:
        return 'Detectamos que você está buscando por opções dietéticas';
      case SearchIntention.price:
        return 'Detectamos que você está buscando por faixa de preço';
      case SearchIntention.rating:
        return 'Detectamos que você está buscando por avaliação';
      default:
        return 'Busca geral realizada';
    }
  }

  void _submitFeedback(String feedback) {
    setState(() {
      _selectedFeedback = feedback;
      _feedbackSubmitted = true;
      _showFeedback = false;
    });

    // Enviar analytics
    AnalyticsService.instance.trackEvent(
      'ai_search_feedback',
      parameters: {
        'query': widget.interpretation.originalQuery,
        'confidence': widget.interpretation.confidence,
        'intention': widget.interpretation.intention.toString(),
        'feedback': feedback,
        'results_count': widget.resultsCount,
        'entities_count': widget.interpretation.entities.length,
      },
    );

    widget.onFeedbackSubmitted?.call();
  }
}
