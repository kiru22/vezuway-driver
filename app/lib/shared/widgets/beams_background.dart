import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class BeamsBackground extends StatefulWidget {
  final Widget child;

  final Color? backgroundColor;
  final int beamCount;
  final double intensity;

  const BeamsBackground({
    super.key,
    required this.child,
    this.backgroundColor,
    this.beamCount = 18,
    this.intensity = 1.0,
  });

  @override
  State<BeamsBackground> createState() => _BeamsBackgroundState();
}

class _BeamsBackgroundState extends State<BeamsBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Beam> _beams;
  final Random _random = Random();
  double _time = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _controller.addListener(_updateTime);

    _beams = _generateBeams();
  }

  void _updateTime() {
    _time += 0.016;
  }

  List<_Beam> _generateBeams() {
    final colors = [
      const Color(0xFFB8F5D0),
      const Color(0xFFA5F3E0),
      const Color(0xFFBAE6FD),
      const Color(0xFFE0F2FE),
      Colors.white.withValues(alpha: 0.9),
    ];

    return List.generate(widget.beamCount, (index) {
      return _Beam(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 1.8 - 0.4,
        width: _random.nextDouble() * 35 + 20,
        length: _random.nextDouble() * 0.5 + 0.6,
        angle: -35 + _random.nextDouble() * 20 - 10,
        speed: _random.nextDouble() * 0.008 + 0.005,
        color: colors[_random.nextInt(colors.length)],
        pulseOffset: _random.nextDouble() * pi * 2,
        pulseSpeed: _random.nextDouble() * 1.0 + 0.8,
        waveAmplitude: _random.nextDouble() * 50 + 30,
        waveFrequency: _random.nextDouble() * 1.0 + 1.5,
        wavePhase: _random.nextDouble() * pi * 2,
        lateralSpeed: _random.nextDouble() * 1.5 + 1.0,
      );
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_updateTime);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: widget.backgroundColor ?? AppColors.loginBackground,
        ),
        Positioned(
          top: -150,
          right: -100,
          child: _BlurredBlob(
            size: 400,
            color: AppColors.loginBlobGreen1,
            blurAmount: 100,
          ),
        ),
        Positioned(
          bottom: -180,
          left: -120,
          child: _BlurredBlob(
            size: 450,
            color: AppColors.loginBlobBlue1,
            blurAmount: 120,
          ),
        ),
        Positioned(
          top: 250,
          left: -80,
          child: _BlurredBlob(
            size: 280,
            color: AppColors.loginBlobGreen2.withValues(alpha: 0.7),
            blurAmount: 80,
          ),
        ),
        Positioned(
          bottom: 150,
          right: -60,
          child: _BlurredBlob(
            size: 220,
            color: AppColors.loginBlobBlue2.withValues(alpha: 0.6),
            blurAmount: 70,
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            for (final beam in _beams) {
              beam.y -= beam.speed;
              if (beam.y + beam.length < -0.2) {
                beam.y = 1.3 + _random.nextDouble() * 0.3;
                beam.x = _random.nextDouble();
              }
            }

            return RepaintBoundary(
              child: Stack(
                children: [
                  ImageFiltered(
                    imageFilter: ColorFilter.mode(
                      Colors.white.withValues(alpha: 0.5),
                      BlendMode.modulate,
                    ),
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ColorFilter.mode(
                          Colors.transparent,
                          BlendMode.srcOver,
                        ),
                        child: CustomPaint(
                          painter: _BeamsPainter(
                            beams: _beams,
                            intensity: widget.intensity,
                            time: _time,
                          ),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Colors.transparent,
                    (widget.backgroundColor ?? AppColors.loginBackground)
                        .withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Beam {
  double x;
  double y;
  double width;
  double length;
  double angle;
  double speed;
  Color color;
  double pulseOffset;
  double pulseSpeed;

  double waveAmplitude;
  double waveFrequency;
  double wavePhase;
  double lateralSpeed;

  _Beam({
    required this.x,
    required this.y,
    required this.width,
    required this.length,
    required this.angle,
    required this.speed,
    required this.color,
    required this.pulseOffset,
    required this.pulseSpeed,
    required this.waveAmplitude,
    required this.waveFrequency,
    required this.wavePhase,
    required this.lateralSpeed,
  });
}

class _BeamsPainter extends CustomPainter {
  final List<_Beam> beams;
  final double intensity;
  final double time;

  _BeamsPainter({
    required this.beams,
    required this.intensity,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final beam in beams) {
      _drawBeam(canvas, size, beam);
    }
  }

  void _drawBeam(Canvas canvas, Size size, _Beam beam) {
    final centerX = beam.x * size.width;
    final centerY = beam.y * size.height;
    final beamLength = beam.length * size.height;
    final angleRad = beam.angle * pi / 180;

    final pulse = 0.7 + 0.3 * sin(time * beam.pulseSpeed + beam.pulseOffset);
    final opacity = intensity * pulse;

    final lateralOffset = sin(time * beam.lateralSpeed + beam.wavePhase) * 50;

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        beam.color.withValues(alpha: 0),
        beam.color.withValues(alpha: 0.5 * opacity),
        beam.color.withValues(alpha: 0.8 * opacity),
        beam.color.withValues(alpha: 0.8 * opacity),
        beam.color.withValues(alpha: 0.5 * opacity),
        beam.color.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.15, 0.4, 0.6, 0.85, 1.0],
    );

    final path = _createSinusoidalPath(
      centerX + lateralOffset,
      centerY,
      beamLength,
      angleRad,
      beam.waveAmplitude,
      beam.waveFrequency,
      beam.wavePhase + time * 1.5,
    );

    _drawBeamPathLayer(canvas, path, beam.width * 5, gradient, size,
        blur: 50, opacityMultiplier: 0.35);

    _drawBeamPathLayer(canvas, path, beam.width * 2.5, gradient, size,
        blur: 30, opacityMultiplier: 0.5);

    _drawBeamPathLayer(canvas, path, beam.width * 1.2, gradient, size,
        blur: 12, opacityMultiplier: 0.7);
  }

  Path _createSinusoidalPath(
    double centerX,
    double centerY,
    double length,
    double angleRad,
    double amplitude,
    double frequency,
    double phase,
  ) {
    final path = Path();
    const segments = 40;
    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final distanceAlongBeam = (t - 0.5) * length;

      final baseX = centerX + sin(angleRad) * distanceAlongBeam;
      final baseY = centerY + cos(angleRad) * distanceAlongBeam;

      final waveOffset = sin(t * frequency * pi * 2 + phase) * amplitude;
      final perpX = cos(angleRad) * waveOffset;
      final perpY = -sin(angleRad) * waveOffset;

      final x = baseX + perpX;
      final y = baseY + perpY;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    return path;
  }

  void _drawBeamPathLayer(
    Canvas canvas,
    Path path,
    double width,
    LinearGradient gradient,
    Size size, {
    required double blur,
    required double opacityMultiplier,
  }) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final shader = gradient.createShader(rect);

    final paint = Paint()
      ..shader = shader
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    canvas.saveLayer(
      null,
      Paint()..color = Colors.white.withValues(alpha: opacityMultiplier),
    );
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BeamsPainter oldDelegate) => true;
}

class _BlurredBlob extends StatelessWidget {
  final double size;
  final Color color;
  final double blurAmount;

  const _BlurredBlob({
    required this.size,
    required this.color,
    required this.blurAmount,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(
        sigmaX: blurAmount,
        sigmaY: blurAmount,
        tileMode: TileMode.decal,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
