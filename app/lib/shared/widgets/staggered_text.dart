import 'dart:ui';

import 'package:flutter/material.dart';

class StaggeredText extends StatefulWidget {
  const StaggeredText({
    super.key,
    required this.text,
    this.style,
    this.characterDelay = const Duration(milliseconds: 30),
    this.characterDuration = const Duration(milliseconds: 400),
    this.maxBlurIntensity = 8.0,
    this.enterTranslateY = 40.0,
    this.enterScale = 0.3,
    this.curve = Curves.easeOutCubic,
    this.animate = true,
  });

  final String text;
  final TextStyle? style;
  final Duration characterDelay;
  final Duration characterDuration;
  final double maxBlurIntensity;
  final double enterTranslateY;
  final double enterScale;
  final Curve curve;
  final bool animate;

  @override
  State<StaggeredText> createState() => _StaggeredTextState();
}

class _StaggeredTextState extends State<StaggeredText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  int _totalMs = 0;

  @override
  void initState() {
    super.initState();
    _totalMs = _calcTotalMs();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _totalMs),
    );
    if (widget.animate) _controller.forward();
  }

  @override
  void didUpdateWidget(StaggeredText oldWidget) {
    super.didUpdateWidget(oldWidget);

    final needsRebuild = oldWidget.text != widget.text ||
        oldWidget.characterDelay != widget.characterDelay ||
        oldWidget.characterDuration != widget.characterDuration ||
        oldWidget.curve != widget.curve;

    if (needsRebuild) {
      _totalMs = _calcTotalMs();
      _controller.duration = Duration(milliseconds: _totalMs);
    }

    if (widget.animate && !oldWidget.animate) {
      _controller.forward(from: 0);
    } else if (!widget.animate && oldWidget.animate) {
      _controller.reset();
    }
  }

  int _calcTotalMs() {
    final chars = widget.text.length;
    if (chars == 0) return 1;
    return widget.characterDuration.inMilliseconds +
        ((chars - 1) * widget.characterDelay.inMilliseconds);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedStyle =
        widget.style ?? DefaultTextStyle.of(context).style;
    final chars = widget.text.characters.toList();
    final useBlur = widget.maxBlurIntensity > 0;
    final curve = widget.curve;
    final totalMs = _totalMs;
    final delayMs = widget.characterDelay.inMilliseconds;
    final durMs = widget.characterDuration.inMilliseconds;

    final spacePainter = TextPainter(
      text: TextSpan(text: ' ', style: resolvedStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final spaceWidth = spacePainter.width;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final controllerValue = _controller.value;
        return Wrap(
          children: List.generate(chars.length, (i) {
            final char = chars[i];

            if (char == ' ') {
              return SizedBox(width: spaceWidth);
            }

            final startMs = i * delayMs;
            final endMs = startMs + durMs;
            final start = startMs / totalMs;
            final end = (endMs / totalMs).clamp(0.0, 1.0);

            final intervalT = ((controllerValue - start) / (end - start))
                .clamp(0.0, 1.0);
            final t = curve.transform(intervalT);

            final opacity = t;
            final translateY = widget.enterTranslateY * (1 - t);
            final scale = lerpDouble(widget.enterScale, 1.0, t)!;
            final blur = useBlur ? widget.maxBlurIntensity * (1 - t) : 0.0;

            Widget charWidget = Text(char, style: resolvedStyle);

            if (useBlur && blur > 0.01) {
              charWidget = ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: blur,
                  sigmaY: blur,
                ),
                child: charWidget,
              );
            }

            return Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, translateY),
                child: Transform.scale(
                  scale: scale,
                  child: charWidget,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
