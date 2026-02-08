import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final Widget? iconWidget;
  final String label;
  final String value;
  final List<Color> gradient;

  const StatCard({
    super.key,
    required this.icon,
    this.iconWidget,
    required this.label,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saturation = isDark ? 0.88 : 0.75;
    final softStart = Color.lerp(Colors.white, gradient.first, saturation)!;
    final midPoint = Color.lerp(softStart, gradient.last, 0.5)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [softStart, midPoint, gradient.last],
          stops: const [0.0, 0.55, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: Colors.white
              .withValues(alpha: isDark ? 0.08 : 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            width: 72,
            height: 72,
            child: Opacity(
              opacity: 0.20,
              child: iconWidget ??
                  Icon(icon, size: 72, color: Colors.white),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: AppTheme.durationSlow,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final offset = Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: offset,
                      child: child,
                    ),
                  );
                },
                child: FittedBox(
                  key: ValueKey(value),
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.8,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.90),
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
