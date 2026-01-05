import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/domain/providers/auth_provider.dart';
import 'shared/providers/theme_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/packages/presentation/screens/packages_screen.dart';
import 'features/packages/presentation/screens/package_detail_screen.dart';
import 'features/routes/presentation/screens/routes_screen.dart';
import 'features/routes/presentation/screens/create_route_screen.dart';
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
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isSplash = state.matchedLocation == '/';

      if (isLoading) {
        return '/';
      }

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      if (isAuthenticated && isSplash) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Splash screen
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      // Auth routes (outside shell)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Home/Dashboard tab
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          // Packages tab
          GoRoute(
            path: '/packages',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PackagesScreen(),
            ),
            routes: [
              // New package route must come before :id to avoid parsing "new" as int
              GoRoute(
                path: 'new',
                builder: (context, state) => const PackagesScreen(), // TODO: Replace with CreatePackageScreen
              ),
              GoRoute(
                path: 'scan',
                builder: (context, state) => const PackagesScreen(), // TODO: Replace with ScanPackageScreen
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return PackageDetailScreen(packageId: id);
                },
              ),
            ],
          ),
          // Routes tab
          GoRoute(
            path: '/routes',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RoutesScreen(),
            ),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateRouteScreen(),
              ),
            ],
          ),
          // Imports
          GoRoute(
            path: '/imports',
            builder: (context, state) => const PackagesScreen(), // TODO: Replace with ImportsScreen
          ),
        ],
      ),
    ],
  );
});

class LogisticsApp extends ConsumerWidget {
  const LogisticsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Logistics UA-ES',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
