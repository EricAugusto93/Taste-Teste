import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:taste_app/core/theme/app_colors.dart';

class SkeletonLoading extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonLoading({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// Skeleton para card de restaurante
class RestaurantCardSkeleton extends StatelessWidget {
  const RestaurantCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagem
          SkeletonLoading(
            width: 80,
            height: 80,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 16),

          // Conteúdo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome do restaurante
                const SkeletonLoading(
                  width: double.infinity,
                  height: 16,
                ),
                const SizedBox(height: 8),

                // Categoria
                SkeletonLoading(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: 12,
                ),
                const SizedBox(height: 8),

                // Rating e tempo
                Row(
                  children: [
                    const SkeletonLoading(
                      width: 60,
                      height: 12,
                    ),
                    const SizedBox(width: 16),
                    SkeletonLoading(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Skeleton para lista horizontal de restaurantes
class HorizontalRestaurantListSkeleton extends StatelessWidget {
  const HorizontalRestaurantListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoading(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 20,
              ),
              const SkeletonLoading(
                width: 60,
                height: 16,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Lista horizontal
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagem
                    SkeletonLoading(
                      width: double.infinity,
                      height: 120,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    const SizedBox(height: 8),

                    // Nome
                    const SkeletonLoading(
                      width: double.infinity,
                      height: 16,
                    ),
                    const SizedBox(height: 4),

                    // Categoria
                    const SkeletonLoading(
                      width: 100,
                      height: 12,
                    ),
                    const SizedBox(height: 4),

                    // Rating
                    const SkeletonLoading(
                      width: 80,
                      height: 12,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Skeleton para grid de categorias
class CategoriesGridSkeleton extends StatelessWidget {
  const CategoriesGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Column(
            children: [
              // Ícone
              SkeletonLoading(
                width: 60,
                height: 60,
                borderRadius: BorderRadius.circular(30),
              ),
              const SizedBox(height: 8),

              // Nome da categoria
              const SkeletonLoading(
                width: double.infinity,
                height: 12,
              ),
            ],
          );
        },
      ),
    );
  }
}

// Skeleton para a home page completa
class HomePageSkeleton extends StatelessWidget {
  const HomePageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header skeleton
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoading(
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: 16,
                      ),
                      const SizedBox(height: 4),
                      SkeletonLoading(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 20,
                      ),
                    ],
                  ),
                  const SkeletonLoading(
                    width: 40,
                    height: 40,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ],
              ),
            ),
          ),

          // Search skeleton
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const SkeletonLoading(
                width: double.infinity,
                height: 48,
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
            ),
          ),

          // Map skeleton
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: const SkeletonLoading(
                width: double.infinity,
                height: 200,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Categories title skeleton
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SkeletonLoading(
                width: MediaQuery.of(context).size.width * 0.3,
                height: 20,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Categories skeleton
          const SliverToBoxAdapter(
            child: CategoriesGridSkeleton(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Horizontal list skeleton
          const SliverToBoxAdapter(
            child: HorizontalRestaurantListSkeleton(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Vertical list skeleton
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const RestaurantCardSkeleton(),
              childCount: 3,
            ),
          ),
        ],
      ),
    );
  }
}
