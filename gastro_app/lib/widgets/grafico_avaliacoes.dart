import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/estatisticas_restaurante.dart';
import '../utils/providers.dart';

class GraficoAvaliacoes extends ConsumerWidget {
  final String restauranteId;
  final bool showTitle;
  final bool showPercentages;

  const GraficoAvaliacoes({
    super.key,
    required this.restauranteId,
    this.showTitle = true,
    this.showPercentages = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estatisticasAsync = ref.watch(estatisticasRestauranteProvider(restauranteId));

    return estatisticasAsync.when(
      data: (estatisticas) {
        final stats = estatisticas as EstatisticasRestaurante?;
        return stats != null ? _buildGrafico(context, stats) : _buildEmpty();
      },
      loading: () => _buildLoading(),
      error: (_, __) => _buildError(),
    );
  }

  Widget _buildGrafico(BuildContext context, EstatisticasRestaurante estatisticas) {
    if (estatisticas.total == 0) {
      return _buildEmpty();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            Row(
              children: [
                const Icon(
                  Icons.bar_chart,
                  color: Color(0xFF2c3985),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Avaliações dos Usuários',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3985),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFfbe9d2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${estatisticas.total} ${estatisticas.total == 1 ? 'avaliação' : 'avaliações'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2c3985),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          // Resumo com emoji principal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _hexToColor(estatisticas.corTopEmoji).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _hexToColor(estatisticas.corTopEmoji).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Text(
                  estatisticas.topEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        estatisticas.descricaoGeral,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _hexToColor(estatisticas.corTopEmoji),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${estatisticas.getPercentual(estatisticas.topEmoji).toStringAsFixed(0)}% dos usuários',
                        style: TextStyle(
                          fontSize: 12,
                          color: _hexToColor(estatisticas.corTopEmoji).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Gráfico de barras
          Column(
            children: estatisticas.emojisOrdenados.map((entry) {
              final emoji = entry.key;
              final count = entry.value;
              final percentual = estatisticas.getPercentual(emoji);
              final cor = _getEmojiColor(emoji);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildBarraEmoji(emoji, count, percentual, cor),
              );
            }).toList(),
          ),
          
          // Confiabilidade
          if (estatisticas.total >= 3) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.verified,
                  size: 16,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  'Dados confiáveis',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.orange.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  'Poucas avaliações ainda',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBarraEmoji(String emoji, int count, double percentual, Color cor) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: cor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cor.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        _getEmojiDescription(emoji),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2c3985),
                        ),
                      ),
                      const Spacer(),
                      if (showPercentages) ...[
                        Text(
                          '${percentual.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: cor,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: cor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: cor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentual / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(cor),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: Color(0xFF2c3985)),
            SizedBox(height: 12),
            Text(
              'Carregando avaliações...',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF2c3985),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 12),
            const Text(
              'Erro ao carregar avaliações',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.sentiment_neutral,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhuma avaliação ainda',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seja o primeiro a avaliar este restaurante!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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

  Color _getEmojiColor(String emoji) {
    switch (emoji) {
      case '😋':
        return const Color(0xFF4CAF50); // Verde
      case '❤️':
        return const Color(0xFFE91E63); // Rosa
      case '😐':
        return const Color(0xFFFF9800); // Laranja
      case '🤢':
        return const Color(0xFFF44336); // Vermelho
      default:
        return const Color(0xFF9E9E9E); // Cinza
    }
  }

  String _getEmojiDescription(String emoji) {
    switch (emoji) {
      case '😋':
        return 'Delicioso';
      case '❤️':
        return 'Amei';
      case '😐':
        return 'Ok';
      case '🤢':
        return 'Não gostei';
      default:
        return 'Avaliação';
    }
  }
}

/// Widget compacto para uso em listas
class GraficoAvaliacoesCompacto extends ConsumerWidget {
  final String restauranteId;

  const GraficoAvaliacoesCompacto({
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: stats.emojisOrdenados.take(3).map((entry) {
              final emoji = entry.key;
              final count = entry.value;
              final percentual = stats.getPercentual(emoji);
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      '${percentual.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2c3985),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
} 