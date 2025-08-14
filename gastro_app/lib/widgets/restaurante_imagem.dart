import 'package:flutter/material.dart';

class RestauranteImagem extends StatelessWidget {
  final String? imagemUrl;
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxFit? fit;

  const RestauranteImagem({
    super.key,
    this.imagemUrl,
    this.width = 100,
    this.height = 80,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        color: Colors.grey.shade100,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: imagemUrl != null && imagemUrl!.isNotEmpty
            ? Image.network(
                imagemUrl!,
                width: width,
                height: height,
                fit: fit,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildPlaceholder(showLoading: true);
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder({bool showLoading = false}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: showLoading
          ? Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.deepOrange.shade300,
                  ),
                ),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant,
                  size: width * 0.3,
                  color: Colors.grey.shade400,
                ),
                if (height > 60) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Sem imagem',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
    );
  }
} 