import 'package:flutter/material.dart';
import '../../core/utils/image_cache_cleaner.dart';
import '../../core/theme/app_colors.dart';

/// Widget de debug para limpar cache de imagens
class DebugImageCacheWidget extends StatelessWidget {
  const DebugImageCacheWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Debug: Cache de Imagens',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await ImageCacheCleaner.clearProblematicImages();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cache de imagens problemáticas limpo'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Limpar\nProblemas'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await ImageCacheCleaner.clearAllImageCache();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Todo cache de imagens limpo'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Limpar\nTudo'),
              ),
              ElevatedButton(
                onPressed: () {
                  ImageCacheCleaner.forceImageReload();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Imagens recarregadas'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Recarregar\nImagens'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
