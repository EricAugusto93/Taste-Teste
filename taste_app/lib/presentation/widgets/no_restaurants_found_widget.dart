import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';

/// Widget para exibir estado vazio quando nenhum restaurante é encontrado
class NoRestaurantsFoundWidget extends StatelessWidget {
  final VoidCallback? onChangeFilters;
  final String? customTitle;
  final String? customSubtitle;
  final String? customButtonText;
  final bool showAnimation;

  const NoRestaurantsFoundWidget({
    super.key,
    this.onChangeFilters,
    this.customTitle,
    this.customSubtitle,
    this.customButtonText,
    this.showAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone animado
            if (showAnimation) _buildAnimatedIcon(),
            
            SizedBox(height: AppDimensions.paddingLarge),
            
            // Card principal
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Emoji e título
                  Text(
                    customTitle ?? 'Nenhum restaurante encontrado 😕',
                    style: AppTextStyles.emptyStateTitle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: AppDimensions.paddingMedium),
                  
                  // Subtexto
                  Text(
                    customSubtitle ?? 'Tente alterar os filtros ou buscar por outra categoria.',
                    style: AppTextStyles.emptyStateSubtitle,
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: AppDimensions.paddingLarge),
                  
                  // Botão CTA
                  if (onChangeFilters != null)
                    _buildActionButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.emptyStateBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.search_off,
                size: 40,
                color: AppColors.emptyStateBlue,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onChangeFilters,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
          elevation: AppDimensions.elevationMedium,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              size: AppDimensions.iconMedium,
            ),
            SizedBox(width: AppDimensions.paddingSmall),
            Text(
              customButtonText ?? 'Alterar Filtros',
              style: AppTextStyles.buttonText,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget compacto para estado vazio em listas
class CompactNoRestaurantsWidget extends StatelessWidget {
  final VoidCallback? onChangeFilters;
  final String? message;

  const CompactNoRestaurantsWidget({
    super.key,
    this.onChangeFilters,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.restaurant_menu_outlined,
            size: 48,
            color: AppColors.textLight,
          ),
          SizedBox(height: AppDimensions.paddingMedium),
          Text(
            message ?? 'Nenhum restaurante encontrado',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          if (onChangeFilters != null) ..[
            SizedBox(height: AppDimensions.paddingMedium),
            TextButton(
              onPressed: onChangeFilters,
              child: Text(
                'Alterar filtros',
                style: AppTextStyles.buttonTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget para estado vazio com sugestões
class NoRestaurantsWithSuggestionsWidget extends StatelessWidget {
  final VoidCallback? onChangeFilters;
  final VoidCallback? onClearFilters;
  final List<String>? suggestions;

  const NoRestaurantsWithSuggestionsWidget({
    super.key,
    this.onChangeFilters,
    this.onClearFilters,
    this.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NoRestaurantsFoundWidget(
            onChangeFilters: onChangeFilters,
            showAnimation: true,
          ),
          
          if (suggestions != null && suggestions!.isNotEmpty) ..[
            SizedBox(height: AppDimensions.paddingLarge),
            
            // Sugestões
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppDimensions.mediumRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Que tal tentar:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppDimensions.paddingSmall),
                  ...suggestions!.map(
                    (suggestion) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingXSmall,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: AppDimensions.iconSmall,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: AppDimensions.paddingSmall),
                          Expanded(
                            child: Text(
                              suggestion,
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Botão para limpar filtros
          if (onClearFilters != null) ..[
            SizedBox(height: AppDimensions.paddingMedium),
            TextButton.icon(
              onPressed: onClearFilters,
              icon: Icon(Icons.clear_all),
              label: Text('Limpar todos os filtros'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}