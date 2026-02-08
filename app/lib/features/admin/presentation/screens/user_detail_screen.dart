import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../shared/enums/driver_status.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/providers/admin_provider.dart';

class UserDetailScreen extends ConsumerWidget {
  final String userId;

  const UserDetailScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.go('/admin'),
        ),
        title: Text(
          l10n.admin_userDetail,
          style: TextStyle(color: colors.textPrimary),
        ),
        elevation: 0,
      ),
      body: usersAsync.when(
        data: (users) {
          final user = users.where((u) => u.id == userId).firstOrNull;
          if (user == null) {
            return Center(
              child: Text(
                l10n.common_error,
                style: TextStyle(color: colors.textPrimary),
              ),
            );
          }
          return _UserDetailBody(user: user);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.common_error,
                style: TextStyle(color: colors.textPrimary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(allUsersProvider),
                child: Text(l10n.common_retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserDetailBody extends StatelessWidget {
  final UserModel user;

  const _UserDetailBody({required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeaderCard(context),
          const SizedBox(height: 16),
          _buildInfoSection(
            context,
            title: l10n.admin_personalInfo,
            icon: Icons.person_outline,
            child: _buildPersonalInfo(context),
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            context,
            title: l10n.admin_userPlan,
            icon: Icons.workspace_premium_rounded,
            child: _buildPlanInfo(context),
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            context,
            title: l10n.admin_dates,
            icon: Icons.calendar_today_outlined,
            child: _buildDatesInfo(context),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage:
                user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null
                ? Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildRoleBadge(context, l10n),
                    if (user.isDriver && user.driverStatus != null)
                      _buildDriverStatusBadge(context, l10n),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    final bool isDriver = user.isDriver;
    final bool isSuperAdmin = user.isSuperAdmin;

    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    if (isSuperAdmin) {
      bgColor = Colors.amber.shade50;
      textColor = Colors.amber.shade700;
      icon = Icons.shield_outlined;
      label = l10n.admin_superAdmin;
    } else if (isDriver) {
      bgColor = Colors.blue.shade50;
      textColor = Colors.blue.shade700;
      icon = Icons.local_shipping_outlined;
      label = l10n.admin_driver;
    } else {
      bgColor = Colors.purple.shade50;
      textColor = Colors.purple.shade700;
      icon = Icons.person_outline;
      label = l10n.admin_client;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverStatusBadge(
      BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final status = user.driverStatus!;

    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    switch (status) {
      case DriverStatus.approved:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        icon = Icons.check_circle_outline;
        label = l10n.admin_statusApproved;
      case DriverStatus.pending:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        icon = Icons.access_time_rounded;
        label = l10n.admin_statusPending;
      case DriverStatus.rejected:
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        icon = Icons.cancel_outlined;
        label = l10n.admin_statusRejected;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        _buildInfoRow(
          context,
          icon: Icons.email_outlined,
          label: l10n.auth_emailLabel,
          value: user.email,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          icon: Icons.phone_outlined,
          label: l10n.auth_phoneLabel,
          value: user.phone ?? l10n.packages_notSpecified,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          icon: Icons.language_outlined,
          label: l10n.admin_userLanguage,
          value: _localeName(user.locale),
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          icon: Icons.palette_outlined,
          label: l10n.admin_userTheme,
          value: _themeName(user.themePreference),
        ),
      ],
    );
  }

  Widget _buildPlanInfo(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (!user.hasActivePlan) {
      return Text(
        l10n.admin_userNoPlan,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: context.colors.textMuted,
        ),
      );
    }

    final planKey = user.activePlanKey!;
    final planColor = AppColors.planColor(planKey);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: planColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded, size: 18, color: planColor),
          const SizedBox(width: 8),
          Text(
            _planDisplayName(planKey, l10n),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: planColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatesInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = l10n.localeName;
    final dateFormat = DateFormat.yMMMd(locale);

    return Column(
      children: [
        _buildInfoRow(
          context,
          icon: Icons.calendar_today_outlined,
          label: l10n.admin_registered,
          value: dateFormat.format(user.createdAt),
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          icon: Icons.update_outlined,
          label: l10n.admin_lastUpdate,
          value: dateFormat.format(user.updatedAt),
        ),
      ],
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colors = context.colors;

    return Row(
      children: [
        Icon(icon, size: 18, color: colors.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _localeName(String locale) {
    return switch (locale) {
      'es' => 'Español',
      'uk' => 'Українська',
      _ => locale,
    };
  }

  static String _themeName(String theme) {
    return switch (theme) {
      'dark' => 'Dark',
      'light' => 'Light',
      'system' => 'System',
      _ => theme,
    };
  }

  static String _planDisplayName(String planKey, AppLocalizations l10n) {
    return switch (planKey) {
      'basic' => l10n.plans_basic,
      'pro' => l10n.plans_pro,
      'premium' => l10n.plans_premium,
      _ => planKey,
    };
  }
}
