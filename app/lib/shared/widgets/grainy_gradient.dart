import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class GrainyGradient extends StatefulWidget {
  final Widget? child;
  final List<Color> colors;
  final Color? backgroundColor;
  final double speed;
  final double amplitude;
  final double grainIntensity;
  final double grainSize;
  final bool grainEnabled;
  final double brightness;

  const GrainyGradient({
    super.key,
    this.child,
    this.colors = const [
      Color(0xFF4ADE80),
      Color(0xFF3B82F6),
      Color(0xFF22C55E),
      Color(0xFF0EA5E9),
    ],
    this.backgroundColor,
    this.speed = 2.9,
    this.amplitude = 0.1,
    this.grainIntensity = 0.112,
    this.grainSize = 1.9,
    this.grainEnabled = true,
    this.brightness = 0.0,
  });

  @override
  State<GrainyGradient> createState() => _GrainyGradientState();
}

class _GrainyGradientState extends State<GrainyGradient>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_BlobConfig> _blobs;
  double _time = 0;

  ui.Image? _grainTexture;
  double _cachedGrainSize = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _controller.addListener(_tick);
    _blobs = _buildBlobs();
    _generateGrainTexture();
  }

  @override
  void didUpdateWidget(GrainyGradient old) {
    super.didUpdateWidget(old);
    if (old.colors.length != widget.colors.length) {
      _blobs = _buildBlobs();
    }
    if (old.grainSize != widget.grainSize) {
      _generateGrainTexture();
    }
  }

  void _tick() {
    _time += 0.016 * widget.speed;
  }

  List<_BlobConfig> _buildBlobs() {
    final rng = Random(42);
    final n = widget.colors.length;
    final blobs = <_BlobConfig>[];

    for (var i = 0; i < n; i++) {
      final angle = (i / n) * 2 * pi;

      blobs.add(_BlobConfig(
        colorIndex: i,
        baseAngle: angle,
        radiusOffset: rng.nextDouble() * 0.15 + 0.9,
        sizeMultiplier: rng.nextDouble() * 0.12 + 0.38,
        speedVariation: rng.nextDouble() * 0.4 + 0.8,
        phaseOffset: rng.nextDouble() * pi * 2,
      ));

      blobs.add(_BlobConfig(
        colorIndex: i,
        baseAngle: angle + pi * 0.7,
        radiusOffset: rng.nextDouble() * 0.25 + 0.95,
        sizeMultiplier: rng.nextDouble() * 0.1 + 0.20,
        alphaMultiplier: 0.7,
        speedVariation: rng.nextDouble() * 0.5 + 0.7,
        phaseOffset: rng.nextDouble() * pi * 2,
      ));
    }

    return blobs;
  }

  Future<void> _generateGrainTexture() async {
    final size = (64 * widget.grainSize).clamp(32, 256).toInt();
    if (_cachedGrainSize == widget.grainSize && _grainTexture != null) return;
    _cachedGrainSize = widget.grainSize;

    final rng = Random();
    final pixels = Uint8List(size * size * 4);
    for (var i = 0; i < pixels.length; i += 4) {
      final v = rng.nextInt(256);
      pixels[i] = v;
      pixels[i + 1] = v;
      pixels[i + 2] = v;
      pixels[i + 3] = 255;
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      size,
      size,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );

    try {
      final image = await completer.future;
      if (mounted) {
        _grainTexture?.dispose();
        setState(() => _grainTexture = image);
      } else {
        image.dispose();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.removeListener(_tick);
    _controller.dispose();
    _grainTexture?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final painter = CustomPaint(
          painter: _GrainyGradientPainter(
            colors: widget.colors,
            backgroundColor: widget.backgroundColor,
            blobs: _blobs,
            time: _time,
            amplitude: widget.amplitude,
            grainIntensity: widget.grainIntensity,
            grainEnabled: widget.grainEnabled,
            brightness: widget.brightness,
            grainTexture: _grainTexture,
          ),
          size: Size.infinite,
        );

        return RepaintBoundary(
          child: widget.child != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [painter, widget.child!],
                )
              : painter,
        );
      },
    );
  }
}

class _BlobConfig {
  final int colorIndex;
  final double baseAngle;
  final double radiusOffset;
  final double sizeMultiplier;
  final double alphaMultiplier;
  final double speedVariation;
  final double phaseOffset;

  const _BlobConfig({
    required this.colorIndex,
    required this.baseAngle,
    required this.radiusOffset,
    required this.sizeMultiplier,
    this.alphaMultiplier = 1.0,
    required this.speedVariation,
    required this.phaseOffset,
  });
}

class _GrainyGradientPainter extends CustomPainter {
  final List<Color> colors;
  final Color? backgroundColor;
  final List<_BlobConfig> blobs;
  final double time;
  final double amplitude;
  final double grainIntensity;
  final bool grainEnabled;
  final double brightness;
  final ui.Image? grainTexture;

  _GrainyGradientPainter({
    required this.colors,
    this.backgroundColor,
    required this.blobs,
    required this.time,
    required this.amplitude,
    required this.grainIntensity,
    required this.grainEnabled,
    required this.brightness,
    this.grainTexture,
  });

  Color _blendBaseColor(List<Color> colors) {
    if (colors.isEmpty) return const Color(0xFF0A0A0A);
    double r = 0, g = 0, b = 0;
    for (final c in colors) {
      r += c.r;
      g += c.g;
      b += c.b;
    }
    final n = colors.length;
    return Color.from(
      alpha: 1.0,
      red: (r / n) * 0.35,
      green: (g / n) * 0.35,
      blue: (b / n) * 0.35,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = backgroundColor ?? _blendBaseColor(colors);

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = baseColor,
    );

    final cx = size.width / 2;
    final cy = size.height / 2;
    final orbitRadius = size.longestSide * 0.25;
    final blurSigma = size.longestSide * 0.1;

    canvas.saveLayer(Offset.zero & size, Paint());

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = baseColor,
    );

    for (final blob in blobs) {
      final color = colors[blob.colorIndex];
      final t = time * blob.speedVariation;
      final orbit = orbitRadius * amplitude * blob.radiusOffset;

      final breathe = 1.0 + sin(t * 0.5 + blob.phaseOffset) * 0.15;
      final blobRadius = size.longestSide * blob.sizeMultiplier * breathe;

      final bx = cx +
          cos(t + blob.baseAngle) * orbit +
          cos(t * 1.7 + blob.phaseOffset) * orbit * 0.3;
      final by = cy +
          sin(t * 0.8 + blob.baseAngle) * orbit +
          sin(t * 1.3 + blob.phaseOffset + 0.7) * orbit * 0.3;
      final center = Offset(bx, by);

      final a = blob.alphaMultiplier;
      final gradient = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          color.withValues(alpha: 0.95 * a),
          color.withValues(alpha: 0.85 * a),
          color.withValues(alpha: 0.45 * a),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.35, 0.7, 1.0],
      );

      final rect = Rect.fromCircle(center: center, radius: blobRadius);
      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..blendMode = BlendMode.srcOver
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);

      canvas.drawCircle(center, blobRadius, paint);
    }

    canvas.restore();

    if (brightness != 0) {
      final isLight = brightness > 0;
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..color = (isLight ? Colors.white : Colors.black)
              .withValues(alpha: brightness.abs().clamp(0.0, 1.0))
          ..blendMode = isLight ? BlendMode.screen : BlendMode.multiply,
      );
    }

    if (grainEnabled && grainTexture != null && grainIntensity > 0) {
      final tx = sin(time * 0.5) * 10;
      final ty = cos(time * 0.3) * 10;
      final shader = ui.ImageShader(
        grainTexture!,
        TileMode.repeated,
        TileMode.repeated,
        Matrix4.translationValues(tx, ty, 0).storage,
      );

      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = shader
          ..blendMode = BlendMode.overlay
          ..color = Colors.white
              .withValues(alpha: grainIntensity.clamp(0.0, 1.0)),
      );
    }
  }

  @override
  bool shouldRepaint(_GrainyGradientPainter old) {
    return old.time != time ||
        old.amplitude != amplitude ||
        old.brightness != brightness ||
        old.grainIntensity != grainIntensity ||
        old.grainEnabled != grainEnabled ||
        old.grainTexture != grainTexture ||
        old.colors != colors ||
        old.backgroundColor != backgroundColor;
  }
}
