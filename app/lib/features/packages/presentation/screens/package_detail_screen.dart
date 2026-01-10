import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/extensions/package_status_extensions.dart';
import '../../../../shared/utils/contact_launcher.dart';
import '../../../../shared/widgets/communication_button.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/status_localizations.dart';
import '../../data/models/package_model.dart';
import '../../domain/providers/package_provider.dart';

class PackageDetailScreen extends ConsumerStatefulWidget {
  final int packageId;

  const PackageDetailScreen({super.key, required this.packageId});

  @override
  ConsumerState<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends ConsumerState<PackageDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Create staggered animations for 4 cards
    _fadeAnimations = List.generate(4, (index) {
      final start = index * 0.15;
      final end = start + 0.4;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
        ),
      );
    });

    _slideAnimations = List.generate(4, (index) {
      final start = index * 0.15;
      final end = start + 0.4;
      return Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
        ),
      );
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packageAsync = ref.watch(packageDetailProvider(widget.packageId));
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.go('/packages'),
        ),
        title: Text(
          context.l10n.packages_detailTitle,
          style: TextStyle(color: colors.textPrimary),
        ),
        actions: [
          packageAsync.whenOrNull(
                data: (package) => IconButton(
                  icon: Icon(Icons.more_vert, color: colors.textPrimary),
                  onPressed: () => _showActionsBottomSheet(context, ref, package),
                ),
              ) ??
              const SizedBox.shrink(),
        ],
        elevation: 0,
      ),
      body: packageAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.l10n.packages_loadError,
                style: TextStyle(color: colors.textPrimary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(packageDetailProvider(widget.packageId)),
                child: Text(context.l10n.common_retry),
              ),
            ],
          ),
        ),
        data: (package) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header con glassmorphism
              _AnimatedCard(
                fadeAnimation: _fadeAnimations[0],
                slideAnimation: _slideAnimations[0],
                child: _HeaderCard(package: package),
              ),
              const SizedBox(height: 16),
              // 2. Ruta con timeline
              if (package.route != null) ...[
                _AnimatedCard(
                  fadeAnimation: _fadeAnimations[1],
                  slideAnimation: _slideAnimations[1],
                  child: _RouteCard(route: package.route!),
                ),
                const SizedBox(height: 16),
              ],
              // 3. Destinatario
              _AnimatedCard(
                fadeAnimation: _fadeAnimations[2],
                slideAnimation: _slideAnimations[2],
                child: _ContactCard(
                  icon: Icons.download,
                  title: context.l10n.packages_receiver,
                  name: package.receiverName,
                  phone: package.receiverPhone,
                  address: _buildFullAddress(package.receiverAddress, package.receiverCity),
                ),
              ),
              const SizedBox(height: 16),
              // 4. Remitente
              _AnimatedCard(
                fadeAnimation: _fadeAnimations[3],
                slideAnimation: _slideAnimations[3],
                child: _ContactCard(
                  icon: Icons.upload,
                  title: context.l10n.packages_sender,
                  name: package.senderName,
                  phone: package.senderPhone,
                  address: _buildFullAddress(package.senderAddress, package.senderCity),
                ),
              ),
              if (package.description != null || package.notes != null) ...[
                const SizedBox(height: 16),
                _DetailsCard(package: package),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String? _buildFullAddress(String? address, String? city) {
    if (address == null && city == null) return null;
    if (address == null) return city;
    if (city == null) return address;
    return '$address, $city';
  }
}

/// Widget wrapper para animaciones staggered
class _AnimatedCard extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Widget child;

  const _AnimatedCard({
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // FadeTransition y SlideTransition ya escuchan sus animaciones internamente
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }
}

/// Ruta con diseño de timeline vertical
class _RouteCard extends StatelessWidget {
  final RouteInfo route;

  const _RouteCard({required this.route});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.route, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.packages_route,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Timeline vertical
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline line and dots
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    // Origen dot (hueco)
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 3,
                        ),
                      ),
                    ),
                    // Línea conectora
                    Container(
                      width: 2,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                    // Destino dot (lleno)
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Información de ruta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Origen con fecha a la derecha
                    Row(
                      children: [
                        Text(
                          route.origin,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        if (route.departureDate != null) ...[
                          const Spacer(),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: colors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(route.departureDate!),
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 22),
                    // Destino
                    Text(
                      route.destination,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}

/// Header card con glassmorphism y jerarquía mejorada
class _HeaderCard extends StatelessWidget {
  final PackageModel package;

  const _HeaderCard({required this.package});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSoft,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tracking code y status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.packages_trackingCode,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      package.trackingCode,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: package.status),
            ],
          ),
          const SizedBox(height: 20),
          // Métricas en grid 2x2 con iconos
          Row(
            children: [
              Expanded(
                child: _MetricItem(
                  icon: Icons.scale_outlined,
                  label: context.l10n.packages_weight,
                  value: package.weight != null
                      ? '${package.weight} ${context.l10n.common_kg}'
                      : '-',
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricItem(
                  icon: Icons.euro_outlined,
                  label: context.l10n.packages_declaredValue,
                  value: package.declaredValue != null
                      ? '${package.declaredValue?.toStringAsFixed(0)} ${context.l10n.common_eur}'
                      : '-',
                  isPrimary: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricItem(
                  icon: Icons.straighten_outlined,
                  label: context.l10n.packages_dimensions,
                  value: _buildDimensionsString(package),
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricItem(
                  icon: Icons.inventory_2_outlined,
                  label: context.l10n.packages_quantityLabel,
                  value: package.quantity != null
                      ? '${package.quantity} ${context.l10n.common_pcs}'
                      : '-',
                  isPrimary: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _buildDimensionsString(PackageModel package) {
    if (package.lengthCm == null && package.widthCm == null && package.heightCm == null) {
      return '-';
    }
    final l = package.lengthCm ?? 0;
    final w = package.widthCm ?? 0;
    final h = package.heightCm ?? 0;
    return '$l x $w x $h';
  }
}

/// Item de métrica con icono y jerarquía visual
class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isPrimary;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            icon,
            size: 14,
            color: colors.textMuted,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isPrimary ? 16 : 14,
                  fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Status badge mejorado
class _StatusBadge extends StatelessWidget {
  final PackageStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            status.localizedName(context),
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final PackageModel package;

  const _DetailsCard({required this.package});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                context.l10n.packages_details,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          if (package.description != null) ...[
            const SizedBox(height: 16),
            Text(
              context.l10n.packages_description,
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              package.description!,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 14,
              ),
            ),
          ],
          if (package.notes != null) ...[
            const SizedBox(height: 16),
            Text(
              context.l10n.packages_notes,
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              package.notes!,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Contact card con jerarquía mejorada y botones grandes
class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String name;
  final String? phone;
  final String? address;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.name,
    this.phone,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasPhone = phone != null && phone!.isNotEmpty;
    final hasAddress = address != null && address!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Nombre - JERARQUÍA PRIMARIA
          Text(
            name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          // Ciudad y teléfono en la misma línea
          if (hasAddress || hasPhone) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                if (hasAddress)
                  Expanded(
                    child: Text(
                      address!,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (hasPhone)
                  Text(
                    phone!,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textMuted,
                    ),
                  ),
              ],
            ),
          ],
          // Botones de comunicación (igual que package_card_v2)
          if (hasPhone) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CommunicationButton(
                    bgColor: AppColors.phoneBg,
                    iconColor: AppColors.phoneText,
                    borderColor: AppColors.phoneBorder,
                    type: CommunicationButtonType.phone,
                    onTap: () => ContactLauncher.makePhoneCall(phone!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CommunicationButton(
                    bgColor: AppColors.viberBg,
                    iconColor: AppColors.viberText,
                    borderColor: AppColors.viberBorder,
                    type: CommunicationButtonType.viber,
                    onTap: () => ContactLauncher.openViber(phone!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CommunicationButton(
                    bgColor: AppColors.whatsappBg,
                    iconColor: AppColors.whatsappText,
                    borderColor: AppColors.whatsappBorder,
                    type: CommunicationButtonType.whatsApp,
                    onTap: () => ContactLauncher.openWhatsApp(phone!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CommunicationButton(
                    bgColor: AppColors.telegramBg,
                    iconColor: AppColors.telegramText,
                    borderColor: AppColors.telegramBorder,
                    type: CommunicationButtonType.telegram,
                    onTap: () => ContactLauncher.openTelegram(phone!),
                  ),
                ),
              ],
            ),
          ],
          // Botón de mapa
          if (hasAddress) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: _MapButton(
                onTap: () => ContactLauncher.openMaps(address!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Botón de mapa mejorado
class _MapButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MapButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              context.l10n.action_viewOnMap,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showActionsBottomSheet(
    BuildContext context, WidgetRef ref, PackageModel package) {
  HapticFeedback.lightImpact();
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _ActionsBottomSheet(
      package: package,
      onStatusSelected: (status) async {
        Navigator.pop(ctx);
        await ref.read(packagesProvider.notifier).updateStatus(
              package.id,
              status,
            );
        ref.invalidate(packageDetailProvider(package.id));
        ref.invalidate(packageHistoryProvider(package.id));
      },
      onEditTap: () {
        Navigator.pop(ctx);
        context.go('/packages/${package.id}/edit');
      },
    ),
  );
}

class _ActionsBottomSheet extends StatelessWidget {
  final PackageModel package;
  final Function(PackageStatus) onStatusSelected;
  final VoidCallback onEditTap;

  const _ActionsBottomSheet({
    required this.package,
    required this.onStatusSelected,
    required this.onEditTap,
  });

  List<PackageStatus> _getAvailableStatuses() {
    return PackageStatus.values
        .where((s) => s != package.status)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(color: colors.border),
            left: BorderSide(color: colors.border),
            right: BorderSide(color: colors.border),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
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
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Change status section
            Text(
              context.l10n.packages_changeStatus.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            // Status options
            ..._getAvailableStatuses()
                .map((status) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ActionOption(
                        icon: status.icon,
                        iconColor: status.color,
                        title: status.localizedName(context),
                        description: status.localizedDescription(context),
                        onTap: () => onStatusSelected(status),
                      ),
                    )),
            const SizedBox(height: 8),
            Divider(color: colors.divider),
            const SizedBox(height: 8),
            // Edit option
            _ActionOption(
              icon: Icons.edit_outlined,
              iconColor: colors.textSecondary,
              title: context.l10n.common_edit,
              onTap: onEditTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? description;
  final VoidCallback onTap;

  const _ActionOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
