import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/locale_provider.dart';

class GreetingSection extends ConsumerWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileState = ref.watch(currentUserProfileProvider);
    final t = ref.watch(translationsProvider);

    return userProfileState.when(
      data: (user) {
        final name = user?.name.trim().isNotEmpty == true ? user!.name : 'User';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name == 'User' ? t.get('hello_user') : t.get('hello', [name]),
              style: AppTextStyles.headlineLarge,
            ),
            const SizedBox(height: 4),
            Text(
              t.get('what_to_do'),
              style: AppTextStyles.bodyMedium,
            ),
          ],
        );
      },
      loading: () {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.get('hello_user'),
              style: AppTextStyles.headlineLarge,
            ),
            const SizedBox(height: 4),
            Text(
              t.get('loading_profile'),
              style: AppTextStyles.bodyMedium,
            ),
          ],
        );
      },
      error: (_, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.get('hello_user'),
              style: AppTextStyles.headlineLarge,
            ),
            const SizedBox(height: 4),
            Text(
              t.get('what_to_do'),
              style: AppTextStyles.bodyMedium,
            ),
          ],
        );
      },
    );
  }
}