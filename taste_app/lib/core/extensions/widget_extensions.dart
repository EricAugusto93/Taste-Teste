import 'package:flutter/material.dart';
import '../animations/animation_service.dart';

/// Extensões para widgets
extension WidgetExtensions on Widget {
  /// Aplica padding em todas as direções
  Widget padding(double value) {
    return Padding(
      padding: EdgeInsets.all(value),
      child: this,
    );
  }

  /// Aplica padding horizontal
  Widget paddingHorizontal(double value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: value),
      child: this,
    );
  }

  /// Aplica padding vertical
  Widget paddingVertical(double value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: value),
      child: this,
    );
  }

  /// Aplica padding apenas na esquerda
  Widget paddingLeft(double value) {
    return Padding(
      padding: EdgeInsets.only(left: value),
      child: this,
    );
  }

  /// Aplica padding apenas na direita
  Widget paddingRight(double value) {
    return Padding(
      padding: EdgeInsets.only(right: value),
      child: this,
    );
  }

  /// Aplica padding apenas no topo
  Widget paddingTop(double value) {
    return Padding(
      padding: EdgeInsets.only(top: value),
      child: this,
    );
  }

  /// Aplica padding apenas na base
  Widget paddingBottom(double value) {
    return Padding(
      padding: EdgeInsets.only(bottom: value),
      child: this,
    );
  }

  /// Aplica margin usando Container
  Widget margin(double value) {
    return Container(
      margin: EdgeInsets.all(value),
      child: this,
    );
  }

  /// Aplica margin horizontal
  Widget marginHorizontal(double value) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: value),
      child: this,
    );
  }

  /// Aplica margin vertical
  Widget marginVertical(double value) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: value),
      child: this,
    );
  }

  /// Centraliza o widget
  Widget center() {
    return Center(child: this);
  }

  /// Aplica Expanded
  Widget expanded({int flex = 1}) {
    return Expanded(flex: flex, child: this);
  }

  /// Aplica Flexible
  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Flexible(flex: flex, fit: fit, child: this);
  }

  /// Aplica animação de fade in
  Widget fadeIn({
    Duration duration = AnimationService.normal,
    Curve curve = AnimationService.easeInOut,
    Duration delay = Duration.zero,
  }) {
    return AnimationService.fadeIn(
      child: this,
      duration: duration,
      curve: curve,
      delay: delay,
    );
  }

  /// Aplica animação de slide in
  Widget slideIn({
    Duration duration = AnimationService.normal,
    Curve curve = AnimationService.easeInOut,
    Offset begin = const Offset(0, 1),
    Duration delay = Duration.zero,
  }) {
    return AnimationService.slideIn(
      child: this,
      duration: duration,
      curve: curve,
      begin: begin,
      delay: delay,
    );
  }

  /// Aplica animação de scale in
  Widget scaleIn({
    Duration duration = AnimationService.normal,
    Curve curve = AnimationService.easeInOut,
    double begin = 0.0,
    Duration delay = Duration.zero,
  }) {
    return AnimationService.scaleIn(
      child: this,
      duration: duration,
      curve: curve,
      begin: begin,
      delay: delay,
    );
  }

  /// Aplica GestureDetector com onTap
  Widget onTap(VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: this,
    );
  }

  /// Aplica InkWell com onTap
  Widget inkWell({
    VoidCallback? onTap,
    BorderRadius? borderRadius,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: this,
    );
  }

  /// Aplica Container com decoração
  Widget decorated({
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: border,
        boxShadow: boxShadow,
        gradient: gradient,
      ),
      child: this,
    );
  }

  /// Aplica ClipRRect
  Widget clipRRect({BorderRadius? borderRadius}) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: this,
    );
  }

  /// Aplica Visibility
  Widget visible(bool visible) {
    return Visibility(
      visible: visible,
      child: this,
    );
  }

  /// Aplica Opacity
  Widget opacity(double opacity) {
    return Opacity(
      opacity: opacity,
      child: this,
    );
  }

  /// Aplica SizedBox com width
  Widget width(double width) {
    return SizedBox(
      width: width,
      child: this,
    );
  }

  /// Aplica SizedBox com height
  Widget height(double height) {
    return SizedBox(
      height: height,
      child: this,
    );
  }

  /// Aplica SizedBox com width e height
  Widget size(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: this,
    );
  }
}