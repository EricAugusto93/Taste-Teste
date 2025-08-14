import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_icons.dart';
import '../../core/animations/animation_service.dart';

/// Widget para exibir sugestões de busca em tempo real
class SearchSuggestionsWidget extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionTap;
  final VoidCallback? onClearSuggestions;
  final bool isLoading;
  final String currentQuery;

  const SearchSuggestionsWidget({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
    this.onClearSuggestions,
    this.isLoading = false,
    this.currentQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (suggestions.isEmpty) {
      return _buildEmptyState();
    }

    return _buildSuggestionsList();
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Text(
            'Buscando sugestões...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    ).fadeIn();
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        children: [
          Icon(
            AppIcons.search,
            size: AppDimensions.iconSmall,
            color: AppColors.textLight,
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Text(
            'Digite para buscar restaurantes...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    ).fadeIn();
  }

  Widget _buildSuggestionsList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header com contador e botão limpar
          if (suggestions.isNotEmpty) _buildSuggestionsHeader(),
          
          // Lista de sugestões
          ...suggestions.asMap().entries.map((entry) {
            final index = entry.key;
            final suggestion = entry.value;
            return _buildSuggestionItem(suggestion, index);
          }).toList(),
        ],
      ),
    ).slideIn(
      begin: const Offset(0, -0.5),
      duration: AnimationService.fast,
    );
  }

  Widget _buildSuggestionsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.search,
            size: AppDimensions.iconSmall,
            color: AppColors.textLight,
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          Text(
            '${suggestions.length} sugestão${suggestions.length != 1 ? 'ões' : ''}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textLight,
            ),
          ),
          const Spacer(),
          if (onClearSuggestions != null)
            GestureDetector(
              onTap: () {
                AnimationService.lightHaptic();
                onClearSuggestions!();
              },
              child: Icon(
                AppIcons.close,
                size: AppDimensions.iconSmall,
                color: AppColors.textLight,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String suggestion, int index) {
    // Destacar a parte que corresponde à query atual
    final highlightedText = _buildHighlightedText(suggestion, currentQuery);
    
    return AnimationService.staggeredListItem(
      index: index,
      duration: AnimationService.fast,
      staggerDelay: const Duration(milliseconds: 50),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AnimationService.selectionHaptic();
            onSuggestionTap(suggestion);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingSmall,
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.search,
                  size: AppDimensions.iconSmall,
                  color: AppColors.textLight,
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: highlightedText,
                ),
                Icon(
                  AppIcons.chevronRight,
                  size: AppDimensions.iconSmall,
                  color: AppColors.textLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textDark,
        ),
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) {
      return Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textDark,
        ),
      );
    }

    final before = text.substring(0, index);
    final match = text.substring(index, index + query.length);
    final after = text.substring(index + query.length);

    return RichText(
      text: TextSpan(
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textDark,
        ),
        children: [
          if (before.isNotEmpty)
            TextSpan(text: before),
          TextSpan(
            text: match,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (after.isNotEmpty)
            TextSpan(text: after),
        ],
      ),
    );
  }
}

/// Widget para sugestões de categoria
class CategorySuggestionsWidget extends StatelessWidget {
  final List<String> categories;
  final Function(String) onCategoryTap;
  final String? selectedCategory;

  const CategorySuggestionsWidget({
    super.key,
    required this.categories,
    required this.onCategoryTap,
    this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(
        vertical: AppDimensions.paddingSmall,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          
          return AnimationService.staggeredListItem(
            index: index,
            duration: AnimationService.fast,
            staggerDelay: const Duration(milliseconds: 30),
            child: Container(
              margin: const EdgeInsets.only(
                right: AppDimensions.paddingSmall,
              ),
              child: FilterChip(
                label: Text(
                  category,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? AppColors.surface : AppColors.textDark,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  AnimationService.lightHaptic();
                  onCategoryTap(category);
                },
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.primary,
                checkmarkColor: AppColors.surface,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                ),
              ),
            ),
          );
        },
      ),
    ).slideIn(
      begin: const Offset(-1, 0),
      duration: AnimationService.normal,
    );
  }
}

/// Widget para histórico de busca rápida
class QuickSearchHistoryWidget extends StatelessWidget {
  final List<String> recentSearches;
  final Function(String) onSearchTap;
  final Function(String)? onRemoveSearch;
  final int maxItems;

  const QuickSearchHistoryWidget({
    super.key,
    required this.recentSearches,
    required this.onSearchTap,
    this.onRemoveSearch,
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    if (recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayItems = recentSearches.take(maxItems).toList();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.clock,
                size: AppDimensions.iconSmall,
                color: AppColors.textLight,
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              Text(
                'Buscas Recentes',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Wrap(
            spacing: AppDimensions.paddingSmall,
            runSpacing: AppDimensions.paddingSmall,
            children: displayItems.asMap().entries.map((entry) {
              final index = entry.key;
              final search = entry.value;
              
              return AnimationService.staggeredListItem(
                index: index,
                duration: AnimationService.fast,
                staggerDelay: const Duration(milliseconds: 40),
                child: GestureDetector(
                  onTap: () {
                    AnimationService.selectionHaptic();
                    onSearchTap(search);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium,
                      vertical: AppDimensions.paddingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSmall,
                      ),
                      border: Border.all(
                        color: AppColors.divider,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          search,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textDark,
                          ),
                        ),
                        if (onRemoveSearch != null) ...[
                          const SizedBox(width: AppDimensions.paddingSmall),
                          GestureDetector(
                            onTap: () {
                              AnimationService.lightHaptic();
                              onRemoveSearch!(search);
                            },
                            child: Icon(
                              AppIcons.close,
                              size: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).fadeIn();
  }
}