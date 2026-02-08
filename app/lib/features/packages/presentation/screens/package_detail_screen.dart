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
import '../../../../shared/widgets/options_bottom_sheet.dart';
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
  ConsumerState<PackageDetailScreen> createState() =>
      _PackageDetailScreenState();
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

  Future<void> _handleStatusChange(PackageModel package) async {
    final nextStatus = package.status.nextStatus;
    if (nextStatus == null) return;

    HapticFeedback.lightImpact();
    await ref
        .read(packagesProvider.notifier)
        .updateStatus(package.id, nextStatus);
    ref.invalidate(packageDetailProvider(package.id));
    ref.invalidate(packageHistoryProvider(package.id));
  }

  @override
  Widget build(BuildContext context) {
    final packageAsync = ref.watch(packageDetailProvider(widget.packageId));
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      bottomNavigationBar: packageAsync.whenOrNull(
        data: (package) => _BottomActionBar(
          package: package,
          onEdit: () => context.go('/packages/${package.id}/edit'),
          onStatusChange: () => _handleStatusChange(package),
        ),
      ),
      appBar: AppBar(
        backgroundColor: colors.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/packages');
            }
          },
        ),
        title: Text(
          context.l10n.packages_detailTitle,
          style: TextStyle(color: colors.textPrimary),
        ),
        actions: [
          packageAsync.whenOrNull(
                data: (package) => IconButton(
                  icon: Icon(Icons.more_vert, color: colors.textPrimary),
                  onPressed: () =>
                      _showActionsBottomSheet(context, ref, package),
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
                onPressed: () =>
                    ref.invalidate(packageDetailProvider(widget.packageId)),
                child: Text(context.l10n.common_retry),
              ),
            ],
          ),
        ),
        data: (package) => SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedStaggeredItem(
                fadeAnimation: _animations.fadeAnimations[0],
                slideAnimation: _animations.slideAnimations[0],
                child: _TrackingStatusCard(package: package),
              ),
              const SizedBox(height: 12),
              AnimatedStaggeredItem(
                fadeAnimation: _animations.fadeAnimations[1],
                slideAnimation: _animations.slideAnimations[1],
                child: _PackageSpecsCard(package: package),
              ),
              if (package.description != null || package.notes != null) ...[
                const SizedBox(height: 12),
                _DetailsCard(package: package),
              ],
              const SizedBox(height: 12),
              AnimatedStaggeredItem(
                fadeAnimation: _animations.fadeAnimations[2],
                slideAnimation: _animations.slideAnimations[2],
                child: _ContactCard(
                  icon: Icons.download,
                  title: context.l10n.packages_receiver,
                  name: package.receiverName,
                  phone: package.receiverPhone,
                  address: AddressUtils.buildFullAddress(
                      package.receiverAddress, package.receiverCity),
                ),
              ),
              const SizedBox(height: 12),
              AnimatedStaggeredItem(
                fadeAnimation: _animations.fadeAnimations[3],
                slideAnimation: _animations.slideAnimations[3],
                child: _ContactCard(
                  icon: Icons.upload,
                  title: context.l10n.packages_sender,
                  name: package.senderName,
                  phone: package.senderPhone,
                  address: AddressUtils.buildFullAddress(
                      package.senderAddress, package.senderCity),
                ),
              ),
              const SizedBox(height: 12),
              _ImagesSection(
                package: package,
                onChanged: () =>
                    ref.invalidate(packageDetailProvider(widget.packageId)),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: context.adaptiveShadow,
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
              const SizedBox(width: 8),
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
          const SizedBox(height: 8),
          Container(height: 1, color: colors.divider),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MetricItem(
                  icon: Icons.straighten_outlined,
                  label: context.l10n.packages_dimensions,
                  value: _buildDimensionsString(package),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricItem(
                  icon: Icons.widgets_outlined,
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
    if (package.lengthCm == null &&
        package.widthCm == null &&
        package.heightCm == null) {
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 22,
            color: AppColors.primary,
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
                  fontSize: 15,
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

class _TrackingStatusCard extends StatefulWidget {
  final PackageModel package;

  const _TrackingStatusCard({required this.package});

  @override
  State<_TrackingStatusCard> createState() => _TrackingStatusCardState();
}

class _TrackingStatusCardState extends State<_TrackingStatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _rotationAnimation;

  // Ángulo de rotación en radianes (~15 grados)
  static const double _tiltAngle = 0.26;

  // Posición actual del coche (valor final de la última animación)
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1700),
      vsync: this,
    );

    final targetProgress = _getProgress(widget.package.status);
    _setupAnimations(fromProgress: 0.0, toProgress: targetProgress);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _TrackingStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.package.status != widget.package.status) {
      _currentProgress = _getProgress(oldWidget.package.status);
      final targetProgress = _getProgress(widget.package.status);

      _setupAnimations(
          fromProgress: _currentProgress, toProgress: targetProgress);
      _controller.reset();
      _controller.forward();
    }
  }

  void _setupAnimations(
      {required double fromProgress, required double toProgress}) {
    _positionAnimation = Tween<double>(
      begin: fromProgress,
      end: toProgress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.76, curve: Curves.easeIn),
    ));

    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -_tiltAngle)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -_tiltAngle, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 9,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: _tiltAngle)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: _tiltAngle, end: 0.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 4,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _getProgress(PackageStatus status) {
    return switch (status) {
      PackageStatus.registered => 0.1,
      PackageStatus.inTransit => 0.5,
      PackageStatus.delivered => 1.0,
      PackageStatus.delayed => 0.5,
    };
  }

  String _formatCreatedDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final time = DateFormat('HH:mm').format(date);

    if (dateOnly == today) {
      return '${context.l10n.common_today}, $time';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return '${context.l10n.common_yesterday}, $time';
    } else {
      return '${DateFormat('dd.MM.yyyy').format(date)}, $time';
    }
  }

  void _copyTrackingCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.package.trackingCode));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.packages_codeCopied),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final originCity =
        widget.package.route?.origin ?? widget.package.senderCity ?? 'Origin';
    final destinationCity = widget.package.route?.destination ??
        widget.package.receiverCity ??
        'Destination';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: context.adaptiveShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.package.status.localizedName(context),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatCreatedDate(context, widget.package.createdAt),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _copyTrackingCode(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.copy_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '#${widget.package.trackingCode}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              return SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
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
                    AnimatedBuilder(
                      animation: _positionAnimation,
                      builder: (context, child) {
                        return Container(
                          width: width * _positionAnimation.value,
                          height: 2,
                          color: Colors.white,
                        );
                      },
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        border: Border.all(color: Colors.white, width: 2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          border: Border.all(color: Colors.white, width: 2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: Listenable.merge(
                          [_positionAnimation, _rotationAnimation]),
                      builder: (context, child) {
                        return Positioned(
                          left: (width * _positionAnimation.value)
                              .clamp(0, width - 32),
                          child: Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        padding: const EdgeInsets.all(6),
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
                          Icons.local_shipping,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
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
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      originCity,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      destinationCity,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
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
        boxShadow: context.adaptiveShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined,
                  size: 20, color: AppColors.primary),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: context.adaptiveShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 12),
          Text(
            name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
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
          if (hasPhone) ...[
            const SizedBox(height: 12),
            CommunicationButtonRow(phone: phone!),
          ],
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

  final availableStatuses =
      PackageStatus.values.where((s) => s != package.status).toList();

  showOptionsBottomSheet(context, sections: [
    BottomSheetSection(
      title: context.l10n.packages_changeStatus,
      options: availableStatuses
          .map((status) => BottomSheetOption(
                icon: status.icon,
                label: status.localizedName(context),
                subtitle: status.localizedDescription(context),
                iconColor: status.color,
                onTap: () async {
                  await ref.read(packagesProvider.notifier).updateStatus(
                        package.id,
                        status,
                      );
                  ref.invalidate(packageDetailProvider(package.id));
                  ref.invalidate(packageHistoryProvider(package.id));
                },
              ))
          .toList(),
    ),
    BottomSheetSection(options: [
      BottomSheetOption(
        icon: Icons.edit_outlined,
        label: context.l10n.common_edit,
        onTap: () => context.go('/packages/${package.id}/edit'),
      ),
    ]),
  ]);
}

/// Sección de imágenes del paquete
class _ImagesSection extends ConsumerStatefulWidget {
  final PackageModel package;
  final VoidCallback onChanged;

  const _ImagesSection({
    required this.package,
    required this.onChanged,
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
        boxShadow: context.adaptiveShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.photo_library_outlined,
                  size: 20, color: AppColors.primary),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        widget.onChanged();
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
        widget.onChanged();
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

/// Barra inferior con botones de Editar y Cambiar estado
class _BottomActionBar extends StatelessWidget {
  final PackageModel package;
  final VoidCallback onEdit;
  final VoidCallback onStatusChange;

  const _BottomActionBar({
    required this.package,
    required this.onEdit,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final nextStatus = package.status.nextStatus;

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        border: Border(
          top: BorderSide(color: colors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onEdit();
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.common_edit,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (nextStatus != null) ...[
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onStatusChange();
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        nextStatus.localizedName(context),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
