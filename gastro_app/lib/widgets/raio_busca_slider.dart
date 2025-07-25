import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../utils/providers.dart';

class RaioBuscaSlider extends ConsumerStatefulWidget {
  const RaioBuscaSlider({super.key});

  @override
  ConsumerState<RaioBuscaSlider> createState() => _RaioBuscaSliderState();
}

class _RaioBuscaSliderState extends ConsumerState<RaioBuscaSlider> {
  Timer? _debounceTimer;
  double? _tempValue;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _updateRaio(double value) {
    setState(() {
      _tempValue = value;
    });
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(raioBuscaProvider.notifier).state = value;
      setState(() {
        _tempValue = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final raioAtual = ref.watch(raioBuscaProvider);
    final displayValue = _tempValue ?? raioAtual;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header
          Row(
            children: [
              const Icon(
                Icons.radio_button_checked,
                color: Color(0xFF2c3985),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Raio de busca',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3985),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2c3985),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${displayValue.toStringAsFixed(0)} km',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF2c3985),
              inactiveTrackColor: const Color(0xFF2c3985).withOpacity(0.2),
              thumbColor: const Color(0xFF2c3985),
              overlayColor: const Color(0xFF2c3985).withOpacity(0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              trackHeight: 6,
            ),
            child: Slider(
              value: displayValue,
              min: 1.0,
              max: 10.0,
              divisions: 9,
              onChanged: _updateRaio,
            ),
          ),
          
          // Labels de distância
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1km',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '5km',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '10km',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Descrição do raio selecionado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFfbe9d2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF2c3985).withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getRaioIcon(displayValue),
                  color: const Color(0xFF2c3985),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getRaioDescricao(displayValue),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2c3985),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRaioIcon(double raio) {
    if (raio <= 2) {
      return Icons.directions_walk;
    } else if (raio <= 5) {
      return Icons.directions_bike;
    } else {
      return Icons.directions_car;
    }
  }

  String _getRaioDescricao(double raio) {
    if (raio <= 2) {
      return 'Distância a pé - restaurantes bem próximos';
    } else if (raio <= 5) {
      return 'Distância de bicicleta ou transporte rápido';
    } else {
      return 'Distância maior - carro ou transporte público';
    }
  }
}