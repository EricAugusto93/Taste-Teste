import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/estatisticas_restaurante.dart';
import '../utils/providers.dart';

class AvaliacaoBadge extends ConsumerWidget {
  final String restauranteId;
  final bool isCompact;
  final double? fontSize;

  const AvaliacaoBadge({
    super.key,
    required this.restauranteId,
    this.isCompact = false,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estatisticasAsync = ref.watch(estatisticasRestauranteProvider(restauranteId));

    return estatisticasAsync.when(
      data: (estatisticas) {
        final stats = estatisticas as EstatisticasRestaurante?;
        return stats != null ? _buildBadge(context, stats) : _buildEmptyBadge();
      },
      loading: () => _buildLoadingBadge(),
      error: (_, __) => _buildEmptyBadge(),
    );
  }

  Widget _buildBadge(BuildContext context, EstatisticasRestaurante estatisticas) {
    if (estatisticas.total == 0) {
      return _buildEmptyBadge();
    }

    final cor = _hexToColor(estatisticas.corTopEmoji);

    if (isCompact) {
      return _buildCompactBadge(estatisticas, cor);
    } else {
      return _buildFullBadge(context, estatisticas, cor);
    }
  }

  Widget _buildCompactBadge(EstatisticasRestaurante estatisticas, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            estatisticas.topEmoji,
            style: TextStyle(fontSize: fontSize ?? 12),
          ),
          const SizedBox(width: 3),
          Text(
            estatisticas.total.toString(),
            style: TextStyle(
              fontSize: fontSize ?? 10,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullBadge(BuildContext context, EstatisticasRestaurante estatisticas, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            estatisticas.topEmoji,
            style: TextStyle(fontSize: fontSize ?? 16),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${estatisticas.total} ${estatisticas.total == 1 ? 'avaliação' : 'avaliações'}',
                style: TextStyle(
                  fontSize: fontSize != null ? fontSize! - 2 : 12,
                  fontWeight: FontWeight.bold,
                  color: cor,
                ),
              ),
              if (estatisticas.isConfiavel) ...[
                const SizedBox(height: 1),
                Text(
                  estatisticas.descricaoGeral,
                  style: TextStyle(
                    fontSize: fontSize != null ? fontSize! - 4 : 10,
                    color: cor.withOpacity(0.8),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 10,
        vertical: isCompact ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: isCompact ? 12 : 16,
            height: isCompact ? 12 : 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
            ),
          ),
          if (!isCompact) ...[
            const SizedBox(width: 6),
            Text(
              'Carregando...',
              style: TextStyle(
                fontSize: fontSize != null ? fontSize! - 2 : 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyBadge() {
    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Text(
          '—',
          style: TextStyle(
            fontSize: fontSize ?? 10,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_border,
            size: fontSize ?? 16,
            color: Colors.grey.shade400,
          ),
          const SizedBox(width: 6),
          Text(
            'Sem avaliações',
            style: TextStyle(
              fontSize: fontSize != null ? fontSize! - 2 : 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }
}

/// Widget mais simples para uso em listas densas
class AvaliacaoBadgeSimples extends ConsumerWidget {
  final String restauranteId;

  const AvaliacaoBadgeSimples({
    super.key,
    required this.restauranteId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estatisticasAsync = ref.watch(estatisticasRestauranteProvider(restauranteId));

    return estatisticasAsync.when(
      data: (estatisticas) {
        final stats = estatisticas as EstatisticasRestaurante?;
        if (stats == null || stats.total == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: _hexToColor(stats.corTopEmoji).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${stats.topEmoji} ${stats.total}',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: _hexToColor(stats.corTopEmoji),
            ),
          ),
        );
      },
      loading: () => Container(
        width: 20,
        height: 12,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Color _hexToColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }
}

/// Widget para mostrar o trending (emoji mais usado globalmente)
class TrendingEmojiBadge extends ConsumerWidget {
  const TrendingEmojiBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estatisticasGlobaisAsync = ref.watch(estatisticasGlobaisProvider);

    return estatisticasGlobaisAsync.when(
      data: (estatisticas) {
        if (estatisticas == null) return const SizedBox.shrink();
        
        final emojiMaisUsado = estatisticas['emoji_mais_usado'] as String?;
        if (emojiMaisUsado == null || emojiMaisUsado.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFee9d21).withOpacity(0.2),
                const Color(0xFF2c3985).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFee9d21).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                emojiMaisUsado,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 4),
              const Text(
                'TRENDING',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFee9d21),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
} 