import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import '../../core/config/supabase_config.dart';
import '../../core/error/exceptions.dart';
import 'auth_service.dart';

/// Serviço para upload e gerenciamento de imagens no Supabase Storage
class ImageUploadService {
  static ImageUploadService? _instance;
  static ImageUploadService get instance => _instance ??= ImageUploadService._();
  ImageUploadService._();

  /// Cliente Supabase
  SupabaseClient get _client => SupabaseConfig.client;

  /// Bucket de imagens
  static const String _bucketName = 'images';

  /// Faz upload de uma imagem
  Future<String> uploadImage({
    required Uint8List imageBytes,
    required String fileName,
    String folder = 'restaurants',
    bool compress = true,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      final userId = AuthService.instance.userId;
      if (userId == null) {
        throw const AuthException('Usuário não autenticado');
      }

      // Comprimir imagem se necessário
      Uint8List processedBytes = imageBytes;
      if (compress) {
        processedBytes = await _compressImage(
          imageBytes,
          maxWidth: maxWidth ?? 1024,
          maxHeight: maxHeight ?? 1024,
        );
      }

      // Gerar nome único para o arquivo
      final extension = path.extension(fileName).toLowerCase();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_${userId}$extension';
      final filePath = '$folder/$uniqueFileName';

      debugPrint('Fazendo upload da imagem: $filePath');
      debugPrint('Tamanho original: ${imageBytes.length} bytes');
      debugPrint('Tamanho comprimido: ${processedBytes.length} bytes');

      // Fazer upload
      final uploadResult = await _client.storage
          .from(_bucketName)
          .uploadBinary(filePath, processedBytes);

      if (uploadResult.isEmpty) {
        throw const ServerException('Falha no upload da imagem');
      }

      // Obter URL pública
      final publicUrl = _client.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      debugPrint('Upload concluído: $publicUrl');
      return publicUrl;
    } on StorageException catch (e) {
      debugPrint('Erro de storage no upload: ${e.message}');
      throw ServerException('Erro no upload: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      debugPrint('Erro inesperado no upload: $e');
      throw ServerException('Erro inesperado no upload da imagem');
    }
  }

  /// Faz upload de múltiplas imagens
  Future<List<String>> uploadMultipleImages({
    required List<Uint8List> imagesBytes,
    required List<String> fileNames,
    String folder = 'restaurants',
    bool compress = true,
    int? maxWidth,
    int? maxHeight,
  }) async {
    if (imagesBytes.length != fileNames.length) {
      throw const CacheException('Número de imagens e nomes devem ser iguais');
    }

    final urls = <String>[];
    
    for (int i = 0; i < imagesBytes.length; i++) {
      try {
        final url = await uploadImage(
          imageBytes: imagesBytes[i],
          fileName: fileNames[i],
          folder: folder,
          compress: compress,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
        urls.add(url);
      } catch (e) {
        debugPrint('Erro no upload da imagem ${fileNames[i]}: $e');
        // Continua com as outras imagens
        rethrow;
      }
    }

    return urls;
  }

  /// Remove uma imagem do storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final userId = AuthService.instance.userId;
      if (userId == null) {
        throw const AuthException('Usuário não autenticado');
      }

      // Extrair o caminho do arquivo da URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      // Encontrar o índice do bucket
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        throw const CacheException('URL de imagem inválida');
      }

      // Extrair o caminho do arquivo
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
      
      debugPrint('Removendo imagem: $filePath');

      // Verificar se o usuário tem permissão (arquivo deve estar em sua pasta)
      if (!filePath.contains(userId)) {
        throw const AuthException('Sem permissão para remover esta imagem');
      }

      // Remover arquivo
      final result = await _client.storage
          .from(_bucketName)
          .remove([filePath]);

      if (result.isEmpty) {
        throw const ServerException('Falha ao remover imagem');
      }

      debugPrint('Imagem removida com sucesso');
    } on StorageException catch (e) {
      debugPrint('Erro de storage na remoção: ${e.message}');
      throw ServerException('Erro na remoção: ${e.message}');
    } catch (e) {
      if (e is AuthException || e is CacheException) rethrow;
      debugPrint('Erro inesperado na remoção: $e');
      throw ServerException('Erro inesperado na remoção da imagem');
    }
  }

  /// Remove múltiplas imagens
  Future<void> deleteMultipleImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      try {
        await deleteImage(url);
      } catch (e) {
        debugPrint('Erro ao remover imagem $url: $e');
        // Continua removendo as outras
      }
    }
  }

  /// Lista imagens de uma pasta
  Future<List<String>> listImages({
    String folder = 'restaurants',
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final result = await _client.storage
          .from(_bucketName)
          .list(
            path: folder,
            options: const SearchOptions(
              limit: 100,
              offset: 0,
            ),
          );

      return result
          .where((file) => _isImageFile(file.name))
          .map((file) => _client.storage
              .from(_bucketName)
              .getPublicUrl('$folder/${file.name}'))
          .toList();
    } on StorageException catch (e) {
      debugPrint('Erro ao listar imagens: ${e.message}');
      throw ServerException('Erro ao listar imagens: ${e.message}');
    } catch (e) {
      debugPrint('Erro inesperado ao listar imagens: $e');
      throw ServerException('Erro inesperado ao listar imagens');
    }
  }

  /// Obtém informações de uma imagem
  Future<Map<String, dynamic>?> getImageInfo(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        return null;
      }

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
      
      final result = await _client.storage
          .from(_bucketName)
          .info(filePath);

      return {
        'id': result.id,
        'name': result.name,
        'size': result.metadata?['size'],
        'content_type': result.metadata?['mimetype'],
        'created_at': result.createdAt,
        'updated_at': result.updatedAt,
      };
    } catch (e) {
      debugPrint('Erro ao obter informações da imagem: $e');
      return null;
    }
  }

  /// Gera URL assinada para acesso temporário
  Future<String> createSignedUrl(
    String filePath, {
    Duration expiresIn = const Duration(hours: 1),
  }) async {
    try {
      final signedUrl = await _client.storage
          .from(_bucketName)
          .createSignedUrl(filePath, expiresIn.inSeconds);

      return signedUrl;
    } on StorageException catch (e) {
      debugPrint('Erro ao criar URL assinada: ${e.message}');
      throw ServerException('Erro ao gerar URL: ${e.message}');
    } catch (e) {
      debugPrint('Erro inesperado ao criar URL assinada: $e');
      throw ServerException('Erro inesperado ao gerar URL');
    }
  }

  /// Comprime uma imagem
  Future<Uint8List> _compressImage(
    Uint8List imageBytes, {
    required int maxWidth,
    required int maxHeight,
    int quality = 85,
  }) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const CacheException('Não foi possível decodificar a imagem');
      }

      // Redimensionar se necessário
      img.Image resized = image;
      if (image.width > maxWidth || image.height > maxHeight) {
        resized = img.copyResize(
          image,
          width: image.width > maxWidth ? maxWidth : null,
          height: image.height > maxHeight ? maxHeight : null,
          maintainAspect: true,
        );
      }

      // Comprimir
      final compressedBytes = img.encodeJpg(resized, quality: quality);
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      debugPrint('Erro na compressão da imagem: $e');
      // Se falhar na compressão, retorna a imagem original
      return imageBytes;
    }
  }

  /// Verifica se um arquivo é uma imagem
  bool _isImageFile(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(extension);
  }

  /// Valida o tamanho do arquivo
  bool isValidFileSize(Uint8List imageBytes, {int maxSizeMB = 10}) {
    final sizeInMB = imageBytes.length / (1024 * 1024);
    return sizeInMB <= maxSizeMB;
  }

  /// Valida o tipo de arquivo
  bool isValidImageType(String fileName) {
    return _isImageFile(fileName);
  }

  /// Obtém estatísticas de uso do storage
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final userId = AuthService.instance.userId;
      if (userId == null) {
        throw const AuthException('Usuário não autenticado');
      }

      // Listar arquivos do usuário
      final userFiles = await _client.storage
          .from(_bucketName)
          .list(path: 'restaurants');

      final userImages = userFiles
          .where((file) => file.name.contains(userId) && _isImageFile(file.name))
          .toList();

      final totalSize = userImages.fold<int>(
        0,
        (sum, file) => sum + (file.metadata?['size'] as int? ?? 0),
      );

      return {
        'total_images': userImages.length,
        'total_size_bytes': totalSize,
        'total_size_mb': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      debugPrint('Erro ao obter estatísticas: $e');
      return {
        'total_images': 0,
        'total_size_bytes': 0,
        'total_size_mb': '0.00',
      };
    }
  }
}