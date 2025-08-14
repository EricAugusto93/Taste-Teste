import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/restaurante.dart';
import '../models/experiencia.dart';
import '../services/experiencia_service.dart';
import '../utils/providers.dart';

class RegistrarExperiencia extends ConsumerStatefulWidget {
  final Restaurante restaurante;
  final Experiencia? experienciaExistente;
  final VoidCallback? onSalvar;

  const RegistrarExperiencia({
    super.key,
    required this.restaurante,
    this.experienciaExistente,
    this.onSalvar,
  });

  @override
  ConsumerState<RegistrarExperiencia> createState() => _RegistrarExperienciaState();
}

class _RegistrarExperienciaState extends ConsumerState<RegistrarExperiencia> {
  late final TextEditingController _comentarioController;
  EmojiAvaliacao? _emojiSelecionado;
  bool _salvando = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _comentarioController = TextEditingController();
    
    // Inicializar com dados existentes se houver
    if (widget.experienciaExistente != null) {
      _comentarioController.text = widget.experienciaExistente!.comentario ?? '';
      _emojiSelecionado = EmojiAvaliacao.fromEmoji(widget.experienciaExistente!.emoji);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _comentarioController.dispose();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (!_disposed && mounted) {
      setState(fn);
    }
  }

  void _inicializarDados() {
    if (widget.experienciaExistente != null) {
      final experiencia = widget.experienciaExistente!;
      _comentarioController.text = experiencia.comentario ?? '';
      _emojiSelecionado = EmojiAvaliacao.fromEmoji(experiencia.emoji);
    }
  }

  Future<void> _salvarExperiencia() async {
    // Prevenir execução múltipla
    if (_salvando) {
      debugPrint('⚠️ Salvamento já em andamento, ignorando...');
      return;
    }

    debugPrint('🔄 Iniciando _salvarExperiencia...');
    
    if (_emojiSelecionado == null) {
      debugPrint('❌ Nenhum emoji selecionado');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma avaliação'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    debugPrint('✅ Emoji selecionado: ${_emojiSelecionado!.emoji}');

    // Verificar se usuário está autenticado primeiro
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    debugPrint('🔐 isAuthenticated: $isAuthenticated');
    
    if (!isAuthenticated) {
      debugPrint('❌ Usuário não autenticado');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário não autenticado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Obter usuário de forma síncrona
    final usuarioAtualAsync = ref.read(usuarioAtualProvider);
    final usuario = usuarioAtualAsync.value;
    
    debugPrint('👤 Obtendo usuário atual...');
    
    if (usuario == null) {
      debugPrint('❌ Usuário não carregado ou é null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao obter dados do usuário'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    debugPrint('📊 Dados do usuário: ${usuario.email}');
    debugPrint('🔄 Iniciando salvamento...');
    
    _safeSetState(() {
      _salvando = true;
    });

    try {
      if (widget.experienciaExistente != null) {
        // Atualizar experiência existente
        await ExperienciaService.atualizarExperiencia(
          widget.experienciaExistente!.id,
          emoji: _emojiSelecionado!.emoji,
          comentario: _comentarioController.text.trim(),
        );
      } else {
        // Criar nova experiência
        await ExperienciaService.registrarExperiencia(
          userId: usuario.id,
          restauranteId: widget.restaurante.id,
          emoji: _emojiSelecionado!.emoji,
          comentario: _comentarioController.text.trim(),
        );
      }

      // Invalidar providers para atualizar a UI
      ref.invalidate(experienciasUsuarioProvider);
      ref.invalidate(experienciaRestauranteProvider(widget.restaurante.id));
      ref.invalidate(estatisticasRestauranteProvider(widget.restaurante.id));
      ref.invalidate(experienciasRecentesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.experienciaExistente != null 
                ? 'Experiência atualizada com sucesso!' 
                : 'Obrigado por compartilhar sua experiência!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        widget.onSalvar?.call();
        Navigator.of(context).pop();
      }

    } catch (e) {
      debugPrint('❌ Erro ao salvar experiência: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar experiência: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        _safeSetState(() {
          _salvando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.rate_review,
                color: Colors.deepOrange.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.experienciaExistente != null 
                        ? 'Editar Experiência' 
                        : 'Registrar Visita',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      widget.restaurante.nome,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Seleção de emoji
          const Text(
            'Como foi sua experiência?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: EmojiAvaliacao.values.map((avaliacao) {
              final selecionado = _emojiSelecionado == avaliacao;
              return GestureDetector(
                onTap: () {
                  _safeSetState(() {
                    _emojiSelecionado = avaliacao;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selecionado 
                      ? Colors.deepOrange.shade50 
                      : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selecionado 
                        ? Colors.deepOrange 
                        : Colors.grey.shade300,
                      width: selecionado ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        avaliacao.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        avaliacao.descricao,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: selecionado 
                            ? Colors.deepOrange.shade700 
                            : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Campo de comentário
          const Text(
            'Comentário (opcional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _comentarioController,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'Conte-nos mais sobre sua experiência...',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.deepOrange),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),

          const SizedBox(height: 24),

          // Botões de ação
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _salvando ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _salvando ? null : _salvarExperiencia,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.experienciaExistente != null 
                          ? 'Atualizar' 
                          : 'Salvar Experiência',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                ),
              ),
            ],
          ),

          // Espaçamento para o teclado
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}