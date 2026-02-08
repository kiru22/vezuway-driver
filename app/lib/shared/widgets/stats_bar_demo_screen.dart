import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'package_box_icon.dart';

class StatsBarDemoScreen extends StatelessWidget {
  const StatsBarDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stats Bar Demo')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('StatsBarBlock', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          const StatsBarBlock(
            packages: '1',
            weight: '222,0 kg',
            value: '1.776€',
          ),
          const SizedBox(height: 40),
          Text('UnifiedStatsCard',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          const UnifiedStatsCard(
            packages: '1',
            weight: '222,0 kg',
            value: '1.776€',
          ),
          const SizedBox(height: 32),
          Text('Con otros valores',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          const UnifiedStatsCard(
            packages: '48',
            weight: '1.250,5 kg',
            value: '32.400€',
          ),
        ],
      ),
    );
  }
}

class StatsBarBlock extends StatelessWidget {
  final String packages;
  final String weight;
  final String value;

  const StatsBarBlock({
    super.key,
    required this.packages,
    required this.weight,
    required this.value,
  });

  static const _emerald = AppColors.primary;
  static const _amber = AppColors.warning;
  static const _blue = Color(0xFF3B82F6);
  static const _rowHeight = 56.0;
  static const _totalHeight = _rowHeight * 3;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: SizedBox(
        height: _totalHeight,
        child: Stack(
          children: [
            const ColoredBox(
              color: Colors.white,
              child: SizedBox.expand(),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _rowHeight * 1.7,
              child: _GradientBand(
                color: _emerald,
                isLTR: true,
                fadeTop: false,
                fadeBottom: true,
              ),
            ),
            Positioned(
              top: _rowHeight * 0.5,
              left: 0,
              right: 0,
              height: _rowHeight * 2,
              child: _GradientBand(
                color: _amber,
                isLTR: false,
                fadeTop: true,
                fadeBottom: true,
              ),
            ),
            Positioned(
              top: _rowHeight * 1.3,
              left: 0,
              right: 0,
              height: _rowHeight * 1.7,
              child: _GradientBand(
                color: _blue,
                isLTR: true,
                fadeTop: true,
                fadeBottom: false,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _rowHeight,
              child: _ContentRow(
                icon: const PackageBoxIcon(
                    size: 24, color: Colors.white, filled: true),
                label: 'Paquetes',
                value: packages,
                isLTR: true,
              ),
            ),
            Positioned(
              top: _rowHeight,
              left: 0,
              right: 0,
              height: _rowHeight,
              child: _ContentRow(
                icon: const Icon(Icons.scale_rounded,
                    size: 24, color: Colors.white),
                label: 'Peso',
                value: weight,
                isLTR: false,
              ),
            ),
            Positioned(
              top: _rowHeight * 2,
              left: 0,
              right: 0,
              height: _rowHeight,
              child: _ContentRow(
                icon: const Icon(Icons.euro_rounded,
                    size: 24, color: Colors.white),
                label: 'Valor',
                value: value,
                isLTR: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientBand extends StatelessWidget {
  final Color color;
  final bool isLTR;
  final bool fadeTop;
  final bool fadeBottom;

  const _GradientBand({
    required this.color,
    required this.isLTR,
    required this.fadeTop,
    required this.fadeBottom,
  });

  @override
  Widget build(BuildContext context) {
    final verticalColors = <Color>[];
    final stops = <double>[];

    if (fadeTop) {
      verticalColors.addAll([Colors.transparent, Colors.white]);
      stops.addAll([0.0, 0.4]);
    } else {
      verticalColors.add(Colors.white);
      stops.add(0.0);
    }

    if (fadeBottom) {
      verticalColors.addAll([Colors.white, Colors.transparent]);
      stops.addAll([0.6, 1.0]);
    } else {
      verticalColors.add(Colors.white);
      stops.add(1.0);
    }

    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: verticalColors,
        stops: stops,
      ).createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: isLTR ? Alignment.centerLeft : Alignment.centerRight,
            end: isLTR ? Alignment.centerRight : Alignment.centerLeft,
            colors: [color, Colors.white],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Variante 2: Card unificada horizontal con icono de fondo
// ═══════════════════════════════════════════════════════════════════════════

class UnifiedStatsCard extends StatelessWidget {
  final String packages;
  final String weight;
  final String value;

  const UnifiedStatsCard({
    super.key,
    required this.packages,
    required this.weight,
    required this.value,
  });

  static const _emerald = AppColors.primary;
  static const _amber = AppColors.warning;
  static const _blue = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    final bgEmerald = Color.lerp(Colors.white, _emerald, 0.10)!;
    final bgAmber = Color.lerp(Colors.white, _amber, 0.10)!;
    final bgBlue = Color.lerp(Colors.white, _blue, 0.10)!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgEmerald, bgAmber, bgBlue],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          Expanded(
            child: _StatCell(
              icon: Icons.inventory_2_rounded,
              iconWidget: const PackageBoxIcon(
                  size: 56,
                  color: AppColors.primaryDark,
                  tapeColor: Colors.white,
                  filled: true),
              label: 'Paquetes',
              value: packages,
              color: _emerald,
            ),
          ),
          Expanded(
            child: _StatCell(
              icon: Icons.scale_rounded,
              label: 'Peso total',
              value: weight,
              color: _amber,
            ),
          ),
          Expanded(
            child: _StatCell(
              icon: Icons.euro_rounded,
              label: 'Valor',
              value: value,
              color: _blue,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final Widget? iconWidget;
  final String label;
  final String value;
  final Color color;

  const _StatCell({
    required this.icon,
    this.iconWidget,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Stack(
        children: [
          Positioned(
            right: -2,
            top: -2,
            width: 56,
            height: 56,
            child: Opacity(
              opacity: 0.15,
              child: iconWidget ?? Icon(icon, size: 56, color: color),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContentRow extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;
  final bool isLTR;

  const _ContentRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isLTR,
  });

  @override
  Widget build(BuildContext context) {
    final children = isLTR
        ? [
            icon,
            const SizedBox(width: 12),
            Text(value, style: _valueStyle),
            const SizedBox(width: 8),
            Text(label, style: _labelStyle),
          ]
        : [
            Text(label, style: _labelStyle),
            const SizedBox(width: 8),
            Text(value, style: _valueStyle),
            const SizedBox(width: 12),
            icon,
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment:
            isLTR ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: children,
      ),
    );
  }

  static const _valueStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static final _labelStyle = TextStyle(
    color: Colors.white.withValues(alpha: 0.85),
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
}
