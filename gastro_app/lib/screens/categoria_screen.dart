import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/restaurante.dart';
import '../widgets/restaurante_card.dart';
import '../utils/providers.dart';

class CategoriaScreen extends ConsumerStatefulWidget {
  final String categoria;
  final String emoji;
  final String titulo;

  const CategoriaScreen({
    super.key,
    required this.categoria,
    required this.emoji,
    required this.titulo,
  });

  @override
  ConsumerState<CategoriaScreen> createState() => _CategoriaScreenState();
}

class _CategoriaScreenState extends ConsumerState<CategoriaScreen> {
  List<Restaurante> _restaurantesFiltrados = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarRestaurantesPorCategoria();
  }

  Future<void> _carregarRestaurantesPorCategoria() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Buscar todos os restaurantes
      final restaurantesAsync = ref.read(sugestoesProximasProvider);
      
      await restaurantesAsync.when(
        data: (restaurantes) async {
          // Filtrar restaurantes por categoria
          final filtrados = _filtrarPorCategoria(restaurantes, widget.categoria);
          
          setState(() {
            _restaurantesFiltrados = filtrados;
            _isLoading = false;
          });
        },
        loading: () {
          setState(() {
            _isLoading = true;
          });
        },
        error: (error, stack) {
          setState(() {
            _restaurantesFiltrados = [];
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _restaurantesFiltrados = [];
        _isLoading = false;
      });
    }
  }

  /// Mapeia as categorias do app para os tipos e tags reais do banco de dados
  /// Baseado na análise dos dados reais: Japonesa, Italiana, Cafeteria, Hamburgueria, etc.
  List<Restaurante> _filtrarPorCategoria(List<Restaurante> restaurantes, String categoria) {
    print('🔍 [_filtrarPorCategoria] Categoria: $categoria');
    print('🔍 [_filtrarPorCategoria] Total de restaurantes recebidos: ${restaurantes.length}');
    
    // Log dos restaurantes recebidos
    for (final r in restaurantes) {
      print('🔍 [_filtrarPorCategoria] Restaurante: ${r.nome}, Tipo: ${r.tipo}, Tags: ${r.tags}');
    }
    
    switch (categoria.toLowerCase()) {
      case 'jantar romântico':
        return restaurantes.where((r) => 
          // Tipos românticos do banco
          r.tipo.toLowerCase().contains('italiano') ||
          r.tipo.toLowerCase().contains('italiana') ||
          r.tipo.toLowerCase().contains('francês') ||
          r.tipo.toLowerCase().contains('francesa') ||
          r.tipo.toLowerCase().contains('contemporâneo') ||
          r.tipo.toLowerCase().contains('bistrô') ||
          r.tipo.toLowerCase().contains('bistro') ||
          // Tags românticas
          r.tags.any((tag) => tag.toLowerCase().contains('romântico')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('intimista')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('sofisticado')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('jantar')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('wine')) ||
          // Nome contém indicadores românticos
          r.nome.toLowerCase().contains('bistrô') ||
          r.nome.toLowerCase().contains('wine') ||
          r.nome.toLowerCase().contains('romantic')
        ).toList();
        
      case 'cafés tranquilos':
        return restaurantes.where((r) => 
          // Tipos de café do banco
          r.tipo.toLowerCase().contains('café') ||
          r.tipo.toLowerCase().contains('cafeteria') ||
          r.tipo.toLowerCase().contains('coffee') ||
          r.tipo.toLowerCase().contains('padaria') ||
          // Tags de café
          r.tags.any((tag) => tag.toLowerCase().contains('café')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('coffee')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('tranquilo')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('wifi')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('torrefação')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('especial')) ||
          // Nome contém café
          r.nome.toLowerCase().contains('café') ||
          r.nome.toLowerCase().contains('coffee') ||
          r.nome.toLowerCase().contains('espresso')
        ).toList();
        
      case 'clássicos da cidade':
        return restaurantes.where((r) => 
          // Tipos tradicionais do banco
          r.tipo.toLowerCase().contains('tradicional') ||
          r.tipo.toLowerCase().contains('brasileiro') ||
          r.tipo.toLowerCase().contains('brasileira') ||
          r.tipo.toLowerCase().contains('churrascaria') ||
          r.tipo.toLowerCase().contains('buffet') ||
          // Tags tradicionais
          r.tags.any((tag) => tag.toLowerCase().contains('tradicional')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('clássico')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('história')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('família')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('centro histórico')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('gaúcho')) ||
          // Nome indica tradição
          r.nome.toLowerCase().contains('tradicional') ||
          r.nome.toLowerCase().contains('gaúcha') ||
          r.nome.toLowerCase().contains('central')
        ).toList();
        
      case 'mata-fome':
        return restaurantes.where((r) => 
          // Tipos fast food do banco
          r.tipo.toLowerCase().contains('fast food') ||
          r.tipo.toLowerCase().contains('lanchonete') ||
          r.tipo.toLowerCase().contains('lancheria') ||
          r.tipo.toLowerCase().contains('hamburgueria') ||
          r.tipo.toLowerCase().contains('hambúrguer') ||
          r.tipo.toLowerCase().contains('pizza') ||
          r.tipo.toLowerCase().contains('pizzaria') ||
          // Tags rápidas
          r.tags.any((tag) => tag.toLowerCase().contains('rápido')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('delivery')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('fast')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('prático')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('burger')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('lanches')) ||
          // Nome indica comida rápida
          r.nome.toLowerCase().contains('burger') ||
          r.nome.toLowerCase().contains('pizza') ||
          r.nome.toLowerCase().contains('lanches') ||
          r.nome.toLowerCase().contains('express')
        ).toList();
        
      case 'doces & sobremesas':
        return restaurantes.where((r) => 
          // Tipos doces do banco
          r.tipo.toLowerCase().contains('doces') ||
          r.tipo.toLowerCase().contains('doceria') ||
          r.tipo.toLowerCase().contains('sobremesas') ||
          r.tipo.toLowerCase().contains('confeitaria') ||
          r.tipo.toLowerCase().contains('sorveteria') ||
          r.tipo.toLowerCase().contains('açaí') ||
          // Tags doces
          r.tags.any((tag) => tag.toLowerCase().contains('doce')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('sobremesa')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('açaí')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('sorvete')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('confeitaria')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('bolo')) ||
          // Nome indica doces
          r.nome.toLowerCase().contains('doce') ||
          r.nome.toLowerCase().contains('açaí') ||
          r.nome.toLowerCase().contains('sorvete') ||
          r.nome.toLowerCase().contains('confeitaria')
        ).toList();
        
      case 'brunch domingo':
        return restaurantes.where((r) => 
          // Tipos brunch do banco
          r.tipo.toLowerCase().contains('brunch') ||
          r.tipo.toLowerCase().contains('café da manhã') ||
          r.tipo.toLowerCase().contains('cafeteria') ||
          r.tipo.toLowerCase().contains('padaria') ||
          r.tipo.toLowerCase().contains('café') ||
          // Tags brunch
          r.tags.any((tag) => tag.toLowerCase().contains('brunch')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('breakfast')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('manhã')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('domingo')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('café especial')) ||
          // Nome indica brunch
          r.nome.toLowerCase().contains('brunch') ||
          r.nome.toLowerCase().contains('breakfast') ||
          r.nome.toLowerCase().contains('café')
        ).toList();
        
      case 'para beber':
        print('🔍 [_filtrarPorCategoria] Filtrando para categoria: para beber');
        final filtrados = restaurantes.where((r) {
          final tipoMatch = r.tipo.toLowerCase().contains('bar') ||
                           r.tipo.toLowerCase().contains('pub') ||
                           r.tipo.toLowerCase().contains('cervejaria') ||
                           r.tipo.toLowerCase().contains('choperia') ||
                           r.tipo.toLowerCase().contains('lounge');
          
          final tagMatch = r.tags.any((tag) => tag.toLowerCase().contains('bar')) ||
                          r.tags.any((tag) => tag.toLowerCase().contains('cerveja')) ||
                          r.tags.any((tag) => tag.toLowerCase().contains('beer')) ||
                          r.tags.any((tag) => tag.toLowerCase().contains('drinks')) ||
                          r.tags.any((tag) => tag.toLowerCase().contains('happy hour')) ||
                          r.tags.any((tag) => tag.toLowerCase().contains('chopp'));
          
          final nomeMatch = r.nome.toLowerCase().contains('bar') ||
                           r.nome.toLowerCase().contains('beer') ||
                           r.nome.toLowerCase().contains('pub') ||
                           r.nome.toLowerCase().contains('cervejaria');
          
          final match = tipoMatch || tagMatch || nomeMatch;
          
          if (match) {
            print('✅ [_filtrarPorCategoria] MATCH - ${r.nome}: tipo=${r.tipo}, tags=${r.tags}');
          } else {
            print('❌ [_filtrarPorCategoria] NO MATCH - ${r.nome}: tipo=${r.tipo}, tags=${r.tags}');
          }
          
          return match;
        }).toList();
        
        print('🔍 [_filtrarPorCategoria] Restaurantes filtrados para "para beber": ${filtrados.length}');
        return filtrados;
        
      case 'pet friendly':
        return restaurantes.where((r) => 
          // Tags pet friendly
          r.tags.any((tag) => tag.toLowerCase().contains('pet')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('cachorro')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('dog')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('gato')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('animais')) ||
          r.tags.any((tag) => tag.toLowerCase().contains('pet friendly')) ||
          // Tipo ou nome indica pet friendly
          r.tipo.toLowerCase().contains('pet friendly') ||
          r.nome.toLowerCase().contains('pet') ||
          r.nome.toLowerCase().contains('dog') ||
          r.nome.toLowerCase().contains('amigo')
        ).toList();
        
      default:
        return restaurantes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfbe9d2),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.emoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              widget.titulo,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2c3985),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _carregarRestaurantesPorCategoria,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar lista',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header com informações da categoria
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2c3985),
                  const Color(0xFF2c3985).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.titulo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_restaurantesFiltrados.length} restaurante${_restaurantesFiltrados.length != 1 ? 's' : ''} encontrado${_restaurantesFiltrados.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista de restaurantes
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _restaurantesFiltrados.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _restaurantesFiltrados.length,
                        itemBuilder: (context, index) {
                          final restaurante = _restaurantesFiltrados[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: RestauranteCard(
                              restaurante: restaurante,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Abrindo ${restaurante.nome}'),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2c3985)),
          ),
          SizedBox(height: 16),
          Text(
            'Carregando restaurantes...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF2c3985),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF2c3985).withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: Text(
                  widget.emoji,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum restaurante encontrado',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3985),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Não encontramos restaurantes para a categoria "${widget.titulo}" no momento.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarRestaurantesPorCategoria,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2c3985),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}