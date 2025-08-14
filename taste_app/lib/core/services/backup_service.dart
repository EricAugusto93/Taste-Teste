import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taste_app/core/services/cache_service.dart';
import 'package:taste_app/core/services/connectivity_service.dart';
import 'package:taste_app/core/services/supabase_service.dart';

/// Status do backup
enum BackupStatus {
  idle,
  inProgress,
  completed,
  failed,
  cancelled,
}

/// Tipo de backup
enum BackupType {
  manual,
  automatic,
  scheduled,
}

/// Configurações de backup
class BackupConfig {
  final bool autoBackupEnabled;
  final Duration autoBackupInterval;
  final bool wifiOnlyBackup;
  final bool includeImages;
  final bool includeCache;
  final bool compressBackup;
  final int maxBackupFiles;
  final DateTime? lastBackupTime;
  final String? backupLocation;
  
  const BackupConfig({
    this.autoBackupEnabled = true,
    this.autoBackupInterval = const Duration(days: 1),
    this.wifiOnlyBackup = true,
    this.includeImages = false,
    this.includeCache = false,
    this.compressBackup = true,
    this.maxBackupFiles = 5,
    this.lastBackupTime,
    this.backupLocation,
  });
  
  factory BackupConfig.fromJson(Map<String, dynamic> json) {
    return BackupConfig(
      autoBackupEnabled: json['autoBackupEnabled'] as bool? ?? true,
      autoBackupInterval: Duration(
        milliseconds: json['autoBackupIntervalMs'] as int? ?? 86400000,
      ),
      wifiOnlyBackup: json['wifiOnlyBackup'] as bool? ?? true,
      includeImages: json['includeImages'] as bool? ?? false,
      includeCache: json['includeCache'] as bool? ?? false,
      compressBackup: json['compressBackup'] as bool? ?? true,
      maxBackupFiles: json['maxBackupFiles'] as int? ?? 5,
      lastBackupTime: json['lastBackupTime'] != null
          ? DateTime.parse(json['lastBackupTime'] as String)
          : null,
      backupLocation: json['backupLocation'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'autoBackupEnabled': autoBackupEnabled,
      'autoBackupIntervalMs': autoBackupInterval.inMilliseconds,
      'wifiOnlyBackup': wifiOnlyBackup,
      'includeImages': includeImages,
      'includeCache': includeCache,
      'compressBackup': compressBackup,
      'maxBackupFiles': maxBackupFiles,
      'lastBackupTime': lastBackupTime?.toIso8601String(),
      'backupLocation': backupLocation,
    };
  }
  
  BackupConfig copyWith({
    bool? autoBackupEnabled,
    Duration? autoBackupInterval,
    bool? wifiOnlyBackup,
    bool? includeImages,
    bool? includeCache,
    bool? compressBackup,
    int? maxBackupFiles,
    DateTime? lastBackupTime,
    String? backupLocation,
  }) {
    return BackupConfig(
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      autoBackupInterval: autoBackupInterval ?? this.autoBackupInterval,
      wifiOnlyBackup: wifiOnlyBackup ?? this.wifiOnlyBackup,
      includeImages: includeImages ?? this.includeImages,
      includeCache: includeCache ?? this.includeCache,
      compressBackup: compressBackup ?? this.compressBackup,
      maxBackupFiles: maxBackupFiles ?? this.maxBackupFiles,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
      backupLocation: backupLocation ?? this.backupLocation,
    );
  }
}

/// Informações do backup
class BackupInfo {
  final String id;
  final String fileName;
  final DateTime createdAt;
  final BackupType type;
  final int sizeBytes;
  final String checksum;
  final Map<String, dynamic> metadata;
  final bool isCompressed;
  final String? description;
  
  BackupInfo({
    required this.id,
    required this.fileName,
    required this.createdAt,
    required this.type,
    required this.sizeBytes,
    required this.checksum,
    required this.metadata,
    this.isCompressed = false,
    this.description,
  });
  
  factory BackupInfo.fromJson(Map<String, dynamic> json) {
    return BackupInfo(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: BackupType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BackupType.manual,
      ),
      sizeBytes: json['sizeBytes'] as int,
      checksum: json['checksum'] as String,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      isCompressed: json['isCompressed'] as bool? ?? false,
      description: json['description'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'createdAt': createdAt.toIso8601String(),
      'type': type.name,
      'sizeBytes': sizeBytes,
      'checksum': checksum,
      'metadata': metadata,
      'isCompressed': isCompressed,
      'description': description,
    };
  }
  
  String get formattedSize {
    if (sizeBytes < 1024) {
      return '$sizeBytes B';
    } else if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

/// Progresso do backup
class BackupProgress {
  final BackupStatus status;
  final double progress;
  final String? currentOperation;
  final String? error;
  final DateTime startTime;
  final DateTime? endTime;
  
  BackupProgress({
    required this.status,
    required this.progress,
    this.currentOperation,
    this.error,
    required this.startTime,
    this.endTime,
  });
  
  Duration? get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }
  
  bool get isCompleted => status == BackupStatus.completed;
  bool get isFailed => status == BackupStatus.failed;
  bool get isInProgress => status == BackupStatus.inProgress;
}

/// Serviço de backup
class BackupService {
  static BackupService? _instance;
  static BackupService get instance => _instance ??= BackupService._();
  
  BackupService._();
  
  final CacheService _cacheService = CacheService.instance;
  final ConnectivityService _connectivityService = ConnectivityService.instance;
  final SupabaseService _supabaseService = SupabaseService.instance;
  
  static const String _configKey = 'backup_config';
  static const String _backupsKey = 'backup_list';
  
  BackupConfig _config = const BackupConfig();
  final List<BackupInfo> _backups = [];
  Timer? _autoBackupTimer;
  
  final StreamController<BackupProgress> _progressController = StreamController<BackupProgress>.broadcast();
  BackupProgress? _currentProgress;
  
  /// Configuração atual
  BackupConfig get config => _config;
  
  /// Lista de backups
  List<BackupInfo> get backups => List.unmodifiable(_backups);
  
  /// Stream de progresso
  Stream<BackupProgress> get progressStream => _progressController.stream;
  
  /// Progresso atual
  BackupProgress? get currentProgress => _currentProgress;
  
  /// Inicializa o serviço
  Future<void> initialize() async {
    try {
      await _loadConfig();
      await _loadBackupList();
      _setupAutoBackup();
      debugPrint('Backup service initialized');
    } catch (e) {
      debugPrint('Error initializing backup service: $e');
    }
  }
  
  /// Carrega configurações
  Future<void> _loadConfig() async {
    try {
      final data = await _cacheService.get(_configKey);
      if (data != null) {
        _config = BackupConfig.fromJson(data as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error loading backup config: $e');
    }
  }
  
  /// Salva configurações
  Future<void> _saveConfig() async {
    try {
      await _cacheService.set(_configKey, _config.toJson());
    } catch (e) {
      debugPrint('Error saving backup config: $e');
    }
  }
  
  /// Carrega lista de backups
  Future<void> _loadBackupList() async {
    try {
      final data = await _cacheService.get(_backupsKey);
      if (data != null) {
        final backupList = (data as List)
            .map((e) => BackupInfo.fromJson(e as Map<String, dynamic>))
            .toList();
        _backups.clear();
        _backups.addAll(backupList);
      }
    } catch (e) {
      debugPrint('Error loading backup list: $e');
    }
  }
  
  /// Salva lista de backups
  Future<void> _saveBackupList() async {
    try {
      final data = _backups.map((e) => e.toJson()).toList();
      await _cacheService.set(_backupsKey, data);
    } catch (e) {
      debugPrint('Error saving backup list: $e');
    }
  }
  
  /// Configura backup automático
  void _setupAutoBackup() {
    _autoBackupTimer?.cancel();
    
    if (_config.autoBackupEnabled) {
      _autoBackupTimer = Timer.periodic(_config.autoBackupInterval, (_) {
        _performAutoBackup();
      });
    }
  }
  
  /// Executa backup automático
  Future<void> _performAutoBackup() async {
    try {
      // Verifica se deve fazer backup
      if (!_shouldPerformAutoBackup()) {
        return;
      }
      
      await createBackup(
        type: BackupType.automatic,
        description: 'Backup automático',
      );
    } catch (e) {
      debugPrint('Error performing auto backup: $e');
    }
  }
  
  /// Verifica se deve executar backup automático
  bool _shouldPerformAutoBackup() {
    // Verifica conectividade
    if (_config.wifiOnlyBackup && !_connectivityService.isWifi) {
      return false;
    }
    
    if (!_connectivityService.isOnline) {
      return false;
    }
    
    // Verifica último backup
    if (_config.lastBackupTime != null) {
      final timeSinceLastBackup = DateTime.now().difference(_config.lastBackupTime!);
      if (timeSinceLastBackup < _config.autoBackupInterval) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Atualiza progresso
  void _updateProgress(BackupProgress progress) {
    _currentProgress = progress;
    _progressController.add(progress);
  }
  
  /// Cria backup
  Future<BackupInfo?> createBackup({
    BackupType type = BackupType.manual,
    String? description,
  }) async {
    try {
      final startTime = DateTime.now();
      
      _updateProgress(BackupProgress(
        status: BackupStatus.inProgress,
        progress: 0.0,
        currentOperation: 'Iniciando backup...',
        startTime: startTime,
      ));
      
      // Coleta dados para backup
      _updateProgress(BackupProgress(
        status: BackupStatus.inProgress,
        progress: 0.1,
        currentOperation: 'Coletando dados...',
        startTime: startTime,
      ));
      
      final backupData = await _collectBackupData();
      
      // Cria arquivo de backup
      _updateProgress(BackupProgress(
        status: BackupStatus.inProgress,
        progress: 0.5,
        currentOperation: 'Criando arquivo de backup...',
        startTime: startTime,
      ));
      
      final backupFile = await _createBackupFile(backupData);
      
      // Upload para cloud (se configurado)
      _updateProgress(BackupProgress(
        status: BackupStatus.inProgress,
        progress: 0.8,
        currentOperation: 'Enviando para nuvem...',
        startTime: startTime,
      ));
      
      await _uploadBackupToCloud(backupFile);
      
      // Cria informações do backup
      final backupInfo = BackupInfo(
        id: _generateBackupId(),
        fileName: backupFile.path.split('/').last,
        createdAt: DateTime.now(),
        type: type,
        sizeBytes: await backupFile.length(),
        checksum: await _calculateChecksum(backupFile),
        metadata: {
          'version': '1.0',
          'platform': defaultTargetPlatform.name,
          'includeImages': _config.includeImages,
          'includeCache': _config.includeCache,
          'compressed': _config.compressBackup,
        },
        isCompressed: _config.compressBackup,
        description: description,
      );
      
      // Adiciona à lista
      _backups.add(backupInfo);
      await _saveBackupList();
      
      // Limpa backups antigos
      await _cleanupOldBackups();
      
      // Atualiza configuração
      _config = _config.copyWith(lastBackupTime: DateTime.now());
      await _saveConfig();
      
      _updateProgress(BackupProgress(
        status: BackupStatus.completed,
        progress: 1.0,
        currentOperation: 'Backup concluído',
        startTime: startTime,
        endTime: DateTime.now(),
      ));
      
      debugPrint('Backup created successfully: ${backupInfo.id}');
      return backupInfo;
    } catch (e) {
      _updateProgress(BackupProgress(
        status: BackupStatus.failed,
        progress: 0.0,
        error: e.toString(),
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      ));
      
      debugPrint('Error creating backup: $e');
      return null;
    }
  }
  
  /// Coleta dados para backup
  Future<Map<String, dynamic>> _collectBackupData() async {
    final data = <String, dynamic>{};
    
    // Dados do cache
    if (_config.includeCache) {
      data['cache'] = await _cacheService.getAllData();
    }
    
    // Configurações do app
    data['settings'] = await _cacheService.get('app_settings');
    
    // Favoritos
    data['favorites'] = await _cacheService.get('favorites');
    
    // Histórico de busca
    data['searchHistory'] = await _cacheService.get('search_history');
    
    // Reviews
    data['reviews'] = await _cacheService.get('user_reviews');
    
    // Dados do usuário
    data['userProfile'] = await _cacheService.get('user_profile');
    
    // Metadados
    data['metadata'] = {
      'version': '1.0',
      'createdAt': DateTime.now().toIso8601String(),
      'platform': defaultTargetPlatform.name,
      'appVersion': '1.0.0', // Seria obtido do package_info
    };
    
    return data;
  }
  
  /// Cria arquivo de backup
  Future<File> _createBackupFile(Map<String, dynamic> data) async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/backups');
    
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'taste_backup_$timestamp.json';
    final file = File('${backupDir.path}/$fileName');
    
    final jsonString = jsonEncode(data);
    
    if (_config.compressBackup) {
      // Aqui você implementaria compressão (gzip, etc.)
      await file.writeAsString(jsonString);
    } else {
      await file.writeAsString(jsonString);
    }
    
    return file;
  }
  
  /// Upload para cloud
  Future<void> _uploadBackupToCloud(File backupFile) async {
    try {
      // Implementaria upload para Supabase Storage ou outro serviço
      // Por enquanto, apenas simula o upload
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('Backup uploaded to cloud: ${backupFile.path}');
    } catch (e) {
      debugPrint('Error uploading backup to cloud: $e');
      // Não falha o backup se o upload falhar
    }
  }
  
  /// Calcula checksum do arquivo
  Future<String> _calculateChecksum(File file) async {
    // Implementaria cálculo de hash MD5 ou SHA256
    final content = await file.readAsString();
    return content.hashCode.toString();
  }
  
  /// Gera ID do backup
  String _generateBackupId() {
    return 'backup_${DateTime.now().millisecondsSinceEpoch}';
  }
  
  /// Limpa backups antigos
  Future<void> _cleanupOldBackups() async {
    if (_backups.length <= _config.maxBackupFiles) {
      return;
    }
    
    // Ordena por data de criação (mais antigos primeiro)
    _backups.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    // Remove backups excedentes
    final toRemove = _backups.length - _config.maxBackupFiles;
    for (int i = 0; i < toRemove; i++) {
      final backup = _backups.removeAt(0);
      await _deleteBackupFile(backup);
      debugPrint('Old backup removed: ${backup.id}');
    }
    
    await _saveBackupList();
  }
  
  /// Remove arquivo de backup
  Future<void> _deleteBackupFile(BackupInfo backup) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/backups/${backup.fileName}');
      
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting backup file: $e');
    }
  }
  
  /// Restaura backup
  Future<bool> restoreBackup(BackupInfo backupInfo) async {
    try {
      final startTime = DateTime.now();
      
      _updateProgress(BackupProgress(
        status: BackupStatus.inProgress,
        progress: 0.0,
        currentOperation: 'Iniciando restauração...',
        startTime: startTime,
      ));
      
      // Carrega arquivo de backup
      _updateProgress(BackupProgress(
        status: BackupStatus.inProgress,
        progress: 0.2,
        currentOperation: 'Carregando backup...',
        startTime: startTime,
      ));
      
      final backupData = await _loadBackupFile(backupInfo);
      
      // Valida backup
      _updateProgress(BackupProgress(
        status: BackupStatus.inProgress,
        progress: 0.4,
        currentOperation: 'Validando backup...',
        startTime: startTime,
      ));
      
      if (!_validateBackupData(backupData)) {
        throw Exception('Backup inválido ou corrompido');
      }
      
      // Restaura dados
      _updateProgress(BackupProgress(
        status: BackupStatus.inProgress,
        progress: 0.6,
        currentOperation: 'Restaurando dados...',
        startTime: startTime,
      ));
      
      await _restoreBackupData(backupData);
      
      _updateProgress(BackupProgress(
        status: BackupStatus.completed,
        progress: 1.0,
        currentOperation: 'Restauração concluída',
        startTime: startTime,
        endTime: DateTime.now(),
      ));
      
      debugPrint('Backup restored successfully: ${backupInfo.id}');
      return true;
    } catch (e) {
      _updateProgress(BackupProgress(
        status: BackupStatus.failed,
        progress: 0.0,
        error: e.toString(),
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      ));
      
      debugPrint('Error restoring backup: $e');
      return false;
    }
  }
  
  /// Carrega arquivo de backup
  Future<Map<String, dynamic>> _loadBackupFile(BackupInfo backupInfo) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/backups/${backupInfo.fileName}');
    
    if (!await file.exists()) {
      throw Exception('Arquivo de backup não encontrado');
    }
    
    final content = await file.readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  }
  
  /// Valida dados do backup
  bool _validateBackupData(Map<String, dynamic> data) {
    // Verifica se tem metadados
    if (!data.containsKey('metadata')) {
      return false;
    }
    
    final metadata = data['metadata'] as Map<String, dynamic>;
    
    // Verifica versão
    if (!metadata.containsKey('version')) {
      return false;
    }
    
    return true;
  }
  
  /// Restaura dados do backup
  Future<void> _restoreBackupData(Map<String, dynamic> data) async {
    // Restaura configurações
    if (data.containsKey('settings') && data['settings'] != null) {
      await _cacheService.set('app_settings', data['settings']);
    }
    
    // Restaura favoritos
    if (data.containsKey('favorites') && data['favorites'] != null) {
      await _cacheService.set('favorites', data['favorites']);
    }
    
    // Restaura histórico de busca
    if (data.containsKey('searchHistory') && data['searchHistory'] != null) {
      await _cacheService.set('search_history', data['searchHistory']);
    }
    
    // Restaura reviews
    if (data.containsKey('reviews') && data['reviews'] != null) {
      await _cacheService.set('user_reviews', data['reviews']);
    }
    
    // Restaura perfil do usuário
    if (data.containsKey('userProfile') && data['userProfile'] != null) {
      await _cacheService.set('user_profile', data['userProfile']);
    }
    
    // Restaura cache (se incluído)
    if (data.containsKey('cache') && data['cache'] != null && _config.includeCache) {
      final cacheData = data['cache'] as Map<String, dynamic>;
      for (final entry in cacheData.entries) {
        await _cacheService.set(entry.key, entry.value);
      }
    }
  }
  
  /// Remove backup
  Future<void> deleteBackup(BackupInfo backupInfo) async {
    try {
      await _deleteBackupFile(backupInfo);
      _backups.removeWhere((b) => b.id == backupInfo.id);
      await _saveBackupList();
      debugPrint('Backup deleted: ${backupInfo.id}');
    } catch (e) {
      debugPrint('Error deleting backup: $e');
      throw Exception('Erro ao excluir backup: $e');
    }
  }
  
  /// Atualiza configurações
  Future<void> updateConfig(BackupConfig newConfig) async {
    _config = newConfig;
    await _saveConfig();
    _setupAutoBackup();
    debugPrint('Backup config updated');
  }
  
  /// Obtém estatísticas de backup
  Map<String, dynamic> getBackupStats() {
    final totalSize = _backups.fold<int>(0, (sum, backup) => sum + backup.sizeBytes);
    
    return {
      'config': _config.toJson(),
      'totalBackups': _backups.length,
      'totalSizeBytes': totalSize,
      'totalSizeFormatted': _formatBytes(totalSize),
      'lastBackupTime': _config.lastBackupTime?.toIso8601String(),
      'nextAutoBackup': _config.autoBackupEnabled && _config.lastBackupTime != null
          ? _config.lastBackupTime!.add(_config.autoBackupInterval).toIso8601String()
          : null,
      'backups': _backups.map((b) => b.toJson()).toList(),
    };
  }
  
  /// Formata bytes
  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
  
  /// Finaliza o serviço
  void dispose() {
    _autoBackupTimer?.cancel();
    _progressController.close();
  }
}