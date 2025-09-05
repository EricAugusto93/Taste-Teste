import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

/// Service for creating custom balloon-style markers for Google Maps
/// Creates circular markers with emoji icons, borders, shadows and pointer tails
/// Includes performance optimizations with marker caching
class BalloonMarkerService {
  // Cache for generated markers to improve performance
  static final Map<String, gmaps.BitmapDescriptor> _markerCache = {};
  
  /// Clears the marker cache (useful for memory management)
  static void clearCache() {
    _markerCache.clear();
  }
  
  /// Pre-generates common markers to improve performance on first load
  static Future<void> preloadCommonMarkers() async {
    final commonEmojis = ['☕', '🍸', '🥐', '🍽️', '🛍️', '🍝', '🍔', '🍕', '🍣', '🥗'];
    
    for (final emoji in commonEmojis) {
      // Preload both normal and selected states
      await createBalloonMarker(emoji: emoji, isSelected: false);
      await createBalloonMarker(emoji: emoji, isSelected: true);
    }
    
    // Also preload user location marker
    await createUserLocationMarker();
  }
  static const double _markerSize = 40.0;
  static const double _selectedMarkerSize = 48.0; // Exactly like React example
  static const double _shadowOffset = 2.0; // Match React "0 2px"
  static const double _borderWidth = 2.0;
  static const double _tailHeight = 6.0; // Reduced for better proportion
  static const double _tailWidth = 12.0;
  
  static const Color _backgroundColor = Colors.white;
  static const Color _borderColor = Color(0xFFE5E7EB);
  static const Color _shadowColor = Colors.black26;
  
  // React-style colors - using #8B5CF6 (purple) for selected state like React example
  static const Color _selectedBorderColor = Color(0xFF8B5CF6); // Exact React color
  
  // Category colors for selected state (all use the same React purple for consistency)
  static const Map<String, Color> _categoryColors = {
    'café': Color(0xFF8B5CF6),        // React purple
    'bar': Color(0xFF8B5CF6),         // React purple
    'padaria': Color(0xFF8B5CF6),     // React purple
    'restaurante': Color(0xFF8B5CF6), // React purple
    'shopping': Color(0xFF8B5CF6),    // React purple
    'pizzaria': Color(0xFF8B5CF6),    // React purple
    'hamburgueria': Color(0xFF8B5CF6),// React purple
    'japonesa': Color(0xFF8B5CF6),    // React purple
    'italiana': Color(0xFF8B5CF6),    // React purple
    'saudavel': Color(0xFF8B5CF6),    // React purple
    'doceria': Color(0xFF8B5CF6),     // React purple
    'buffet': Color(0xFF8B5CF6),      // React purple
  };

  /// Creates a custom balloon marker icon with emoji (with caching)
  static Future<gmaps.BitmapDescriptor> createBalloonMarker({
    required String emoji,
    bool isSelected = false,
    bool isCluster = false,
    String? clusterCount,
    String? category,
  }) async {
    // WORKAROUND: Flutter Web has issues with custom BitmapDescriptor.bytes()
    // Use colored markers for web platform as fallback
    if (kIsWeb) {
      debugPrint('🌐 Web detectado - usando fallback colorido para: $emoji');
      return _createWebFallbackMarker(
        emoji: emoji, 
        isSelected: isSelected, 
        isCluster: isCluster,
        category: category,
      );
    }
    
    // Generate cache key for mobile platforms
    final cacheKey = '${emoji}_${isSelected}_${isCluster}_${clusterCount ?? ''}_${category ?? ''}';
    
    // Return cached marker if available
    if (_markerCache.containsKey(cacheKey)) {
      return _markerCache[cacheKey]!;
    }
    
    try {
      final size = isSelected ? _selectedMarkerSize : _markerSize;
      final totalHeight = size + _tailHeight + _shadowOffset;
      final totalWidth = size + _shadowOffset;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, totalWidth, totalHeight));

      // Draw shadow
      _drawShadow(canvas, size, totalWidth, totalHeight);
      
      // Draw balloon circle
      _drawBalloon(canvas, size, isSelected, isCluster, category);
      
      // Draw tail
      _drawTail(canvas, size, totalWidth, isSelected, category);
      
      // Draw emoji or cluster count
      if (isCluster && clusterCount != null) {
        _drawClusterText(canvas, size, clusterCount);
      } else {
        _drawEmoji(canvas, size, emoji);
      }

      final picture = recorder.endRecording();
      final img = await picture.toImage(totalWidth.toInt(), totalHeight.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final uint8List = byteData!.buffer.asUint8List();

      final bitmapDescriptor = gmaps.BitmapDescriptor.bytes(uint8List);
      
      // Cache the generated marker
      _markerCache[cacheKey] = bitmapDescriptor;
      
      return bitmapDescriptor;
    } catch (e) {
      debugPrint('❌ Erro ao criar balloon marker, usando fallback: $e');
      return _createWebFallbackMarker(
        emoji: emoji, 
        isSelected: isSelected, 
        isCluster: isCluster,
        category: category,
      );
    }
  }

  /// Draws the shadow behind the balloon with React-style styling (0 2px 6px rgba(0,0,0,0.15))
  static void _drawShadow(Canvas canvas, double size, double totalWidth, double totalHeight) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15) // Exact React shadow opacity
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    final shadowPath = Path();
    
    // Shadow circle
    shadowPath.addOval(Rect.fromLTWH(
      _shadowOffset, 
      _shadowOffset, 
      size, 
      size
    ));
    
    // Shadow tail
    final tailCenterX = (totalWidth - _shadowOffset) / 2;
    final tailStartY = size + _shadowOffset;
    
    shadowPath.moveTo(tailCenterX - _tailWidth / 2 + _shadowOffset, tailStartY);
    shadowPath.lineTo(tailCenterX + _shadowOffset, tailStartY + _tailHeight);
    shadowPath.lineTo(tailCenterX + _tailWidth / 2 + _shadowOffset, tailStartY);
    shadowPath.close();

    canvas.drawPath(shadowPath, shadowPaint);
  }

  /// Draws the main balloon circle with category-based coloring
  static void _drawBalloon(Canvas canvas, double size, bool isSelected, bool isCluster, String? category) {
    final center = Offset(size / 2, size / 2);
    final radius = size / 2;

    // Background circle - always white for non-cluster markers
    final backgroundPaint = Paint()
      ..color = isCluster ? const Color(0xFF6B73D9) : _backgroundColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, backgroundPaint);

    // Border circle with category color when selected
    Color borderColor = _borderColor;
    if (isSelected && category != null && !isCluster) {
      borderColor = _getCategoryColor(category);
    } else if (isSelected && isCluster) {
      borderColor = const Color(0xFF6B73D9);
    }

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _borderWidth;
    
    canvas.drawCircle(center, radius - _borderWidth / 2, borderPaint);
  }

  /// Gets the color for a category (all use React purple when selected)
  static Color _getCategoryColor(String category) {
    // All selected markers use the same React purple color for consistency
    return _selectedBorderColor;
  }

  /// Draws the tail pointing downward with 45° rotation like React CSS
  static void _drawTail(Canvas canvas, double size, double totalWidth, bool isSelected, String? category) {
    final tailPaint = Paint()
      ..color = _backgroundColor
      ..style = PaintingStyle.fill;

    Color borderColor = _borderColor;
    if (isSelected && category != null) {
      borderColor = _getCategoryColor(category);
    }

    final tailBorderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _borderWidth;

    final tailCenterX = (totalWidth - _shadowOffset) / 2;
    final tailStartY = size - 1; // Slight overlap with circle
    
    // Create rotated square tail (like CSS transform rotate(45deg))
    canvas.save();
    canvas.translate(tailCenterX, tailStartY + _tailHeight / 2);
    canvas.rotate(3.14159 / 4); // 45 degrees in radians
    
    final squareSize = _tailWidth * 0.7; // Smaller square for better proportion
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: squareSize,
      height: squareSize,
    );
    
    // Draw only the visible part (bottom-left triangle)
    final clipPath = Path();
    clipPath.moveTo(-squareSize / 2, -squareSize / 2);
    clipPath.lineTo(squareSize / 2, -squareSize / 2);
    clipPath.lineTo(-squareSize / 2, squareSize / 2);
    clipPath.close();
    
    canvas.clipPath(clipPath);
    
    // Fill the square
    canvas.drawRect(rect, tailPaint);
    
    // Draw border only on visible sides (left and bottom in original orientation)
    final borderPath = Path();
    borderPath.moveTo(-squareSize / 2, -squareSize / 2);
    borderPath.lineTo(-squareSize / 2, squareSize / 2);
    borderPath.lineTo(squareSize / 2, squareSize / 2);
    
    canvas.drawPath(borderPath, tailBorderPaint);
    canvas.restore();
  }

  /// Draws emoji in the center of the balloon
  static void _drawEmoji(Canvas canvas, double size, String emoji) {
    final textStyle = TextStyle(
      fontSize: size * 0.5,
      fontFamily: 'NotoColorEmoji',
    );
    
    final textSpan = TextSpan(
      text: emoji,
      style: textStyle,
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout();
    
    final offset = Offset(
      (size - textPainter.width) / 2,
      (size - textPainter.height) / 2,
    );
    
    textPainter.paint(canvas, offset);
  }

  /// Draws cluster count text with improved styling
  static void _drawClusterText(Canvas canvas, double size, String count) {
    final fontSize = size * 0.4; // Slightly larger for better visibility
    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w700, // Bolder text
      color: Colors.white,
      letterSpacing: -0.5,
    );
    
    final textSpan = TextSpan(
      text: count,
      style: textStyle,
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout();
    
    final offset = Offset(
      (size - textPainter.width) / 2,
      (size - textPainter.height) / 2,
    );
    
    textPainter.paint(canvas, offset);
  }

  /// Creates a user location balloon marker
  static Future<gmaps.BitmapDescriptor> createUserLocationMarker() async {
    return createBalloonMarker(emoji: '📍');
  }

  /// Creates a cluster balloon marker
  static Future<gmaps.BitmapDescriptor> createClusterMarker(int count) async {
    return createBalloonMarker(
      emoji: '',
      isCluster: true,
      clusterCount: count.toString(),
    );
  }

  /// Creates a selected state balloon marker with category coloring
  static Future<gmaps.BitmapDescriptor> createSelectedMarker(String emoji, {String? category}) async {
    return createBalloonMarker(
      emoji: emoji,
      isSelected: true,
      category: category,
    );
  }

  /// Web fallback method - creates colored markers with rich color mapping
  /// This works reliably on Flutter Web while custom BitmapDescriptor.bytes() doesn't
  static gmaps.BitmapDescriptor _createWebFallbackMarker({
    required String emoji,
    bool isSelected = false,
    bool isCluster = false,
    String? category,
  }) {
    // Enhanced color mapping based on emoji categories
    // Using more distinct colors for better visibility on web
    const emojiColorMap = {
      // Food categories with distinct colors
      '🍝': 220.0,  // Red-pink for Italian
      '☕': 30.0,   // Orange for Coffee
      '🥗': 120.0,  // Green for Healthy/Salads
      '🏛️': 240.0,  // Blue for Classic/Traditional
      '🍰': 300.0,  // Magenta for Desserts
      '🍽️': 60.0,   // Yellow for General Restaurant
      '🍸': 270.0,  // Violet for Bars/Drinks
      '🍣': 180.0,  // Azure/Cyan for Japanese
      '🍔': 25.0,   // Orange-red for Burgers
      '🍕': 10.0,   // Red for Pizza
      '🧁': 320.0,  // Pink for Confectionery
      '🥐': 45.0,   // Gold for Bakery
      '🛍️': 280.0,  // Purple for Shopping
      '🥙': 40.0,   // Orange-yellow for Arabic
      '🍛': 200.0,  // Light blue for Indian
      '🥖': 50.0,   // Yellow-green for French
      '🍺': 35.0,   // Orange for German/Beer
      '🌮': 80.0,   // Green-yellow for Mexican
      '🥡': 15.0,   // Red-orange for Chinese
      '🇧🇷': 140.0, // Green for Brazilian
      '🥩': 350.0,  // Red for Churrasco/BBQ
      '🦐': 190.0,  // Light blue for Seafood
      '🐟': 200.0,  // Blue for Fish
      '🍟': 70.0,   // Yellow for Fast Food
      '🍦': 330.0,  // Pink for Ice Cream
      '🍇': 260.0,  // Purple for Açaí
      '🥪': 90.0,   // Light green for Sandwiches
      '🌱': 100.0,  // Green for Vegan
      '🥟': 210.0,  // Light blue for Asian dumplings
      '🇺🇾': 160.0, // Blue-green for Uruguayan
      '📍': 180.0,  // Cyan for User location
    };

    // Get base color for this emoji
    double hue = emojiColorMap[emoji] ?? 30.0; // Default to orange
    
    // For clusters, use a special purple color
    if (isCluster) {
      hue = 260.0; // Purple for clusters
    }
    
    // For selected state, shift hue slightly to indicate selection
    if (isSelected && !isCluster) {
      hue = (hue + 20.0) % 360.0; // Shift hue for selected state
    }

    debugPrint('🎨 Web fallback marker - Emoji: $emoji, Hue: $hue, Selected: $isSelected, Cluster: $isCluster');
    
    return gmaps.BitmapDescriptor.defaultMarkerWithHue(hue);
  }
}