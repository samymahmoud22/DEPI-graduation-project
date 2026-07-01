import 'package:flutter/material.dart';

import '/../app/theme/app_colors.dart';

class ResultBox extends StatelessWidget {
  final String text;
  final double height;

  const ResultBox({
    super.key,
    required this.text,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.topLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
      ),
    );
  }
}