import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final String semanticsLabel;
  final bool obscureText;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.semanticsLabel,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      textField: true,
      child: TextField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Colors.black87, 
          fontSize: 20,
          fontFamily: 'Inter',
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.font20Regular.copyWith(color: Colors.black54),
          filled: true,
          fillColor: AppColors.textFieldBackground, // #FFFFFF
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          // Deep internal padding to prevent text touching borders
          contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 13),
        ),
      ),
    );
  }
}
