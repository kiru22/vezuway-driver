import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/domain/providers/auth_provider.dart';
import 'generated/l10n/app_localizations.dart';
import 'shared/providers/locale_provider.dart';
import 'shared/providers/theme_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/packages/presentation/screens/packages_screen.dart';
import 'features/packages/presentation/screens/package_detail_screen.dart';
import 'features/packages/presentation/screens/create_package_screen.dart';
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
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/routes/create',
        builder: (context, state) => const CreateRouteScreen(),
      ),
      GoRoute(
        path: '/packages/new',
        builder: (context, state) => const CreatePackageScreen(),
      ),
      // Package detail and edit routes outside ShellRoute (no navbar)
      GoRoute(
        path: '/packages/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PackageDetailScreen(packageId: id);
        },
      ),
      GoRoute(
        path: '/packages/:id/edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CreatePackageScreen(packageId: id);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/packages',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PackagesScreen(),
            ),
          ),
          GoRoute(
            path: '/routes',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RoutesScreen(),
            ),
          ),
          GoRoute(
            path: '/imports',
            builder: (context, state) => const PackagesScreen(),
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
