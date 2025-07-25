import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../models/restaurante.dart';
import '../services/localizacao_service.dart';
import '../utils/providers.dart';

// Provider para memoizar o cálculo de distância
final distanciaRestauranteProvider = Provider.family<double?, Map<String, dynamic>>((ref, params) {
  final localizacao = ref.watch(localizacaoAtualProvider);
  final statusLocalizacao = ref.watch(statusLocalizacaoProvider);
  
  // Só calcular se temos localização válida
  if (localizacao == null || 
      (statusLocalizacao != StatusLocalizacao.obtida && 
       statusLocalizacao != StatusLocalizacao.fallback)) {
    return null;
  }
  
  final latitude = params['latitude'] as double;
  final longitude = params['longitude'] as double;
  
  return LocalizacaoService.calcularDistancia(
    localizacao['latitude']!,
    localizacao['longitude']!,
    latitude,
    longitude,
  );
});

class DistanciaBadge extends ConsumerWidget {
  final Restaurante restaurante;
  final bool mostrarIcone;
  final double? tamanhoFonte;

  const DistanciaBadge({
    super.key,
    required this.restaurante,
    this.mostrarIcone = true,
    this.tamanhoFonte,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distancia = ref.watch(distanciaRestauranteProvider({
      'id': restaurante.id,
      'latitude': restaurante.latitude,
      'longitude': restaurante.longitude,
    }));

    // Se não tem distância calculada, não exibir
    if (distancia == null) {
      return const SizedBox.shrink();
    }

    final distanciaFormatada = LocalizacaoService.formatarDistancia(distancia);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getCorDistancia(distancia),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mostrarIcone) ...[
            Icon(
              Icons.location_on,
              size: (tamanhoFonte ?? 12) + 2,
              color: Colors.white,
            ),
            const SizedBox(width: 2),
          ],
          Text(
            distanciaFormatada,
            style: TextStyle(
              fontSize: tamanhoFonte ?? 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCorDistancia(double distanciaKm) {
    if (distanciaKm <= 0.5) {
      return Colors.green.shade600; // Muito próximo
    } else if (distanciaKm <= 2.0) {
      return Colors.orange.shade600; // Próximo
    } else if (distanciaKm <= 5.0) {
      return Colors.deepOrange.shade600; // Médio
    } else {
      return Colors.red.shade600; // Longe
    }
  }
}