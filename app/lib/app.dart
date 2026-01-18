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
import 'features/home/presentation/screens/home_screen.dart';
import 'features/packages/presentation/screens/packages_screen.dart';
import 'features/packages/presentation/screens/package_detail_screen.dart';
import 'features/packages/presentation/screens/create_package_screen.dart';
import 'features/routes/presentation/screens/routes_screen.dart';
import 'features/routes/presentation/screens/create_route_screen.dart';
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
        path: '/routes/create',
        pageBuilder: (context, state) => fadeSlideTransitionPage(
          state: state,
          child: const CreateRouteScreen(),
        ),
      ),
      GoRoute(
        path: '/packages/new',
        pageBuilder: (context, state) => fadeSlideTransitionPage(
          state: state,
          child: const CreatePackageScreen(),
        ),
      ),
      // Package detail and edit routes outside ShellRoute (no navbar)
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
        path: '/profile',
        pageBuilder: (context, state) => fadeSlideTransitionPage(
          state: state,
          child: const ProfileScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) {
              const currentIndex = 0;
              final container = ProviderScope.containerOf(context);
              final prevIndex = container.read(currentTabIndexProvider);
              final slideFromRight = shouldSlideFromRight(prevIndex, currentIndex);

              // Demorar la actualización hasta después del build
              Future.microtask(() {
                container.read(currentTabIndexProvider.notifier).state = currentIndex;
              });

              return horizontalSlideTransitionPage(
                state: state,
                slideFromRight: slideFromRight,
                child: const HomeScreen(),
              );
            },
          ),
          GoRoute(
            path: '/packages',
            pageBuilder: (context, state) {
              const currentIndex = 1;
              final container = ProviderScope.containerOf(context);
              final prevIndex = container.read(currentTabIndexProvider);
              final slideFromRight = shouldSlideFromRight(prevIndex, currentIndex);

              Future.microtask(() {
                container.read(currentTabIndexProvider.notifier).state = currentIndex;
              });

              return horizontalSlideTransitionPage(
                state: state,
                slideFromRight: slideFromRight,
                child: const PackagesScreen(),
              );
            },
          ),
          GoRoute(
            path: '/routes',
            pageBuilder: (context, state) {
              const currentIndex = 2;
              final container = ProviderScope.containerOf(context);
              final prevIndex = container.read(currentTabIndexProvider);
              final slideFromRight = shouldSlideFromRight(prevIndex, currentIndex);

              Future.microtask(() {
                container.read(currentTabIndexProvider.notifier).state = currentIndex;
              });

              return horizontalSlideTransitionPage(
                state: state,
                slideFromRight: slideFromRight,
                child: const RoutesScreen(),
              );
            },
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
