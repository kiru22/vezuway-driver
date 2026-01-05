import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class RouteProgress extends StatelessWidget {
  final String origin;
  final String destination;
  final String? originCountry;
  final String? destinationCountry;
  final double progress;
  final bool showTruck;
  final bool compact;

  const RouteProgress({
    super.key,
    required this.origin,
    required this.destination,
    this.originCountry,
    this.destinationCountry,
    this.progress = 0.0,
    this.showTruck = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Origin
        Expanded(
          flex: 2,
          child: _LocationInfo(
            city: origin,
            country: originCountry,
            alignment: CrossAxisAlignment.start,
            isOrigin: true,
            compact: compact,
          ),
        ),
        // Progress line with truck
        Expanded(
          flex: 3,
          child: _AnimatedProgressLine(
            progress: progress,
            showTruck: showTruck,
            compact: compact,
          ),
        ),
        // Destination
        Expanded(
          flex: 2,
          child: _LocationInfo(
            city: destination,
            country: destinationCountry,
            alignment: CrossAxisAlignment.end,
            isOrigin: false,
            compact: compact,
          ),
        ),
      ],
    );
  }
}

class _LocationInfo extends StatelessWidget {
  final String city;
  final String? country;
  final CrossAxisAlignment alignment;
  final bool isOrigin;
  final bool compact;

  const _LocationInfo({
    required this.city,
    this.country,
    required this.alignment,
    required this.isOrigin,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOrigin && alignment == CrossAxisAlignment.start) ...[
              _LocationDot(isOrigin: true, compact: compact),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                city,
                style: TextStyle(
                  fontSize: compact ? 14 : 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: alignment == CrossAxisAlignment.end
                    ? TextAlign.end
                    : TextAlign.start,
              ),
            ),
            if (!isOrigin && alignment == CrossAxisAlignment.end) ...[
              const SizedBox(width: 8),
              _LocationDot(isOrigin: false, compact: compact),
            ],
          ],
        ),
        if (country != null) ...[
          const SizedBox(height: 2),
          Text(
            country!.toUpperCase(),
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ],
    );
  }
}

class _LocationDot extends StatelessWidget {
  final bool isOrigin;
  final bool compact;

  const _LocationDot({required this.isOrigin, required this.compact});

  @override
  Widget build(BuildContext context) {
    final size = compact ? 10.0 : 12.0;
    final innerSize = compact ? 4.0 : 5.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOrigin ? AppColors.primary : AppColors.success,
        boxShadow: [
          BoxShadow(
            color: (isOrigin ? AppColors.primary : AppColors.success)
                .withValues(alpha: 0.4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: innerSize,
          height: innerSize,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _AnimatedProgressLine extends StatelessWidget {
  final double progress;
  final bool showTruck;
  final bool compact;

  const _AnimatedProgressLine({
    required this.progress,
    required this.showTruck,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final lineWidth = constraints.maxWidth;
        final truckPosition = (lineWidth - 24) * progress.clamp(0.0, 1.0);

        return SizedBox(
          height: compact ? 32 : 40,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Background line
              Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  final dotProgress = (index + 1) / 5;
                  final isActive = progress >= dotProgress;
                  return AnimatedContainer(
                    duration: AppTheme.durationNormal,
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? AppColors.primary : AppColors.border,
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                  );
                }),
              ),
              // Animated truck icon
              if (showTruck && progress > 0)
                AnimatedPositioned(
                  duration: AppTheme.durationSlow,
                  curve: Curves.easeOutCubic,
                  left: truckPosition,
                  child: _TruckIcon(compact: compact),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TruckIcon extends StatelessWidget {
  final bool compact;

  const _TruckIcon({required this.compact});

  @override
  Widget build(BuildContext context) {
    final size = compact ? 20.0 : 24.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.local_shipping_rounded,
        size: size * 0.65,
        color: Colors.white,
      ),
    );
  }
}

/// Vertical route timeline for detailed tracking
class RouteTimeline extends StatelessWidget {
  final List<RouteStop> stops;
  final int currentStopIndex;

  const RouteTimeline({
    super.key,
    required this.stops,
    this.currentStopIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(stops.length, (index) {
        final stop = stops[index];
        final isCompleted = index < currentStopIndex;
        final isCurrent = index == currentStopIndex;
        final isLast = index == stops.length - 1;

        return _TimelineItem(
          stop: stop,
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          showConnector: !isLast,
        );
      }),
    );
  }
}

class RouteStop {
  final String location;
  final String? time;
  final String? description;
  final IconData? icon;

  const RouteStop({
    required this.location,
    this.time,
    this.description,
    this.icon,
  });
}

class _TimelineItem extends StatelessWidget {
  final RouteStop stop;
  final bool isCompleted;
  final bool isCurrent;
  final bool showConnector;

  const _TimelineItem({
    required this.stop,
    required this.isCompleted,
    required this.isCurrent,
    required this.showConnector,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          SizedBox(
            width: 32,
            child: Column(
              children: [
                // Dot
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted || isCurrent
                        ? AppColors.primary
                        : AppColors.border,
                    border: isCurrent
                        ? Border.all(color: AppColors.primaryLight, width: 3)
                        : null,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 10,
                          color: Colors.white,
                        )
                      : null,
                ),
                // Connector line
                if (showConnector)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isCompleted ? AppColors.primary : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (stop.icon != null) ...[
                        Icon(
                          stop.icon,
                          size: 16,
                          color: isCurrent
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          stop.location,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isCurrent
                                ? AppColors.textPrimary
                                : isCompleted
                                    ? AppColors.textSecondary
                                    : AppColors.textMuted,
                          ),
                        ),
                      ),
                      if (stop.time != null)
                        Text(
                          stop.time!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isCurrent
                                ? AppColors.primary
                                : AppColors.textMuted,
                            fontWeight:
                                isCurrent ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                  if (stop.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      stop.description!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
