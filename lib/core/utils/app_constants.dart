import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // Responsive Spacing
  static double topSpacing(BuildContext context) => MediaQuery.of(context).size.height * 0.02;

  // Padding
  static const double horizontalPadding = 30.0;

  // Vertical Spacing
  static const double verticalSpace8 = 4.0;
  static const double verticalSpace10 = 10.0;
  static const double verticalSpace15 = 15.0;
  static const double verticalSpace20 = 20.0;
  static const double verticalSpace30 = 30.0;
  static const double verticalSpace40 = 40.0;
  static const double verticalSpace50 = 50.0;
  static const double verticalSpace60 = 60.0;
  static const double verticalSpace100 = 80.0;
  static const double verticalSpace150 = 150.0;

  // Radiuses
  static const double cardRadius = 16.0;
}
