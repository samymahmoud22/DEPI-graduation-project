import 'package:flutter/material.dart';

import '../../../../app/theme/app_text_styles.dart';

class AuthHeader extends StatelessWidget {
  final String title;

  const AuthHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: AppTextStyles.screenTitle,
    );
  }
}