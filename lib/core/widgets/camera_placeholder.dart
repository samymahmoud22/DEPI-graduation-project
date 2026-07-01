import 'package:flutter/material.dart';

import '/../app/theme/app_colors.dart';

class CameraPlaceholder extends StatelessWidget {
  final double height;
  final IconData icon;

  const CameraPlaceholder({
    super.key,
    this.height = 250,
    this.icon = Icons.camera_alt_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }
}