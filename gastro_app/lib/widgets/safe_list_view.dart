import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

/// Widget wrapper seguro para ListView que previne erros PersistedOffset
/// no Flutter Web
class SafeListView extends StatefulWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final Axis scrollDirection;
  final bool reverse;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final double? itemExtent;
  final Widget? prototypeItem;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;

  const SafeListView({
    Key? key,
    this.children = const <Widget>[],
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemExtent,
    this.prototypeItem,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  }) : super(key: key);

  @override
  State<SafeListView> createState() => _SafeListViewState();
}

class _SafeListViewState extends State<SafeListView> {
  ScrollController? _internalController;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    
    // Criar controller interno se não foi fornecido
    if (widget.controller == null) {
      try {
        _internalController = ScrollController();
      } catch (e) {
        debugPrint('⚠️ Erro ao criar ScrollController: $e');
      }
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    
    // Dispose seguro do controller interno
    if (_internalController != null) {
      try {
        _internalController!.dispose();
      } catch (e) {
        debugPrint('⚠️ Erro ao descartar ScrollController: $e');
      } finally {
        _internalController = null;
      }
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_disposed) {
      return const SizedBox.shrink();
    }

    try {
      return ListView(
        key: widget.key,
        controller: widget.controller ?? _internalController,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        primary: widget.primary,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding,
        itemExtent: widget.itemExtent,
        prototypeItem: widget.prototypeItem,
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        addSemanticIndexes: widget.addSemanticIndexes,
        cacheExtent: widget.cacheExtent,
        semanticChildCount: widget.semanticChildCount,
        dragStartBehavior: widget.dragStartBehavior,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        restorationId: widget.restorationId,
        clipBehavior: widget.clipBehavior,
        children: widget.children,
      );
    } catch (e) {
      debugPrint('⚠️ Erro ao renderizar ListView: $e');
      return const Center(
        child: Text(
          'Erro ao carregar lista',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
  }
}

/// Widget wrapper seguro para ListView.builder que previne erros PersistedOffset
class SafeListViewBuilder extends StatefulWidget {
  final int? itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ScrollController? controller;
  final Axis scrollDirection;
  final bool reverse;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final double? itemExtent;
  final Widget? prototypeItem;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;

  const SafeListViewBuilder({
    Key? key,
    this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemExtent,
    this.prototypeItem,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  }) : super(key: key);

  @override
  State<SafeListViewBuilder> createState() => _SafeListViewBuilderState();
}

class _SafeListViewBuilderState extends State<SafeListViewBuilder> {
  ScrollController? _internalController;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    
    // Criar controller interno se não foi fornecido
    if (widget.controller == null) {
      try {
        _internalController = ScrollController();
      } catch (e) {
        debugPrint('⚠️ Erro ao criar ScrollController: $e');
      }
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    
    // Dispose seguro do controller interno
    if (_internalController != null) {
      try {
        _internalController!.dispose();
      } catch (e) {
        debugPrint('⚠️ Erro ao descartar ScrollController: $e');
      } finally {
        _internalController = null;
      }
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_disposed) {
      return const SizedBox.shrink();
    }

    try {
      return ListView.builder(
        key: widget.key,
        itemCount: widget.itemCount,
        itemBuilder: (context, index) {
          try {
            return widget.itemBuilder(context, index);
          } catch (e) {
            debugPrint('⚠️ Erro ao construir item $index: $e');
            return const SizedBox.shrink();
          }
        },
        controller: widget.controller ?? _internalController,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        primary: widget.primary,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding,
        itemExtent: widget.itemExtent,
        prototypeItem: widget.prototypeItem,
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        addSemanticIndexes: widget.addSemanticIndexes,
        cacheExtent: widget.cacheExtent,
        semanticChildCount: widget.semanticChildCount,
        dragStartBehavior: widget.dragStartBehavior,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        restorationId: widget.restorationId,
        clipBehavior: widget.clipBehavior,
      );
    } catch (e) {
      debugPrint('⚠️ Erro ao renderizar ListView.builder: $e');
      return const Center(
        child: Text(
          'Erro ao carregar lista',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
  }
}