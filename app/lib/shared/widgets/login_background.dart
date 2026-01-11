import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Widget de fondo con blobs difuminados para pantallas de autenticación.
/// Crea un efecto visual moderno con gradientes verde-azul.
class LoginBackground extends StatelessWidget {
  const LoginBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      color: AppColors.loginBackground,
      child: Stack(
        children: [
          // Blob superior izquierdo (azul arriba, verde abajo)
          Positioned(
            top: -60,
            left: -60,
            child: _GradientBlob(
              width: 280,
              height: 320,
              colors: const [
                Color(0xFF3B82F6), // blue-500
                Color(0xFF22C55E), // green-500
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              blurSigma: 60,
            ),
          ),
          // Blob centro-izquierda (verde)
          Positioned(
            top: size.height * 0.35,
            left: -100,
            child: _GradientBlob(
              width: 250,
              height: 300,
              colors: const [
                Color(0xFF4ADE80), // green-400
                Color(0xFF22C55E), // green-500
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              blurSigma: 70,
            ),
          ),
          // Blob inferior derecho (verde y azul)
          Positioned(
            bottom: -80,
            right: -60,
            child: _GradientBlob(
              width: 320,
              height: 280,
              colors: const [
                Color(0xFF22C55E), // green-500
                Color(0xFF0EA5E9), // sky-500
                Color(0xFF3B82F6), // blue-500
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              blurSigma: 65,
            ),
          ),
          // Contenido
          child,
        ],
      ),
    );
  }
}

/// Blob con gradiente y efecto blur.
class _GradientBlob extends StatelessWidget {
  const _GradientBlob({
    required this.width,
    required this.height,
    required this.colors,
    required this.begin,
    required this.end,
    required this.blurSigma,
  });

  final double width;
  final double height;
  final List<Color> colors;
  final Alignment begin;
  final Alignment end;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: blurSigma,
        sigmaY: blurSigma,
        tileMode: TileMode.decal,
      ),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width / 2),
          gradient: LinearGradient(
            begin: begin,
            end: end,
            colors: colors,
          ),
        ),
      ),
    );
  }
}
