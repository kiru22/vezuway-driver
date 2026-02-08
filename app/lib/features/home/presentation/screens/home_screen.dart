import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/shimmer_widget.dart';
import '../../../../shared/widgets/user_menu_sheet.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../notifications/presentation/widgets/notification_permission_banner.dart';
import '../../../packages/domain/providers/package_provider.dart';
import '../../../routes/domain/providers/route_provider.dart';
import '../../../trips/domain/providers/trip_provider.dart';
import '../../domain/providers/dashboard_provider.dart';
import '../widgets/hero_section.dart';
import '../widgets/stats_grid.dart';
import '../widgets/trip_carousel.dart';

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
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
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
              SliverToBoxAdapter(
                child: AppHeader(
                  onMenuTap: () => showUserMenuSheet(context, ref),
                ),
              ),
              const SliverToBoxAdapter(
                child: NotificationPermissionBanner(),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: HeroSection(userName: authState.user?.name),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.home_upcomingRoutes,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/routes'),
                        child: Text(
                          context.l10n.common_viewAll,
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
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: UpcomingTripsList(trips: upcomingTrips),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
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
      ref.read(tripsProvider.notifier).loadTrips(),
      ref.read(packagesProvider.notifier).loadPackages(),
    ]);
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
              child: ShimmerWidget(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
            ),
          );
        }),
      ),
    );
  }
}
