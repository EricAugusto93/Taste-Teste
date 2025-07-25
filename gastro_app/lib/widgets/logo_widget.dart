import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Widget da logo real do Taste Test
class LogoWidget extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;

  const LogoWidget({
    super.key,
    this.width = 160,
    this.height = 100,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: color != null
          ? ColorFiltered(
              colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
              child: Image.asset(
                'assets/images/taste_test_logo.png',
                width: width,
                height: height,
                fit: BoxFit.contain,
                semanticLabel: 'Taste Test Logo',
              ),
            )
          : Image.asset(
              'assets/images/taste_test_logo.png',
              width: width,
              height: height,
              fit: BoxFit.contain,
              semanticLabel: 'Taste Test Logo',
            ),
    );
  }

  /// Factory para logo grande (tela de login)
  factory LogoWidget.large({Color? color}) {
    return LogoWidget(
      width: 200,
      height: 120,
      color: color,
    );
  }

  /// Factory para logo médio (header)
  factory LogoWidget.medium({Color? color}) {
    return LogoWidget(
      width: 140,
      height: 84,
      color: color,
    );
  }

  /// Factory para logo pequeno (ícone)
  factory LogoWidget.small({Color? color}) {
    return LogoWidget(
      width: 100,
      height: 60,
      color: color,
    );
  }

  /// Factory para AppBar
  factory LogoWidget.appBar({Color? color}) {
    return LogoWidget(
      width: 120,
      height: 40,
      color: color,
    );
  }
} 