import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/restaurante.dart';
import '../services/usuario_service.dart';
import '../utils/providers.dart';
import 'restaurante_imagem.dart';
import 'distancia_badge.dart';
import 'registrar_experiencia.dart';

class RestauranteCard extends ConsumerWidget {
  final Restaurante restaurante;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool? isFavorito; // Opcional, será obtido do provider se não fornecido

  const RestauranteCard({
    super.key,
    required this.restaurante,
    this.onTap,
    this.onFavorite,
    this.isFavorito,
  });

  Future<void> _toggleFavorito(BuildContext context, WidgetRef ref) async {
    // Verificar se usuário está autenticado primeiro
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faça login para favoritar restaurantes'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Obter dados do usuário atual
    final usuarioAtualAsync = ref.read(usuarioAtualProvider);
    
    await usuarioAtualAsync.when(
      data: (usuario) async {
        if (usuario == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao obter dados do usuário'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Mostrar loading
        ref.read(loadingFavoritoProvider(restaurante.id).notifier).state = true;

        try {
          // Usar apenas o favoritosActions para evitar duplicação
          final favoritosActions = ref.read(favoritosActionsProvider);
          await favoritosActions.toggleFavorito(restaurante.id);
          
          // Verificar o novo status
          final isFavoritoAgora = ref.read(isFavoritoProvider(restaurante.id));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isFavoritoAgora 
                  ? '${restaurante.nome} adicionado aos favoritos!' 
                  : '${restaurante.nome} removido dos favoritos!',
              ),
              backgroundColor: isFavoritoAgora ? Colors.green : Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );

          onFavorite?.call();

        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar favorito: $e'),
              backgroundColor: Colors.red,
            ),
          );
        } finally {
          ref.read(loadingFavoritoProvider(restaurante.id).notifier).state = false;
        }
      },
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Carregando dados do usuário...'),
            backgroundColor: Colors.blue,
          ),
        );
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar usuário: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  void _mostrarRegistrarExperiencia(BuildContext context, WidgetRef ref) {
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Experiência registrada com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obter status de favorito do provider ou usar o valor fornecido
    final isFavoritoAtual = isFavorito ?? ref.watch(isFavoritoProvider(restaurante.id));
    final isLoadingFavorito = ref.watch(loadingFavoritoProvider(restaurante.id));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do restaurante
            Stack(
              children: [
                RestauranteImagem(
                  imagemUrl: restaurante.imagemUrl,
                  width: double.infinity,
                  height: 180,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                
                // Botão de favorito
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: isLoadingFavorito
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : IconButton(
                            onPressed: () => _toggleFavorito(context, ref),
                            icon: Icon(
                              (isFavoritoAtual ?? false) ? Icons.favorite : Icons.favorite_border,
                              color: (isFavoritoAtual ?? false) ? Colors.red : Colors.grey,
                            ),
                            tooltip: (isFavoritoAtual ?? false) ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
                          ),
                  ),
                ),
                
                // Badge de distância
                Positioned(
                  top: 12,
                  left: 12,
                  child: DistanciaBadge(restaurante: restaurante),
                ),
              ],
            ),
            
            // Informações do restaurante
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome e tipo
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurante.nome,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              restaurante.tipo,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Botão de registrar experiência
                      IconButton(
                        onPressed: () => _mostrarRegistrarExperiencia(context, ref),
                        icon: Icon(
                          Icons.rate_review,
                          color: Colors.orange.shade600,
                        ),
                        tooltip: 'Registrar experiência',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Descrição
                  if (restaurante.descricao.isNotEmpty)
                    Text(
                      restaurante.descricao,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const SizedBox(height: 12),
                  
                  // Tags
                  if (restaurante.tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: restaurante.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.shade200,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}