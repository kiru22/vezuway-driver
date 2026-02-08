import 'package:flutter/material.dart';

import 'staggered_text.dart';

class StaggeredTextDemoScreen extends StatefulWidget {
  const StaggeredTextDemoScreen({super.key});

  @override
  State<StaggeredTextDemoScreen> createState() =>
      _StaggeredTextDemoScreenState();
}

class _StaggeredTextDemoScreenState extends State<StaggeredTextDemoScreen> {
  double _charDelayMs = 30;
  double _translateY = 40;
  double _scale = 0.3;
  double _blur = 8;
  bool _animate = true;
  int _replayKey = 0;

  static const _presets = [
    _Preset(
      name: 'Typewriter',
      icon: Icons.keyboard_rounded,
      delay: 60,
      translateY: 0,
      scale: 1.0,
      blur: 0,
    ),
    _Preset(
      name: 'Cascade',
      icon: Icons.waterfall_chart_rounded,
      delay: 25,
      translateY: 55,
      scale: 0.2,
      blur: 12,
    ),
    _Preset(
      name: 'Pop-in',
      icon: Icons.bubble_chart_rounded,
      delay: 40,
      translateY: 0,
      scale: 0.0,
      blur: 0,
    ),
    _Preset(
      name: 'Wave',
      icon: Icons.waves_rounded,
      delay: 20,
      translateY: 30,
      scale: 0.6,
      blur: 4,
    ),
  ];

  void _replay() {
    setState(() {
      _animate = false;
      _replayKey++;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _animate = true);
    });
  }

  void _applyPreset(_Preset preset) {
    setState(() {
      _charDelayMs = preset.delay;
      _translateY = preset.translateY;
      _scale = preset.scale;
      _blur = preset.blur;
      _animate = false;
      _replayKey++;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Staggered Text')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ── Hero ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: StaggeredText(
                key: ValueKey('hero_$_replayKey'),
                text: 'vezuway.',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                characterDelay: Duration(milliseconds: _charDelayMs.round()),
                enterTranslateY: _translateY,
                enterScale: _scale,
                maxBlurIntensity: _blur,
                animate: _animate,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ── Replay button ──
          Center(
            child: FilledButton.icon(
              onPressed: _replay,
              icon: const Icon(Icons.replay_rounded, size: 20),
              label: const Text('Replay'),
            ),
          ),
          const SizedBox(height: 32),

          // ── Presets ──
          Text('Presets', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((p) {
              final isActive = _charDelayMs == p.delay &&
                  _translateY == p.translateY &&
                  _scale == p.scale &&
                  _blur == p.blur;
              return ChoiceChip(
                avatar: Icon(p.icon, size: 18),
                label: Text(p.name),
                selected: isActive,
                onSelected: (_) => _applyPreset(p),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // ── Controls ──
          Text('Controls', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          _SliderRow(
            label: 'Character delay',
            value: _charDelayMs,
            min: 10,
            max: 100,
            suffix: 'ms',
            onChanged: (v) => setState(() => _charDelayMs = v),
          ),
          _SliderRow(
            label: 'Translate Y',
            value: _translateY,
            min: 0,
            max: 80,
            suffix: 'px',
            onChanged: (v) => setState(() => _translateY = v),
          ),
          _SliderRow(
            label: 'Enter scale',
            value: _scale,
            min: 0,
            max: 1,
            decimals: 2,
            onChanged: (v) => setState(() => _scale = v),
          ),
          _SliderRow(
            label: 'Blur intensity',
            value: _blur,
            min: 0,
            max: 20,
            onChanged: (v) => setState(() => _blur = v),
          ),
          const SizedBox(height: 32),

          // ── Context example ──
          Text('In context', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StaggeredText(
                  key: ValueKey('ctx_title_$_replayKey'),
                  text: 'Welcome back!',
                  style: theme.textTheme.headlineMedium,
                  characterDelay:
                      Duration(milliseconds: _charDelayMs.round()),
                  enterTranslateY: _translateY,
                  enterScale: _scale,
                  maxBlurIntensity: _blur,
                  animate: _animate,
                ),
                const SizedBox(height: 8),
                StaggeredText(
                  key: ValueKey('ctx_sub_$_replayKey'),
                  text: 'Your shipments are on track',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  characterDelay:
                      Duration(milliseconds: _charDelayMs.round()),
                  characterDuration: const Duration(milliseconds: 300),
                  enterTranslateY: _translateY * 0.5,
                  enterScale: _scale,
                  maxBlurIntensity: _blur * 0.5,
                  animate: _animate,
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _Preset {
  final String name;
  final IconData icon;
  final double delay;
  final double translateY;
  final double scale;
  final double blur;

  const _Preset({
    required this.name,
    required this.icon,
    required this.delay,
    required this.translateY,
    required this.scale,
    required this.blur,
  });
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.suffix = '',
    this.decimals = 0,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String suffix;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = decimals > 0
        ? value.toStringAsFixed(decimals)
        : value.round().toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              '$display$suffix',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
