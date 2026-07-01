import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';

class SplashController {
  Future<void> navigate({
    required BuildContext context,
    required bool isLoggedIn,
  }) async {
    await Future.delayed(const Duration(seconds: 3));

    if (!context.mounted) return;

    if (isLoggedIn) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.login);
    }
  }
}