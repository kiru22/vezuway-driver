import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    // Set system UI overlay style based on theme
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: context.isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: colors.navBackground,
      systemNavigationBarIconBrightness: context.isDarkMode ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: child,
      extendBody: true,
      floatingActionButton: _FloatingAddButton(
        onPressed: () => _showAddPackageSheet(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _PremiumBottomNav(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/home' || location == '/') return 0;
    if (location.startsWith('/packages')) return 1;
    if (location.startsWith('/routes')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    HapticFeedback.lightImpact();
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/packages');
        break;
      case 2:
        context.go('/routes');
        break;
    }
  }

  void _showAddPackageSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddPackageSheet(),
    );
  }
}

class _FloatingAddButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _FloatingAddButton({required this.onPressed});

  @override
  State<_FloatingAddButton> createState() => _FloatingAddButtonState();
}

class _FloatingAddButtonState extends State<_FloatingAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 32,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _PremiumBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: colors.navBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusXxl),
          border: Border.all(
            color: colors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Inicio',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              // Space for FAB
              const SizedBox(width: 72),
              _NavItem(
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2_rounded,
                label: 'Pedidos',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.route_outlined,
                activeIcon: Icons.route_rounded,
                label: 'Rutas',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: AppTheme.durationFast,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? AppColors.primary : colors.navItemInactive,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: AppTheme.durationFast,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : colors.navItemInactive,
                letterSpacing: 0.2,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPackageSheet extends StatelessWidget {
  const _AddPackageSheet();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: colors.borderAccent),
          left: BorderSide(color: colors.borderAccent),
          right: BorderSide(color: colors.borderAccent),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Title with icon
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Crear nuevo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Selecciona que quieres registrar',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Options grid
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.route_rounded,
                  title: 'Nueva ruta',
                  subtitle: 'Espana-Ucrania',
                  gradient: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/routes/create');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.inventory_2_rounded,
                  title: 'Nuevo paquete',
                  subtitle: 'Manual',
                  gradient: [AppColors.primary, AppColors.primaryDark],
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/packages/new');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.document_scanner_rounded,
                  title: 'Escanear',
                  subtitle: 'OCR',
                  gradient: const [Color(0xFF059669), Color(0xFF047857)],
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/packages/scan');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.upload_file_rounded,
                  title: 'Importar',
                  subtitle: 'Excel',
                  gradient: const [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/imports');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: gradient.first.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
