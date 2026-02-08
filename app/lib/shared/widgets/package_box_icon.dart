import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';

class PackageBoxIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final bool filled;

  const PackageBoxIcon({
    super.key,
    this.size = 24,
    this.color,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? IconTheme.of(context).color ?? Colors.white;
    final asset = filled
        ? 'assets/icons/package_box_filled.svg'
        : 'assets/icons/package_box.svg';
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: filled
            ? Stack(
                children: [
                  SvgPicture.asset(
                    asset,
                    colorFilter:
                        ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
                  SvgPicture.asset(
                    'assets/icons/package_box_tape.svg',
                    colorFilter: ColorFilter.mode(
                        AppColors.primary, BlendMode.srcIn),
                  ),
                ],
              )
            : SvgPicture.asset(
                asset,
                colorFilter:
                    ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
      ),
    );
  }
}
