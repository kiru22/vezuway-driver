import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../data/models/pending_driver_model.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_error_view.dart';
import '../widgets/approve_reject_dialog.dart';
import '../widgets/pending_driver_card.dart';

class PendingRequestsScreen extends ConsumerWidget {
  const PendingRequestsScreen({super.key});

  Future<void> _handleApprove(
    BuildContext context,
    WidgetRef ref,
    driver,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ApproveRejectDialog(driver: driver, isApproval: true),
    );

    if (confirmed != true || !context.mounted) return;

    final success =
        await ref.read(adminActionsProvider.notifier).approveDriver(driver.id);

    if (success && context.mounted) {
      final l10n = AppLocalizations.of(context);
      _showSnackBar(context, l10n.admin_driverApproved(driver.name), AppColors.primary);
    }
  }

  Future<void> _handleReject(
    BuildContext context,
    WidgetRef ref,
    driver,
  ) async {
    final result = await showDialog<dynamic>(
      context: context,
      builder: (_) => ApproveRejectDialog(driver: driver, isApproval: false),
    );

    if (result == null || !context.mounted) return;

    final reason = result is String && result.isNotEmpty ? result : null;
    final success = await ref
        .read(adminActionsProvider.notifier)
        .rejectDriver(driver.id, reason: reason);

    if (success && context.mounted) {
      final l10n = AppLocalizations.of(context);
      _showSnackBar(context, l10n.admin_driverRejected(driver.name), Colors.red.shade700);
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pendingDriversAsync = ref.watch(pendingDriversProvider);
    final actionState = ref.watch(adminActionsProvider);

    return Column(
      children: [
        if (actionState.status == AdminActionStatus.error)
          AdminActionErrorBanner(
            errorMessage: actionState.error,
            onDismiss: () =>
                ref.read(adminActionsProvider.notifier).clearMessages(),
          ),
        Expanded(
          child: pendingDriversAsync.when(
            data: (drivers) => _buildDriversList(context, ref, drivers, l10n),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => AdminErrorView(
              message: l10n.admin_loadError,
              detail: error.toString(),
              onRetry: () => ref.invalidate(pendingDriversProvider),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDriversList(
    BuildContext context,
    WidgetRef ref,
    List<PendingDriverModel> drivers,
    AppLocalizations l10n,
  ) {
    if (drivers.isEmpty) {
      return EmptyState(
        icon: Icons.check_circle_outline,
        title: l10n.admin_noPendingDrivers,
        subtitle: l10n.admin_allDriversReviewed,
        iconColor: Colors.green,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(pendingDriversProvider),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: drivers
            .map(
              (driver) => PendingDriverCard(
                driver: driver,
                onApprove: () => _handleApprove(context, ref, driver),
                onReject: () => _handleReject(context, ref, driver),
              ),
            )
            .toList(),
      ),
    );
  }
}
