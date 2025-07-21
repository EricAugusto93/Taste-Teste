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

  Future<void> _toggleFavorito(WidgetRef ref) async {
    final usuarioAtual = ref.read(usuarioAtualProvider);
    
    await usuarioAtual.when(
      data: (usuario) async {
        if (usuario == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Faça login para favoritar restaurantes'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        // Mostrar loading
        ref.read(loadingFavoritoProvider(restaurante.id).notifier).state = true;

        try {
          final novoStatus = await UsuarioService.toggleFavorito(usuario.id, restaurante.id);
          
          // Atualizar o estado local
          final favoritosAtuais = ref.read(favoritosProvider);
          if (novoStatus) {
            ref.read(favoritosProvider.notifier).state = {...favoritosAtuais, restaurante.id};
          } else {
            final novosFavoritos = Set<String>.from(favoritosAtuais);
            novosFavoritos.remove(restaurante.id);
            ref.read(favoritosProvider.notifier).state = novosFavoritos;
          }

          // Invalidar provider de restaurantes favoritos
          ref.invalidate(restaurantesFavoritosProvider);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                novoStatus 
                  ? '${restaurante.nome} adicionado aos favoritos!' 
                  : '${restaurante.nome} removido dos favoritos!',
              ),
              backgroundColor: novoStatus ? Colors.green : Colors.orange,
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
      loading: () => null,
      error: (error, stack) => null,
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com imagem, nome e botão favorito
              Row(
                children: [
                  // Imagem do restaurante
                  RestauranteImagem(
                    imagemUrl: restaurante.imagemUrl,
                    width: 80,
                    height: 80,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Informações do restaurante
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurante.nome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.deepOrange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                restaurante.tipo.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.deepOrange.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            DistanciaBadge(
                              restaurante: restaurante,
                              mostrarIcone: false,
                              tamanhoFonte: 12,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Botão favorito
                  isLoadingFavorito 
                    ? Container(
                        width: 48,
                        height: 48,
                        padding: const EdgeInsets.all(12),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                        ),
                      )
                    : IconButton(
                        onPressed: () => _toggleFavorito(ref),
                        icon: Icon(
                          isFavoritoAtual ? Icons.favorite : Icons.favorite_border,
                          color: isFavoritoAtual ? Colors.red : Colors.grey,
                          size: 24,
                        ),
                        tooltip: isFavoritoAtual ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
                      ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Descrição
              Text(
                restaurante.descricao,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Tags
              if (restaurante.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: restaurante.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
              
              // Botões de ação
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(
                        Icons.visibility,
                        size: 16,
                      ),
                      label: const Text('Ver Detalhes'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepOrange,
                        side: BorderSide(color: Colors.deepOrange.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _mostrarRegistrarExperiencia(context, ref),
                      icon: const Icon(
                        Icons.rate_review,
                        size: 16,
                      ),
                      label: const Text('Avaliar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 