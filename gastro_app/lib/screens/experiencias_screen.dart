import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/providers.dart';
import '../widgets/experiencia_button.dart';
import '../services/experiencia_service.dart';
import '../utils/snackbar_utils.dart';

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
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    // Iniciar animações
    _fadeController.forward();
    _slideController.forward();
  }

  void _refreshExperiencias() {
    ref.invalidate(experienciasUsuarioProvider);
    
    // Mostrar feedback visual usando o utilitário global
    SnackBarUtils.showSuccess(context, 'Experiências atualizadas!');
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
    );
  }

  Widget _buildContent(BuildContext context, List<dynamic> experienciasList) {
    if (experienciasList.isEmpty) {
      return _buildEmptyState(context);
    }

    // Se são ExperienciaComRestaurante, usamos como tal
    final experiencias = experienciasList.cast<ExperienciaComRestaurante>();

    return Column(
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
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: experiencias.length,
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
      final emoji = exp.experiencia.emoji;
      emojiCount[emoji] = (emojiCount[emoji] ?? 0) + 1;
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFfbe9d2).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  experiencia.comentario!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Experiência excluída com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh da lista
        final container = ProviderScope.containerOf(context);
        container.invalidate(experienciasUsuarioProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir experiência: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
              'Você ainda não registrou nenhuma experiência.\n\nVisite restaurantes e compartilhe suas avaliações!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.explore),
              label: const Text('Explorar Restaurantes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2c3985),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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