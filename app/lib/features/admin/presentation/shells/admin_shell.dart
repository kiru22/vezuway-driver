import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../generated/l10n/app_localizations.dart';
import '../../../../shared/widgets/pill_tab_bar.dart';
import '../../../../shared/widgets/user_menu_sheet.dart';
import '../../domain/providers/admin_provider.dart';
import '../screens/all_users_screen.dart';
import '../screens/pending_requests_screen.dart';

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final pendingCount = ref.watch(pendingDriversCountProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    l10n.admin_panelTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.person_outline),
                    onPressed: () => showUserMenuSheet(context, ref),
                    tooltip: l10n.userMenu_profile,
                  ),
                ],
              ),
            ),

            // Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: PillTabBar(
                controller: _tabController,
                labels: [l10n.admin_requests, l10n.admin_users],
                badges: [pendingCount, null],
                badgeStyles: const [BadgeStyle.success, null],
              ),
            ),

            // Content - TabBarView para transición suave
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  PendingRequestsScreen(),
                  AllUsersScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
