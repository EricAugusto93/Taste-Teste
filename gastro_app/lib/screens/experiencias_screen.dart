import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/providers.dart';
import '../widgets/experiencia_button.dart';
import '../widgets/registrar_experiencia.dart';
import '../widgets/safe_list_view.dart';
import '../services/experiencia_service.dart';
import '../utils/snackbar_utils.dart';
import '../config/app_theme.dart';

class ExperienciasScreen extends ConsumerStatefulWidget {
  const ExperienciasScreen({super.key});

  @override
  ConsumerState<ExperienciasScreen> createState() => _ExperienciasScreenState();
}

class _ExperienciasScreenState extends ConsumerState<ExperienciasScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    // Verificação de segurança para evitar PersistedOffset errors
    try {
      if (_slideController.isAnimating) {
        _slideController.stop();
      }
      _slideController.dispose();
    } catch (e) {
      debugPrint('⚠️ Erro ao descartar slideController: $e');
    }
    
    try {
      if (_fadeController.isAnimating) {
        _fadeController.stop();
      }
      _fadeController.dispose();
    } catch (e) {
      debugPrint('⚠️ Erro ao descartar fadeController: $e');
    }
    
    super.dispose();
  }

  void _setupAnimations() {
    try {
      _slideController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );

      _fadeController = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );

      _slideAnimation = Tween<Offset>(
        begin: const Offset(0.0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ));

      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ));

      // Iniciar animações com verificação de mounted
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao configurar animações: $e');
    }
  }

  void _refreshExperiencias() {
    ref.invalidate(experienciasUsuarioProvider);
    
    // Mostrar feedback visual usando o utilitário global
    SnackBarUtils.showSuccess(context, 'Experiências atualizadas!');
  }

  void _mostrarSeletorRestaurante() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSeletorRestaurante(),
    );
  }

  Widget _buildSeletorRestaurante() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.restaurant,
                  color: Color(0xFF2c3985),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Selecione um Restaurante',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3985),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final restaurantesAsync = ref.watch(sugestoesProximasProvider);
                return restaurantesAsync.when(
                  data: (restaurantes) {
                    if (restaurantes.isEmpty) {
                      return const Center(
                        child: Text('Nenhum restaurante encontrado'),
                      );
                    }
                    return SafeListViewBuilder(
                      padding: const EdgeInsets.all(16),
                      itemCount: restaurantes.length,
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final restaurante = restaurantes[index];
                        return _buildRestauranteItem(restaurante);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stack) => Center(
                    child: Text('Erro: $error'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestauranteItem(dynamic restaurante) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFee9d21).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.restaurant,
            color: Color(0xFFee9d21),
          ),
        ),
        title: Text(
          restaurante.nome,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2c3985),
          ),
        ),
        subtitle: Text(restaurante.tipo),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {
          Navigator.pop(context);
          _mostrarRegistrarExperiencia(restaurante);
        },
      ),
    );
  }

  void _mostrarRegistrarExperiencia(dynamic restaurante) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: RegistrarExperiencia(
          restaurante: restaurante,
          onSalvar: () {
            _refreshExperiencias();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Experiência registrada com sucesso!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final experiencias = ref.watch(experienciasUsuarioProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFfbe9d2),
      appBar: AppBar(
        title: const Text(
          'Minhas Experiências',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2c3985),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: IconButton(
                  onPressed: _refreshExperiencias,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Atualizar lista',
                ),
              );
            },
          ),
        ],
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: experiencias.when(
            data: (experienciasList) => _buildContent(context, experienciasList),
            loading: () => _buildLoading(),
            error: (error, stack) => _buildError(context, error.toString()),
          ),
        ),
      ),
      floatingActionButton: experiencias.when(
        data: (experienciasList) => experienciasList.isEmpty 
          ? _buildAnimatedFAB()
          : _buildNormalFAB(),
        loading: () => _buildNormalFAB(),
        error: (_, __) => _buildNormalFAB(),
      ),
    );
  }

  Widget _buildAnimatedFAB() {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_fadeController.value * 0.1),
          child: FloatingActionButton.extended(
            onPressed: _mostrarSeletorRestaurante,
            backgroundColor: const Color(0xFF2c3985),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Nova Experiência'),
            elevation: 6 + (_fadeController.value * 2),
          ),
        );
      },
    );
  }

  Widget _buildNormalFAB() {
    return FloatingActionButton.extended(
      onPressed: _mostrarSeletorRestaurante,
      backgroundColor: const Color(0xFF2c3985),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Nova Experiência'),
    );
  }

  Widget _buildContent(BuildContext context, List<dynamic> experienciasList) {
    if (experienciasList.isEmpty) {
      return _buildEmptyState(context);
    }

    // Filtrar experiências válidas (que têm restaurante associado)
    final experienciasValidas = experienciasList.where((exp) => 
      exp != null && 
      exp.restaurante != null && 
      exp.experiencia != null
    ).toList();
    
    if (experienciasValidas.isEmpty) {
      return _buildEmptyState(context);
    }

    // Converter para ExperienciaComRestaurante
    final experiencias = experienciasValidas.cast<ExperienciaComRestaurante>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header com estatísticas
        Container(
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
          child: Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.purple.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${experiencias.length} ${experiencias.length == 1 ? 'experiência registrada' : 'experiências registradas'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2c3985),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Suas avaliações e memórias',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildEmojiStats(experiencias),
            ],
          ),
        ),

        // Lista de experiências
        Expanded(
          child: SafeListViewBuilder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: experiencias.length,
            shrinkWrap: false,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final experienciaComRestaurante = experiencias[index];
              return _buildExperienciaCard(context, experienciaComRestaurante);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiStats(List<ExperienciaComRestaurante> experiencias) {
    final emojiCount = <String, int>{};
    
    for (final exp in experiencias) {
      final emoji = exp.experiencia?.emoji;
      if (emoji != null && emoji.isNotEmpty) {
        emojiCount[emoji] = (emojiCount[emoji] ?? 0) + 1;
      }
    }

    if (emojiCount.isEmpty) return const SizedBox();

    final mostUsedEmoji = emojiCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mostUsedEmoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 4),
          Text(
            'mais usado',
            style: TextStyle(
              fontSize: 12,
              color: Colors.purple.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienciaCard(BuildContext context, ExperienciaComRestaurante expComRest) {
    final experiencia = expComRest.experiencia;
    final restaurante = expComRest.restaurante;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      constraints: const BoxConstraints(
        minHeight: 120,
        maxHeight: 400,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header da experiência
            Row(
              children: [
                // Emoji da avaliação
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: Center(
                    child: Text(
                      experiencia.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Info do restaurante
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurante.nome,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2c3985),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        restaurante.tipo.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFee9d21),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Data da visita
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(experiencia.dataVisita),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Comentário
            if (experiencia.comentario != null && experiencia.comentario!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  maxHeight: 100,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFfbe9d2).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    experiencia.comentario!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Navegar para detalhes do restaurante
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Abrindo ${restaurante.nome}'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.restaurant, size: 16),
                    label: const Text('Ver Restaurante'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2c3985),
                      side: const BorderSide(color: Color(0xFF2c3985)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Botão para editar experiência
                ExperienciaButton(
                  restauranteId: restaurante.id,
                  restauranteNome: restaurante.nome,
                  size: 16,
                ),
                
                const SizedBox(width: 8),
                
                // Botão de deletar
                IconButton(
                  onPressed: () => _showDeleteDialog(context, experiencia.id, restaurante.nome),
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade400,
                    size: 20,
                  ),
                  tooltip: 'Excluir experiência',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String experienciaId, String restauranteNome) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir experiência'),
        content: Text(
          'Tem certeza que deseja excluir sua experiência em "$restauranteNome"? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteExperiencia(context, experienciaId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteExperiencia(BuildContext context, String experienciaId) async {
    try {
      await ExperienciaService.excluirExperiencia(experienciaId);
      
      if (context.mounted) {
        SnackBarUtils.showSuccess(context, 'Experiência excluída com sucesso!');
        
        // Refresh da lista
        ref.invalidate(experienciasUsuarioProvider);
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarUtils.showError(context, 'Erro ao excluir experiência: $e');
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'semana' : 'semanas'} atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.star_border,
                size: 60,
                color: Colors.purple.shade300,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhuma experiência ainda',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3985),
              ),
            ),
                                    const SizedBox(height: 12),
                        Text(
                          'Você ainda não registrou nenhuma experiência.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Visite restaurantes e compartilhe suas avaliações!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2c3985).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF2c3985).withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                color: Color(0xFF2c3985),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Clique no botão "+" para adicionar sua primeira experiência!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color(0xFF2c3985),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
            const SizedBox(height: 32),
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _mostrarSeletorRestaurante,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Registrar Primeira Experiência'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2c3985),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.explore),
                  label: const Text('Explorar Restaurantes'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2c3985),
                    side: const BorderSide(color: Color(0xFF2c3985)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF2c3985)),
          SizedBox(height: 16),
          Text(
            'Carregando suas experiências...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF2c3985),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar experiências',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3985),
              ),
            ),
            const SizedBox(height: 8),
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
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Voltar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2c3985),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}