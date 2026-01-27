import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/l10n_extension.dart';

/// Reusable delete confirmation dialog.
/// Returns true if user confirms, false if cancelled.
///
/// Usage:
/// ```dart
/// final confirmed = await showDeleteConfirmationDialog(
///   context: context,
///   itemType: 'contacto',
/// );
/// if (confirmed == true) {
///   // Perform delete
/// }
/// ```
Future<bool?> showDeleteConfirmationDialog({
  required BuildContext context,
  required String itemType,
  String? title,
  String? message,
  String? cancelLabel,
  String? deleteLabel,
}) {
  final l10n = context.l10n;

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title ?? l10n.common_deleteConfirmTitle),
      content: Text(message ?? l10n.common_deleteConfirmMessage(itemType)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(cancelLabel ?? l10n.common_cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: Text(deleteLabel ?? l10n.common_delete),
        ),
      ],
    ),
  );
}
