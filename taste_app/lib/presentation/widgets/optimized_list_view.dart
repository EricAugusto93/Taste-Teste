import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/animations/animation_service.dart';
import 'loading_widget.dart';

/// Widget otimizado para listas com lazy loading e paginação infinita
class OptimizedListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function()? onLoadMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMoreItems;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;
  final double loadMoreThreshold;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final Widget? loadingMoreWidget;
  final bool enableAnimations;
  final Duration animationDelay;
  final int visibleItemsThreshold;
  final bool enableLazyLoading;
  final double? itemExtent;

  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMoreItems = true,
    this.scrollController,
    this.padding,
    this.loadMoreThreshold = 200.0,
    this.emptyWidget,
    this.loadingWidget,
    this.loadingMoreWidget,
    this.enableAnimations = true,
    this.animationDelay = const Duration(milliseconds: 50),
    this.visibleItemsThreshold = 5,
    this.enableLazyLoading = true,
    this.itemExtent,
  });

  @override
  State<OptimizedListView<T>> createState() => _OptimizedListViewState<T>();
}

class _OptimizedListViewState<T> extends State<OptimizedListView<T>> {
  late ScrollController _scrollController;
  final Set<int> _visibleItems = {};
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;

    // Verificar se deve carregar mais itens
    if (_shouldLoadMore()) {
      _loadMore();
    }
  }

  bool _shouldLoadMore() {
    if (_isLoadingMore || !widget.hasMoreItems || widget.onLoadMore == null) {
      return false;
    }

    final position = _scrollController.position;
    return position.pixels >= position.maxScrollExtent - widget.loadMoreThreshold;
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await widget.onLoadMore?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onItemVisibilityChanged(int index, bool isVisible) {
    if (!widget.enableLazyLoading) return;

    setState(() {
      if (isVisible) {
        _visibleItems.add(index);
      } else {
        _visibleItems.remove(index);
      }
    });
  }

  bool _shouldRenderItem(int index) {
    if (!widget.enableLazyLoading) return true;
    
    // Sempre renderizar os primeiros itens
    if (index < widget.visibleItemsThreshold) return true;
    
    // Renderizar itens visíveis e alguns ao redor
    return _visibleItems.contains(index) ||
           _visibleItems.any((visibleIndex) => (index - visibleIndex).abs() <= 2);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.items.isEmpty) {
      return widget.loadingWidget ?? const LoadingWidget();
    }

    if (widget.items.isEmpty) {
      return widget.emptyWidget ?? const SizedBox.shrink();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding ?? const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: widget.items.length + (widget.isLoadingMore || _isLoadingMore ? 1 : 0),
      itemExtent: widget.itemExtent,
      itemBuilder: (context, index) {
        // Widget de loading no final da lista
        if (index >= widget.items.length) {
          return widget.loadingMoreWidget ??
              const Padding(
                padding: EdgeInsets.all(AppDimensions.paddingMedium),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
        }

        final item = widget.items[index];
        
        Widget child;
        
        if (widget.enableLazyLoading) {
          child = VisibilityDetector(
            key: Key('optimized_list_item_$index'),
            onVisibilityChanged: (info) {
              _onItemVisibilityChanged(index, info.visibleFraction > 0.1);
            },
            child: _shouldRenderItem(index)
                ? widget.itemBuilder(context, item, index)
                : _buildPlaceholderItem(index),
          );
        } else {
          child = widget.itemBuilder(context, item, index);
        }

        // Aplicar animação se habilitada
        if (widget.enableAnimations) {
          return AnimationService.staggeredListItem(
            index: index,
            staggerDelay: widget.animationDelay,
            child: child,
          );
        }

        return child;
      },
    );
  }

  Widget _buildPlaceholderItem(int index) {
    return Container(
      height: 100, // Altura estimada do item
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Widget otimizado para grid com lazy loading
class OptimizedGridView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function()? onLoadMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMoreItems;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;
  final double loadMoreThreshold;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final Widget? loadingMoreWidget;
  final bool enableAnimations;
  final Duration animationDelay;
  final SliverGridDelegate gridDelegate;
  final int visibleItemsThreshold;
  final bool enableLazyLoading;

  const OptimizedGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.gridDelegate,
    this.onLoadMore,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMoreItems = true,
    this.scrollController,
    this.padding,
    this.loadMoreThreshold = 200.0,
    this.emptyWidget,
    this.loadingWidget,
    this.loadingMoreWidget,
    this.enableAnimations = true,
    this.animationDelay = const Duration(milliseconds: 50),
    this.visibleItemsThreshold = 10,
    this.enableLazyLoading = true,
  });

  @override
  State<OptimizedGridView<T>> createState() => _OptimizedGridViewState<T>();
}

class _OptimizedGridViewState<T> extends State<OptimizedGridView<T>> {
  late ScrollController _scrollController;
  final Set<int> _visibleItems = {};
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;

    if (_shouldLoadMore()) {
      _loadMore();
    }
  }

  bool _shouldLoadMore() {
    if (_isLoadingMore || !widget.hasMoreItems || widget.onLoadMore == null) {
      return false;
    }

    final position = _scrollController.position;
    return position.pixels >= position.maxScrollExtent - widget.loadMoreThreshold;
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await widget.onLoadMore?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onItemVisibilityChanged(int index, bool isVisible) {
    if (!widget.enableLazyLoading) return;

    setState(() {
      if (isVisible) {
        _visibleItems.add(index);
      } else {
        _visibleItems.remove(index);
      }
    });
  }

  bool _shouldRenderItem(int index) {
    if (!widget.enableLazyLoading) return true;
    
    if (index < widget.visibleItemsThreshold) return true;
    
    return _visibleItems.contains(index) ||
           _visibleItems.any((visibleIndex) => (index - visibleIndex).abs() <= 3);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.items.isEmpty) {
      return widget.loadingWidget ?? const LoadingWidget();
    }

    if (widget.items.isEmpty) {
      return widget.emptyWidget ?? const SizedBox.shrink();
    }

    return GridView.builder(
      controller: _scrollController,
      padding: widget.padding ?? const EdgeInsets.all(AppDimensions.paddingMedium),
      gridDelegate: widget.gridDelegate,
      itemCount: widget.items.length + (widget.isLoadingMore || _isLoadingMore ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          return widget.loadingMoreWidget ??
              const Card(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
        }

        final item = widget.items[index];
        
        Widget child;
        
        if (widget.enableLazyLoading) {
          child = VisibilityDetector(
            key: Key('optimized_grid_item_$index'),
            onVisibilityChanged: (info) {
              _onItemVisibilityChanged(index, info.visibleFraction > 0.1);
            },
            child: _shouldRenderItem(index)
                ? widget.itemBuilder(context, item, index)
                : _buildPlaceholderItem(index),
          );
        } else {
          child = widget.itemBuilder(context, item, index);
        }

        if (widget.enableAnimations) {
          return AnimationService.staggeredListItem(
            index: index,
            staggerDelay: widget.animationDelay,
            child: child,
          );
        }

        return child;
      },
    );
  }

  Widget _buildPlaceholderItem(int index) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}