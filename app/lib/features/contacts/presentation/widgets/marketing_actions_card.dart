import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/domain/providers/subscription_provider.dart';
import '../../../../shared/utils/contact_launcher.dart';
import '../../../packages/data/models/package_model.dart';
import '../../../trips/domain/providers/trip_provider.dart';
import '../../data/models/contact_model.dart';
import '../../domain/providers/contact_provider.dart';

class MarketingActionsCard extends ConsumerWidget {
  final ContactModel contact;

  const MarketingActionsCard({
    super.key,
    required this.contact,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final isPremium = ref.watch(isPremiumProvider);
    final hasPhone = contact.phone != null && contact.phone!.isNotEmpty;

    final packagesAsync = ref.watch(contactPackagesProvider(contact.id));
    final registeredPackage = packagesAsync.whenOrNull(
      data: (packages) => packages
          .where((p) => p.status == PackageStatus.registered)
          .firstOrNull,
    );

    final tripsState = ref.watch(tripsProvider);
    final nextTrip = tripsState.upcomingTrips.firstOrNull;
    final isLocked = !isPremium;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          _MarketingActionTile(
            icon: Icons.local_shipping_outlined,
            iconBgColor: AppColors.statusInfoBg,
            iconColor: AppColors.statusInfoText,
            title: l10n.marketing_trackingTitle,
            subtitle: l10n.marketing_trackingDesc,
            isLocked: isLocked,
            isEnabled: hasPhone && registeredPackage != null,
            onTap: () {
              if (registeredPackage != null) {
                final message = l10n.marketing_trackingMessage(
                  contact.name,
                  registeredPackage.trackingCode,
                );
                ContactLauncher.openWhatsApp(contact.phone!, message: message);
              }
            },
          ),
          Divider(height: 1, color: colors.border, indent: 52, endIndent: 16),
          _MarketingActionTile(
            icon: Icons.card_giftcard_outlined,
            iconBgColor: AppColors.statusSuccessBg,
            iconColor: AppColors.statusSuccessText,
            title: l10n.marketing_loyaltyTitle,
            subtitle: l10n.marketing_loyaltyDesc,
            isLocked: isLocked,
            isEnabled: hasPhone,
            onTap: () {
              final message = l10n.marketing_loyaltyMessage(contact.name);
              ContactLauncher.openWhatsApp(contact.phone!, message: message);
            },
          ),
          Divider(height: 1, color: colors.border, indent: 52, endIndent: 16),
          _MarketingActionTile(
            icon: Icons.flight_takeoff,
            iconBgColor: AppColors.statusWarningBg,
            iconColor: AppColors.statusWarningText,
            title: l10n.marketing_tripTitle,
            subtitle: l10n.marketing_tripDesc,
            isLocked: isLocked,
            isEnabled: hasPhone && nextTrip != null,
            onTap: () {
              if (nextTrip != null) {
                final dateStr =
                    DateFormat('dd/MM').format(nextTrip.departureDate);
                final message = l10n.marketing_tripMessage(
                  contact.name,
                  nextTrip.originCity,
                  nextTrip.destinationCity,
                  dateStr,
                );
                ContactLauncher.openWhatsApp(contact.phone!, message: message);
              }
            },
          ),
          if (isLocked) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: navegar a pantalla de planes
                  },
                  icon: const Icon(Icons.lock_open, size: 14),
                  label: Text(l10n.marketing_upgradeCta,
                      style: const TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.3)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MarketingActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isLocked;
  final bool isEnabled;
  final VoidCallback onTap;

  const _MarketingActionTile({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isLocked,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final canAct = !isLocked && isEnabled;
    final opacity = (isLocked || !isEnabled) ? 0.45 : 1.0;

    return InkWell(
      onTap: canAct ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Opacity(
              opacity: opacity,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Opacity(
                opacity: opacity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: colors.textMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (canAct)
              _SendButton(onTap: onTap)
            else
              Icon(
                isLocked ? Icons.lock_outline : Icons.info_outline,
                size: 16,
                color: colors.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SendButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(Icons.send, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}
