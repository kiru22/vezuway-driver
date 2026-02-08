import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/communication_button_row.dart';
import '../../../../shared/widgets/package_box_icon.dart';
import '../../data/models/contact_model.dart';

class ContactStatsCard extends StatelessWidget {
  final ContactModel contact;

  const ContactStatsCard({
    super.key,
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  contact.initials,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            contact.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        if (contact.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified,
                              size: 20, color: AppColors.primary),
                        ],
                      ],
                    ),
                    if (contact.email != null || contact.phone != null)
                      const SizedBox(height: 2),
                    if (contact.phone != null)
                      _buildInfoChip(
                          context, Icons.phone_outlined, contact.phone!),
                    if (contact.email != null)
                      _buildInfoChip(
                          context, Icons.email_outlined, contact.email!),
                    if (contact.fullAddress.isNotEmpty)
                      _buildInfoChip(context, Icons.location_on_outlined,
                          contact.fullAddress),
                  ],
                ),
              ),
            ],
          ),

          if (contact.phone != null) ...[
            const SizedBox(height: 14),
            CommunicationButtonRow(phone: contact.phone!),
          ],

          const SizedBox(height: 16),
          Divider(height: 1, color: colors.border),
          const SizedBox(height: 16),

          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    context.l10n.contacts_statsSent,
                    contact.totalPackagesSent.toString(),
                    Icons.north_east,
                    Colors.blue,
                  ),
                ),
                VerticalDivider(width: 1, color: colors.border),
                Expanded(
                  child: _buildStatItem(
                    context,
                    context.l10n.contacts_statsReceived,
                    contact.totalPackagesReceived.toString(),
                    Icons.south_west,
                    Colors.green,
                  ),
                ),
                VerticalDivider(width: 1, color: colors.border),
                Expanded(
                  child: _buildStatItem(
                    context,
                    context.l10n.contacts_statsTotal,
                    contact.totalPackages.toString(),
                    Icons.inventory_2_outlined,
                    AppColors.primary,
                    iconWidget: PackageBoxIcon(size: 20, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          if (contact.lastPackageAt != null) ...[
            const SizedBox(height: 14),
            Divider(height: 1, color: colors.border),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule, size: 14, color: colors.textMuted),
                const SizedBox(width: 6),
                Text(
                  '${context.l10n.contacts_lastActivity}: ${_formatDate(contact.lastPackageAt!)}',
                  style: TextStyle(fontSize: 13, color: colors.textMuted),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colors.textMuted),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: colors.textMuted),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color, {
    Widget? iconWidget,
  }) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget ?? Icon(icon, size: 20, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: colors.textMuted),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
