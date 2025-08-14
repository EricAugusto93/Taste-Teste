import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/providers.dart';
import '../services/localizacao_service.dart';
import '../services/restaurante_service.dart';
import '../widgets/restaurante_proximidade_card.dart';
import '../widgets/raio_busca_slider.dart';
import '../widgets/smooth_loader.dart';

class ProximidadeScreen extends ConsumerStatefulWidget {
  const ProximidadeScreen({super.key});

  @override
  ConsumerState<ProximidadeScreen> createState() => _ProximidadeScreenState();
}

class _ProximidadeScreenState extends ConsumerState<ProximidadeScreen> {
  bool _restaurantesInseridos = false;

  @override
  void initState() {
    super.initState();
    // Iniciar obtenção de localização ao abrir a tela apenas se necessário
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final statusAtual = ref.read(statusLocalizacaoProvider);
        // Só inicializar se ainda não foi inicializado ou se houve erro
        if (statusAtual == StatusLocalizacao.inicial || 
            statusAtual == StatusLocalizacao.erro) {
          LocalizacaoManager.inicializarLocalizacao(ref);
        }
        
        // Inserir restaurantes de teste se ainda não foram inseridos
        _inserirRestaurantesTeste();
      }
    });
  }

  Future<void> _inserirRestaurantesTeste() async {
    if (_restaurantesInseridos) return;
    
    try {
      print('🔧 [ProximidadeScreen] Inserindo restaurantes de teste...');
      await RestauranteService.inserirRestaurantesTeste();
      _restaurantesInseridos = true;
      print('✅ [ProximidadeScreen] Restaurantes de teste inseridos!');
      
      // Invalidar providers para recarregar os dados
      if (mounted) {
        ref.invalidate(todosRestaurantesProvider);
      }
    } catch (e) {
      print('❌ [ProximidadeScreen] Erro ao inserir restaurantes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusLocalizacao = ref.watch(statusLocalizacaoProvider);
    final usandoFallback = ref.watch(usandoFallbackProvider);
    final estatisticas = ref.watch(estatisticasProximidadeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFfbe9d2),
      appBar: AppBar(
        title: const Text(
          'Descobrir por Proximidade',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2c3985),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _reobterLocalizacao,
            icon: const Icon(Icons.my_location),
            tooltip: 'Atualizar localização',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header com status e controles
          _buildHeader(statusLocalizacao, usandoFallback, estatisticas),
          
          // Slider de raio
          _buildRaioControl(),
          
          // Lista de restaurantes
          Expanded(
            child: _buildRestaurantesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(StatusLocalizacao status, bool usandoFallback, Map<String, int> stats) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
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
          // Status da localização
          Row(
            children: [
              Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusTitle(status, usandoFallback),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2c3985),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStatusSubtitle(status, usandoFallback),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Estatísticas se há restaurantes
          if (stats['total']! > 0) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Restaurantes encontrados: ${stats['total']}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2c3985),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatBadge('🟢', stats['muitoProximo']!, 'Até 1km'),
                _buildStatBadge('🟠', stats['proximo']!, '1-3km'),
                _buildStatBadge('🔴', stats['distante']!, '+ 3km'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatBadge(String emoji, int count, String label) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2c3985),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildRaioControl() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: const RaioBuscaSlider(),
    );
  }

  Widget _buildRestaurantesList() {
    final restaurantesProximos = ref.watch(restaurantesProximosProvider);
    
    return restaurantesProximos.when(
      data: (restaurantes) {
        print('🔍 [ProximidadeScreen] Restaurantes recebidos: ${restaurantes.length}');
        for (int i = 0; i < restaurantes.length && i < 3; i++) {
          print('🔍 [ProximidadeScreen] Restaurante $i: ${restaurantes[i].restaurante.nome} - ${restaurantes[i].distancia.toStringAsFixed(2)}km');
        }
        
        if (restaurantes.isEmpty) {
          print('🔍 [ProximidadeScreen] Lista vazia, mostrando empty state');
          return _buildEmptyState();
        }
        
        print('🔍 [ProximidadeScreen] Construindo ListView com ${restaurantes.length} itens');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: restaurantes.length,
          itemBuilder: (context, index) {
            final restauranteComDistancia = restaurantes[index];
            print('🔍 [ProximidadeScreen] Construindo card para: ${restauranteComDistancia.restaurante.nome}');
            return RestauranteProximidadeCard(
              restauranteComDistancia: restauranteComDistancia,
            );
          },
        );
      },
      loading: () {
        print('🔍 [ProximidadeScreen] Estado: Loading');
        return _buildLoading();
      },
      error: (error, stack) {
        print('🔍 [ProximidadeScreen] Erro: $error');
        return _buildError(error.toString());
      },
    );
  }

  Widget _buildEmptyState() {
    final raio = ref.watch(raioBuscaProvider);
    final usandoFallback = ref.watch(usandoFallbackProvider);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_searching,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              usandoFallback 
                ? 'Nenhum restaurante encontrado no raio de ${raio.toStringAsFixed(0)}km em Porto Alegre'
                : 'Nenhum restaurante encontrado no raio de ${raio.toStringAsFixed(0)}km',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2c3985),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tente aumentar o raio de busca ou verificar sua localização',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _reobterLocalizacao,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2c3985),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: SmoothLoader.restaurantSearch(),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 24),
            const Text(
              'Erro ao buscar restaurantes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _reobterLocalizacao,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares para status
  IconData _getStatusIcon(StatusLocalizacao status) {
    switch (status) {
      case StatusLocalizacao.inicial:
      case StatusLocalizacao.desconhecido:
        return Icons.location_searching;
      case StatusLocalizacao.obtida:
        return Icons.location_on;
      case StatusLocalizacao.obtendo:
        return Icons.location_searching;
      case StatusLocalizacao.fallback:
        return Icons.location_city;
      case StatusLocalizacao.negada:
      case StatusLocalizacao.negadaPermanentemente:
        return Icons.location_disabled;
      case StatusLocalizacao.servicoDesabilitado:
        return Icons.location_disabled;
      case StatusLocalizacao.erro:
        return Icons.error_outline;
    }
  }

  Color _getStatusColor(StatusLocalizacao status) {
    switch (status) {
      case StatusLocalizacao.inicial:
      case StatusLocalizacao.desconhecido:
        return Colors.grey;
      case StatusLocalizacao.obtida:
        return Colors.green;
      case StatusLocalizacao.obtendo:
        return const Color(0xFF2c3985);
      case StatusLocalizacao.fallback:
        return const Color(0xFFee9d21);
      case StatusLocalizacao.negada:
      case StatusLocalizacao.negadaPermanentemente:
        return Colors.red;
      case StatusLocalizacao.servicoDesabilitado:
        return Colors.red;
      case StatusLocalizacao.erro:
        return Colors.red;
    }
  }

  String _getStatusTitle(StatusLocalizacao status, bool usandoFallback) {
    if (usandoFallback) {
      return 'Usando localização aproximada';
    }
    
    switch (status) {
      case StatusLocalizacao.inicial:
      case StatusLocalizacao.desconhecido:
        return 'Verificando localização';
      case StatusLocalizacao.obtida:
        return 'Localização precisa obtida';
      case StatusLocalizacao.obtendo:
        return 'Obtendo sua localização...';
      case StatusLocalizacao.negada:
        return 'Permissão de localização negada';
      case StatusLocalizacao.negadaPermanentemente:
        return 'Permissão bloqueada';
      case StatusLocalizacao.servicoDesabilitado:
        return 'Localização desabilitada';
      case StatusLocalizacao.erro:
        return 'Erro na localização';
      case StatusLocalizacao.fallback:
        return 'Localização aproximada';
    }
  }

  String _getStatusSubtitle(StatusLocalizacao status, bool usandoFallback) {
    if (usandoFallback) {
      return 'Mostrando resultados para Porto Alegre';
    }
    
    switch (status) {
      case StatusLocalizacao.inicial:
      case StatusLocalizacao.desconhecido:
        return 'Preparando busca por proximidade';
      case StatusLocalizacao.obtida:
        return 'Restaurantes ordenados por proximidade real';
      case StatusLocalizacao.obtendo:
        return 'Aguarde enquanto encontramos você';
      case StatusLocalizacao.negada:
        return 'Toque no ícone para tentar novamente';
      case StatusLocalizacao.negadaPermanentemente:
        return 'Vá às configurações para permitir localização';
      case StatusLocalizacao.servicoDesabilitado:
        return 'Ative a localização no seu dispositivo';
      case StatusLocalizacao.erro:
        return 'Usando localização aproximada como alternativa';
      case StatusLocalizacao.fallback:
        return 'Mostrando resultados para Porto Alegre';
    }
  }

  Future<void> _reobterLocalizacao() async {
    // Re-inicializar localização
    if (mounted) {
      await LocalizacaoManager.inicializarLocalizacao(ref);
      // O restaurantesProximosProvider será atualizado automaticamente
      // quando a localização mudar, não precisamos invalidar manualmente
    }
  }
}