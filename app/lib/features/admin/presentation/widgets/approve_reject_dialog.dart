import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../shared/widgets/styled_form_field.dart';
import '../../data/models/pending_driver_model.dart';

class ApproveRejectDialog extends StatefulWidget {
  final PendingDriverModel driver;
  final bool isApproval;

  const ApproveRejectDialog({
    super.key,
    required this.driver,
    required this.isApproval,
  });

  @override
  State<ApproveRejectDialog> createState() => _ApproveRejectDialogState();
}

class _ApproveRejectDialogState extends State<ApproveRejectDialog> {
  final _reasonController = TextEditingController();

  Color get _accentColor =>
      widget.isApproval ? AppColors.primary : Colors.red.shade700;

  Color get _bgColor => widget.isApproval
      ? AppColors.primary.withValues(alpha: 0.1)
      : Colors.red.shade50;

  IconData get _icon =>
      widget.isApproval ? Icons.check_circle_outline : Icons.cancel_outlined;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final title =
        widget.isApproval ? l10n.admin_approveDriver : l10n.admin_rejectDriver;
    final message = widget.isApproval
        ? l10n.admin_approveConfirm(widget.driver.name)
        : l10n.admin_rejectConfirm(widget.driver.name);
    final actionLabel =
        widget.isApproval ? l10n.admin_approve : l10n.admin_reject;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icon, color: _accentColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
              ),
            ),
            if (!widget.isApproval) ...[
              const SizedBox(height: 24),
              StyledFormField(
                controller: _reasonController,
                label: l10n.admin_rejectReasonLabel,
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                hint: l10n.admin_rejectReasonHint,
              ),
            ],
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  child: Text(l10n.common_cancel),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        widget.isApproval ? true : _reasonController.text.trim(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(actionLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
