import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt; // Package not available
import 'package:permission_handler/permission_handler.dart';
import '../../utils/navigation_helper.dart';

/// Serviço para busca por voz
class VoiceSearchService {
  static VoiceSearchService? _instance;
  static VoiceSearchService get instance => _instance ??= VoiceSearchService._();
  
  VoiceSearchService._();
  
  // final stt.SpeechToText _speech = stt.SpeechToText(); // Package not available
  final _MockSpeechToText _speech = _MockSpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  
  StreamController<String>? _resultController;
  StreamController<bool>? _listeningController;
  StreamController<double>? _confidenceController;
  
  /// Stream de resultados da busca por voz
  Stream<String> get resultStream {
    _resultController ??= StreamController<String>.broadcast();
    return _resultController!.stream;
  }
  
  /// Stream do status de escuta
  Stream<bool> get listeningStream {
    _listeningController ??= StreamController<bool>.broadcast();
    return _listeningController!.stream;
  }
  
  /// Stream da confiança do reconhecimento
  Stream<double> get confidenceStream {
    _confidenceController ??= StreamController<double>.broadcast();
    return _confidenceController!.stream;
  }
  
  /// Verifica se está escutando
  bool get isListening => _isListening;
  
  /// Verifica se está inicializado
  bool get isInitialized => _isInitialized;
  
  /// Inicializa o serviço de voz
  Future<bool> initialize() async {
    try {
      // Verifica permissão de microfone
      final permission = await Permission.microphone.request();
      if (!permission.isGranted) {
        debugPrint('Microphone permission denied');
        return false;
      }
      
      // Inicializa o speech to text
      _isInitialized = await _speech.initialize(
        onError: _onError,
        onStatus: _onStatus,
        debugLogging: true,
      );
      
      if (_isInitialized) {
        debugPrint('VoiceSearchService initialized successfully');
      } else {
        debugPrint('Failed to initialize VoiceSearchService');
      }
      
      return _isInitialized;
    } catch (e) {
      debugPrint('Error initializing VoiceSearchService: $e');
      return false;
    }
  }
  
  /// Inicia a escuta
  Future<bool> startListening({
    String localeId = 'pt_BR',
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }
    
    if (_isListening) {
      debugPrint('Already listening');
      return false;
    }
    
    try {
      await _speech.listen(
        onResult: _onResult,
        localeId: localeId,
        listenFor: timeout,
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        // listenMode: stt.ListenMode.confirmation, // Package not available
      );
      
      _isListening = true;
      _listeningController?.add(true);
      
      debugPrint('Started voice listening');
      return true;
    } catch (e) {
      debugPrint('Error starting voice listening: $e');
      return false;
    }
  }
  
  /// Para a escuta
  Future<void> stopListening() async {
    if (!_isListening) return;
    
    try {
      await _speech.stop();
      _isListening = false;
      _listeningController?.add(false);
      
      debugPrint('Stopped voice listening');
    } catch (e) {
      debugPrint('Error stopping voice listening: $e');
    }
  }
  
  /// Cancela a escuta
  Future<void> cancelListening() async {
    if (!_isListening) return;
    
    try {
      await _speech.cancel();
      _isListening = false;
      _listeningController?.add(false);
      
      debugPrint('Cancelled voice listening');
    } catch (e) {
      debugPrint('Error cancelling voice listening: $e');
    }
  }
  
  /// Verifica se o dispositivo suporta reconhecimento de voz
  Future<bool> isAvailable() async {
    try {
      return await _speech.hasPermission;
    } catch (e) {
      debugPrint('Error checking voice availability: $e');
      return false;
    }
  }
  
  /// Obtém idiomas disponíveis
  Future<List<dynamic>> getAvailableLocales() async { // stt.LocaleName not available
    try {
      if (!_isInitialized) {
        await initialize();
      }
      return await _speech.locales();
    } catch (e) {
      debugPrint('Error getting available locales: $e');
      return [];
    }
  }
  
  /// Callback para resultados
  void _onResult(dynamic result) { // stt.SpeechRecognitionResult not available
    final text = result.recognizedWords;
    final confidence = result.confidence;
    
    debugPrint('Voice result: $text (confidence: $confidence)');
    
    if (text.isNotEmpty) {
      _resultController?.add(text);
      _confidenceController?.add(confidence);
    }
    
    // Se o resultado é final, para a escuta
    if (result.finalResult) {
      _isListening = false;
      _listeningController?.add(false);
    }
  }
  
  /// Callback para erros
  void _onError(dynamic error) { // stt.SpeechRecognitionError not available
    debugPrint('Voice recognition error: ${error.errorMsg}');
    
    _isListening = false;
    _listeningController?.add(false);
    
    // Adiciona mensagem de erro como resultado
    _resultController?.add('');
  }
  
  /// Callback para mudanças de status
  void _onStatus(String status) {
    debugPrint('Voice recognition status: $status');
    
    switch (status) {
      case 'listening':
        _isListening = true;
        _listeningController?.add(true);
        break;
      case 'notListening':
      case 'done':
        _isListening = false;
        _listeningController?.add(false);
        break;
    }
  }
  
  /// Limpa recursos
  void dispose() {
    _resultController?.close();
    _listeningController?.close();
    _confidenceController?.close();
    
    _resultController = null;
    _listeningController = null;
    _confidenceController = null;
  }
}

/// Mock implementation for SpeechToText since package is not available
class _MockSpeechToText {
  Future<bool> initialize({
    Function(String)? onError,
    Function(String)? onStatus,
    bool debugLogging = false,
  }) async {
    onStatus?.call('ready');
    return true;
  }
  
  Future<void> listen({
    Function(dynamic)? onResult,
    String localeId = 'pt_BR',
    Duration? listenFor,
    Duration? pauseFor,
    bool partialResults = true,
    bool cancelOnError = true,
  }) async {
    // Mock implementation - simulates voice recognition
    await Future.delayed(const Duration(milliseconds: 500));
    onResult?.call(_MockSpeechResult('busca por voz não disponível', 0.9));
  }
  
  Future<void> stop() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  Future<void> cancel() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  Future<bool> get hasPermission async => true;
  
  Future<List<dynamic>> locales() async => [];
}

/// Mock result for speech recognition
class _MockSpeechResult {
  final String recognizedWords;
  final double confidence;
  
  _MockSpeechResult(this.recognizedWords, this.confidence);
}

/// Widget para botão de busca por voz
class VoiceSearchButton extends StatefulWidget {
  final Function(String)? onResult;
  final VoidCallback? onStart;
  final VoidCallback? onStop;
  final Color? color;
  final double? size;
  final bool enabled;
  
  const VoiceSearchButton({
    super.key,
    this.onResult,
    this.onStart,
    this.onStop,
    this.color,
    this.size,
    this.enabled = true,
  });
  
  @override
  State<VoiceSearchButton> createState() => _VoiceSearchButtonState();
}

class _VoiceSearchButtonState extends State<VoiceSearchButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  
  StreamSubscription<String>? _resultSubscription;
  StreamSubscription<bool>? _listeningSubscription;
  
  bool _isListening = false;
  bool _isAvailable = false;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _checkAvailability();
    _setupListeners();
  }
  
  void _checkAvailability() async {
    final available = await VoiceSearchService.instance.isAvailable();
    if (mounted) {
      setState(() {
        _isAvailable = available;
      });
    }
  }
  
  void _setupListeners() {
    _resultSubscription = VoiceSearchService.instance.resultStream.listen(
      (result) {
        if (result.isNotEmpty) {
          widget.onResult?.call(result);
        }
      },
    );
    
    _listeningSubscription = VoiceSearchService.instance.listeningStream.listen(
      (listening) {
        if (mounted) {
          setState(() {
            _isListening = listening;
          });
          
          if (listening) {
            _animationController.repeat(reverse: true);
            widget.onStart?.call();
          } else {
            _animationController.stop();
            _animationController.reset();
            widget.onStop?.call();
          }
        }
      },
    );
  }
  
  void _toggleListening() async {
    if (!_isAvailable || !widget.enabled) return;
    
    if (_isListening) {
      await VoiceSearchService.instance.stopListening();
    } else {
      final started = await VoiceSearchService.instance.startListening();
      if (!started) {
        _showErrorDialog();
      }
    }
  }
  
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro de Voz'),
        content: const Text(
          'Não foi possível iniciar o reconhecimento de voz. '
          'Verifique se você deu permissão para usar o microfone.',
        ),
        actions: [
          TextButton(
            onPressed: () => NavigationHelper.safeGoBack(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _resultSubscription?.cancel();
    _listeningSubscription?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.primaryColor;
    final size = widget.size ?? 24.0;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isListening ? _scaleAnimation.value : 1.0,
          child: Container(
            decoration: _isListening
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 10 * _pulseAnimation.value,
                        spreadRadius: 5 * _pulseAnimation.value,
                      ),
                    ],
                  )
                : null,
            child: IconButton(
              onPressed: _isAvailable && widget.enabled ? _toggleListening : null,
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening
                    ? Colors.red
                    : (_isAvailable && widget.enabled ? color : Colors.grey),
                size: size,
              ),
              tooltip: _isListening
                  ? 'Parar gravação'
                  : 'Buscar por voz',
            ),
          ),
        );
      },
    );
  }
}

/// Widget para exibir status da busca por voz
class VoiceSearchStatus extends StatefulWidget {
  final Widget? child;
  
  const VoiceSearchStatus({
    super.key,
    this.child,
  });
  
  @override
  State<VoiceSearchStatus> createState() => _VoiceSearchStatusState();
}

class _VoiceSearchStatusState extends State<VoiceSearchStatus> {
  StreamSubscription<bool>? _listeningSubscription;
  StreamSubscription<double>? _confidenceSubscription;
  
  bool _isListening = false;
  double _confidence = 0.0;
  
  @override
  void initState() {
    super.initState();
    
    _listeningSubscription = VoiceSearchService.instance.listeningStream.listen(
      (listening) {
        if (mounted) {
          setState(() {
            _isListening = listening;
          });
        }
      },
    );
    
    _confidenceSubscription = VoiceSearchService.instance.confidenceStream.listen(
      (confidence) {
        if (mounted) {
          setState(() {
            _confidence = confidence;
          });
        }
      },
    );
  }
  
  @override
  void dispose() {
    _listeningSubscription?.cancel();
    _confidenceSubscription?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isListening) {
      return widget.child ?? const SizedBox.shrink();
    }
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.mic,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Escutando...',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (_confidence > 0)
                Text(
                  '${(_confidence * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.red.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}