import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../data/models/contact_model.dart';

class ContactStatsCard extends StatelessWidget {
  final ContactModel contact;

  const ContactStatsCard({
    super.key,
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar grande
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              contact.initials,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Nombre
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (contact.isVerified) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.verified,
                  size: 24,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Email y teléfono
          if (contact.email != null)
            _buildInfoRow(
              context,
              Icons.email_outlined,
              contact.email!,
            ),
          if (contact.phone != null)
            _buildInfoRow(
              context,
              Icons.phone_outlined,
              contact.phone!,
            ),
          if (contact.fullAddress.isNotEmpty)
            _buildInfoRow(
              context,
              Icons.location_on_outlined,
              contact.fullAddress,
            ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),

          // Estadísticas
          Row(
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
              Container(
                width: 1,
                height: 50,
                color: Theme.of(context).dividerColor,
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  context.l10n.contacts_statsReceived,
                  contact.totalPackagesReceived.toString(),
                  Icons.south_west,
                  Colors.green,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Theme.of(context).dividerColor,
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  context.l10n.contacts_statsTotal,
                  contact.totalPackages.toString(),
                  Icons.inventory_2_outlined,
                  AppColors.primary,
                ),
              ),
            ],
          ),

          if (contact.lastPackageAt != null) ...[
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  '${context.l10n.contacts_lastActivity}: ${_formatDate(contact.lastPackageAt!)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color:
                Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
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
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color:
                Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
