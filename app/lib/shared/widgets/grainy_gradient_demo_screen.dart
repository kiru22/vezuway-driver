import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'grainy_gradient.dart';

class GrainyGradientDemoScreen extends StatefulWidget {
  const GrainyGradientDemoScreen({super.key});

  @override
  State<GrainyGradientDemoScreen> createState() =>
      _GrainyGradientDemoScreenState();
}

class _GrainyGradientDemoScreenState extends State<GrainyGradientDemoScreen> {
  double _speed = 2.9;
  double _amplitude = 0.1;
  double _grainIntensity = 0.112;
  double _grainSize = 1.9;
  double _brightness = 0.0;
  bool _grainEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Grainy Gradient')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // 1. Default
          Text('Default', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: const SizedBox(
              height: 220,
              child: GrainyGradient(),
            ),
          ),

          const SizedBox(height: 32),

          // 2. Design System
          Text('Design System', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: const SizedBox(
              height: 220,
              child: GrainyGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                  AppColors.info,
                  AppColors.primaryLight,
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // 3. Interactive controls
          Text('Interactive', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 220,
              child: GrainyGradient(
                speed: _speed,
                amplitude: _amplitude,
                grainIntensity: _grainIntensity,
                grainSize: _grainSize,
                grainEnabled: _grainEnabled,
                brightness: _brightness,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _slider('Speed', _speed, 0.0, 10.0, (v) => setState(() => _speed = v)),
          _slider('Amplitude', _amplitude, 0.0, 1.0,
              (v) => setState(() => _amplitude = v)),
          _slider('Grain Intensity', _grainIntensity, 0.0, 1.0,
              (v) => setState(() => _grainIntensity = v)),
          _slider('Grain Size', _grainSize, 0.5, 4.0,
              (v) => setState(() => _grainSize = v)),
          _slider('Brightness', _brightness, -1.0, 1.0,
              (v) => setState(() => _brightness = v)),
          SwitchListTile(
            title: const Text('Grain Enabled'),
            value: _grainEnabled,
            onChanged: (v) => setState(() => _grainEnabled = v),
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: 32),

          // 4. As background
          Text('As Background', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 200,
              child: GrainyGradient(
                speed: 1.5,
                amplitude: 0.08,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Premium Feature',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gradient backgrounds for cards and sections',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // 5. Minimal (2 colors)
          Text('Minimal (2 colors)', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: const SizedBox(
              height: 160,
              child: GrainyGradient(
                colors: [Color(0xFF1E40AF), Color(0xFF7C3AED)],
                speed: 1.0,
                amplitude: 0.06,
                grainIntensity: 0.08,
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(value.toStringAsFixed(2),
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}
