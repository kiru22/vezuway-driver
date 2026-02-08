import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DemoHubScreen extends StatelessWidget {
  const DemoHubScreen({super.key});

  static const _demos = [
    _DemoEntry(
      title: 'Gooey Switch',
      subtitle: 'Switch, Toggle & TabBar',
      icon: Icons.toggle_on_rounded,
      route: '/demo/gooey-switch',
      color: Color(0xFF8B5CF6),
    ),
    _DemoEntry(
      title: 'Stats Bar',
      subtitle: 'StatsBarBlock & UnifiedStatsCard',
      icon: Icons.bar_chart_rounded,
      route: '/demo/stats-bar',
      color: Color(0xFF3B82F6),
    ),
    _DemoEntry(
      title: 'StatCard Premium',
      subtitle: 'Gradient cards con glow & sombras',
      icon: Icons.auto_awesome_rounded,
      route: '/demo/stat-card',
      color: Color(0xFF10B981),
    ),
    _DemoEntry(
      title: 'Iconos Rutas & Viajes',
      subtitle: '5 propuestas + preview bottom nav',
      icon: Icons.compare_rounded,
      route: '/demo/icons',
      color: Color(0xFFEF4444),
    ),
    _DemoEntry(
      title: 'Grainy Gradient',
      subtitle: 'Animated gradient with grain texture',
      icon: Icons.gradient_rounded,
      route: '/demo/grainy-gradient',
      color: Color(0xFF7C3AED),
    ),
    _DemoEntry(
      title: 'Staggered Text',
      subtitle: 'Character-by-character animation',
      icon: Icons.text_fields_rounded,
      route: '/demo/staggered-text',
      color: Color(0xFF3B82F6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Component Demos')),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _demos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final demo = _demos[index];
          return _DemoCard(demo: demo);
        },
      ),
    );
  }
}

class _DemoEntry {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final Color color;

  const _DemoEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.color,
  });
}

class _DemoCard extends StatelessWidget {
  final _DemoEntry demo;

  const _DemoCard({required this.demo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(demo.route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: demo.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(demo.icon, color: demo.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      demo.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      demo.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
