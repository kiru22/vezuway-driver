import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../plans/data/models/plan_request_model.dart';
import '../../domain/providers/admin_provider.dart';
import '../widgets/admin_error_view.dart';
import '../widgets/plan_request_card.dart';

class PlanRequestsScreen extends ConsumerWidget {
  const PlanRequestsScreen({super.key});

  Future<void> _handleApprove(
    BuildContext context,
    WidgetRef ref,
    PlanRequestModel request,
  ) async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.admin_approvePlan),
        content: Text(
          l10n.admin_approvePlanConfirm(
            request.planName,
            request.userName ?? '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.common_cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.admin_approve),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await ref
        .read(adminActionsProvider.notifier)
        .approvePlanRequest(request.id);

    if (success && context.mounted) {
      _showSnackBar(
        context,
        l10n.admin_planApproved(request.userName ?? ''),
        AppColors.primary,
      );
    }
  }

  Future<void> _handleReject(
    BuildContext context,
    WidgetRef ref,
    PlanRequestModel request,
  ) async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.admin_rejectPlan),
        content: Text(
          l10n.admin_rejectPlanConfirm(
            request.planName,
            request.userName ?? '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.common_cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.admin_reject),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await ref
        .read(adminActionsProvider.notifier)
        .rejectPlanRequest(request.id);

    if (success && context.mounted) {
      _showSnackBar(
        context,
        l10n.admin_planRejected(request.userName ?? ''),
        Colors.red.shade700,
      );
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
    final planRequestsAsync = ref.watch(adminPlanRequestsProvider);
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
          child: planRequestsAsync.when(
            data: (requests) => _buildList(context, ref, requests, l10n),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => AdminErrorView(
              message: l10n.admin_loadError,
              detail: error.toString(),
              onRetry: () => ref.invalidate(adminPlanRequestsProvider),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<PlanRequestModel> requests,
    AppLocalizations l10n,
  ) {
    if (requests.isEmpty) {
      return EmptyState(
        icon: Icons.workspace_premium_outlined,
        title: l10n.admin_noPlanRequests,
        subtitle: l10n.admin_noPlanRequestsSubtitle,
        iconColor: Colors.orange,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminPlanRequestsProvider),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: requests
            .map(
              (request) => PlanRequestCard(
                request: request,
                onApprove: () => _handleApprove(context, ref, request),
                onReject: () => _handleReject(context, ref, request),
              ),
            )
            .toList(),
      ),
    );
  }
}
