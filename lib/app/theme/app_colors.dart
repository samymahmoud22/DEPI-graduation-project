import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // --- Backgrounds ---
  // Main deep blue background
  static const Color background = Color(0xFF0F2C55);
  
  // White background for input fields
  static const Color textFieldBackground = Color(0xFFFFFFFF);

  // --- Typography ---
  // White for labels and titles
  static const Color textColor = Color(0xFFFFFFFF);
  
  // The bright blue for 'Sign Up' and 'Login' links
  static const Color linkColor = Color(0xFF4A90E2);
  
  // A muted grey-blue for the 'Forgot Password?' text
  static const Color forgotPasswordColor = Color(0xFF94A3B8);

  // --- Buttons ---
  // Bright blue for main buttons
  static const Color primaryButton = Color(0xFF4A90E2);
  
  // Muted blue for History and Settings buttons
  static const Color secondaryButton = Color(0xFF284C78);

  // --- Actions ---
  // Red for Stop button
  static const Color stopAction = Color(0xFFE23131);
  
  // Light green for Repeat button
  static const Color repeatAction = Color(0xFF7ADA70);

  // --- Home Screen ---
  // The secondary color for home elements (cards, nav bar)
  static const Color homeSecondaryColor = Color(0xFF284C78);
  
  // The lighter blue circle behind the mic
  static const Color micCircleColor = Color(0xFF3B82F6);
}
