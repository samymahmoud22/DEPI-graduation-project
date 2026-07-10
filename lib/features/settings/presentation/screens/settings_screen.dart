import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/providers/safe_walk_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(logoutUseCaseProvider)();

    ref.invalidate(currentUserProfileProvider);

    if (!context.mounted) return;

    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go(AppRoutes.home),
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                  ),
                  Expanded(
                    child: Text(
                      t.get('settings'),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.screenTitle,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 36),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.get('language'),
                    style: AppTextStyles.headlineMedium,
                  ),
                  DropdownButton<String>(
                    value: locale.languageCode,
                    dropdownColor: AppColors.card,
                    style: const TextStyle(color: AppColors.white, fontSize: 16),
                    iconEnabledColor: AppColors.white,
                    underline: Container(),
                    items: const [
                      DropdownMenuItem(
                        value: 'en',
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: 'ar',
                        child: Text('العربية'),
                      ),
                    ],
                    onChanged: (lang) {
                      if (lang != null) {
                        ref.read(localeProvider.notifier).setLocale(Locale(lang));
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.get('safe_walk'),
                          style: AppTextStyles.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.get('safe_walk_desc'),
                          style: const TextStyle(color: AppColors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: ref.watch(safeWalkProvider),
                    activeColor: AppColors.green,
                    activeTrackColor: AppColors.green.withOpacity(0.4),
                    onChanged: (val) {
                      ref.read(safeWalkProvider.notifier).setSafeWalk(val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 34),

              Text(
                t.get('account'),
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 8),

              _SettingsTile(
                icon: Icons.person_outline,
                title: t.get('profile'),
                onTap: () => context.push(AppRoutes.profile),
              ),
              const SizedBox(height: 14),

              _SettingsTile(
                icon: Icons.logout,
                title: t.get('logout'),
                onTap: () => _logout(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.white, size: 22),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}