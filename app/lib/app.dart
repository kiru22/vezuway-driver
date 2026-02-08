import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/navigation/page_transitions.dart';
import 'core/theme/app_theme.dart';
import 'shared/providers/tab_index_provider.dart';
import 'features/auth/domain/providers/auth_provider.dart';
import 'generated/l10n/app_localizations.dart';
import 'shared/providers/locale_provider.dart';
import 'shared/providers/theme_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/user_type_selection_screen.dart';
import 'features/auth/presentation/screens/driver_pending_screen.dart';
import 'features/auth/presentation/screens/driver_rejected_screen.dart';
import 'features/admin/presentation/screens/user_detail_screen.dart';
import 'features/admin/presentation/shells/admin_shell.dart';
import 'features/client_dashboard/presentation/screens/client_dashboard_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/packages/presentation/screens/packages_screen.dart';
import 'features/packages/presentation/screens/package_detail_screen.dart';
import 'features/packages/presentation/screens/create_package_screen.dart';
import 'features/packages/presentation/screens/my_orders_screen.dart';
import 'features/contacts/presentation/screens/contacts_screen.dart';
import 'features/contacts/presentation/screens/contact_detail_screen.dart';
import 'features/routes/presentation/screens/create_route_screen.dart';
import 'features/routes/presentation/screens/edit_route_screen.dart';
import 'features/trips/presentation/screens/trips_routes_screen.dart';
import 'features/trips/presentation/screens/create_trip_screen.dart';
import 'features/plans/presentation/screens/plans_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/shell/presentation/main_shell.dart';
import 'shared/widgets/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoading = authState.status == AuthStatus.loading ||
          authState.status == AuthStatus.initial;
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final user = authState.user;
      final location = state.matchedLocation;

      if (isLoading) return '/';

      final isAuthRoute = location == '/login' || location == '/register';
      final isProfileRoute = location.startsWith('/profile');

      if (!isAuthenticated && !isAuthRoute) return '/login';

      if (isAuthenticated) {
        if (user?.needsRoleSelection == true) {
          if (location != '/select-user-type') {
            return '/select-user-type';
          }
          return null;
        }

        if (user?.isPendingDriver == true) {
          if (location != '/driver-pending' && !isProfileRoute) {
            return '/driver-pending';
          }
          return null;
        }

        if (user?.isRejectedDriver == true) {
          if (location != '/driver-rejected' && !isProfileRoute) {
            return '/driver-rejected';
          }
          return null;
        }

        if (user?.isSuperAdmin == true) {
          final forbiddenForAdmin = [
            '/home',
            '/packages',
            '/routes',
            '/contacts',
            '/trips',
            '/imports',
            '/client-dashboard',
          ];

          if (forbiddenForAdmin.any((route) => location.startsWith(route))) {
            return '/admin';
          }
        }

        if (user?.isClient == true) {
          final forbiddenForClients = [
            '/routes',
            '/contacts',
            '/home',
            '/trips',
            '/imports',
            '/packages',
            '/admin',
          ];

          if (forbiddenForClients.any((route) => location.startsWith(route))) {
            return '/client-dashboard';
          }
        }

        if (user?.isDriver == true) {
          if (location.startsWith('/admin')) {
            return '/home';
          }
        }

        if (isAuthRoute) {
          if (user?.isSuperAdmin == true) {
            return '/admin';
          } else if (user?.isClient == true) {
            return '/client-dashboard';
          } else {
            return '/home';
          }
        }

        if (location == '/') {
          if (user?.isSuperAdmin == true) {
            return '/admin';
          } else if (user?.isClient == true) {
            return '/client-dashboard';
          } else {
            return '/home';
          }
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => fadeSlideTransitionPage(
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => fadeSlideTransitionPage(
          state: state,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: '/select-user-type',
        pageBuilder: (context, state) => fadeSlideTransitionPage(
          state: state,
          child: const UserTypeSelectionScreen(),
        ),
      ),
      GoRoute(
        path: '/driver-pending',
        pageBuilder: (context, state) => fadeSlideTransitionPage(
          state: state,
          child: const DriverPendingScreen(),
        ),
      ),
      GoRoute(
        path: '/driver-rejected',
        pageBuilder: (context, state) => fadeSlideTransitionPage(
          state: state,
          child: const DriverRejectedScreen(),
        ),
      ),
      GoRoute(
        path: '/routes/create',
        pageBuilder: (context, state) => fadeSlideTransitionPage(
          state: state,
          child: const CreateRouteScreen(),
        ),
      ),
      GoRoute(
        path: '/routes/:id/edit',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return fadeSlideTransitionPage(
            state: state,
            child: EditRouteScreen(routeId: id),
          );
        },
      ),
      GoRoute(
        path: '/trips/create',
        pageBuilder: (context, state) {
          final routeId = state.uri.queryParameters['routeId'];
          return fadeSlideTransitionPage(
            state: state,
            child: CreateTripScreen(routeId: routeId),
          );
        },
      ),
      GoRoute(
        path: '/trips/:id/edit',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return fadeSlideTransitionPage(
            state: state,
            child: CreateTripScreen(tripId: id),
          );
        },
      ),

      GoRoute(
        path: '/packages/new',
        pageBuilder: (context, state) => fadeSlideTransitionPage(
          state: state,
          child: const CreatePackageScreen(),
        ),
      ),

      GoRoute(
        path: '/packages/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return fadeSlideTransitionPage(
            state: state,
            child: PackageDetailScreen(packageId: id),
          );
        },
      ),
      GoRoute(
        path: '/packages/:id/edit',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return fadeSlideTransitionPage(
            state: state,
            child: CreatePackageScreen(packageId: id),
          );
        },
      ),
      GoRoute(
        path: '/my-orders',
        pageBuilder: (context, state) => fadeSlideTransitionPage(
          state: state,
          child: const MyOrdersScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => fadeSlideTransitionPage(
          state: state,
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/plans',
        pageBuilder: (context, state) => fadeSlideTransitionPage(
          state: state,
          child: const PlansScreen(),
        ),
      ),
      GoRoute(
        path: '/client-dashboard',
        pageBuilder: (context, state) => fadeSlideTransitionPage(
          state: state,
          child: const ClientDashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/admin',
        pageBuilder: (context, state) => fadeSlideTransitionPage(
          state: state,
          child: const AdminShell(),
        ),
        routes: [
          GoRoute(
            path: 'users/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return fadeSlideTransitionPage(
                state: state,
                child: UserDetailScreen(userId: id),
              );
            },
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => _buildTabPage(
              context: context,
              state: state,
              tabIndex: 0,
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/packages',
            pageBuilder: (context, state) => _buildTabPage(
              context: context,
              state: state,
              tabIndex: 1,
              child: const PackagesScreen(),
            ),
          ),
          GoRoute(
            path: '/routes',
            pageBuilder: (context, state) => _buildTabPage(
              context: context,
              state: state,
              tabIndex: 2,
              child: const TripsRoutesScreen(),
            ),
          ),
          GoRoute(
            path: '/contacts',
            pageBuilder: (context, state) => _buildTabPage(
              context: context,
              state: state,
              tabIndex: 3,
              child: const ContactsScreen(),
            ),
          ),
          GoRoute(
            path: '/imports',
            pageBuilder: (context, state) => fadeSlideTransitionPage(
              state: state,
              child: const PackagesScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/contacts/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return fadeSlideTransitionPage(
            state: state,
            child: ContactDetailScreen(contactId: id),
          );
        },
      ),
    ],
  );
});

/// Helper function to build tab pages with horizontal slide transitions.
/// Reduces duplication in the ShellRoute tab definitions.
Page<void> _buildTabPage({
  required BuildContext context,
  required GoRouterState state,
  required int tabIndex,
  required Widget child,
}) {
  final container = ProviderScope.containerOf(context);
  final prevIndex = container.read(currentTabIndexProvider);
  final slideFromRight = shouldSlideFromRight(prevIndex, tabIndex);

  Future.microtask(() {
    container.read(currentTabIndexProvider.notifier).state = tabIndex;
  });

  return horizontalSlideTransitionPage(
    state: state,
    slideFromRight: slideFromRight,
    child: child,
  );
}

class LogisticsApp extends ConsumerWidget {
  const LogisticsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final appLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'vezuway.',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      locale: appLocale.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
