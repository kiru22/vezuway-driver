import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';

class DriverInfoCard extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final String? vehicle;
  final double? rating;
  final int? deliveryCount;
  final bool showVerified;
  final bool compact;
  final VoidCallback? onTap;
  final VoidCallback? onCallTap;

  const DriverInfoCard({
    super.key,
    required this.name,
    this.avatarUrl,
    this.vehicle,
    this.rating,
    this.deliveryCount,
    this.showVerified = true,
    this.compact = false,
    this.onTap,
    this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          // Avatar with verification badge
          _DriverAvatar(
            avatarUrl: avatarUrl,
            name: name,
            showVerified: showVerified,
            size: compact ? 40 : 48,
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: compact ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (vehicle != null)
                  Row(
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 12,
                        color: colors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          vehicle!,
                          style: TextStyle(
                            fontSize: compact ? 12 : 13,
                            color: colors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Rating & Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (rating != null)
                _RatingBadge(rating: rating!, compact: compact),
              if (deliveryCount != null) ...[
                const SizedBox(height: 4),
                Text(
                  '$deliveryCount envios',
                  style: TextStyle(
                    fontSize: compact ? 10 : 11,
                    color: colors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          if (onCallTap != null) ...[
            const SizedBox(width: 12),
            _CallButton(onTap: onCallTap!, compact: compact),
          ],
        ],
      ),
    );
  }
}

class _DriverAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final bool showVerified;
  final double size;

  const _DriverAvatar({
    this.avatarUrl,
    required this.name,
    this.showVerified = true,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Stack(
      children: [
        // Glow effect
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        // Avatar container with border
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.borderAccent,
                colors.border,
              ],
            ),
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surfaceLight,
            ),
            child: ClipOval(
              child: avatarUrl != null
                  ? Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _AvatarPlaceholder(
                        name: name,
                        size: size - 4,
                      ),
                    )
                  : _AvatarPlaceholder(name: name, size: size - 4),
            ),
          ),
        ),
        // Verified badge
        if (showVerified)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.36,
              height: size * 0.36,
              decoration: BoxDecoration(
                color: AppColors.verified,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.surface,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.verified.withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.check,
                size: size * 0.22,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  final String name;
  final double size;

  const _AvatarPlaceholder({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.3),
            AppColors.primaryDark.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  final bool compact;

  const _RatingBadge({required this.rating, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: compact ? 14 : 16,
            color: AppColors.ratingStar,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool compact;

  const _CallButton({required this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final size = compact ? 36.0 : 42.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.phone_rounded,
          size: compact ? 18 : 20,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Large driver profile card for detail views
class DriverProfileCard extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final String? vehicle;
  final double? rating;
  final int? deliveryCount;
  final String? subtitle;
  final VoidCallback? onCallTap;
  final VoidCallback? onMessageTap;

  const DriverProfileCard({
    super.key,
    required this.name,
    this.avatarUrl,
    this.vehicle,
    this.rating,
    this.deliveryCount,
    this.subtitle,
    this.onCallTap,
    this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          // Large avatar
          _DriverAvatar(
            avatarUrl: avatarUrl,
            name: name,
            showVerified: true,
            size: 80,
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: colors.textMuted,
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (rating != null) ...[
                _StatItem(
                  icon: Icons.star_rounded,
                  iconColor: AppColors.ratingStar,
                  value: rating!.toStringAsFixed(1),
                  label: 'Rating',
                ),
                const SizedBox(width: 32),
              ],
              if (deliveryCount != null)
                _StatItem(
                  icon: Icons.local_shipping_outlined,
                  iconColor: AppColors.primary,
                  value: '$deliveryCount',
                  label: 'Envios',
                ),
            ],
          ),
          if (onCallTap != null || onMessageTap != null) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                if (onCallTap != null)
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.phone_rounded,
                      label: 'Llamar',
                      onTap: onCallTap!,
                      isPrimary: true,
                    ),
                  ),
                if (onCallTap != null && onMessageTap != null)
                  const SizedBox(width: 12),
                if (onMessageTap != null)
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Mensaje',
                      onTap: onMessageTap!,
                      isPrimary: false,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isPrimary ? AppColors.primaryGradient : null,
          color: isPrimary ? null : colors.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: isPrimary ? null : Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary ? Colors.white : colors.textPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
