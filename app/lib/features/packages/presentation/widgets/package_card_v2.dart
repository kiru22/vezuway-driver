import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/status_localizations.dart' show PackageStatusL10n;
import '../../../../shared/extensions/package_status_extensions.dart';
import '../../../../shared/utils/contact_launcher.dart';
import '../../../../shared/widgets/communication_button_row.dart';
import '../../../../shared/widgets/map_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/package_model.dart';

/// Tarjeta de paquete compacta con borde de estado.
/// - Primer click: expande mostrando botones de comunicación
/// - Segundo click: navega al detalle fullscreen
/// - Long-press: activa modo selección
class PackageCardV2 extends StatefulWidget {
  final PackageModel package;
  final VoidCallback onTap;
  final Function(PackageStatus) onStatusChange;
  final bool isExpanded;
  final VoidCallback? onExpand;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onSelectionToggle;
  final VoidCallback? onLongPress;

  const PackageCardV2({
    super.key,
    required this.package,
    required this.onTap,
    required this.onStatusChange,
    this.isExpanded = false,
    this.onExpand,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionToggle,
    this.onLongPress,
  });

  @override
  State<PackageCardV2> createState() => _PackageCardV2State();
}

class _PackageCardV2State extends State<PackageCardV2>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  late AnimationController _checkboxController;
  late Animation<double> _checkboxAnimation;

  /// Si el paquete está en estado final, no puede seleccionarse
  bool get _isSelectable => widget.package.status != PackageStatus.delivered;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: widget.isExpanded ? 1.0 : 0.0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    );

    _checkboxController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: widget.isSelectionMode ? 1.0 : 0.0,
    );
    _checkboxAnimation = CurvedAnimation(
      parent: _checkboxController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(PackageCardV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
    if (widget.isSelectionMode != oldWidget.isSelectionMode) {
      if (widget.isSelectionMode) {
        _checkboxController.forward();
      } else {
        _checkboxController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    _checkboxController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();

    // En modo selección, el tap alterna la selección
    if (widget.isSelectionMode) {
      if (_isSelectable) {
        widget.onSelectionToggle?.call();
      }
      return;
    }

    if (!widget.isExpanded) {
      // Primer click: expandir
      widget.onExpand?.call();
    } else {
      // Segundo click: ir al detalle
      widget.onTap();
    }
  }

  void _handleLongPress() {
    if (!widget.isSelectionMode && _isSelectable) {
      HapticFeedback.mediumImpact();
      widget.onLongPress?.call();
    }
  }

  /// Obtiene la ciudad de origen (senderCity o route.origin), null si no hay
  String? get _originCity =>
      _nonEmpty(widget.package.senderCity) ??
      _nonEmpty(widget.package.route?.origin);

  /// Obtiene la ciudad de destino (receiverCity o route.destination)
  String get _destinationCity =>
      _nonEmpty(widget.package.receiverCity) ??
      _nonEmpty(widget.package.route?.destination) ??
      '—';

  bool get _hasOriginAddress => _nonEmpty(widget.package.senderAddress) != null;

  bool get _hasDestinationAddress =>
      _nonEmpty(widget.package.receiverAddress) != null;

  /// Returns the string if non-null and non-empty, otherwise null.
  static String? _nonEmpty(String? value) =>
      (value != null && value.isNotEmpty) ? value : null;

  /// Icono de origen: punto sólido si tiene dirección, outline si solo ciudad
  Widget _buildOriginIcon() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: _hasOriginAddress ? AppColors.primary : Colors.transparent,
        shape: BoxShape.circle,
        border: _hasOriginAddress
            ? null
            : Border.all(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  /// Border color based on selection/expansion state
  Color _resolveBorderColor(AppColorsExtension colors) {
    if (widget.isSelected) {
      return AppColors.primary.withValues(alpha: 0.6);
    }
    if (widget.isExpanded) {
      return AppColors.primary.withValues(alpha: 0.4);
    }
    return colors.border;
  }

  /// Icono de destino: pin sólido si tiene dirección, outline si solo ciudad
  Widget _buildDestinationIcon() {
    return Icon(
      _hasDestinationAddress
          ? Icons.location_on
          : Icons.location_on_outlined,
      size: 14,
      color: AppColors.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasPhone = widget.package.receiverPhone != null &&
        widget.package.receiverPhone!.isNotEmpty;
    final hasAddress = widget.package.receiverAddress != null &&
        widget.package.receiverAddress!.isNotEmpty;

    final isHighlighted = widget.isExpanded || widget.isSelected;

    return GestureDetector(
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: _resolveBorderColor(colors),
            width: isHighlighted ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isHighlighted
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : colors.shadow.withValues(alpha: 0.15),
              blurRadius: isHighlighted ? 16 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd - 1),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizeTransition(
                  sizeFactor: _checkboxAnimation,
                  axis: Axis.horizontal,
                  child: _SelectionCheckbox(
                    isSelected: widget.isSelected,
                    isEnabled: _isSelectable,
                    onTap: widget.onSelectionToggle,
                  ),
                ),
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: widget.package.status.color,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: RichText(
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        fontFamily: 'monospace',
                                        letterSpacing: 0.3,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '#',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        TextSpan(
                                          text: widget.package.trackingCode,
                                          style: TextStyle(
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                StatusBadge(
                                  status: widget.package.status,
                                  size: StatusBadgeSize.compact,
                                ),
                              ],
                            ),
                            if (widget.package.receiverName.isNotEmpty)
                              Text(
                                widget.package.receiverName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      if (_originCity != null) ...[
                                        _buildOriginIcon(),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            _originCity!,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: colors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          child: Text(
                                            '→',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: colors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                      _buildDestinationIcon(),
                                      const SizedBox(width: 2),
                                      Flexible(
                                        child: Text(
                                          _destinationCity,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: colors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _buildMetricsString(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colors.textSecondary
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                                if (widget.package.declaredValue != null &&
                                    widget.package.declaredValue! > 0) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '${widget.package.declaredValue!.toInt()}€',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizeTransition(
                        sizeFactor: _expandAnimation,
                        child: Column(
                          children: [
                            Container(
                              height: 1,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              color: colors.border.withValues(alpha: 0.3),
                            ),
                            if (hasPhone)
                              CommunicationButtonRow(
                                phone: widget.package.receiverPhone!,
                                padding:
                                    const EdgeInsets.fromLTRB(12, 10, 12, 8),
                              ),

                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                              child: Row(
                                children: [
                                  if (hasAddress)
                                    Expanded(
                                      child: MapButton(
                                        style: MapButtonStyle.outlined,
                                        onTap: () => ContactLauncher.openMaps(
                                            widget.package.receiverAddress!),
                                      ),
                                    ),
                                  if (hasAddress &&
                                      widget.package.status !=
                                          PackageStatus.delivered)
                                    const SizedBox(width: 8),
                                  if (widget.package.status !=
                                      PackageStatus.delivered)
                                    Expanded(
                                      child: _ChangeStatusButton(
                                        currentStatus: widget.package.status,
                                        onTap: () {
                                          final nextStatus =
                                              widget.package.status.nextStatus;
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el string de métricas: "10kg • 1шт"
  String _buildMetricsString() {
    final parts = <String>[];

    if (widget.package.weight != null && widget.package.weight! > 0) {
      parts.add('${widget.package.weight!.toInt()}kg');
    }
    if (widget.package.quantity != null && widget.package.quantity! > 0) {
      parts.add('${widget.package.quantity}${context.l10n.common_pcs}');
    }

    return parts.join(' • ');
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
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
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

/// Checkbox para selección de paquetes en modo bulk.
class _SelectionCheckbox extends StatelessWidget {
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _SelectionCheckbox({
    required this.isSelected,
    required this.isEnabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final resolved = _resolveColors(colors);

    return GestureDetector(
      onTap: isEnabled
          ? () {
              HapticFeedback.lightImpact();
              onTap?.call();
            }
          : null,
      child: Container(
        width: 44,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: resolved.background,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: resolved.border,
              width: 2,
            ),
          ),
          child: isSelected
              ? const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                )
              : null,
        ),
      ),
    );
  }

  ({Color background, Color border}) _resolveColors(AppColorsExtension colors) {
    if (isSelected) {
      return (background: AppColors.primary, border: AppColors.primary);
    }
    if (isEnabled) {
      return (background: Colors.transparent, border: colors.border);
    }
    return (
      background: colors.border.withValues(alpha: 0.3),
      border: colors.border.withValues(alpha: 0.5),
    );
  }
}
