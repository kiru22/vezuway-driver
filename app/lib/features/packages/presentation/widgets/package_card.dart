import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/status_localizations.dart';
import '../../data/models/package_model.dart';

class PackageCard extends StatelessWidget {
  final PackageModel package;
  final VoidCallback onTap;
  final Function(PackageStatus) onStatusChange;

  const PackageCard({
    super.key,
    required this.package,
    required this.onTap,
    required this.onStatusChange,
  });

  Color _getStatusColor(PackageStatus status) {
    switch (status) {
      case PackageStatus.pending:
        return AppColors.textMuted;
      case PackageStatus.pickedUp:
        return AppColors.info;
      case PackageStatus.inTransit:
        return AppColors.primary;
      case PackageStatus.inWarehouse:
        return const Color(0xFF8B5CF6);
      case PackageStatus.outForDelivery:
        return const Color(0xFF6366F1);
      case PackageStatus.delivered:
        return AppColors.success;
      case PackageStatus.cancelled:
        return AppColors.error;
      case PackageStatus.returned:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? colors.cardBackground : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with tracking code and status
                  Row(
                    children: [
                      // Status indicator
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getStatusColor(package.status),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: _getStatusColor(package.status)
                                  .withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Package icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.inventory_2_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Tracking code
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              package.trackingCode,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: colors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${(package.weight ?? 0.0).toStringAsFixed(1)} kg',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status badge
                      _StatusBadge(
                        status: package.status,
                        color: _getStatusColor(package.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Sender to Receiver
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? colors.surfaceLight : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _PersonInfo(
                            icon: Icons.upload_rounded,
                            iconColor: AppColors.info,
                            label: context.l10n.packages_sender,
                            name: package.senderName,
                            textColor: colors.textPrimary,
                            mutedColor: colors.textMuted,
                          ),
                        ),
                        // Arrow
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDark ? colors.cardBackground : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.border),
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: colors.textMuted,
                            size: 16,
                          ),
                        ),
                        Expanded(
                          child: _PersonInfo(
                            icon: Icons.download_rounded,
                            iconColor: AppColors.success,
                            label: context.l10n.packages_receiver,
                            name: package.receiverName,
                            alignEnd: true,
                            textColor: colors.textPrimary,
                            mutedColor: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Description
                  if (package.description != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      package.description!,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Action bar
            if (package.status != PackageStatus.delivered &&
                package.status != PackageStatus.cancelled)
              Container(
                decoration: BoxDecoration(
                  color: isDark ? colors.surfaceLight : const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppTheme.radiusXl - 1),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showStatusMenu(context),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(context.l10n.packages_changeStatus),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showStatusMenu(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _StatusSelectorSheet(
        currentStatus: package.status,
        onStatusSelected: (status) {
          Navigator.pop(context);
          onStatusChange(status);
        },
        getStatusColor: _getStatusColor,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PackageStatus status;
  final Color color;

  const _StatusBadge({
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        status.localizedName(context),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _PersonInfo extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String name;
  final bool alignEnd;
  final Color textColor;
  final Color mutedColor;

  const _PersonInfo({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.name,
    this.alignEnd = false,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!alignEnd) ...[
              Icon(icon, size: 12, color: iconColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: mutedColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (alignEnd) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 12, color: iconColor),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: textColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
        ),
      ],
    );
  }
}

class _StatusSelectorSheet extends StatelessWidget {
  final PackageStatus currentStatus;
  final Function(PackageStatus) onStatusSelected;
  final Color Function(PackageStatus) getStatusColor;

  const _StatusSelectorSheet({
    required this.currentStatus,
    required this.onStatusSelected,
    required this.getStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: AppColors.borderAccent),
          left: BorderSide(color: AppColors.borderAccent),
          right: BorderSide(color: AppColors.borderAccent),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.packages_changeStatus,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.packages_selectNewStatus,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          // Status options
          ...PackageStatus.values
              .where((s) => s != currentStatus)
              .map((status) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _StatusOption(
                      status: status,
                      color: getStatusColor(status),
                      onTap: () => onStatusSelected(status),
                    ),
                  )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final PackageStatus status;
  final Color color;
  final VoidCallback onTap;

  const _StatusOption({
    required this.status,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                status.localizedName(context),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact package card for lists
class PackageCardCompact extends StatelessWidget {
  final PackageModel package;
  final VoidCallback onTap;

  const PackageCardCompact({
    super.key,
    required this.package,
    required this.onTap,
  });

  Color _getStatusColor(PackageStatus status) {
    switch (status) {
      case PackageStatus.pending:
        return AppColors.textMuted;
      case PackageStatus.pickedUp:
        return AppColors.info;
      case PackageStatus.inTransit:
        return AppColors.primary;
      case PackageStatus.inWarehouse:
        return const Color(0xFF8B5CF6);
      case PackageStatus.outForDelivery:
        return const Color(0xFF6366F1);
      case PackageStatus.delivered:
        return AppColors.success;
      case PackageStatus.cancelled:
        return AppColors.error;
      case PackageStatus.returned:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: _getStatusColor(package.status),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.trackingCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${package.senderName} - ${package.receiverName}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Weight
            Text(
              '${(package.weight ?? 0.0).toStringAsFixed(1)} kg',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
