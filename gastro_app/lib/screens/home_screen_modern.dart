import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/restaurante.dart';
import '../models/categoria.dart';
import '../services/ai_service.dart';
import '../services/restaurante_service.dart';
import '../services/usuario_service.dart';
import '../config/app_theme.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../utils/providers.dart';
import '../widgets/header_bar.dart';
import '../widgets/restaurante_card_modern.dart';
import '../widgets/tag_chip.dart';
import '../widgets/sugestoes_proximas.dart';
import '../widgets/categorias_carrossel.dart';
import '../widgets/taste_test_logo.dart';
import 'resultados_screen_modern.dart';
import 'favoritos_screen.dart';
import 'experiencias_screen.dart';

class HomeScreenModern extends ConsumerStatefulWidget {
  const HomeScreenModern({super.key});

  @override
  ConsumerState<HomeScreenModern> createState() => _HomeScreenModernState();
}

class _HomeScreenModernState extends ConsumerState<HomeScreenModern>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _carregarFavoritos();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _carregarFavoritos() async {
    final usuarioAtual = ref.read(usuarioAtualProvider);
    
    usuarioAtual.whenData((usuario) async {
      if (usuario != null) {
        try {
          final favoritos = await UsuarioService.obterIdsFavoritos(usuario.id);
          ref.read(favoritosProvider.notifier).state = favoritos.toSet();
        } catch (e) {
          // Ignorar erro silenciosamente
        }
      }
    });
  }

  Future<void> _handleSearch(String input) async {
    if (input.trim().isEmpty) return;

    ref.read(estadoBuscaProvider.notifier).update((state) => {
      ...state,
      'loading': true,
      'erro': null,
    });

    try {
      // Usar novo sistema de IA com debounce e fallback
      final respostaIA = await AiService.processarBuscaPorDesejo(input);
      ref.read(analiseIAProvider.notifier).update((state) => respostaIA);

      // Buscar restaurantes com novos filtros
      final restaurantes = await RestauranteService.buscarComFiltros(
        tipo: respostaIA['tipo'],
        tags: respostaIA['tags']?.cast<String>(),
        localizacao: respostaIA['localizacao'],
        ambiente: respostaIA['ambiente'],
        faixaPreco: respostaIA['faixaPreco']?.toDouble(),
      );

      ref.read(estadoBuscaProvider.notifier).update((state) => {
        'loading': false,
        'resultados': restaurantes,
        'temResultados': restaurantes.isNotEmpty,
        'buscaFeita': true,
        'erro': null,
      });

      _searchFocusNode.unfocus();

      // Mostrar feedback de interpretação da IA
      if (respostaIA['confianca'] != null) {
        final confianca = respostaIA['confianca'] as double;
        final providerInfo = respostaIA['metadados']?['provider'] ?? 'IA';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  confianca > 70 ? Icons.psychology : Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    confianca > 70 
                        ? 'Entendi! ${restaurantes.length} opções encontradas'
                        : 'Encontrei ${restaurantes.length} resultados aproximados',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  '${confianca.round()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            backgroundColor: confianca > 70 
                ? AppTheme.mostarda 
                : AppTheme.terracota.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedio),
            ),
            duration: const Duration(milliseconds: 2000),
          ),
        );
      }

      if (restaurantes.isNotEmpty) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ResultadosScreenModern(
              restaurantes: restaurantes,
              buscaOriginal: input,
              analiseIA: respostaIA,
            ),
          ),
        );
      }

    } catch (e) {
      ref.read(estadoBuscaProvider.notifier).update((state) => {
        ...state,
        'loading': false,
        'erro': 'Erro ao buscar restaurantes: $e',
      });

      // Mostrar erro amigável
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Não entendi muito bem. Tente ser mais específico!',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.bordoSuave,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dicas',
            textColor: Colors.white,
            onPressed: () {
              _mostrarDicasBusca();
            },
          ),
        ),
      );
    }
  }

  void _mostrarDicasBusca() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lightbulb, color: AppTheme.mostarda),
            SizedBox(width: 8),
            Text('Dicas de Busca'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tente frases como:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...[
              '• "Pizza romântica para dois"',
              '• "Café tranquilo para trabalhar"',
              '• "Bar com música ao vivo"',
              '• "Comida vegana barata"',
              '• "Jantar japonês na zona sul"',
            ].map((dica) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(dica, style: const TextStyle(color: AppTheme.cinzaEscuro)),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  void _verDetalhes(Restaurante restaurante) {
    // TODO: Navegar para tela de detalhes
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrindo detalhes de ${restaurante.nome}'),
        backgroundColor: AppTheme.mostarda,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedio),
        ),
      ),
    );
  }

  void _handleCategoriaSelected(Categoria categoria) async {
    // Mostrar feedback visual imediato
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: categoria.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                categoria.emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Buscando ${categoria.nome.toLowerCase()}...',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: categoria.primaryColor.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedio),
        ),
        duration: const Duration(milliseconds: 1500),
      ),
    );

    // Pequeno delay para feedback visual
    await Future.delayed(const Duration(milliseconds: 300));

    // Preencher o campo de busca com a query da categoria
    _searchController.text = categoria.queryBusca;
    
    // Fechar o teclado se estiver aberto
    _searchFocusNode.unfocus();
    
    // Disparar a busca automaticamente
    await _handleSearch(categoria.queryBusca);
  }

  @override
  Widget build(BuildContext context) {
    final estadoBusca = ref.watch(estadoBuscaProvider);
    final usuarioAtual = ref.watch(usuarioAtualProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.cinzaClaro,
      body: Column(
        children: [
          // Header principal com boas-vindas
          FadeTransition(
            opacity: _fadeAnimation,
            child: usuarioAtual.when(
              data: (usuario) => WelcomeHeader(
                userName: usuario?.nome ?? 'Usuário',
                onProfileTap: () {
                  // TODO: Abrir perfil
                },
                onNotificationTap: () {
                  // TODO: Abrir notificações
                },
                notificationCount: 0,
              ),
              loading: () => const WelcomeHeader(userName: 'Carregando...'),
              error: (_, __) => const WelcomeHeader(userName: 'Usuário'),
            ),
          ),

          // Campo de busca
          SlideTransition(
            position: _slideAnimation,
            child: _buildSearchSection(estadoBusca),
          ),

          // Cards de navegação rápida
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildQuickActions(),
          ),

          // Conteúdo principal
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildMainContent(context, estadoBusca),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(Map<String, dynamic> estadoBusca) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.espacoGrande),
      padding: const EdgeInsets.all(AppTheme.espacoGrande),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusExtraGrande),
        boxShadow: AppTheme.sombraCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo de busca principal
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cinzaClaro,
              borderRadius: BorderRadius.circular(AppTheme.radiusGrande),
              border: Border.all(
                color: AppTheme.mostardaClara.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Ex: lugar tranquilo pra café da manhã',
                hintStyle: TextStyle(
                  color: AppTheme.cinzaMedio,
                  fontSize: 16,
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.search,
                    color: AppTheme.mostarda,
                    size: 24,
                  ),
                ),
                suffixIcon: estadoBusca['loading'] 
                  ? Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.mostarda,
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: () => _handleSearch(_searchController.text),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          gradient: AppTheme.gradientPrimario,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.espacoGrande,
                  vertical: AppTheme.espacoGrande,
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.cinzaEscuro,
              ),
              onSubmitted: _handleSearch,
              enabled: !estadoBusca['loading'],
            ),
          ),
          
          const SizedBox(height: AppTheme.espacoMedio),
          
          // Sugestões rápidas
          _buildQuickSuggestions(),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    final suggestions = [
      'lugar tranquilo pra café da manhã',
      'pizza artesanal com a família',
      'bar descontraído',
      'comida vegana saudável',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sugestões populares',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.cinzaEscuro,
          ),
        ),
        const SizedBox(height: AppTheme.espacoPequeno),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((suggestion) {
            return GestureDetector(
              onTap: () {
                _searchController.text = suggestion;
                _handleSearch(suggestion);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientPrimario.scale(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.mostardaClara,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 14,
                      color: AppTheme.mostardaEscura,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      suggestion,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.mostardaEscura,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.espacoGrande),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionCardModern(
              icon: Icons.favorite,
              iconColor: AppTheme.customColors['favorite']!,
              title: 'Meus Favoritos',
              subtitle: 'Restaurantes salvos',
              gradient: LinearGradient(
                colors: [
                  AppTheme.customColors['favorite']!.withOpacity(0.1),
                  AppTheme.customColors['favorite']!.withOpacity(0.05),
                ],
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FavoritosScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: AppTheme.espacoMedio),
          Expanded(
            child: _QuickActionCardModern(
              icon: Icons.rate_review,
              iconColor: AppTheme.mostarda,
              title: 'Experiências',
              subtitle: 'Suas avaliações',
              gradient: AppTheme.gradientPrimario.scale(0.1),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ExperienciasScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, Map<String, dynamic> estadoBusca) {
    if (estadoBusca['loading']) {
      return _buildLoadingState();
    }

    if (estadoBusca['erro'] != null) {
      return _buildErrorState(estadoBusca['erro']);
    }

    if (estadoBusca['buscaFeita'] && !estadoBusca['temResultados']) {
      return _buildNoResultsState();
    }

    if (estadoBusca['temResultados']) {
      return _buildResultsState(estadoBusca['resultados']);
    }

    return _buildInitialState();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.gradientPrimario,
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.espacoGrande),
          Text(
            'Analisando seu desejo...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.cinzaEscuro,
            ),
          ),
          const SizedBox(height: AppTheme.espacoPequeno),
          Text(
            'Buscando os melhores restaurantes para você',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.cinzaMedio,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String erro) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.espacoExtraGrande),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: AppTheme.espacoGrande),
            Text(
              'Ops! Algo deu errado',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: AppTheme.espacoPequeno),
            Text(
              erro,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.cinzaMedio,
              ),
            ),
            const SizedBox(height: AppTheme.espacoGrande),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(estadoBuscaProvider.notifier).update((state) => {
                  ...state,
                  'erro': null,
                  'buscaFeita': false,
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.espacoExtraGrande),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.mostardaClara.withOpacity(0.2),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.search_off,
                size: 40,
                color: AppTheme.mostarda,
              ),
            ),
            const SizedBox(height: AppTheme.espacoGrande),
            Text(
              'Ops, não encontramos nada com esse perfil.',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.cinzaEscuro,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.espacoPequeno),
            Text(
              'Tente uma combinação diferente!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.cinzaMedio,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.espacoGrande),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                _searchFocusNode.requestFocus();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Nova Busca'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsState(List<Restaurante> resultados) {
    return Column(
      children: [
        // Header dos resultados
        Container(
          padding: const EdgeInsets.all(AppTheme.espacoGrande),
          margin: const EdgeInsets.symmetric(horizontal: AppTheme.espacoGrande),
          decoration: BoxDecoration(
            gradient: AppTheme.gradientSuave,
            borderRadius: BorderRadius.circular(AppTheme.radiusGrande),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Encontramos ${resultados.length} opção${resultados.length > 1 ? 'ões' : ''} perfeita${resultados.length > 1 ? 's' : ''} para você! 🎉',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cinzaEscuro,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  _searchController.clear();
                  ref.read(estadoBuscaProvider.notifier).update((state) => {
                    'loading': false,
                    'resultados': <Restaurante>[],
                    'temResultados': false,
                    'buscaFeita': false,
                    'erro': null,
                  });
                },
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.cinzaMedio,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppTheme.espacoMedio),
        
        // Lista de resultados
        Expanded(
          child: ListView.builder(
            itemCount: resultados.length,
            itemBuilder: (context, index) {
              final restaurante = resultados[index];
              return RestauranteCardModern(
                restaurante: restaurante,
                onTap: () => _verDetalhes(restaurante),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInitialState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Área de boas-vindas
          Container(
            margin: const EdgeInsets.all(AppTheme.espacoGrande),
            padding: const EdgeInsets.all(AppTheme.espacoExtraGrande),
            decoration: BoxDecoration(
              gradient: AppTheme.gradientSuave,
              borderRadius: BorderRadius.circular(AppTheme.radiusExtraGrande),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradientPrimario,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Center(
                    child: Text(
                      '🍽️',
                      style: TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.espacoGrande),
                Text(
                  'Conte-nos o que você deseja!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.cinzaEscuro,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.espacoPequeno),
                Text(
                  'Use palavras como "tranquilo", "romântico", "pizza" ou "café da manhã"',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.cinzaMedio,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Seção "Hoje eu quero..."
          HojeEuQueroSection(
            onCategoriaSelected: _handleCategoriaSelected,
          ),

          const SizedBox(height: AppTheme.espacoMedio),

          // Seção de categorias em destaque (fins de semana/datas especiais)
          CategoriasDestaque(
            categorias: _getCategoriasDestaque(),
            onCategoriaSelected: _handleCategoriaSelected,
            titulo: 'Para Ocasiões Especiais',
          ),

          const SizedBox(height: AppTheme.espacoGrande),

          // Seção de todas as categorias em carrossel
          CategoriasCarrossel(
            titulo: 'Explore Todas as Categorias',
            subtitulo: 'Deslize para ver mais opções',
            categorias: CategoriasData.categorias,
            onCategoriaSelected: _handleCategoriaSelected,
            displayMode: CategoriaDisplayMode.carrossel,
            altura: 260,
          ),

          const SizedBox(height: AppTheme.espacoGrande),

          // Sugestões próximas
          const SugestoesProximas(),
          
          const SizedBox(height: AppTheme.espacoGrande),
        ],
      ),
    );
  }

  List<Categoria> _getCategoriasDestaque() {
    // Lógica simples para categorias em destaque
    // Pode ser baseada em dia da semana, horário, ou dados de analytics
    final agora = DateTime.now();
    
    if (agora.weekday == DateTime.saturday || agora.weekday == DateTime.sunday) {
      // Fins de semana: brunch, beber com amigos, romântico
      return [
        CategoriasData.obterPorId('brunch_domingo')!,
        CategoriasData.obterPorId('beber_amigos')!,
        CategoriasData.obterPorId('jantar_romantico')!,
      ];
    } else if (agora.hour >= 18) {
      // Noites de semana: happy hour, delivery rápido
      return [
        CategoriasData.obterPorId('beber_amigos')!,
        CategoriasData.obterPorId('mata_fome_rapido')!,
        CategoriasData.obterPorId('jantar_romantico')!,
      ];
    } else if (agora.hour >= 14 && agora.hour < 17) {
      // Tarde: café, doces
      return [
        CategoriasData.obterPorId('cafes_tranquilos')!,
        CategoriasData.obterPorId('doces_sobremesas')!,
        CategoriasData.obterPorId('mata_fome_rapido')!,
      ];
    } else {
      // Manhã/almoço: café da manhã/brunch, clássicos
      return [
        CategoriasData.obterPorId('brunch_domingo')!,
        CategoriasData.obterPorId('classicos_cidade')!,
        CategoriasData.obterPorId('vegetariano_vegano')!,
      ];
    }
  }
}

class _QuickActionCardModern extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _QuickActionCardModern({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_QuickActionCardModern> createState() => __QuickActionCardModernState();
}

class __QuickActionCardModernState extends State<_QuickActionCardModern>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) => _controller.reverse(),
            onTapCancel: () => _controller.reverse(),
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.espacoGrande),
              decoration: BoxDecoration(
                gradient: widget.gradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusGrande),
                boxShadow: AppTheme.sombraCard,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: widget.iconColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.iconColor,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.cinzaMedio,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.espacoMedio),
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.cinzaEscuro,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.cinzaMedio,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 