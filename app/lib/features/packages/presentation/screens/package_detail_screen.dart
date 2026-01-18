import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/extensions/package_status_extensions.dart';
import '../../../../shared/utils/address_utils.dart';
import '../../../../shared/utils/contact_launcher.dart';
import '../../../../shared/widgets/communication_button_row.dart';
import '../../../../shared/widgets/map_button.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/status_localizations.dart';
import '../../data/models/package_model.dart';
import '../../domain/providers/package_provider.dart';
import '../widgets/package_image_gallery.dart';
import '../widgets/add_image_button.dart';
import '../../../../shared/utils/staggered_animations.dart';

class PackageDetailScreen extends ConsumerStatefulWidget {
  final String packageId;

  const PackageDetailScreen({super.key, required this.packageId});

  @override
  ConsumerState<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends ConsumerState<PackageDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late StaggeredAnimations _animations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Create staggered animations for 4 cards using helper
    _animations = StaggeredAnimations(
      controller: _animationController,
      itemCount: 4,
    );

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
              // 1. Tracking Status Card (Blue)
              AnimatedStaggeredItem(
                fadeAnimation: _animations.fadeAnimations[0],
                slideAnimation: _animations.slideAnimations[0],
                child: _TrackingStatusCard(package: package),
              ),
              const SizedBox(height: 16),
              // 2. Package Specs (Weight, Dimensions, etc.)
              AnimatedStaggeredItem(
                fadeAnimation: _animations.fadeAnimations[1],
                slideAnimation: _animations.slideAnimations[1],
                child: _PackageSpecsCard(package: package),
              ),
              const SizedBox(height: 16),
              // 3. Destinatario
              AnimatedStaggeredItem(
                fadeAnimation: _animations.fadeAnimations[2],
                slideAnimation: _animations.slideAnimations[2],
                child: _ContactCard(
                  icon: Icons.download,
                  title: context.l10n.packages_receiver,
                  name: package.receiverName,
                  phone: package.receiverPhone,
                  address: AddressUtils.buildFullAddress(package.receiverAddress, package.receiverCity),
                ),
              ),
              const SizedBox(height: 16),
              // 4. Remitente
              AnimatedStaggeredItem(
                fadeAnimation: _animations.fadeAnimations[3],
                slideAnimation: _animations.slideAnimations[3],
                child: _ContactCard(
                  icon: Icons.upload,
                  title: context.l10n.packages_sender,
                  name: package.senderName,
                  phone: package.senderPhone,
                  address: AddressUtils.buildFullAddress(package.senderAddress, package.senderCity),
                ),
              ),
              if (package.description != null || package.notes != null) ...[
                const SizedBox(height: 16),
                _DetailsCard(package: package),
              ],
              // 5. Sección de imágenes
              const SizedBox(height: 16),
              _ImagesSection(
                package: package,
                onImageAdded: () {
                  ref.invalidate(packageDetailProvider(widget.packageId));
                },
                onImageDeleted: () {
                  ref.invalidate(packageDetailProvider(widget.packageId));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PackageSpecsCard extends StatelessWidget {
  final PackageModel package;

  const _PackageSpecsCard({required this.package});

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
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricItem(
                  icon: Icons.scale_outlined,
                  label: context.l10n.packages_weight,
                  value: package.weight != null
                      ? '${package.weight} ${context.l10n.common_kg}'
                      : '-',
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
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: colors.divider),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MetricItem(
                  icon: Icons.straighten_outlined,
                  label: context.l10n.packages_dimensions,
                  value: _buildDimensionsString(package),
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

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
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
    );
  }
}

class _TrackingStatusCard extends StatelessWidget {
  final PackageModel package;

  const _TrackingStatusCard({required this.package});

  @override
  Widget build(BuildContext context) {
    final progress = _getProgress(package.status);
    // Use package route info or fallback to package cities
    final originCity = package.route?.origin ?? package.senderCity ?? 'Origin';
    final destinationCity = package.route?.destination ?? package.receiverCity ?? 'Destination';
    final departureDate = package.route?.departureDate != null
        ? _formatDate(package.route!.departureDate!)
        : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: ID + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID: ${package.trackingCode}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  package.status.localizedName(context),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Route Visualizer
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              return SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                  // Dotted Line (Background)
                  Row(
                    children: List.generate(
                      15,
                      (index) => Expanded(
                        child: Container(
                          height: 2,
                          color: index % 2 == 0
                              ? Colors.white.withValues(alpha: 0.3)
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  ),

                  // Progress Line (Solid)
                  Container(
                    width: width * progress,
                    height: 2,
                    color: Colors.white,
                  ),

                  // Start Dot
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      border: Border.all(color: Colors.white, width: 2),
                      shape: BoxShape.circle,
                    ),
                  ),

                  // End Dot
                  Positioned(
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        border: Border.all(color: Colors.white, width: 2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Current Position Icon (Box)
                  Positioned(
                    left: (width * progress).clamp(0, width - 36),
                    child: Container(
                      width: 36,
                      height: 36,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 20,
                        color: package.status.color,
                      ),
                    ),
                  ),
                ],
              ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Cities
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.packages_origin,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      originCity,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (departureDate.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        departureDate,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                     Text(
                      context.l10n.packages_destination,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      destinationCity,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  double _getProgress(PackageStatus status) {
    return switch (status) {
      PackageStatus.registered => 0.1,
      PackageStatus.inTransit => 0.5,
      PackageStatus.delivered => 1.0,
      PackageStatus.delayed => 0.5,
    };
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
          // Botones de comunicación
          if (hasPhone) ...[
            const SizedBox(height: 16),
            CommunicationButtonRow(phone: phone!),
          ],
          // Botón de mapa
          if (hasAddress) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: MapButton(
                onTap: () => ContactLauncher.openMaps(address!),
              ),
            ),
          ],
        ],
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

/// Sección de imágenes del paquete
class _ImagesSection extends ConsumerStatefulWidget {
  final PackageModel package;
  final VoidCallback onImageAdded;
  final VoidCallback onImageDeleted;

  const _ImagesSection({
    required this.package,
    required this.onImageAdded,
    required this.onImageDeleted,
  });

  @override
  ConsumerState<_ImagesSection> createState() => _ImagesSectionState();
}

class _ImagesSectionState extends ConsumerState<_ImagesSection> {
  bool _isUploading = false;
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasImages = widget.package.images.isNotEmpty;

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
              Icon(Icons.photo_library_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.packages_imagesSection,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (hasImages)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${widget.package.images.length}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasImages) ...[
            PackageImageGallery(
              remoteImages: widget.package.images,
              editMode: true,
              onRemoveRemote: _handleDeleteImage,
              height: 180,
            ),
            const SizedBox(height: 12),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  context.l10n.packages_noImages,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          AddImageButton(
            isLoading: _isUploading,
            onImageSelected: _handleAddImage,
          ),
        ],
      ),
    );
  }

  Future<void> _handleAddImage(Uint8List imageBytes) async {
    if (_isUploading) return;

    setState(() => _isUploading = true);

    try {
      final repository = ref.read(packageRepositoryProvider);
      await repository.addImages(widget.package.id, [imageBytes]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.packages_imageAdded),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onImageAdded();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.packages_imageError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _handleDeleteImage(String mediaId) async {
    if (_isDeleting) return;

    // Confirmar eliminación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.packages_deleteImageTitle),
        content: Text(context.l10n.packages_deleteImageConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(context.l10n.common_delete),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      final repository = ref.read(packageRepositoryProvider);
      await repository.deleteImage(widget.package.id, mediaId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.packages_imageDeleted),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onImageDeleted();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.packages_imageError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }
}
