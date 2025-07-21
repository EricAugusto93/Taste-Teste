import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/restaurante.dart';
import '../utils/providers.dart';
import '../services/localizacao_service.dart';
import 'favorite_button.dart';
import 'experiencia_button.dart';
import 'avaliacao_badge.dart';

class RestauranteProximidadeCard extends ConsumerWidget {
  final RestauranteComDistancia restauranteComDistancia;

  const RestauranteProximidadeCard({
    super.key,
    required this.restauranteComDistancia,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurante = restauranteComDistancia.restaurante;
    final distancia = restauranteComDistancia.distancia;
    final distanciaInfo = restauranteComDistancia.distanciaInfo;

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Navegar para detalhes do restaurante
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Abrindo detalhes de ${restaurante.nome}'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem com badge de distância
              _buildImageWithBadge(restaurante, distancia, distanciaInfo),
              
              // Conteúdo do card
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome e avaliação
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            restaurante.nome,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2c3985),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Badge de avaliação agregada
                        AvaliacaoBadge(
                          restauranteId: restaurante.id,
                          isCompact: true,
                          fontSize: 12,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Tipo e distância
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFfbe9d2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF2c3985).withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            restaurante.tipo,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2c3985),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: distanciaInfo.cor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getTempoEstimado(distancia),
                          style: TextStyle(
                            fontSize: 12,
                            color: distanciaInfo.cor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Descrição
                    Text(
                      restaurante.descricao,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Avaliação detalhada se houver
                    AvaliacaoBadge(
                      restauranteId: restaurante.id,
                      isCompact: false,
                      fontSize: 14,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Tags se houver
                    if (restaurante.tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: restaurante.tags.take(3).map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2c3985).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2c3985),
                            ),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Botões de ação
                    Row(
                      children: [
                        // Informação de proximidade
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: distanciaInfo.cor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: distanciaInfo.cor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  distanciaInfo.icone,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  restauranteComDistancia.distanciaFormatada,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: distanciaInfo.cor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'de você',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: distanciaInfo.cor.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Botão favoritar
                        FavoriteButton(
                          restauranteId: restaurante.id,
                          size: 20,
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // Botão experiência
                        ExperienciaButton(
                          restauranteId: restaurante.id,
                          restauranteNome: restaurante.nome,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageWithBadge(
    Restaurante restaurante,
    double distancia,
    DistanciaInfo distanciaInfo,
  ) {
    return Stack(
      children: [
        // Imagem do restaurante
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2c3985).withOpacity(0.8),
                  const Color(0xFFee9d21).withOpacity(0.6),
                ],
              ),
            ),
            child: restaurante.imagemUrl != null && restaurante.imagemUrl!.isNotEmpty
                ? Stack(
                    children: [
                      Image.network(
                        restaurante.imagemUrl!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                      ),
                      // Overlay gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : _buildImagePlaceholder(),
          ),
        ),
        
        // Badge de distância (canto superior direito)
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: distanciaInfo.cor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  distanciaInfo.icone,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 4),
                Text(
                  LocalizacaoService.formatarDistancia(distancia),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Badge de avaliação (canto superior esquerdo)
        Positioned(
          top: 12,
          left: 12,
          child: AvaliacaoBadgeSimples(restauranteId: restaurante.id),
        ),
        
        // Badge de status (abaixo do badge de avaliação se fechado) 
        if (!restaurante.isAberto) 
          Positioned(
            top: 32,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'Fechado',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2c3985).withOpacity(0.8),
            const Color(0xFFee9d21).withOpacity(0.6),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }

  String _getTempoEstimado(double distanciaKm) {
    // Estimativa baseada em caminhada (5 km/h)
    final minutosCaminhada = (distanciaKm / 5 * 60).round();
    
    if (minutosCaminhada <= 5) {
      return '${minutosCaminhada}min a pé';
    } else if (minutosCaminhada <= 15) {
      return '${minutosCaminhada}min caminhando';
    } else if (distanciaKm <= 3) {
      final minutosBike = (distanciaKm / 15 * 60).round();
      return '${minutosBike}min de bike';
    } else {
      final minutosCarro = (distanciaKm / 30 * 60).round();
      return '${minutosCarro}min de carro';
    }
  }
} 