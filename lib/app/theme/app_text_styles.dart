import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._(); // Private constructor to prevent instantiation

  static const TextStyle font40Bold = TextStyle(
    fontFamily: 'Inter',
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static const TextStyle font36Medium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 36,
    fontWeight: FontWeight.w500,
    color: AppColors.textColor,
  );

  static const TextStyle font20Regular = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
  );
}
