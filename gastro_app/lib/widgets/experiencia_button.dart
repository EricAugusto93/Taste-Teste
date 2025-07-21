import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../services/experiencia_service.dart';
import '../utils/providers.dart';
import '../screens/auth_screen.dart';

class ExperienciaButton extends ConsumerStatefulWidget {
  final String restauranteId;
  final String restauranteNome;
  final double size;

  const ExperienciaButton({
    super.key,
    required this.restauranteId,
    required this.restauranteNome,
    this.size = 24,
  });

  @override
  ConsumerState<ExperienciaButton> createState() => _ExperienciaButtonState();
}

class _ExperienciaButtonState extends ConsumerState<ExperienciaButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final experienciaAsync = ref.watch(experienciaRestauranteProvider(widget.restauranteId));

    return experienciaAsync.when(
      data: (experiencia) => _buildButton(context, experiencia),
      loading: () => _buildLoadingButton(),
      error: (_, __) => _buildButton(context, null),
    );
  }

  Widget _buildButton(BuildContext context, dynamic experiencia) {
    final temExperiencia = experiencia != null;
    final emoji = temExperiencia ? experiencia['emoji'] as String : '';

    return Container(
      decoration: BoxDecoration(
        color: temExperiencia ? Colors.orange.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(widget.size / 2),
        border: Border.all(
          color: temExperiencia ? Colors.orange.shade300 : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.size / 2),
          onTap: isLoading ? null : _handleExperienciaPress,
          child: Container(
            width: widget.size,
            height: widget.size,
            child: Stack(
              children: [
                Center(
                  child: isLoading
                      ? SizedBox(
                          width: widget.size * 0.6,
                          height: widget.size * 0.6,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.orange,
                          ),
                        )
                      : temExperiencia
                          ? Text(
                              emoji,
                              style: TextStyle(fontSize: widget.size * 0.5),
                            )
                          : Icon(
                              Icons.rate_review_outlined,
                              size: widget.size * 0.6,
                              color: Colors.grey.shade600,
                            ),
                ),
                if (temExperiencia)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: widget.size * 0.25,
                      height: widget.size * 0.25,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(widget.size),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingButton() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(widget.size / 2),
      ),
      child: Center(
        child: SizedBox(
          width: widget.size * 0.6,
          height: widget.size * 0.6,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Future<void> _handleExperienciaPress() async {
    final isAuth = ref.read(isAuthenticatedProvider);
    
    if (!isAuth) {
      _showLoginModal();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final experienciaExistente = await _verificarExperienciaExistente();
      
      if (experienciaExistente != null) {
        await _showEditExperienciaModal(experienciaExistente);
      } else {
        await _showAddExperienciaModal();
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Erro ao carregar experiência: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<dynamic> _verificarExperienciaExistente() async {
    try {
      return await ExperienciaService.obterExperienciaRestaurante(widget.restauranteId);
    } catch (e) {
      return null;
    }
  }

  void _showLoginModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFFfbe9d2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Entre para avaliar ${widget.restauranteNome}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2c3985),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Expanded(
              child: AuthScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddExperienciaModal() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExperienciaModal(
        restauranteNome: widget.restauranteNome,
        isEditing: false,
      ),
    );

    if (result != null && mounted) {
      await _salvarNovaExperiencia(result);
    }
  }

  Future<void> _showEditExperienciaModal(dynamic experiencia) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExperienciaModal(
        restauranteNome: widget.restauranteNome,
        isEditing: true,
        experienciaExistente: experiencia,
      ),
    );

    if (result != null && mounted) {
      if (result['action'] == 'delete') {
        await _excluirExperiencia(experiencia['id']);
      } else {
        await _editarExperiencia(experiencia['id'], result);
      }
    }
  }

  Future<void> _salvarNovaExperiencia(Map<String, dynamic> dados) async {
    try {
      final authUser = AuthService.currentUser;
      if (authUser == null) throw Exception('Usuário não autenticado');

      await ExperienciaService.registrarExperiencia(
        userId: authUser.id,
        restauranteId: widget.restauranteId,
        emoji: dados['emoji'],
        comentario: dados['comentario'],
      );

      // Atualizar estatísticas em tempo real
      final atualizarEstatisticas = ref.read(atualizarEstatisticasProvider);
      await atualizarEstatisticas(widget.restauranteId, dados['emoji'], dados['comentario']);

      // Invalidar providers para atualizar UI
      ref.invalidate(experienciaRestauranteProvider(widget.restauranteId));
      ref.invalidate(experienciasUsuarioProvider);

      _showSuccessMessage('Experiência registrada com sucesso!');
    } catch (e) {
      _showErrorMessage('Erro ao registrar experiência: $e');
    }
  }

  Future<void> _editarExperiencia(String experienciaId, Map<String, dynamic> dados) async {
    try {
      await ExperienciaService.atualizarExperiencia(
        experienciaId,
        emoji: dados['emoji'],
        comentario: dados['comentario'],
      );

      // Atualizar estatísticas em tempo real
      final atualizarEstatisticas = ref.read(atualizarEstatisticasProvider);
      await atualizarEstatisticas(widget.restauranteId, dados['emoji'], dados['comentario']);

      // Invalidar providers para atualizar UI
      ref.invalidate(experienciaRestauranteProvider(widget.restauranteId));
      ref.invalidate(experienciasUsuarioProvider);

      _showSuccessMessage('Experiência atualizada com sucesso!');
    } catch (e) {
      _showErrorMessage('Erro ao atualizar experiência: $e');
    }
  }

  Future<void> _excluirExperiencia(String experienciaId) async {
    try {
      await ExperienciaService.excluirExperiencia(experienciaId);

      // Invalidar cache de estatísticas
      final invalidarEstatisticas = ref.read(invalidarEstatisticasProvider);
      invalidarEstatisticas(widget.restauranteId);

      // Invalidar providers para atualizar UI
      ref.invalidate(experienciaRestauranteProvider(widget.restauranteId));
      ref.invalidate(experienciasUsuarioProvider);

      _showSuccessMessage('Experiência removida com sucesso!');
    } catch (e) {
      _showErrorMessage('Erro ao remover experiência: $e');
    }
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ExperienciaModal extends StatefulWidget {
  final String restauranteNome;
  final bool isEditing;
  final dynamic experienciaExistente;

  const _ExperienciaModal({
    required this.restauranteNome,
    required this.isEditing,
    this.experienciaExistente,
  });

  @override
  State<_ExperienciaModal> createState() => _ExperienciaModalState();
}

class _ExperienciaModalState extends State<_ExperienciaModal> {
  final TextEditingController _comentarioController = TextEditingController();
  String _emojiSelecionado = '';
  bool isLoading = false;

  final List<String> _emojisDisponiveis = ['😋', '❤️', '😐', '🤢'];
  final Map<String, String> _emojiDescricoes = {
    '😋': 'Delicioso',
    '❤️': 'Amei',
    '😐': 'Ok',
    '🤢': 'Não gostei',
  };

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.experienciaExistente != null) {
      _emojiSelecionado = widget.experienciaExistente['emoji'] ?? '';
      _comentarioController.text = widget.experienciaExistente['comentario'] ?? '';
    }
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    widget.isEditing ? 'Editar Experiência' : 'Como foi sua experiência?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2c3985),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.restauranteNome,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Seleção de emoji
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Como você avalia?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2c3985),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _emojisDisponiveis.map((emoji) {
                      final isSelected = _emojiSelecionado == emoji;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _emojiSelecionado = emoji;
                          });
                        },
                        child: Container(
                          width: 60,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2c3985).withOpacity(0.1) : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF2c3985) : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _emojiDescricoes[emoji] ?? '',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? const Color(0xFF2c3985) : Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Campo de comentário
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Comentário (opcional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2c3985),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _comentarioController,
                    maxLines: 3,
                    maxLength: 200,
                    decoration: const InputDecoration(
                      hintText: 'Conte como foi sua experiência...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botões
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (widget.isEditing) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isLoading ? null : () {
                          Navigator.of(context).pop({'action': 'delete'});
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          'Excluir',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _salvarExperiencia,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2c3985),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(widget.isEditing ? 'Salvar Alterações' : 'Registrar Experiência'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _salvarExperiencia() async {
    if (_emojiSelecionado.isEmpty) {
      _showErrorMessage('Selecione como você avalia este restaurante');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final resultado = {
        'emoji': _emojiSelecionado,
        'comentario': _comentarioController.text.trim(),
      };

      Navigator.of(context).pop(resultado);
    } catch (e) {
      _showErrorMessage('Erro ao salvar experiência: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
} 