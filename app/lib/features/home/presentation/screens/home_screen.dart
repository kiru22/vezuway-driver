import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../routes/domain/providers/route_provider.dart';
import '../../../packages/domain/providers/package_provider.dart';
import '../../domain/providers/dashboard_provider.dart';
import '../widgets/hero_section.dart';
import '../widgets/trip_carousel.dart';
import '../widgets/stats_grid.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(routesProvider.notifier).loadRoutes();
      ref.read(packagesProvider.notifier).loadPackages();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final upcomingTrips = ref.watch(upcomingTripsProvider);
    final dashboardStats = ref.watch(dashboardStatsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: colorScheme.primary,
          backgroundColor: colorScheme.surfaceContainerHighest,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: AppHeader(
                  onMenuTap: () => _showUserMenu(context),
                ),
              ),
              // Greeting section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: HeroSection(userName: authState.user?.name),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
              // Stats section
              SliverToBoxAdapter(
                child: dashboardStats.when(
                  data: (stats) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: StatsGrid(stats: stats),
                  ),
                  loading: () => const _StatsLoadingShimmer(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 28),
              ),
              // Section title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Proximas rutas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Ver todas',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 12),
              ),
              // Upcoming routes list
              SliverToBoxAdapter(
                child: UpcomingRoutesList(routes: upcomingTrips),
              ),
              // Bottom padding for nav bar
              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    HapticFeedback.mediumImpact();
    await Future.wait([
      ref.read(routesProvider.notifier).loadRoutes(),
      ref.read(packagesProvider.notifier).loadPackages(),
    ]);
  }

  void _showUserMenu(BuildContext context) {
    HapticFeedback.lightImpact();
    final user = ref.read(authProvider).user;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _UserMenuSheet(
        userName: user?.name ?? 'Usuario',
        userEmail: user?.email ?? '',
        onLogout: () {
          Navigator.pop(context);
          ref.read(authProvider.notifier).logout();
        },
      ),
    );
  }
}

class _StatsLoadingShimmer extends StatelessWidget {
  const _StatsLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(left: index > 0 ? 12 : 0),
              height: 120,
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: colors.border),
              ),
              child: const _ShimmerEffect(),
            ),
          );
        }),
      ),
    );
  }
}

class _ShimmerEffect extends StatefulWidget {
  const _ShimmerEffect();

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
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
    final colors = context.colors;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                colors.shimmerBase,
                colors.shimmerHighlight,
                colors.shimmerBase,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
          ),
        );
      },
    );
  }
}

class _UserMenuSheet extends StatelessWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const _UserMenuSheet({
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),
          // User avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userEmail,
            style: TextStyle(
              fontSize: 14,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 28),
          // Menu options
          _MenuOption(
            icon: Icons.person_outline_rounded,
            label: 'Mi perfil',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
          _MenuOption(
            icon: Icons.settings_outlined,
            label: 'Configuracion',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
          _MenuOption(
            icon: Icons.help_outline_rounded,
            label: 'Ayuda',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
          // Logout button
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onLogout();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Cerrar sesion',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: colors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
