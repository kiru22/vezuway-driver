import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class IconProposalsDemoScreen extends StatelessWidget {
  const IconProposalsDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Iconos Rutas & Viajes')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Actual', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          const _IconRow(
            items: [
              _IconOption(
                icon: Icons.timeline_rounded,
                label: 'timeline',
                subtitle: 'Tab actual',
              ),
              _IconOption(
                icon: Icons.route_rounded,
                label: 'route',
                subtitle: 'En contexto',
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('Propuestas', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          _proposal(theme, '1', 'Mapa + pin', [
            const _IconOption(
              icon: Icons.map_rounded,
              label: 'map',
              subtitle: 'Rutas',
            ),
            const _IconOption(
              icon: Icons.explore_rounded,
              label: 'explore',
              subtitle: 'Viajes',
            ),
          ]),
          const SizedBox(height: 20),
          _proposal(theme, '2', 'Navegacion', [
            const _IconOption(
              icon: Icons.near_me_rounded,
              label: 'near_me',
              subtitle: 'Rutas',
            ),
            const _IconOption(
              icon: Icons.navigation_rounded,
              label: 'navigation',
              subtitle: 'Viajes',
            ),
          ]),
          const SizedBox(height: 20),
          _proposal(theme, '3', 'Transporte', [
            const _IconOption(
              icon: Icons.fork_right_rounded,
              label: 'fork_right',
              subtitle: 'Rutas',
            ),
            const _IconOption(
              icon: Icons.moving_rounded,
              label: 'moving',
              subtitle: 'Viajes',
            ),
          ]),
          const SizedBox(height: 20),
          _proposal(theme, '4', 'Geo', [
            const _IconOption(
              icon: Icons.alt_route_rounded,
              label: 'alt_route',
              subtitle: 'Rutas',
            ),
            const _IconOption(
              icon: Icons.share_location_rounded,
              label: 'share_location',
              subtitle: 'Viajes',
            ),
          ]),
          const SizedBox(height: 20),
          _proposal(theme, '5', 'Minimalista', [
            const _IconOption(
              icon: Icons.signpost_rounded,
              label: 'signpost',
              subtitle: 'Rutas',
            ),
            const _IconOption(
              icon: Icons.flight_takeoff_rounded,
              label: 'flight_takeoff',
              subtitle: 'Viajes',
            ),
          ]),
          const SizedBox(height: 32),
          Text('Preview en bottom nav', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          _NavPreview(
            proposals: [
              _NavProposal(label: 'Actual', icon: Icons.timeline_rounded),
              _NavProposal(label: '1. map', icon: Icons.map_rounded),
              _NavProposal(label: '2. near_me', icon: Icons.near_me_rounded),
              _NavProposal(label: '3. fork_right', icon: Icons.fork_right_rounded),
              _NavProposal(label: '4. alt_route', icon: Icons.alt_route_rounded),
              _NavProposal(label: '5. signpost', icon: Icons.signpost_rounded),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _proposal(ThemeData theme, String number, String name, List<_IconOption> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$number. $name', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        _IconRow(items: items),
      ],
    );
  }
}

class _IconOption {
  final IconData icon;
  final String label;
  final String subtitle;

  const _IconOption({
    required this.icon,
    required this.label,
    required this.subtitle,
  });
}

class _IconRow extends StatelessWidget {
  final List<_IconOption> items;

  const _IconRow({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                children: [
                  Icon(items[i].icon, size: 32, color: AppColors.primary),
                  const SizedBox(height: 8),
                  Text(
                    items[i].label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    items[i].subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _NavProposal {
  final String label;
  final IconData icon;

  const _NavProposal({required this.label, required this.icon});
}

class _NavPreview extends StatelessWidget {
  final List<_NavProposal> proposals;

  const _NavPreview({required this.proposals});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        for (final p in proposals) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.shopping_bag_rounded, 'Pedidos', false),
                _navItem(Icons.space_dashboard_rounded, 'Panel', false),
                const SizedBox(width: 40),
                _navItem(p.icon, 'Rutas', true),
                _navItem(Icons.contacts_rounded, 'Contactos', false),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4, bottom: 8),
            child: Text(
              p.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    final color = active ? AppColors.primary : AppColors.navItemInactive;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: color),
        ),
      ],
    );
  }
}
