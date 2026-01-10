import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/status_localizations.dart';
import '../../../../shared/extensions/package_status_extensions.dart';
import '../../../../shared/utils/address_utils.dart';
import '../../../../shared/utils/contact_launcher.dart';
import '../../../../shared/widgets/communication_button_row.dart';
import '../../../../shared/widgets/map_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/package_model.dart';

/// Tarjeta de paquete con comportamiento de doble click.
/// - Primer click: expande mostrando botones de comunicación
/// - Segundo click: navega al detalle fullscreen
class PackageCardV2 extends StatefulWidget {
  final PackageModel package;
  final VoidCallback onTap;
  final Function(PackageStatus) onStatusChange;

  const PackageCardV2({
    super.key,
    required this.package,
    required this.onTap,
    required this.onStatusChange,
  });

  @override
  State<PackageCardV2> createState() => _PackageCardV2State();
}

class _PackageCardV2State extends State<PackageCardV2>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    if (!_isExpanded) {
      // Primer click: expandir
      setState(() => _isExpanded = true);
      _animationController.forward();
    } else {
      // Segundo click: ir al detalle
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final hasPhone =
        widget.package.receiverPhone != null && widget.package.receiverPhone!.isNotEmpty;
    final hasAddress =
        widget.package.receiverAddress != null && widget.package.receiverAddress!.isNotEmpty;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? colors.cardBackground : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: _isExpanded
                ? AppColors.primary.withValues(alpha: 0.4)
                : colors.border.withValues(alpha: 0.5),
            width: _isExpanded ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isExpanded
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: _isExpanded ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Tracking + Name + Badge
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${widget.package.trackingCode}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: colors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.package.receiverName,
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(
                    status: widget.package.status,
                    size: StatusBadgeSize.compact,
                  ),
                ],
              ),
            ),

            // Location + Metrics row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  // Location
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            AddressUtils.extractCity(widget.package.receiverAddress),
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Metrics: weight, quantity, price
                  _MetricsRow(
                    weight: widget.package.weight,
                    quantity: widget.package.quantity,
                    price: widget.package.declaredValue,
                    textColor: colors.textSecondary,
                  ),
                ],
              ),
            ),

            // Expandable section
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Column(
                children: [
                  // Communication buttons (orden: Llamar, Viber, WhatsApp, Telegram)
                  if (hasPhone)
                    CommunicationButtonRow(
                      phone: widget.package.receiverPhone!,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    ),

                  // Action buttons row: Open map + Change status
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        // Open map button (izquierda)
                        if (hasAddress)
                          Expanded(
                            child: MapButton(
                              style: MapButtonStyle.outlined,
                              onTap: () => ContactLauncher.openMaps(widget.package.receiverAddress!),
                            ),
                          ),
                        if (hasAddress &&
                            widget.package.status != PackageStatus.delivered)
                          const SizedBox(width: 8),
                        // Change status button (derecha)
                        if (widget.package.status != PackageStatus.delivered)
                          Expanded(
                            child: _ChangeStatusButton(
                              currentStatus: widget.package.status,
                              onTap: () {
                                final nextStatus = widget.package.status.nextStatus;
                                if (nextStatus != null) {
                                  widget.onStatusChange(nextStatus);
                                }
                              },
                            ),
                          ),
                      ],
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
}

class _MetricsRow extends StatelessWidget {
  final double? weight;
  final int? quantity;
  final double? price;
  final Color textColor;

  const _MetricsRow({
    this.weight,
    this.quantity,
    this.price,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final parts = <TextSpan>[];

    if (weight != null && weight! > 0) {
      parts.add(TextSpan(text: '${weight!.toInt()}'));
      parts.add(TextSpan(
        text: 'kg',
        style: TextStyle(color: textColor.withValues(alpha: 0.7)),
      ));
    }
    if (quantity != null && quantity! > 0) {
      if (parts.isNotEmpty) {
        parts.add(TextSpan(
          text: ' • ',
          style: TextStyle(color: textColor.withValues(alpha: 0.5)),
        ));
      }
      parts.add(TextSpan(text: '$quantity'));
      parts.add(TextSpan(
        text: context.l10n.common_pcs,
        style: TextStyle(color: textColor.withValues(alpha: 0.7)),
      ));
    }
    if (price != null && price! > 0) {
      if (parts.isNotEmpty) {
        parts.add(TextSpan(
          text: ' • ',
          style: TextStyle(color: textColor.withValues(alpha: 0.5)),
        ));
      }
      parts.add(TextSpan(
        text: '${price!.toInt()}',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ));
      parts.add(const TextSpan(text: '€'));
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        children: parts,
      ),
    );
  }
}

class _ChangeStatusButton extends StatelessWidget {
  final PackageStatus currentStatus;
  final VoidCallback onTap;

  const _ChangeStatusButton({
    required this.currentStatus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nextStatus = currentStatus.nextStatus;
    if (nextStatus == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                nextStatus.localizedName(context),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

