import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/restaurant_model.dart';

/// Widget avançado para criar marcadores customizados no mapa
class AdvancedMapMarker {
  /// Criar marcador premium para restaurante com design moderno
  static Future<Uint8List> createPremiumRestaurantMarker({
    required RestaurantModel restaurant,
    bool isSelected = false,
    double size = 90,
    bool showPrice = true,
    bool showRating = true,
    double animationValue = 0.0,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final markerSize = Size(size, size + 35); // Extra altura para informações
    final center = Offset(markerSize.width / 2, markerSize.height / 2 - 17);
    final radius = size / 2;

    // Animação de pulso para selecionado
    if (isSelected && animationValue > 0) {
      final pulseRadius = radius + (animationValue * 15);
      final pulseOpacity = 0.4 * (1 - animationValue);
      
      final pulsePaint = Paint()
        ..color = AppColors.primary.withOpacity(pulseOpacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(center, pulseRadius, pulsePaint);
    }

    // Sombra com múltiplas camadas para profundidade
    _drawLayeredShadow(canvas, center, radius, isSelected);

    // Background com gradiente glassmorphism
    final backgroundPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        [
          Colors.white.withOpacity(0.95),
          Colors.white.withOpacity(0.85),
          Colors.grey.shade100.withOpacity(0.9),
        ],
        [0.0, 0.7, 1.0],
      )
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, backgroundPaint);

    // Borda com gradiente dinâmico
    final borderColor = _getRestaurantBorderColor(restaurant, isSelected);
    final borderPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(center.dx - radius, center.dy - radius),
        Offset(center.dx + radius, center.dy + radius),
        [borderColor, borderColor.withOpacity(0.7)],
        [0.0, 1.0],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 4 : 3;
    
    canvas.drawCircle(center, radius, borderPaint);

    // Emoji com efeito 3D - usa emoji do banco de dados ou fallback por categoria
    final emoji = restaurant.emoji ?? _getRestaurantEmoji(restaurant.categoryId);
    await _drawEmojiWith3DEffect(canvas, emoji, center, size * 0.45);

    // Badge de status (aberto/fechado)
    if (restaurant.isOpen != null) {
      _drawStatusBadge(canvas, center, radius, restaurant.isOpen!);
    }

    // Informações na parte inferior
    var yOffset = markerSize.height - 30;
    
    if (showRating && restaurant.rating > 0) {
      yOffset = await _drawRatingBadge(
        canvas, 
        Offset(markerSize.width / 2, yOffset), 
        restaurant.rating,
      );
    }
    
    if (showPrice && restaurant.priceRange != null) {
      await _drawPriceBadge(
        canvas, 
        Offset(markerSize.width / 2, yOffset + 18), 
        restaurant.priceRange!,
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

  /// Criar marcador de emoji simples para restaurante
  static Future<Uint8List> createEmojiMarker({
    required String emoji,
    bool isSelected = false,
    double size = 60,
    double animationValue = 0.0,
    bool showRating = false,
    double? rating,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final markerSize = Size(size, size + (showRating ? 25 : 0));
    final center = Offset(markerSize.width / 2, markerSize.height / 2 - (showRating ? 12 : 0));

    // Animação de pulso para selecionado
    if (isSelected && animationValue > 0) {
      final pulseRadius = (size / 2) + (animationValue * 20);
      final pulseOpacity = 0.3 * (1 - animationValue);
      
      final pulsePaint = Paint()
        ..color = AppColors.primary.withOpacity(pulseOpacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(center, pulseRadius, pulsePaint);
    }

    // Sombra do emoji para destacar no mapa
    final shadowOffset = Offset(center.dx + 2, center.dy + 3);
    await _drawEmojiText(
      canvas, 
      emoji, 
      shadowOffset, 
      size * 0.8,
      color: Colors.black.withOpacity(0.3),
    );

    // Emoji principal
    await _drawEmojiText(canvas, emoji, center, size * 0.8);

    // Badge de rating se habilitado
    if (showRating && rating != null && rating > 0) {
      await _drawCompactRatingBadge(
        canvas,
        Offset(markerSize.width / 2, markerSize.height - 15),
        rating,
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

  /// Criar marcador de localização do usuário com animação
  static Future<Uint8List> createAnimatedUserMarker({
    double size = 70,
    double animationValue = 0.0,
    bool showAccuracy = true,
    double? accuracy,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final markerSize = Size(size, size);
    final center = Offset(markerSize.width / 2, markerSize.height / 2);

    // Círculo de precisão se disponível
    if (showAccuracy && accuracy != null && accuracy > 0) {
      final accuracyRadius = (accuracy / 10).clamp(size / 3, size);
      final accuracyPaint = Paint()
        ..color = AppColors.primary.withOpacity(0.1)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(center, accuracyRadius, accuracyPaint);
      
      final accuracyBorderPaint = Paint()
        ..color = AppColors.primary.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      
      canvas.drawCircle(center, accuracyRadius, accuracyBorderPaint);
    }

    // Múltiplos círculos de pulso animados
    for (int i = 0; i < 4; i++) {
      final pulseDelay = i * 0.25;
      final adjustedAnimation = ((animationValue + pulseDelay) % 1.0);
      final pulseRadius = (size / 3) + (adjustedAnimation * 20);
      final pulseOpacity = (0.6 * (1 - adjustedAnimation)).clamp(0.0, 0.6);
      
      final pulsePaint = Paint()
        ..color = AppColors.primary.withOpacity(pulseOpacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(center, pulseRadius, pulsePaint);
    }

    // Sombra principal
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    
    canvas.drawCircle(
      Offset(center.dx + 2, center.dy + 2),
      size / 3.5,
      shadowPaint,
    );

    // Círculo principal com gradiente
    final mainPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        size / 3.5,
        [AppColors.primary, AppColors.primaryDark],
        [0.0, 1.0],
      )
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, size / 3.5, mainPaint);

    // Borda branca com brilho
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    canvas.drawCircle(center, size / 3.5, borderPaint);

    // Ponto central animado
    final centerSize = (size / 10) + (animationValue * 3);
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, centerSize, centerPaint);

    // Converter para imagem
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      markerSize.width.toInt(),
      markerSize.height.toInt(),
    );
    
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Criar marcador de cluster premium
  static Future<Uint8List> createPremiumClusterMarker({
    required int count,
    double size = 80,
    Color? backgroundColor,
    bool isExpanded = false,
    double animationValue = 0.0,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final markerSize = Size(size, size);
    final center = Offset(markerSize.width / 2, markerSize.height / 2);
    final radius = size / 2;

    final clusterColor = backgroundColor ?? _getClusterColor(count);

    // Animação de expansão
    final animatedRadius = radius + (animationValue * 10);
    final animatedOpacity = 1.0 - (animationValue * 0.3);

    // Sombra dinâmica
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25 * animatedOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawCircle(
      Offset(center.dx + 3, center.dy + 3),
      animatedRadius,
      shadowPaint,
    );

    // Background com gradiente
    final backgroundPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        animatedRadius,
        [
          clusterColor,
          clusterColor.withOpacity(0.8),
          clusterColor.withOpacity(0.9),
        ],
        [0.0, 0.7, 1.0],
      )
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, animatedRadius, backgroundPaint);

    // Borda com brilho
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(animatedOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawCircle(center, animatedRadius, borderPaint);

    // Texto do contador com sombra
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: _getClusterFontSize(count, size),
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.5),
          offset: const Offset(1, 1),
          blurRadius: 2,
        ),
      ],
    );

    final textPainter = TextPainter(
      text: TextSpan(text: count.toString(), style: textStyle),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
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

  // Métodos auxiliares privados
  
  static void _drawLayeredShadow(Canvas canvas, Offset center, double radius, bool isSelected) {
    final shadowLayers = isSelected ? 3 : 2;
    
    for (int i = 0; i < shadowLayers; i++) {
      final shadowOffset = Offset(2.0 + i, 2.0 + i);
      final shadowOpacity = 0.15 - (i * 0.05);
      final shadowBlur = 4.0 + (i * 2);
      
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(shadowOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur);
      
      canvas.drawCircle(
        Offset(center.dx + shadowOffset.dx, center.dy + shadowOffset.dy),
        radius + i,
        shadowPaint,
      );
    }
  }

  static Color _getRestaurantBorderColor(RestaurantModel restaurant, bool isSelected) {
    if (isSelected) return AppColors.primary;
    
    if (restaurant.rating >= 4.5) return Colors.green;
    if (restaurant.rating >= 4.0) return Colors.orange;
    if (restaurant.rating >= 3.5) return AppColors.primary;
    return Colors.grey;
  }

  static String _getRestaurantEmoji(String? category) {
    switch (category?.toLowerCase()) {
      case 'pizza': return '🍕';
      case 'hamburguer': return '🍔';
      case 'japonesa': return '🍣';
      case 'chinesa': return '🥡';
      case 'brasileira': return '🍽️';
      case 'mexicana': return '🌮';
      case 'doce': return '🍰';
      case 'café': return '☕';
      case 'vegetariana': return '🥗';
      case 'churrasco': return '🥩';
      case 'frutos do mar': return '🐟';
      case 'árabe': return '🥙';
      case 'indiana': return '🍛';
      default: return '🍽️';
    }
  }

  static Future<void> _drawEmojiWith3DEffect(
    Canvas canvas, 
    String emoji, 
    Offset center, 
    double size,
  ) async {
    // Sombra do emoji
    final emojiShadowPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: size,
          fontFamily: 'NotoColorEmoji',
          foreground: Paint()
            ..color = Colors.black.withOpacity(0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    emojiShadowPainter.layout();
    emojiShadowPainter.paint(
      canvas,
      Offset(
        center.dx - emojiShadowPainter.width / 2 + 1,
        center.dy - emojiShadowPainter.height / 2 + 1,
      ),
    );

    // Emoji principal
    final emojiPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: size,
          fontFamily: 'NotoColorEmoji',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    emojiPainter.layout();
    emojiPainter.paint(
      canvas,
      Offset(
        center.dx - emojiPainter.width / 2,
        center.dy - emojiPainter.height / 2,
      ),
    );
  }

  static void _drawStatusBadge(Canvas canvas, Offset center, double radius, bool isOpen) {
    final badgeCenter = Offset(center.dx + radius * 0.7, center.dy - radius * 0.7);
    final badgeRadius = 8.0;
    
    // Sombra do badge
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    canvas.drawCircle(
      Offset(badgeCenter.dx + 1, badgeCenter.dy + 1),
      badgeRadius,
      shadowPaint,
    );
    
    // Background do badge
    final badgePaint = Paint()
      ..color = isOpen ? Colors.green : Colors.red
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(badgeCenter, badgeRadius, badgePaint);
    
    // Borda branca
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(badgeCenter, badgeRadius, borderPaint);
  }

  static Future<double> _drawRatingBadge(
    Canvas canvas, 
    Offset position, 
    double rating,
  ) async {
    final badgeWidth = 45.0;
    final badgeHeight = 20.0;
    
    // Sombra
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    final shadowRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(position.dx + 1, position.dy + 1),
        width: badgeWidth,
        height: badgeHeight,
      ),
      const Radius.circular(10),
    );
    
    canvas.drawRRect(shadowRect, shadowPaint);
    
    // Background
    final ratingColor = _getRatingColor(rating);
    final backgroundPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(position.dx - badgeWidth/2, position.dy),
        Offset(position.dx + badgeWidth/2, position.dy),
        [ratingColor, ratingColor.withOpacity(0.8)],
        [0.0, 1.0],
      )
      ..style = PaintingStyle.fill;
    
    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: position,
        width: badgeWidth,
        height: badgeHeight,
      ),
      const Radius.circular(10),
    );
    
    canvas.drawRRect(backgroundRect, backgroundPaint);
    
    // Texto
    final textPainter = TextPainter(
      text: TextSpan(
        text: '⭐${rating.toStringAsFixed(1)}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
    
    return position.dy;
  }

  static Future<void> _drawPriceBadge(
    Canvas canvas, 
    Offset position, 
    String priceRange,
  ) async {
    final badgeWidth = 35.0;
    final badgeHeight = 16.0;
    
    // Background
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.fill;
    
    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: position,
        width: badgeWidth,
        height: badgeHeight,
      ),
      const Radius.circular(8),
    );
    
    canvas.drawRRect(backgroundRect, backgroundPaint);
    
    // Texto
    final textPainter = TextPainter(
      text: TextSpan(
        text: priceRange,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  static Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.orange;
    if (rating >= 3.5) return Colors.amber;
    return Colors.red;
  }

  static Color _getClusterColor(int count) {
    if (count >= 50) return Colors.red;
    if (count >= 20) return Colors.orange;
    if (count >= 10) return AppColors.primary;
    return Colors.blue;
  }

  static double _getClusterFontSize(int count, double markerSize) {
    if (count >= 100) return markerSize * 0.25;
    if (count >= 10) return markerSize * 0.3;
    return markerSize * 0.35;
  }

  /// Desenhar emoji como texto simples (sem efeito 3D)
  static Future<void> _drawEmojiText(
    Canvas canvas, 
    String emoji, 
    Offset center, 
    double size, {
    Color? color,
  }) async {
    final emojiPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: size,
          fontFamily: 'NotoColorEmoji',
          color: color,
          foreground: color != null ? (Paint()..color = color) : null,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    emojiPainter.layout();
    emojiPainter.paint(
      canvas,
      Offset(
        center.dx - emojiPainter.width / 2,
        center.dy - emojiPainter.height / 2,
      ),
    );
  }

  /// Desenhar badge compacto de rating
  static Future<double> _drawCompactRatingBadge(
    Canvas canvas,
    Offset position,
    double rating,
  ) async {
    final badgeSize = 20.0;
    final radius = badgeSize / 2;

    // Background do badge
    final backgroundPaint = Paint()
      ..color = _getRatingColor(rating)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(position, radius, backgroundPaint);

    // Borda do badge
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(position, radius, borderPaint);

    // Texto do rating
    final ratingText = rating.toStringAsFixed(1);
    final textPainter = TextPainter(
      text: TextSpan(
        text: ratingText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );

    return badgeSize;
  }
}