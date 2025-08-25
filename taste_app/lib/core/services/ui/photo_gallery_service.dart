import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../utils/navigation_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../cache_service.dart';
import '../connectivity_service.dart';
import '../supabase_service.dart';

/// Tipos de fonte de foto
enum PhotoSource {
  camera,
  gallery,
  url,
  asset,
}

/// Qualidade da foto
enum PhotoQuality {
  low(25),
  medium(50),
  high(75),
  original(100);

  const PhotoQuality(this.value);
  final int value;
}

/// Modelo para foto da galeria
class GalleryPhoto {
  final String id;
  final String restaurantId;
  final String url;
  final String? localPath;
  final String? caption;
  final String? userId;
  final DateTime createdAt;
  final PhotoSource source;
  final Map<String, dynamic>? metadata;
  final bool isPublic;
  final int likes;
  final List<String> tags;

  const GalleryPhoto({
    required this.id,
    required this.restaurantId,
    required this.url,
    this.localPath,
    this.caption,
    this.userId,
    required this.createdAt,
    required this.source,
    this.metadata,
    this.isPublic = true,
    this.likes = 0,
    this.tags = const [],
  });

  factory GalleryPhoto.fromJson(Map<String, dynamic> json) {
    return GalleryPhoto(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      url: json['url'] as String,
      localPath: json['local_path'] as String?,
      caption: json['caption'] as String?,
      userId: json['user_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      source: PhotoSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => PhotoSource.url,
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
      isPublic: json['is_public'] as bool? ?? true,
      likes: json['likes'] as int? ?? 0,
      tags: List<String>.from(json['tags'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'url': url,
      'local_path': localPath,
      'caption': caption,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'source': source.name,
      'metadata': metadata,
      'is_public': isPublic,
      'likes': likes,
      'tags': tags,
    };
  }

  GalleryPhoto copyWith({
    String? id,
    String? restaurantId,
    String? url,
    String? localPath,
    String? caption,
    String? userId,
    DateTime? createdAt,
    PhotoSource? source,
    Map<String, dynamic>? metadata,
    bool? isPublic,
    int? likes,
    List<String>? tags,
  }) {
    return GalleryPhoto(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      caption: caption ?? this.caption,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      source: source ?? this.source,
      metadata: metadata ?? this.metadata,
      isPublic: isPublic ?? this.isPublic,
      likes: likes ?? this.likes,
      tags: tags ?? this.tags,
    );
  }
}

/// Configurações da galeria
class GalleryConfig {
  final int maxPhotosPerRestaurant;
  final int maxFileSize; // em bytes
  final List<String> allowedExtensions;
  final PhotoQuality defaultQuality;
  final bool enableCache;
  final Duration cacheDuration;
  final bool enableCompression;
  final bool enableWatermark;
  final String? watermarkText;

  const GalleryConfig({
    this.maxPhotosPerRestaurant = 20,
    this.maxFileSize = 5 * 1024 * 1024, // 5MB
    this.allowedExtensions = const ['jpg', 'jpeg', 'png', 'webp'],
    this.defaultQuality = PhotoQuality.high,
    this.enableCache = true,
    this.cacheDuration = const Duration(days: 7),
    this.enableCompression = true,
    this.enableWatermark = false,
    this.watermarkText,
  });

  factory GalleryConfig.fromJson(Map<String, dynamic> json) {
    return GalleryConfig(
      maxPhotosPerRestaurant: json['max_photos_per_restaurant'] as int? ?? 20,
      maxFileSize: json['max_file_size'] as int? ?? 5 * 1024 * 1024,
      allowedExtensions: List<String>.from(
        json['allowed_extensions'] as List? ?? ['jpg', 'jpeg', 'png', 'webp'],
      ),
      defaultQuality: PhotoQuality.values.firstWhere(
        (e) => e.name == json['default_quality'],
        orElse: () => PhotoQuality.high,
      ),
      enableCache: json['enable_cache'] as bool? ?? true,
      cacheDuration: Duration(
        milliseconds: json['cache_duration_ms'] as int? ?? 7 * 24 * 60 * 60 * 1000,
      ),
      enableCompression: json['enable_compression'] as bool? ?? true,
      enableWatermark: json['enable_watermark'] as bool? ?? false,
      watermarkText: json['watermark_text'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'max_photos_per_restaurant': maxPhotosPerRestaurant,
      'max_file_size': maxFileSize,
      'allowed_extensions': allowedExtensions,
      'default_quality': defaultQuality.name,
      'enable_cache': enableCache,
      'cache_duration_ms': cacheDuration.inMilliseconds,
      'enable_compression': enableCompression,
      'enable_watermark': enableWatermark,
      'watermark_text': watermarkText,
    };
  }
}

/// Resultado do upload de foto
class PhotoUploadResult {
  final bool success;
  final String? photoId;
  final String? url;
  final String? error;
  final Map<String, dynamic>? metadata;

  const PhotoUploadResult({
    required this.success,
    this.photoId,
    this.url,
    this.error,
    this.metadata,
  });

  factory PhotoUploadResult.success({
    required String photoId,
    required String url,
    Map<String, dynamic>? metadata,
  }) {
    return PhotoUploadResult(
      success: true,
      photoId: photoId,
      url: url,
      metadata: metadata,
    );
  }

  factory PhotoUploadResult.error(String error) {
    return PhotoUploadResult(
      success: false,
      error: error,
    );
  }
}

/// Serviço de galeria de fotos
class PhotoGalleryService {
  static PhotoGalleryService? _instance;
  static PhotoGalleryService get instance => _instance ??= PhotoGalleryService._();
  PhotoGalleryService._();

  final ImagePicker _picker = ImagePicker();
  final CacheService _cacheService = CacheService.instance;
  final ConnectivityService _connectivityService = ConnectivityService.instance;
  final SupabaseService _supabaseService = SupabaseService.instance;

  GalleryConfig _config = const GalleryConfig();
  final Map<String, List<GalleryPhoto>> _photoCache = {};
  bool _isInitialized = false;

  /// Inicializar o serviço
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Carregar configurações
      await _loadConfig();

      // Carregar cache de fotos
      await _loadPhotoCache();

      _isInitialized = true;
      debugPrint('PhotoGalleryService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing PhotoGalleryService: $e');
      rethrow;
    }
  }

  /// Carregar configurações
  Future<void> _loadConfig() async {
    try {
      final configData = await _cacheService.get('gallery_config');
      if (configData != null) {
        _config = GalleryConfig.fromJson(configData);
      }
    } catch (e) {
      debugPrint('Error loading gallery config: $e');
    }
  }

  /// Salvar configurações
  Future<void> _saveConfig() async {
    try {
      await _cacheService.set(
        'gallery_config',
        _config.toJson(),
        duration: const Duration(days: 30),
      );
    } catch (e) {
      debugPrint('Error saving gallery config: $e');
    }
  }

  /// Carregar cache de fotos
  Future<void> _loadPhotoCache() async {
    try {
      final cacheData = await _cacheService.get('photo_cache');
      if (cacheData != null) {
        final Map<String, dynamic> cache = cacheData;
        for (final entry in cache.entries) {
          final photos = (entry.value as List)
              .map((json) => GalleryPhoto.fromJson(json))
              .toList();
          _photoCache[entry.key] = photos;
        }
      }
    } catch (e) {
      debugPrint('Error loading photo cache: $e');
    }
  }

  /// Salvar cache de fotos
  Future<void> _savePhotoCache() async {
    try {
      final cacheData = <String, dynamic>{};
      for (final entry in _photoCache.entries) {
        cacheData[entry.key] = entry.value.map((photo) => photo.toJson()).toList();
      }
      await _cacheService.set(
        'photo_cache',
        cacheData,
        duration: _config.cacheDuration,
      );
    } catch (e) {
      debugPrint('Error saving photo cache: $e');
    }
  }

  /// Obter fotos de um restaurante
  Future<List<GalleryPhoto>> getRestaurantPhotos(String restaurantId) async {
    try {
      // Verificar cache primeiro
      if (_config.enableCache && _photoCache.containsKey(restaurantId)) {
        return _photoCache[restaurantId]!;
      }

      // Buscar do servidor se online
      if (_connectivityService.isOnline) {
        final photos = await _fetchPhotosFromServer(restaurantId);
        
        // Atualizar cache
        if (_config.enableCache) {
          _photoCache[restaurantId] = photos;
          await _savePhotoCache();
        }
        
        return photos;
      }

      // Retornar cache ou lista vazia
      return _photoCache[restaurantId] ?? [];
    } catch (e) {
      debugPrint('Error getting restaurant photos: $e');
      return _photoCache[restaurantId] ?? [];
    }
  }

  /// Buscar fotos do servidor
  Future<List<GalleryPhoto>> _fetchPhotosFromServer(String restaurantId) async {
    try {
      // Simular busca do servidor (implementar com Supabase)
      await Future.delayed(const Duration(milliseconds: 500));
      
      // TODO: Implementar busca real do Supabase
      // final response = await _supabaseService.client
      //     .from('restaurant_photos')
      //     .select()
      //     .eq('restaurant_id', restaurantId)
      //     .order('created_at', ascending: false);
      
      // return (response as List)
      //     .map((json) => GalleryPhoto.fromJson(json))
      //     .toList();
      
      return [];
    } catch (e) {
      debugPrint('Error fetching photos from server: $e');
      return [];
    }
  }

  /// Tirar foto com a câmera
  Future<PhotoUploadResult> takePhoto({
    required String restaurantId,
    String? caption,
    List<String>? tags,
    PhotoQuality? quality,
  }) async {
    try {
      // Verificar permissão da câmera
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        return PhotoUploadResult.error('Permissão da câmera negada');
      }

      // Tirar foto
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: (quality ?? _config.defaultQuality).value,
      );

      if (image == null) {
        return PhotoUploadResult.error('Nenhuma foto foi tirada');
      }

      // Processar e fazer upload
      return await _processAndUploadPhoto(
        image,
        restaurantId: restaurantId,
        caption: caption,
        tags: tags ?? [],
        source: PhotoSource.camera,
      );
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return PhotoUploadResult.error('Erro ao tirar foto: $e');
    }
  }

  /// Selecionar foto da galeria
  Future<PhotoUploadResult> pickFromGallery({
    required String restaurantId,
    String? caption,
    List<String>? tags,
    PhotoQuality? quality,
  }) async {
    try {
      // Verificar permissão da galeria
      final permission = await Permission.photos.request();
      if (!permission.isGranted) {
        return PhotoUploadResult.error('Permissão da galeria negada');
      }

      // Selecionar foto
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: (quality ?? _config.defaultQuality).value,
      );

      if (image == null) {
        return PhotoUploadResult.error('Nenhuma foto foi selecionada');
      }

      // Processar e fazer upload
      return await _processAndUploadPhoto(
        image,
        restaurantId: restaurantId,
        caption: caption,
        tags: tags ?? [],
        source: PhotoSource.gallery,
      );
    } catch (e) {
      debugPrint('Error picking from gallery: $e');
      return PhotoUploadResult.error('Erro ao selecionar foto: $e');
    }
  }

  /// Processar e fazer upload da foto
  Future<PhotoUploadResult> _processAndUploadPhoto(
    XFile image, {
    required String restaurantId,
    String? caption,
    required List<String> tags,
    required PhotoSource source,
  }) async {
    try {
      // Verificar tamanho do arquivo
      final fileSize = await image.length();
      if (fileSize > _config.maxFileSize) {
        return PhotoUploadResult.error(
          'Arquivo muito grande. Máximo: ${_config.maxFileSize ~/ (1024 * 1024)}MB',
        );
      }

      // Verificar extensão
      final extension = image.path.split('.').last.toLowerCase();
      if (!_config.allowedExtensions.contains(extension)) {
        return PhotoUploadResult.error(
          'Formato não suportado. Use: ${_config.allowedExtensions.join(', ')}',
        );
      }

      // Verificar limite de fotos por restaurante
      final existingPhotos = await getRestaurantPhotos(restaurantId);
      if (existingPhotos.length >= _config.maxPhotosPerRestaurant) {
        return PhotoUploadResult.error(
          'Limite de ${_config.maxPhotosPerRestaurant} fotos por restaurante atingido',
        );
      }

      // Gerar ID único
      final photoId = 'photo_${DateTime.now().millisecondsSinceEpoch}';
      
      // Salvar localmente primeiro
      final localPath = await _savePhotoLocally(image, photoId);
      
      // Criar objeto da foto
      final photo = GalleryPhoto(
        id: photoId,
        restaurantId: restaurantId,
        url: localPath, // Temporariamente usar path local
        localPath: localPath,
        caption: caption,
        userId: _supabaseService.currentUser?.id,
        createdAt: DateTime.now(),
        source: source,
        tags: tags,
        metadata: {
          'file_size': fileSize,
          'extension': extension,
          'original_name': image.name,
        },
      );

      // Adicionar ao cache
      if (_photoCache.containsKey(restaurantId)) {
        _photoCache[restaurantId]!.insert(0, photo);
      } else {
        _photoCache[restaurantId] = [photo];
      }
      await _savePhotoCache();

      // TODO: Fazer upload para Supabase Storage em background
      // _uploadToServer(photo);

      return PhotoUploadResult.success(
        photoId: photoId,
        url: localPath,
        metadata: photo.metadata,
      );
    } catch (e) {
      debugPrint('Error processing and uploading photo: $e');
      return PhotoUploadResult.error('Erro ao processar foto: $e');
    }
  }

  /// Salvar foto localmente
  Future<String> _savePhotoLocally(XFile image, String photoId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${directory.path}/photos');
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      final extension = image.path.split('.').last;
      final fileName = '$photoId.$extension';
      final localFile = File('${photosDir.path}/$fileName');
      
      await image.saveTo(localFile.path);
      return localFile.path;
    } catch (e) {
      debugPrint('Error saving photo locally: $e');
      rethrow;
    }
  }

  /// Excluir foto
  Future<bool> deletePhoto(String photoId, String restaurantId) async {
    try {
      // Remover do cache
      if (_photoCache.containsKey(restaurantId)) {
        _photoCache[restaurantId]!.removeWhere((photo) => photo.id == photoId);
        await _savePhotoCache();
      }

      // TODO: Remover do servidor
      // await _deleteFromServer(photoId);

      return true;
    } catch (e) {
      debugPrint('Error deleting photo: $e');
      return false;
    }
  }

  /// Compartilhar foto
  Future<void> sharePhoto(GalleryPhoto photo) async {
    try {
      if (photo.localPath != null && File(photo.localPath!).existsSync()) {
        await Share.shareXFiles(
          [XFile(photo.localPath!)],
          text: photo.caption ?? 'Foto do restaurante',
        );
      } else {
        await Share.share(
          photo.url,
          subject: photo.caption ?? 'Foto do restaurante',
        );
      }
    } catch (e) {
      debugPrint('Error sharing photo: $e');
    }
  }

  /// Atualizar configurações
  Future<void> updateConfig(GalleryConfig config) async {
    _config = config;
    await _saveConfig();
  }

  /// Obter configurações atuais
  GalleryConfig get config => _config;

  /// Limpar cache de fotos
  Future<void> clearCache() async {
    _photoCache.clear();
    await _cacheService.remove('photo_cache');
  }

  /// Obter estatísticas da galeria
  Map<String, dynamic> getStatistics() {
    int totalPhotos = 0;
    int totalRestaurants = _photoCache.length;
    
    for (final photos in _photoCache.values) {
      totalPhotos += photos.length;
    }

    return {
      'total_photos': totalPhotos,
      'total_restaurants': totalRestaurants,
      'cache_size': _photoCache.length,
      'config': _config.toJson(),
    };
  }
}

/// Widget para galeria de fotos
class PhotoGalleryWidget extends StatefulWidget {
  final String restaurantId;
  final bool allowUpload;
  final int maxPhotosToShow;
  final double height;
  final VoidCallback? onPhotoTap;

  const PhotoGalleryWidget({
    super.key,
    required this.restaurantId,
    this.allowUpload = false,
    this.maxPhotosToShow = 10,
    this.height = 200,
    this.onPhotoTap,
  });

  @override
  State<PhotoGalleryWidget> createState() => _PhotoGalleryWidgetState();
}

class _PhotoGalleryWidgetState extends State<PhotoGalleryWidget> {
  final PhotoGalleryService _galleryService = PhotoGalleryService.instance;
  List<GalleryPhoto> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    try {
      final photos = await _galleryService.getRestaurantPhotos(widget.restaurantId);
      if (mounted) {
        setState(() {
          _photos = photos.take(widget.maxPhotosToShow).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_photos.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.photo_library_outlined,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                'Nenhuma foto disponível',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
              if (widget.allowUpload) ..[
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _showUploadOptions,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Adicionar Foto'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _photos.length + (widget.allowUpload ? 1 : 0),
        itemBuilder: (context, index) {
          if (widget.allowUpload && index == _photos.length) {
            return _buildAddPhotoButton();
          }

          final photo = _photos[index];
          return _buildPhotoItem(photo);
        },
      ),
    );
  }

  Widget _buildPhotoItem(GalleryPhoto photo) {
    return Container(
      width: widget.height * 1.2,
      margin: const EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GestureDetector(
          onTap: widget.onPhotoTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagem
              photo.localPath != null && File(photo.localPath!).existsSync()
                  ? Image.file(
                      File(photo.localPath!),
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      photo.url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
              // Overlay com informações
              if (photo.caption != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Text(
                      photo.caption!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return Container(
      width: widget.height * 0.8,
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: _showUploadOptions,
          borderRadius: BorderRadius.circular(12),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo,
                size: 32,
                color: Colors.grey,
              ),
              SizedBox(height: 4),
              Text(
                'Adicionar',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar Foto'),
              onTap: () {
                NavigationHelper.safeGoBack(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da Galeria'),
              onTap: () {
                NavigationHelper.safeGoBack(context);
                _pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    final result = await _galleryService.takePhoto(
      restaurantId: widget.restaurantId,
    );

    if (result.success) {
      _loadPhotos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto adicionada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Erro ao adicionar foto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final result = await _galleryService.pickFromGallery(
      restaurantId: widget.restaurantId,
    );

    if (result.success) {
      _loadPhotos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto adicionada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Erro ao adicionar foto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
