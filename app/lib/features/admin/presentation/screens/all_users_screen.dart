import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../generated/l10n/app_localizations.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/gooey_tab_bar.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_error_view.dart';
import '../widgets/user_card.dart';

class AllUsersScreen extends ConsumerStatefulWidget {
  const AllUsersScreen({super.key});

  @override
  ConsumerState<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends ConsumerState<AllUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GooeyTabBar(
              controller: _tabController,
              labels: [l10n.admin_allUsers, l10n.admin_clients, l10n.admin_drivers],
            ),
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _UsersList(
                usersAsync: ref.watch(allUsersProvider),
                onRefresh: () => ref.invalidate(allUsersProvider),
                l10n: l10n,
              ),
              _UsersList(
                usersAsync: ref.watch(clientUsersProvider),
                onRefresh: () => ref.invalidate(allUsersProvider),
                l10n: l10n,
              ),
              _UsersList(
                usersAsync: ref.watch(driverUsersProvider),
                onRefresh: () => ref.invalidate(allUsersProvider),
                l10n: l10n,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UsersList extends StatelessWidget {
  final AsyncValue<List<UserModel>> usersAsync;
  final VoidCallback onRefresh;
  final AppLocalizations l10n;

  const _UsersList({
    required this.usersAsync,
    required this.onRefresh,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return usersAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return EmptyState(
            icon: Icons.people_outline,
            title: l10n.admin_noUsers,
            subtitle: '',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => onRefresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) => UserCard(
              user: users[index],
              onTap: () => context.push('/admin/users/${users[index].id}'),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => AdminErrorView(
        message: l10n.admin_loadError,
        detail: error.toString(),
        onRetry: onRefresh,
      ),
    );
  }
}
