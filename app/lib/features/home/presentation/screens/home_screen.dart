import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/shimmer_widget.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../routes/domain/providers/route_provider.dart';
import '../../../packages/domain/providers/package_provider.dart';
import '../../domain/providers/dashboard_provider.dart';
import '../widgets/hero_section.dart';
import '../widgets/trip_carousel.dart';
import '../widgets/stats_grid.dart';
import '../../../notifications/presentation/widgets/notification_permission_banner.dart';

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
              // Notification permission banner
              const SliverToBoxAdapter(
                child: NotificationPermissionBanner(),
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
                        context.l10n.home_upcomingRoutes,
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
      useRootNavigator: true,
      builder: (sheetContext) => _UserMenuSheet(
        userName: user?.name ?? context.l10n.common_user,
        userEmail: user?.email ?? '',
        avatarUrl: user?.avatarUrl,
        onLogout: () {
          Navigator.pop(sheetContext);
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

class _UserMenuSheet extends ConsumerWidget {
  final String userName;
  final String userEmail;
  final String? avatarUrl;
  final VoidCallback onLogout;

  const _UserMenuSheet({
    required this.userName,
    required this.userEmail,
    this.avatarUrl,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final locale = ref.watch(localeProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomPadding),
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
          const SizedBox(height: 16),
          // User info row
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: avatarUrl == null ? AppColors.primaryGradient : null,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: avatarUrl != null
                      ? Image.network(
                          avatarUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildInitial(),
                        )
                      : _buildInitial(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Language and Theme row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                // Language selector
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.userMenu_language,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _LanguageChip(
                            label: 'ES',
                            isSelected: locale == AppLocale.es,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref.read(localeProvider.notifier).setLocale(AppLocale.es);
                            },
                          ),
                          const SizedBox(width: 8),
                          _LanguageChip(
                            label: 'UA',
                            isSelected: locale == AppLocale.uk,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref.read(localeProvider.notifier).setLocale(AppLocale.uk);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Theme toggle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.userMenu_theme,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(themeModeProvider.notifier).toggleTheme();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colors.border),
                        ),
                        child: Icon(
                          isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          color: isDarkMode ? AppColors.warning : colors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Menu options
          _MenuOption(
            icon: Icons.person_outline_rounded,
            label: context.l10n.userMenu_profile,
            onTap: () {
              Navigator.pop(context);
              context.push('/profile');
            },
          ),
          const SizedBox(height: 6),
          _MenuOption(
            icon: Icons.settings_outlined,
            label: context.l10n.userMenu_settings,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 6),
          _MenuOption(
            icon: Icons.help_outline_rounded,
            label: context.l10n.userMenu_help,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 12),
          // Logout button
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onLogout();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.auth_logout,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitial() {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: colors.textSecondary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
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

class _LanguageChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : colors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? null : Border.all(color: colors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
