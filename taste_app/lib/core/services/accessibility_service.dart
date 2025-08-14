import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:taste_app/core/services/cache_service.dart';

/// Configurações de acessibilidade
class AccessibilityConfig {
  final bool highContrast;
  final bool largeText;
  final bool reduceMotion;
  final bool screenReader;
  final double textScaleFactor;
  final bool hapticFeedback;
  final bool audioDescriptions;
  final String preferredLanguage;
  
  const AccessibilityConfig({
    this.highContrast = false,
    this.largeText = false,
    this.reduceMotion = false,
    this.screenReader = false,
    this.textScaleFactor = 1.0,
    this.hapticFeedback = true,
    this.audioDescriptions = false,
    this.preferredLanguage = 'pt-BR',
  });
  
  factory AccessibilityConfig.fromJson(Map<String, dynamic> json) {
    return AccessibilityConfig(
      highContrast: json['highContrast'] as bool? ?? false,
      largeText: json['largeText'] as bool? ?? false,
      reduceMotion: json['reduceMotion'] as bool? ?? false,
      screenReader: json['screenReader'] as bool? ?? false,
      textScaleFactor: (json['textScaleFactor'] as num?)?.toDouble() ?? 1.0,
      hapticFeedback: json['hapticFeedback'] as bool? ?? true,
      audioDescriptions: json['audioDescriptions'] as bool? ?? false,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'pt-BR',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'highContrast': highContrast,
      'largeText': largeText,
      'reduceMotion': reduceMotion,
      'screenReader': screenReader,
      'textScaleFactor': textScaleFactor,
      'hapticFeedback': hapticFeedback,
      'audioDescriptions': audioDescriptions,
      'preferredLanguage': preferredLanguage,
    };
  }
  
  AccessibilityConfig copyWith({
    bool? highContrast,
    bool? largeText,
    bool? reduceMotion,
    bool? screenReader,
    double? textScaleFactor,
    bool? hapticFeedback,
    bool? audioDescriptions,
    String? preferredLanguage,
  }) {
    return AccessibilityConfig(
      highContrast: highContrast ?? this.highContrast,
      largeText: largeText ?? this.largeText,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      screenReader: screenReader ?? this.screenReader,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      audioDescriptions: audioDescriptions ?? this.audioDescriptions,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }
}

/// Serviço de acessibilidade
class AccessibilityService {
  static AccessibilityService? _instance;
  static AccessibilityService get instance => _instance ??= AccessibilityService._();
  
  AccessibilityService._();
  
  final CacheService _cacheService = CacheService.instance;
  static const String _configKey = 'accessibility_config';
  
  AccessibilityConfig _config = const AccessibilityConfig();
  
  /// Configuração atual de acessibilidade
  AccessibilityConfig get config => _config;
  
  /// Inicializa o serviço de acessibilidade
  Future<void> initialize() async {
    try {
      // Carrega configurações salvas
      await _loadConfig();
      
      // Detecta configurações do sistema
      await _detectSystemSettings();
      
      debugPrint('Accessibility service initialized');
    } catch (e) {
      debugPrint('Error initializing accessibility service: $e');
    }
  }
  
  /// Carrega configurações salvas
  Future<void> _loadConfig() async {
    try {
      final data = await _cacheService.get(_configKey);
      if (data != null) {
        _config = AccessibilityConfig.fromJson(data as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error loading accessibility config: $e');
    }
  }
  
  /// Salva configurações
  Future<void> _saveConfig() async {
    try {
      await _cacheService.set(_configKey, _config.toJson());
    } catch (e) {
      debugPrint('Error saving accessibility config: $e');
    }
  }
  
  /// Detecta configurações do sistema
  Future<void> _detectSystemSettings() async {
    try {
      // Detecta se o leitor de tela está ativo
      final screenReader = SemanticsBinding.instance.accessibilityFeatures.accessibleNavigation;
      
      // Detecta se o texto grande está ativo
      final largeText = SemanticsBinding.instance.accessibilityFeatures.boldText;
      
      // Detecta se a redução de movimento está ativa
      final reduceMotion = SemanticsBinding.instance.accessibilityFeatures.reduceMotion;
      
      // Detecta se o alto contraste está ativo
      final highContrast = SemanticsBinding.instance.accessibilityFeatures.highContrast;
      
      // Atualiza configurações se detectadas
      if (screenReader || largeText || reduceMotion || highContrast) {
        _config = _config.copyWith(
          screenReader: screenReader,
          largeText: largeText,
          reduceMotion: reduceMotion,
          highContrast: highContrast,
        );
        
        await _saveConfig();
      }
    } catch (e) {
      debugPrint('Error detecting system accessibility settings: $e');
    }
  }
  
  /// Atualiza configuração de alto contraste
  Future<void> setHighContrast(bool enabled) async {
    _config = _config.copyWith(highContrast: enabled);
    await _saveConfig();
    debugPrint('High contrast ${enabled ? 'enabled' : 'disabled'}');
  }
  
  /// Atualiza configuração de texto grande
  Future<void> setLargeText(bool enabled) async {
    _config = _config.copyWith(largeText: enabled);
    await _saveConfig();
    debugPrint('Large text ${enabled ? 'enabled' : 'disabled'}');
  }
  
  /// Atualiza configuração de redução de movimento
  Future<void> setReduceMotion(bool enabled) async {
    _config = _config.copyWith(reduceMotion: enabled);
    await _saveConfig();
    debugPrint('Reduce motion ${enabled ? 'enabled' : 'disabled'}');
  }
  
  /// Atualiza fator de escala do texto
  Future<void> setTextScaleFactor(double factor) async {
    final clampedFactor = factor.clamp(0.8, 2.0);
    _config = _config.copyWith(textScaleFactor: clampedFactor);
    await _saveConfig();
    debugPrint('Text scale factor set to $clampedFactor');
  }
  
  /// Atualiza configuração de feedback háptico
  Future<void> setHapticFeedback(bool enabled) async {
    _config = _config.copyWith(hapticFeedback: enabled);
    await _saveConfig();
    debugPrint('Haptic feedback ${enabled ? 'enabled' : 'disabled'}');
  }
  
  /// Executa feedback háptico se habilitado
  void performHapticFeedback([HapticFeedbackType type = HapticFeedbackType.lightImpact]) {
    if (_config.hapticFeedback) {
      HapticFeedback.vibrate();
    }
  }
  
  /// Anuncia texto para leitores de tela
  void announceForScreenReader(String message, {bool assertive = false}) {
    if (_config.screenReader) {
      SemanticsService.announce(
        message,
        assertive ? Assertiveness.assertive : Assertiveness.polite,
      );
    }
  }
  
  /// Obtém duração de animação baseada nas configurações
  Duration getAnimationDuration(Duration defaultDuration) {
    if (_config.reduceMotion) {
      return Duration.zero;
    }
    return defaultDuration;
  }
  
  /// Obtém cores baseadas no modo de alto contraste
  ColorScheme getColorScheme(ColorScheme defaultScheme) {
    if (!_config.highContrast) {
      return defaultScheme;
    }
    
    // Esquema de alto contraste
    return ColorScheme.fromSeed(
      seedColor: defaultScheme.primary,
      brightness: defaultScheme.brightness,
    ).copyWith(
      primary: _config.highContrast ? Colors.black : defaultScheme.primary,
      onPrimary: _config.highContrast ? Colors.white : defaultScheme.onPrimary,
      secondary: _config.highContrast ? Colors.grey[800] : defaultScheme.secondary,
      onSecondary: _config.highContrast ? Colors.white : defaultScheme.onSecondary,
      surface: _config.highContrast ? Colors.white : defaultScheme.surface,
      onSurface: _config.highContrast ? Colors.black : defaultScheme.onSurface,
    );
  }
  
  /// Obtém estilo de texto baseado nas configurações
  TextStyle getTextStyle(TextStyle defaultStyle) {
    TextStyle style = defaultStyle;
    
    // Aplica fator de escala
    if (_config.textScaleFactor != 1.0) {
      style = style.copyWith(
        fontSize: (style.fontSize ?? 14) * _config.textScaleFactor,
      );
    }
    
    // Aplica texto em negrito se habilitado
    if (_config.largeText) {
      style = style.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: (style.fontSize ?? 14) * 1.2,
      );
    }
    
    return style;
  }
  
  /// Verifica se uma cor tem contraste suficiente
  bool hasGoodContrast(Color foreground, Color background) {
    final luminance1 = foreground.computeLuminance();
    final luminance2 = background.computeLuminance();
    
    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;
    
    final contrast = (lighter + 0.05) / (darker + 0.05);
    
    // WCAG AA requer contraste mínimo de 4.5:1 para texto normal
    return contrast >= 4.5;
  }
  
  /// Obtém cor com contraste adequado
  Color getContrastColor(Color background) {
    final luminance = background.computeLuminance();
    
    // Se o fundo é claro, usa texto escuro; se escuro, usa texto claro
    if (luminance > 0.5) {
      return _config.highContrast ? Colors.black : Colors.grey[800]!;
    } else {
      return _config.highContrast ? Colors.white : Colors.grey[200]!;
    }
  }
  
  /// Cria semantics para um elemento
  Semantics createSemantics({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    bool? button,
    bool? header,
    bool? focusable,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button ?? false,
      header: header ?? false,
      focusable: focusable ?? true,
      onTap: onTap,
      child: child,
    );
  }
  
  /// Obtém configurações de tema acessível
  ThemeData getAccessibleTheme(ThemeData baseTheme) {
    return baseTheme.copyWith(
      colorScheme: getColorScheme(baseTheme.colorScheme),
      textTheme: baseTheme.textTheme.apply(
        fontSizeFactor: _config.textScaleFactor,
        fontWeightDelta: _config.largeText ? 2 : 0,
      ),
      // Aumenta áreas de toque para melhor acessibilidade
      materialTapTargetSize: MaterialTapTargetSize.padded,
      // Desabilita animações se necessário
      pageTransitionsTheme: _config.reduceMotion
          ? const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
              },
            )
          : baseTheme.pageTransitionsTheme,
    );
  }
  
  /// Obtém estatísticas de acessibilidade
  Map<String, dynamic> getAccessibilityStats() {
    return {
      'config': _config.toJson(),
      'systemFeatures': {
        'accessibleNavigation': SemanticsBinding.instance.accessibilityFeatures.accessibleNavigation,
        'boldText': SemanticsBinding.instance.accessibilityFeatures.boldText,
        'reduceMotion': SemanticsBinding.instance.accessibilityFeatures.reduceMotion,
        'highContrast': SemanticsBinding.instance.accessibilityFeatures.highContrast,
        'invertColors': SemanticsBinding.instance.accessibilityFeatures.invertColors,
        'disableAnimations': SemanticsBinding.instance.accessibilityFeatures.disableAnimations,
      },
    };
  }
}

/// Widget para configurações de acessibilidade
class AccessibilitySettingsWidget extends StatefulWidget {
  const AccessibilitySettingsWidget({super.key});
  
  @override
  State<AccessibilitySettingsWidget> createState() => _AccessibilitySettingsWidgetState();
}

class _AccessibilitySettingsWidgetState extends State<AccessibilitySettingsWidget> {
  late AccessibilityConfig _config;
  
  @override
  void initState() {
    super.initState();
    _config = AccessibilityService.instance.config;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Acessibilidade'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Alto contraste
          SwitchListTile(
            title: const Text('Alto Contraste'),
            subtitle: const Text('Aumenta o contraste das cores'),
            value: _config.highContrast,
            onChanged: (value) async {
              await AccessibilityService.instance.setHighContrast(value);
              setState(() {
                _config = AccessibilityService.instance.config;
              });
            },
          ),
          
          // Texto grande
          SwitchListTile(
            title: const Text('Texto Grande'),
            subtitle: const Text('Aumenta o tamanho do texto'),
            value: _config.largeText,
            onChanged: (value) async {
              await AccessibilityService.instance.setLargeText(value);
              setState(() {
                _config = AccessibilityService.instance.config;
              });
            },
          ),
          
          // Reduzir movimento
          SwitchListTile(
            title: const Text('Reduzir Movimento'),
            subtitle: const Text('Reduz animações e transições'),
            value: _config.reduceMotion,
            onChanged: (value) async {
              await AccessibilityService.instance.setReduceMotion(value);
              setState(() {
                _config = AccessibilityService.instance.config;
              });
            },
          ),
          
          // Feedback háptico
          SwitchListTile(
            title: const Text('Feedback Háptico'),
            subtitle: const Text('Vibração ao tocar em elementos'),
            value: _config.hapticFeedback,
            onChanged: (value) async {
              await AccessibilityService.instance.setHapticFeedback(value);
              setState(() {
                _config = AccessibilityService.instance.config;
              });
            },
          ),
          
          const Divider(),
          
          // Escala de texto
          ListTile(
            title: const Text('Tamanho do Texto'),
            subtitle: Text('${(_config.textScaleFactor * 100).round()}%'),
          ),
          Slider(
            value: _config.textScaleFactor,
            min: 0.8,
            max: 2.0,
            divisions: 12,
            label: '${(_config.textScaleFactor * 100).round()}%',
            onChanged: (value) async {
              await AccessibilityService.instance.setTextScaleFactor(value);
              setState(() {
                _config = AccessibilityService.instance.config;
              });
            },
          ),
          
          const Divider(),
          
          // Informações do sistema
          const ListTile(
            title: Text(
              'Configurações do Sistema',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          
          ListTile(
            title: const Text('Leitor de Tela'),
            subtitle: Text(
              SemanticsBinding.instance.accessibilityFeatures.accessibleNavigation
                  ? 'Ativo'
                  : 'Inativo',
            ),
            trailing: Icon(
              SemanticsBinding.instance.accessibilityFeatures.accessibleNavigation
                  ? Icons.check_circle
                  : Icons.cancel,
              color: SemanticsBinding.instance.accessibilityFeatures.accessibleNavigation
                  ? Colors.green
                  : Colors.grey,
            ),
          ),
          
          ListTile(
            title: const Text('Texto em Negrito'),
            subtitle: Text(
              SemanticsBinding.instance.accessibilityFeatures.boldText
                  ? 'Ativo'
                  : 'Inativo',
            ),
            trailing: Icon(
              SemanticsBinding.instance.accessibilityFeatures.boldText
                  ? Icons.check_circle
                  : Icons.cancel,
              color: SemanticsBinding.instance.accessibilityFeatures.boldText
                  ? Colors.green
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget acessível para botões
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final String? semanticHint;
  final ButtonStyle? style;
  
  const AccessibleButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.semanticLabel,
    this.semanticHint,
    this.style,
  });
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      enabled: onPressed != null,
      onTap: onPressed,
      child: ElevatedButton(
        onPressed: () {
          AccessibilityService.instance.performHapticFeedback();
          onPressed?.call();
        },
        style: style,
        child: child,
      ),
    );
  }
}

/// Widget acessível para texto
class AccessibleText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final String? semanticLabel;
  final bool isHeader;
  final int? maxLines;
  final TextOverflow? overflow;
  
  const AccessibleText(
    this.text, {
    super.key,
    this.style,
    this.semanticLabel,
    this.isHeader = false,
    this.maxLines,
    this.overflow,
  });
  
  @override
  Widget build(BuildContext context) {
    final accessibleStyle = AccessibilityService.instance.getTextStyle(
      style ?? Theme.of(context).textTheme.bodyMedium!,
    );
    
    return Semantics(
      label: semanticLabel ?? text,
      header: isHeader,
      child: Text(
        text,
        style: accessibleStyle,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}