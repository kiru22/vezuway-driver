import 'package:flutter/material.dart';
import '../../core/theme/theme_extensions.dart';

/// Standard drag handle for bottom sheets.
/// Provides visual affordance for dragging to dismiss.
class BottomSheetHandle extends StatelessWidget {
  const BottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: colors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
