import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/experiencia.dart';
import '../services/experiencia_service.dart';
import '../config/app_theme.dart';
import '../utils/providers.dart';

class EmojiSelector extends ConsumerStatefulWidget {
  final String restauranteId;
  final Experiencia? experienciaExistente;
  final VoidCallback? onRated;

  const EmojiSelector({
    super.key,
    required this.restauranteId,
    this.experienciaExistente,
    this.onRated,
  });

  @override
  ConsumerState<EmojiSelector> createState() => _EmojiSelectorState();
}

class _EmojiSelectorState extends ConsumerState<EmojiSelector>
    with TickerProviderStateMixin {
  final TextEditingController _comentarioController = TextEditingController();
  EmojiAvaliacao? _emojiSelecionado;
  bool _salvando = false;
  
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _inicializarDados();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }

  void _inicializarDados() {
    if (widget.experienciaExistente != null) {
      final experiencia = widget.experienciaExistente!;
      _comentarioController.text = experiencia.comentario;
      _emojiSelecionado = EmojiAvaliacao.fromEmoji(experiencia.emoji);
    }
  }

  Future<void> _salvarExperiencia() async {
    if (_emojiSelecionado == null) {
      _showSnackBar('Por favor, selecione uma avaliação', AppTheme.customColors['warning']!);
      return;
    }

    final usuarioAtual = ref.read(usuarioAtualProvider);
    
    await usuarioAtual.when(
      data: (usuario) async {
        if (usuario == null) {
          _showSnackBar('Usuário não autenticado', AppTheme.customColors['warning']!);
          return;
        }

        setState(() {
          _salvando = true;
        });

        try {
          if (widget.experienciaExistente != null) {
            await ExperienciaService.atualizarExperiencia(
              widget.experienciaExistente!.id,
              emoji: _emojiSelecionado!.emoji,
              comentario: _comentarioController.text.trim(),
            );
          } else {
            await ExperienciaService.registrarExperiencia(
              userId: usuario.id,
              restauranteId: widget.restauranteId,
              emoji: _emojiSelecionado!.emoji,
              comentario: _comentarioController.text.trim(),
            );
          }

          // Invalidar providers para atualizar a UI
          ref.invalidate(experienciasUsuarioProvider);
          ref.invalidate(experienciaRestauranteProvider(widget.restauranteId));
          ref.invalidate(estatisticasRestauranteProvider(widget.restauranteId));
          ref.invalidate(experienciasRecentesProvider);

          _showSnackBar(
            widget.experienciaExistente != null 
              ? 'Experiência atualizada com sucesso!' 
              : 'Obrigado por compartilhar sua experiência!',
            AppTheme.customColors['success']!,
          );

          widget.onRated?.call();
          await _fecharModal();

        } catch (e) {
          _showSnackBar('Erro ao salvar experiência', Colors.red);
        } finally {
          if (mounted) {
            setState(() {
              _salvando = false;
            });
          }
        }
      },
      loading: () => null,
      error: (error, stack) => null,
    );
  }

  Future<void> _fecharModal() async {
    await _slideController.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedio),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _fecharModal,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: SlideTransition(
          position: _slideAnimation,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                margin: const EdgeInsets.all(AppTheme.espacoMedio),
                decoration: BoxDecoration(
                  color: AppTheme.brancoQuente,
                  borderRadius: BorderRadius.circular(AppTheme.radiusExtraGrande),
                  boxShadow: AppTheme.sombraElevada,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.espacoGrande),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: AppTheme.espacoGrande),
                        _buildEmojiSelection(),
                        const SizedBox(height: AppTheme.espacoGrande),
                        _buildCommentField(),
                        const SizedBox(height: AppTheme.espacoGrande),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.gradientPrimario,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.rate_review,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.espacoMedio),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.experienciaExistente != null 
                    ? 'Editar Experiência' 
                    : 'Como foi sua visita?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.cinzaEscuro,
                  ),
                ),
                Text(
                  'Compartilhe sua experiência gastronômica',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.cinzaMedio,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _fecharModal,
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.cinzaClaro,
              foregroundColor: AppTheme.cinzaMedio,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiSelection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sua avaliação',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.cinzaEscuro,
            ),
          ),
          const SizedBox(height: AppTheme.espacoMedio),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: EmojiAvaliacao.values.map((avaliacao) {
              return _buildEmojiOption(avaliacao);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiOption(EmojiAvaliacao avaliacao) {
    final selecionado = _emojiSelecionado == avaliacao;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _emojiSelecionado = avaliacao;
        });
        
        // Animação de feedback
        _scaleController.forward().then((_) {
          _scaleController.reverse();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: selecionado ? AppTheme.gradientPrimario : null,
          color: selecionado ? null : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusGrande),
          border: Border.all(
            color: selecionado 
              ? AppTheme.mostardaEscura 
              : AppTheme.cinzaMedio.withOpacity(0.3),
            width: selecionado ? 2 : 1,
          ),
          boxShadow: selecionado 
            ? [
                BoxShadow(
                  color: AppTheme.mostarda.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
        ),
        child: Column(
          children: [
            AnimatedScale(
              scale: selecionado ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              child: Text(
                avaliacao.emoji,
                style: const TextStyle(fontSize: 36),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              avaliacao.descricao,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selecionado 
                  ? Colors.white 
                  : AppTheme.cinzaMedio,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentField() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comentário (opcional)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.cinzaEscuro,
            ),
          ),
          const SizedBox(height: AppTheme.espacoMedio),
          TextField(
            controller: _comentarioController,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'Conte-nos mais sobre sua experiência gastronômica...',
              hintStyle: TextStyle(
                color: AppTheme.cinzaMedio,
                fontSize: 14,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.chat_bubble_outline,
                  color: AppTheme.mostarda,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _salvando ? null : _fecharModal,
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: AppTheme.espacoMedio),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _salvando ? null : _salvarExperiencia,
              child: _salvando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.experienciaExistente != null 
                          ? Icons.update 
                          : Icons.send,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.experienciaExistente != null 
                          ? 'Atualizar' 
                          : 'Compartilhar',
                      ),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }
} 