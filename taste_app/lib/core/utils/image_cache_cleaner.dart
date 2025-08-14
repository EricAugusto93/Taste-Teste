import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';
import '../services/cache_service.dart';

/// Utilitário para limpar cache de imagens problemáticas
class ImageCacheCleaner {
  static final CacheService _cacheService = GetIt.instance<CacheService>();

  /// Limpa todo o cache de imagens
  static Future<void> clearAllImageCache() async {
    try {
      // Limpar cache do CachedNetworkImage
      await DefaultCacheManager().emptyCache();
      
      // Limpar cache interno do app
      await _cacheService.clear();
      
      debugPrint('Cache de imagens limpo com sucesso');
    } catch (e) {
      debugPrint('Erro ao limpar cache de imagens: $e');
    }
  }

  /// Limpa cache de uma imagem específica
  static Future<void> clearImageCache(String imageUrl) async {
    try {
      // Remover do cache do CachedNetworkImage
      await DefaultCacheManager().removeFile(imageUrl);
      
      debugPrint('Cache da imagem removido: $imageUrl');
    } catch (e) {
      debugPrint('Erro ao remover cache da imagem: $e');
    }
  }

  /// Limpa cache de imagens problemáticas conhecidas
  static Future<void> clearProblematicImages() async {
    final problematicUrls = [
      // URL removida para evitar erros CORS
      // Adicione outras URLs problemáticas aqui
    ];

    for (final url in problematicUrls) {
      await clearImageCache(url);
    }

    debugPrint('Cache de imagens problemáticas limpo');
  }

  /// Força recarregamento de todas as imagens na tela
  static void forceImageReload() {
    try {
      // Limpar cache de imagens em memória
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      
      debugPrint('Cache de imagens em memória limpo');
    } catch (e) {
      debugPrint('Erro ao limpar cache em memória: $e');
    }
  }

  /// Método completo para resolver problemas de imagem
  static Future<void> fixImageIssues() async {
    await clearProblematicImages();
    await clearAllImageCache();
    forceImageReload();
    
    debugPrint('Problemas de imagem corrigidos');
  }
}