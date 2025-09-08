import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Widget para criar marcadores customizados no mapa
class CustomMapMarker {
  /// Criar marcador customizado para restaurante
  static Future<Uint8List> createRestaurantMarker({
    required String emoji,
    required double rating,
    bool isSelected = false,
    double size = 80,
    bool isAnimated = false,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final markerSize = Size(size, size + 25); // Extra altura para o rating
    final center = Offset(markerSize.width / 2, markerSize.height / 2 - 12);
    final radius = size / 2;

    // Desenhar sombra mais suave
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(
      Offset(center.dx + 3, center.dy + 3),
      radius + (isSelected ? 4 : 0),
      shadowPaint,
    );

    // Desenhar círculo de pulso para selecionado
    if (isSelected) {
      final pulsePaint = Paint()
        ..color = AppColors.primary.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius + 8, pulsePaint);
    }

    // Desenhar gradiente principal
    final gradientPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        isSelected
            ? [AppColors.primary, AppColors.primaryDark]
            : [Colors.white, const Color(0xFFF8F9FA)],
        [0.0, 1.0],
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, gradientPaint);

    // Desenhar borda com gradiente
    final borderPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(center.dx - radius, center.dy - radius),
        Offset(center.dx + radius, center.dy + radius),
        isSelected
            ? [AppColors.primaryDark, AppColors.primary]
            : [AppColors.primary, AppColors.primaryLight],
        [0.0, 1.0],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 4 : 3;

    canvas.drawCircle(center, radius, borderPaint);

    // Desenhar emoji com sombra
    final emojiShadowPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: size * 0.4,
          fontFamily: 'NotoColorEmoji',
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    emojiShadowPainter.layout();
    emojiShadowPainter.paint(
      canvas,
      Offset(
        (markerSize.width - emojiShadowPainter.width) / 2,
        center.dy - emojiShadowPainter.height / 2,
      ),
    );

    // Desenhar rating com design melhorado
    if (rating > 0) {
      final ratingCenter = Offset(markerSize.width / 2, markerSize.height - 12);
      const ratingWidth = 40.0;
      const ratingHeight = 20.0;

      // Sombra do rating
      final ratingShadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      final ratingShadowRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(ratingCenter.dx + 1, ratingCenter.dy + 1),
          width: ratingWidth,
          height: ratingHeight,
        ),
        const Radius.circular(10),
      );

      canvas.drawRRect(ratingShadowRect, ratingShadowPaint);

      // Background do rating com gradiente
      final ratingColor = _getRatingColor(rating);
      final ratingBgPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(ratingCenter.dx - ratingWidth / 2, ratingCenter.dy),
          Offset(ratingCenter.dx + ratingWidth / 2, ratingCenter.dy),
          [ratingColor, ratingColor.withOpacity(0.8)],
          [0.0, 1.0],
        )
        ..style = PaintingStyle.fill;

      final ratingRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: ratingCenter,
          width: ratingWidth,
          height: ratingHeight,
        ),
        const Radius.circular(10),
      );

      canvas.drawRRect(ratingRect, ratingBgPaint);

      // Texto do rating
      final ratingTextPainter = TextPainter(
        text: TextSpan(
          text: rating.toStringAsFixed(1),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0.5, 0.5),
                blurRadius: 1,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      ratingTextPainter.layout();
      ratingTextPainter.paint(
        canvas,
        Offset(
          ratingCenter.dx - ratingTextPainter.width / 2,
          ratingCenter.dy - ratingTextPainter.height / 2,
        ),
      );
    }

    // Converter para imagem
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      markerSize.width.toInt(),
      markerSize.height.toInt(),
    );

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Criar marcador para localização do usuário
  static Future<Uint8List> createUserLocationMarker({
    double size = 60,
    bool isAnimated = false,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final markerSize = Size(size, size);
    final center = Offset(markerSize.width / 2, markerSize.height / 2);

    // Desenhar múltiplos círculos de pulso para animação
    for (int i = 0; i < 3; i++) {
      final pulseRadius = (size / 2) + (i * 8);
      final pulseOpacity = 0.4 - (i * 0.1);

      final pulsePaint = Paint()
        ..color = AppColors.primary.withOpacity(pulseOpacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, pulseRadius, pulsePaint);
    }

    // Desenhar sombra
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(
      Offset(center.dx + 2, center.dy + 2),
      size / 3,
      shadowPaint,
    );

    // Desenhar círculo principal com gradiente
    final mainPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        size / 3,
        [AppColors.primary, AppColors.primaryDark],
        [0.0, 1.0],
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, size / 3, mainPaint);

    // Desenhar borda branca
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, size / 3, borderPaint);

    // Desenhar ponto central
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, size / 8, centerPaint);

    // Converter para imagem
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      markerSize.width.toInt(),
      markerSize.height.toInt(),
    );

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Criar marcador animado para restaurante
  static Future<Uint8List> createAnimatedRestaurantMarker({
    required String emoji,
    required double rating,
    required double animationValue, // 0.0 a 1.0
    double size = 80,
  }) async {
    final animatedSize = size + (animationValue * 10);
    return createRestaurantMarker(
      emoji: emoji,
      rating: rating,
      isSelected: true,
      size: animatedSize,
      isAnimated: true,
    );
  }

  /// Criar marcador para categoria
  static Future<Uint8List> createCategoryMarker({
    required IconData icon,
    required Color color,
    double size = 70,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final markerSize = Size(size, size);
    final center = Offset(markerSize.width / 2, markerSize.height / 2);

    // Desenhar sombra
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(
      Offset(center.dx + 2, center.dy + 2),
      size / 2,
      shadowPaint,
    );

    // Desenhar círculo principal com gradiente
    final mainPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        size / 2,
        [color, color.withOpacity(0.8)],
        [0.0, 1.0],
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, size / 2, mainPaint);

    // Desenhar borda
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, size / 2, borderPaint);

    // Desenhar ícone com sombra
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          fontSize: size * 0.4,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        center.dx - iconPainter.width / 2,
        center.dy - iconPainter.height / 2,
      ),
    );

    // Converter para imagem
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      markerSize.width.toInt(),
      markerSize.height.toInt(),
    );

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Obter emoji baseado na categoria do restaurante
  static String getRestaurantEmoji(String? category) {
    switch (category?.toLowerCase()) {
      case 'pizza':
      case 'italiana':
        return '🍕';
      case 'hamburguer':
      case 'lanche':
        return '🍔';
      case 'japonesa':
      case 'sushi':
        return '🍣';
      case 'chinesa':
      case 'asiática':
        return '🥡';
      case 'brasileira':
      case 'caseira':
        return '🍽️';
      case 'mexicana':
        return '🌮';
      case 'doce':
      case 'sobremesa':
        return '🍰';
      case 'café':
      case 'cafeteria':
        return '☕';
      case 'vegetariana':
      case 'vegana':
        return '🥗';
      case 'churrasco':
      case 'carne':
        return '🥩';
      case 'frutos do mar':
      case 'peixe':
        return '🐟';
      case 'árabe':
        return '🥙';
      case 'indiana':
        return '🍛';
      default:
        return '🍽️';
    }
  }

  /// Obter cor baseada na categoria
  static Color getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'pizza':
      case 'italiana':
        return const Color(0xFFE74C3C);
      case 'hamburguer':
      case 'lanche':
        return const Color(0xFFF39C12);
      case 'japonesa':
      case 'sushi':
        return const Color(0xFF9B59B6);
      case 'chinesa':
      case 'asiática':
        return const Color(0xFFE67E22);
      case 'brasileira':
      case 'caseira':
        return const Color(0xFF27AE60);
      case 'mexicana':
        return const Color(0xFFF1C40F);
      case 'doce':
      case 'sobremesa':
        return const Color(0xFFE91E63);
      case 'café':
      case 'cafeteria':
        return const Color(0xFF795548);
      case 'vegetariana':
      case 'vegana':
        return const Color(0xFF4CAF50);
      default:
        return AppColors.primary;
    }
  }

  /// Obter cor baseada no rating
  static Color _getRatingColor(double rating) {
    if (rating >= 4.5) {
      return const Color(0xFF4CAF50); // Verde para excelente
    } else if (rating >= 4.0) {
      return const Color(0xFF8BC34A); // Verde claro para muito bom
    } else if (rating >= 3.5) {
      return const Color(0xFFFFC107); // Amarelo para bom
    } else if (rating >= 3.0) {
      return const Color(0xFFFF9800); // Laranja para regular
    } else {
      return const Color(0xFFFF5722); // Vermelho para ruim
    }
  }
}

/// Widget para InfoWindow customizada
class CustomInfoWindow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double? rating;
  final String? deliveryTime;
  final String? distance;
  final VoidCallback? onTap;
  final String? imageUrl;

  const CustomInfoWindow({
    super.key,
    required this.title,
    this.subtitle,
    this.rating,
    this.deliveryTime,
    this.distance,
    this.onTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com imagem (se disponível)
            if (imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl!,
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 80,
                      color: AppColors.surfaceVariant,
                      child: const Icon(
                        Icons.restaurant,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Título
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Subtítulo
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 8),

            // Informações adicionais
            Row(
              children: [
                // Rating
                if (rating != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Tempo de entrega
                if (deliveryTime != null) ...[
                  const Icon(
                    Icons.access_time,
                    size: 12,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    deliveryTime!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Distância
                if (distance != null) ...[
                  const Icon(
                    Icons.location_on,
                    size: 12,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    distance!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],

                const Spacer(),

                // Seta indicando que é clicável
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
