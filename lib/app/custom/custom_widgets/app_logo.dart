import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final double borderRadius;

  const AppLogo({super.key, this.size = 100, this.color, this.borderRadius = 20});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          AppConstants.appLogoPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          color: color,
          colorBlendMode: color != null ? BlendMode.srcIn : null,
        ),
      ),
    );
  }
}
