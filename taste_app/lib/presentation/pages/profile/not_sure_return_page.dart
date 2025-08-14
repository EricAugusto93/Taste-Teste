import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart' as custom;

/// Página "Não sei se eu volto" - Lista de lugares com experiências duvidosas
class NotSureReturnPage extends ConsumerStatefulWidget {
  const NotSureReturnPage({super.key});

  @override
  ConsumerState<NotSureReturnPage> createState() => _NotSureReturnPageState();
}

class _NotSureReturnPageState extends ConsumerState<NotSureReturnPage> {
  final List<NotSureReturnItem> _mockItems = [
    NotSureReturnItem(
      id: '1',
      name: 'Restaurante do Centro',
      category: 'Brasileira',
      location: 'Centro, São Paulo',
      imageUrl: 'https://via.placeholder.com/300x200',
      visitDate: DateTime.now().subtract(const Duration(days: 15)),
      reason: 'Atendimento demorado e comida fria',
      rating: 2,
    ),
    NotSureReturnItem(
      id: '2',
      name: 'Pizzaria da Esquina',
      category: 'Italiana',
      location: 'Vila Olímpia, São Paulo',
      imageUrl: 'https://via.placeholder.com/300x200',
      visitDate: DateTime.now().subtract(const Duration(days: 30)),
      reason: 'Pizza muito salgada, ambiente barulhento',
      rating: 2,
    ),
    NotSureReturnItem(
      id: '3',
      name: 'Lanchonete Express',
      category: 'Fast Food',
      location: 'Paulista, São Paulo',
      imageUrl: 'https://via.placeholder.com/300x200',
      visitDate: DateTime.now().subtract(const Duration(days: 7)),
      reason: 'Preço alto para a qualidade oferecida',
      rating: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Não sei se eu volto',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF4A5FBF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_mockItems.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _buildItemsList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF4A5FBF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF87CEEB).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sentiment_neutral,
                  color: Color(0xFF87CEEB),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Experiências duvidosas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_mockItems.length} lugares visitados',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockItems.length,
      itemBuilder: (context, index) {
        final item = _mockItems[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(NotSureReturnItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              height: 160,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Icon(
                Icons.restaurant,
                size: 48,
                color: Colors.grey,
              ),
            ),
          ),
          
          // Conteúdo
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: AppTextStyles.headingSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeItem(item.id),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF87CEEB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.category,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF87CEEB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _buildRating(item.rating),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.location,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_outlined,
                            size: 16,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Motivo da dúvida:',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.reason,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Visitado há ${_getTimeAgo(item.visitDate)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 16,
          color: index < rating ? Colors.amber : Colors.grey,
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF87CEEB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.sentiment_satisfied,
                size: 64,
                color: Color(0xFF87CEEB),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Que bom!',
              style: AppTextStyles.headingMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Você ainda não teve experiências duvidosas. Continue explorando novos lugares!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                NavigationHelper.safeGoBack(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF87CEEB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Explorar restaurantes',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeItem(String itemId) {
    setState(() {
      _mockItems.removeWhere((item) => item.id == itemId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removido da lista'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} dias';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} horas';
    } else {
      return 'agora';
    }
  }
}

/// Modelo para itens da lista "Não sei se eu volto"
class NotSureReturnItem {
  final String id;
  final String name;
  final String category;
  final String location;
  final String imageUrl;
  final DateTime visitDate;
  final String reason;
  final int rating;

  NotSureReturnItem({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.imageUrl,
    required this.visitDate,
    required this.reason,
    required this.rating,
  });
}