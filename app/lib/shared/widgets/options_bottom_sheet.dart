import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_extensions.dart';
import 'bottom_sheet_handle.dart';

/// A single option in an options bottom sheet.
class BottomSheetOption {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;
  final Color? iconColor;
  final bool enabled;
  final String? disabledReason;

  const BottomSheetOption({
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.isDestructive = false,
    this.iconColor,
    this.enabled = true,
    this.disabledReason,
  });
}

/// A section of options, optionally with a header title.
class BottomSheetSection {
  final String? title;
  final List<BottomSheetOption> options;

  const BottomSheetSection({
    this.title,
    required this.options,
  });
}

/// Shows a modal bottom sheet with grouped option sections.
///
/// Each section can have an optional uppercase header title.
/// Options support icons, subtitles, destructive styling,
/// custom icon colors, and disabled state.
Future<void> showOptionsBottomSheet(
  BuildContext context, {
  required List<BottomSheetSection> sections,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    showDragHandle: false,
    builder: (ctx) => _OptionsBottomSheetContent(
      sections: sections,
    ),
  );
}

class _OptionsBottomSheetContent extends StatelessWidget {
  final List<BottomSheetSection> sections;

  const _OptionsBottomSheetContent({required this.sections});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BottomSheetHandle(),
              const SizedBox(height: 16),
              for (var i = 0; i < sections.length; i++) ...[
                _buildSection(context, sections[i]),
                if (i < sections.length - 1) ...[
                  const SizedBox(height: 8),
                  Divider(color: colors.divider),
                  const SizedBox(height: 8),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, BottomSheetSection section) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (section.title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              section.title!.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
        for (final option in section.options)
          _buildOption(context, option),
      ],
    );
  }

  Widget _buildOption(BuildContext context, BottomSheetOption option) {
    final colors = context.colors;
    final isEnabled = option.enabled && option.onTap != null;

    // Resolve the color: explicit iconColor > destructive red > primary
    final Color resolvedColor;
    if (!isEnabled) {
      resolvedColor = colors.textMuted;
    } else if (option.iconColor != null) {
      resolvedColor = option.iconColor!;
    } else if (option.isDestructive) {
      resolvedColor = AppColors.error;
    } else {
      resolvedColor = AppColors.primary;
    }

    final subtitleText =
        (!option.enabled && option.disabledReason != null)
            ? option.disabledReason!
            : option.subtitle;

    return ListTile(
      enabled: isEnabled,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: resolvedColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(option.icon, color: resolvedColor),
      ),
      title: Text(
        option.label,
        style: TextStyle(
          color: isEnabled
              ? (option.isDestructive && option.iconColor == null
                  ? AppColors.error
                  : colors.textPrimary)
              : colors.textMuted,
        ),
      ),
      subtitle: subtitleText != null
          ? Text(
              subtitleText,
              style: TextStyle(color: colors.textMuted, fontSize: 12),
            )
          : null,
      onTap: isEnabled
          ? () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              option.onTap!();
            }
          : null,
    );
  }
}
