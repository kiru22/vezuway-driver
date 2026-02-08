import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'package_box_icon.dart';
import 'stat_card.dart';

class StatCardDemoScreen extends StatelessWidget {
  const StatCardDemoScreen({super.key});

  static const _emerald = AppColors.primary;
  static const _blue = Color(0xFF3B82F6);
  static const _purple = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('KPI Layouts')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _sectionTitle(theme, 'A — Fila de 3 StatCards'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.inventory_2_rounded,
                  iconWidget: const PackageBoxIcon(
                    size: 72,
                    color: Colors.white,
                    filled: true,
                  ),
                  label: 'Entregados',
                  value: '128',
                  gradient: [_emerald, const Color(0xFF059669)],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  icon: Icons.people_rounded,
                  label: 'Usuarios',
                  value: '54',
                  gradient: [_purple, const Color(0xFF7C3AED)],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  icon: Icons.euro_rounded,
                  label: 'Facturado',
                  value: '32.4K',
                  gradient: [_blue, const Color(0xFF2563EB)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _sectionTitle(theme, 'B — Barra inline compacta'),
          const SizedBox(height: 12),
          const _InlineStatsBar(
            items: [
              _InlineStat(
                  icon: Icons.inventory_2_rounded,
                  value: '128',
                  label: 'Entregados',
                  color: AppColors.primary),
              _InlineStat(
                  icon: Icons.people_rounded,
                  value: '54',
                  label: 'Usuarios',
                  color: Color(0xFF8B5CF6)),
              _InlineStat(
                  icon: Icons.euro_rounded,
                  value: '32.4K',
                  label: 'Facturado',
                  color: Color(0xFF3B82F6)),
            ],
          ),
          const SizedBox(height: 40),
          _sectionTitle(theme, 'C — Card unica gradient'),
          const SizedBox(height: 12),
          const _GradientKpiCard(
            items: [
              _KpiItem(
                  icon: Icons.inventory_2_rounded,
                  value: '128',
                  label: 'Entregados'),
              _KpiItem(
                  icon: Icons.people_rounded,
                  value: '54',
                  label: 'Usuarios'),
              _KpiItem(
                  icon: Icons.euro_rounded,
                  value: '32.4K',
                  label: 'Facturado'),
            ],
          ),
          const SizedBox(height: 40),
          _sectionTitle(theme, 'E — Gradient + ghost icons'),
          const SizedBox(height: 12),
          const _GradientGhostCard(
            items: [
              _KpiItem(
                  icon: Icons.inventory_2_rounded,
                  iconWidget: PackageBoxIcon(
                      size: 56, color: Colors.white, filled: true),
                  value: '128',
                  label: 'Entregados'),
              _KpiItem(
                  icon: Icons.people_rounded,
                  value: '54',
                  label: 'Usuarios'),
              _KpiItem(
                  icon: Icons.euro_rounded,
                  value: '32.4K',
                  label: 'Facturado'),
            ],
          ),
          const SizedBox(height: 40),
          _sectionTitle(theme, 'D — UnifiedStatsCard premium'),
          const SizedBox(height: 12),
          const _PremiumUnifiedCard(
            items: [
              _ColoredKpi(
                  icon: Icons.inventory_2_rounded,
                  value: '128',
                  label: 'Entregados',
                  color: AppColors.primary),
              _ColoredKpi(
                  icon: Icons.people_rounded,
                  value: '54',
                  label: 'Usuarios',
                  color: Color(0xFF8B5CF6)),
              _ColoredKpi(
                  icon: Icons.euro_rounded,
                  value: '32.4K',
                  label: 'Facturado',
                  color: Color(0xFF3B82F6)),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionTitle(ThemeData theme, String text) {
    return Text(text, style: theme.textTheme.titleLarge);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// B — Barra inline compacta (~48px)
// ═══════════════════════════════════════════════════════════════════════════

class _InlineStat {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _InlineStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
}

class _InlineStatsBar extends StatelessWidget {
  final List<_InlineStat> items;

  const _InlineStatsBar({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0)
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: dividerColor,
                  indent: 4,
                  endIndent: 4,
                ),
              Expanded(child: _buildCell(items[i], theme)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCell(_InlineStat item, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(item.icon, size: 18, color: item.color),
        const SizedBox(width: 6),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
              ),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// C — Card unica gradient con 3 KPIs (~70px)
// ═══════════════════════════════════════════════════════════════════════════

class _KpiItem {
  final IconData icon;
  final Widget? iconWidget;
  final String value;
  final String label;

  const _KpiItem({
    required this.icon,
    this.iconWidget,
    required this.value,
    required this.label,
  });
}

class _GradientKpiCard extends StatelessWidget {
  final List<_KpiItem> items;

  const _GradientKpiCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0D9488), const Color(0xFF059669)]
              : [const Color(0xFF10B981), const Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
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
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0)
                VerticalDivider(
                  width: 24,
                  thickness: 1,
                  color: Colors.white.withValues(alpha: 0.20),
                  indent: 2,
                  endIndent: 2,
                ),
              Expanded(child: _buildKpi(items[i])),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKpi(_KpiItem item) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(item.icon, size: 20, color: Colors.white.withValues(alpha: 0.70)),
        const SizedBox(height: 6),
        Text(
          item.value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
          maxLines: 1,
        ),
        const SizedBox(height: 2),
        Text(
          item.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.80),
          ),
          maxLines: 1,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// D — UnifiedStatsCard premium (card horizontal con 3 columnas)
// ═══════════════════════════════════════════════════════════════════════════

class _ColoredKpi {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _ColoredKpi({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
}

class _PremiumUnifiedCard extends StatelessWidget {
  final List<_ColoredKpi> items;

  const _PremiumUnifiedCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? AppColors.surface : Colors.white;
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0)
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: dividerColor,
                  indent: 4,
                  endIndent: 4,
                ),
              Expanded(child: _buildCell(items[i], theme)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCell(_ColoredKpi item, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(item.icon, size: 18, color: item.color),
        ),
        const SizedBox(height: 8),
        Text(
          item.value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
          maxLines: 1,
        ),
        const SizedBox(height: 2),
        Text(
          item.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// E — Gradient card + ghost icons (A + C hybrid)
// ═══════════════════════════════════════════════════════════════════════════

class _GradientGhostCard extends StatelessWidget {
  final List<_KpiItem> items;

  const _GradientGhostCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0D9488), const Color(0xFF059669)]
              : [const Color(0xFF10B981), const Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
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
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0)
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Colors.white.withValues(alpha: 0.15),
                  indent: 12,
                  endIndent: 12,
                ),
              Expanded(child: _buildKpi(items[i])),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKpi(_KpiItem item) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          right: 2,
          bottom: 2,
          child: Opacity(
            opacity: 0.12,
            child: item.iconWidget ??
                Icon(item.icon, size: 56, color: Colors.white),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.80),
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
