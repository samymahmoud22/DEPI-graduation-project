import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme/app_theme.dart';
import '/core/widgets/volume_trigger_wrapper.dart';
import '/core/localization/locale_provider.dart';

class VisionMateApp extends ConsumerWidget {
  const VisionMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Vision Mate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: locale,
      routerConfig: appRouter,
      builder: (context, child) {
        final isArabic = locale.languageCode == 'ar';
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: VolumeTriggerWrapper(child: child!),
        );
      },
    );
  }
}