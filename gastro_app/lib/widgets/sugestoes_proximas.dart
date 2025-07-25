import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/restaurante.dart';
import '../services/localizacao_service.dart';
import '../utils/providers.dart';
import '../widgets/restaurante_card.dart';
import '../screens/resultados_screen.dart';

class SugestoesProximas extends ConsumerStatefulWidget {
  const SugestoesProximas({super.key});

  @override
  ConsumerState<SugestoesProximas> createState() => _SugestoesProximasState();
}

class _SugestoesProximasState extends ConsumerState<SugestoesProximas> {
  bool _expandido = false;

  Future<void> _solicitarLocalizacao() async {
    // Usar o LocalizacaoManager para consistência
    if (mounted) {
      await LocalizacaoManager.inicializarLocalizacao(ref);
    }
  }

  void _verTodosResultados(List<Restaurante> restaurantes) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultadosScreen(
          restaurantes: restaurantes,
          buscaOriginal: 'Sugestões próximas',
          analiseIA: {
            'tipo': null,
            'tags': [],
            'localizacao': 'Sua localização atual',
          },
        ),
      ),
    );
  }

  void _reativarLocalizacao() {
    _solicitarLocalizacao();
  }

  @override
  Widget build(BuildContext context) {
    final statusLocalizacao = ref.watch(statusLocalizacaoProvider);
    final sugestoesAsync = ref.watch(sugestoesProximasProvider);
    final configuracao = ref.watch(configuracaoDistanciaProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.deepOrange.shade600,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTituloSugestoes(statusLocalizacao, configuracao),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        _getSubtituloSugestoes(statusLocalizacao, configuracao),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (statusLocalizacao == StatusLocalizacao.negada ||
                    statusLocalizacao == StatusLocalizacao.servicoDesabilitado)
                  TextButton.icon(
                    onPressed: _reativarLocalizacao,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Tentar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.deepOrange,
                    ),
                  ),
                if (statusLocalizacao == StatusLocalizacao.negadaPermanentemente)
                  TextButton.icon(
                    onPressed: () async {
                      await LocalizacaoService.openLocationSettings();
                    },
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text('Config'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.deepOrange,
                    ),
                  ),
              ],
            ),
          ),

          // Conteúdo
          sugestoesAsync.when(
            loading: () => _buildLoading(),
            error: (error, stack) => _buildError(error.toString()),
            data: (restaurantes) => _buildSugestoes(restaurantes),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
            ),
            SizedBox(height: 16),
            Text(
              'Carregando sugestões...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String erro) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Erro ao carregar sugestões',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            erro,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSugestoes(List<Restaurante> restaurantes) {
    if (restaurantes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.restaurant,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Nenhum restaurante encontrado',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tente aumentar o raio de busca',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    final restaurantesExibidos = _expandido 
      ? restaurantes 
      : restaurantes.take(3).toList();

    return Column(
      children: [
        // Lista de restaurantes
        ...restaurantesExibidos.map((restaurante) {
          return RestauranteCard(
            restaurante: restaurante,
            onTap: () {
              // TODO: Navegar para detalhes
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Abrindo ${restaurante.nome}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            onFavorite: () {
              // TODO: Implementar favoritos
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${restaurante.nome} favoritado!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          );
        }).toList(),

        // Botões de ação
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (restaurantes.length > 3)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _expandido = !_expandido;
                      });
                    },
                    icon: Icon(
                      _expandido ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                    ),
                    label: Text(
                      _expandido 
                        ? 'Ver menos' 
                        : 'Ver mais (${restaurantes.length - 3})',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepOrange,
                      side: BorderSide(color: Colors.deepOrange.shade300),
                    ),
                  ),
                ),
              if (restaurantes.length > 3) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _verTodosResultados(restaurantes),
                  icon: const Icon(Icons.map, size: 20),
                  label: const Text('Ver no Mapa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getTituloSugestoes(StatusLocalizacao status, Map<String, dynamic> config) {
    switch (status) {
      case StatusLocalizacao.inicial:
      case StatusLocalizacao.desconhecido:
        return 'Restaurantes em destaque';
      case StatusLocalizacao.obtendo:
        return 'Obtendo sua localização...';
      case StatusLocalizacao.obtida:
        return 'Sugestões próximas';
      case StatusLocalizacao.negada:
        return 'Permissão de localização negada';
      case StatusLocalizacao.negadaPermanentemente:
        return 'Localização bloqueada';
      case StatusLocalizacao.servicoDesabilitado:
        return 'Localização desabilitada';
      case StatusLocalizacao.erro:
        return 'Erro na localização';
      case StatusLocalizacao.fallback:
        return 'Restaurantes próximos';
    }
  }

  String _getSubtituloSugestoes(StatusLocalizacao status, Map<String, dynamic> config) {
    switch (status) {
      case StatusLocalizacao.inicial:
      case StatusLocalizacao.desconhecido:
        return 'Baseado na região de Porto Alegre';
      case StatusLocalizacao.obtendo:
        return 'Aguarde um momento...';
      case StatusLocalizacao.obtida:
      case StatusLocalizacao.fallback:
        return 'Lugares até ${(config['raioMaximo'] ?? 10.0).toStringAsFixed(0)} km de você';
      case StatusLocalizacao.negada:
        return 'Toque em "Tentar" para permitir localização';
      case StatusLocalizacao.negadaPermanentemente:
        return 'Ative nas configurações do app';
      case StatusLocalizacao.servicoDesabilitado:
        return 'Ative a localização no seu dispositivo';
      case StatusLocalizacao.erro:
        return 'Usando localização aproximada';
    }
  }
}