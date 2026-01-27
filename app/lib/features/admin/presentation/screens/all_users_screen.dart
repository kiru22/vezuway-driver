import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_error_view.dart';
import '../widgets/admin_stats_card.dart';
import '../widgets/user_card.dart';

class AllUsersScreen extends ConsumerWidget {
  const AllUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedFilter = ref.watch(userRoleFilterProvider);
    final usersAsync = ref.watch(allUsersProvider);

    return Column(
      children: [
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              _FilterChip(
                label: l10n.admin_allUsers,
                isSelected: selectedFilter == null,
                onTap: () =>
                    ref.read(userRoleFilterProvider.notifier).state = null,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: l10n.admin_clients,
                isSelected: selectedFilter == 'client',
                onTap: () =>
                    ref.read(userRoleFilterProvider.notifier).state = 'client',
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: l10n.admin_drivers,
                isSelected: selectedFilter == 'driver',
                onTap: () =>
                    ref.read(userRoleFilterProvider.notifier).state = 'driver',
              ),
            ],
          ),
        ),

        // Users list
        Expanded(
          child: usersAsync.when(
            data: (users) {
              if (users.isEmpty) {
                return EmptyState(
                  icon: Icons.people_outline,
                  title: l10n.admin_noUsers,
                  subtitle: '',
                );
              }

              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(allUsersProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return AdminStatsCard(
                        count: users.length,
                        label: _getStatsLabel(selectedFilter, users.length, l10n),
                        icon: Icons.people_rounded,
                        color: AppColors.primary,
                      );
                    }
                    return UserCard(user: users[index - 1]);
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => AdminErrorView(
              message: l10n.admin_loadError,
              detail: error.toString(),
              onRetry: () => ref.invalidate(allUsersProvider),
            ),
          ),
        ),
      ],
    );
  }

  String _getStatsLabel(String? filter, int count, AppLocalizations l10n) {
    final isSingular = count == 1;
    switch (filter) {
      case 'client':
        return isSingular ? l10n.admin_clientSingular : l10n.admin_clientPlural;
      case 'driver':
        return isSingular ? l10n.admin_driverSingular : l10n.admin_driverPlural;
      default:
        return isSingular ? l10n.admin_userSingular : l10n.admin_userPlural;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : colors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : colors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

