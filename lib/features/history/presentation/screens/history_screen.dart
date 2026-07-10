import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/localization/app_translations.dart';
import '../controller/history_controller.dart';
import '../../domain/entities/history_item_entity.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _selectedTab = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyControllerProvider).loadHistory();
    });
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'text':
        return Icons.article_outlined;
      case 'person':
        return Icons.person_outline;
      case 'object':
        return Icons.camera_alt_outlined;
      case 'navigation':
        return Icons.location_on_outlined;
      default:
        return Icons.history;
    }
  }

  String _getTypeLabel(String type, AppTranslations t) {
    switch (type) {
      case 'text':
        return t.get('text_history');
      case 'person':
        return t.get('person_history');
      case 'object':
        return t.get('object_history');
      case 'navigation':
        return t.get('search_history');
      default:
        return '';
    }
  }

  Future<void> _speakItem(HistoryItemEntity item, AppTranslations t) async {
    final tts = ref.read(ttsServiceProvider);
    final typeLabel = _getTypeLabel(item.type, t);
    final speechText = '$typeLabel. ${item.title}. ${item.description}';
    await tts.speak(speechText);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(historyControllerProvider);
    final t = ref.watch(translationsProvider);

    // Filter items based on selected tab
    final filteredItems = controller.items.where((item) {
      if (_selectedTab == 'all') return true;
      return item.type == _selectedTab;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                  ),
                  Expanded(
                    child: Text(
                      t.get('history_title'),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.screenTitle,
                    ),
                  ),
                  if (controller.items.isNotEmpty)
                    TextButton(
                      onPressed: () => _showClearConfirmation(context, controller, t),
                      child: Text(
                        t.get('clear_all'),
                        style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),

              // Filter Tabs Scroll
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _tabButton('all', t.get('all')),
                    const SizedBox(width: 8),
                    _tabButton('text', t.get('text_history')),
                    const SizedBox(width: 8),
                    _tabButton('person', t.get('person_history')),
                    const SizedBox(width: 8),
                    _tabButton('object', t.get('object_history')),
                    const SizedBox(width: 8),
                    _tabButton('navigation', t.get('search_history')),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // List of items
              Expanded(
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryButton))
                    : filteredItems.isEmpty
                        ? Center(
                            child: Text(
                              t.get('no_history'),
                              style: const TextStyle(color: AppColors.white70, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredItems.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              final timeStr = DateFormat('yyyy-MM-dd kk:mm').format(item.timestamp);

                              return Card(
                                color: AppColors.card,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: InkWell(
                                  onTap: () => _speakItem(item, t),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: AppColors.primaryButton.withValues(alpha: 0.2),
                                          child: Icon(_getTypeIcon(item.type), color: AppColors.white),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.title,
                                                style: const TextStyle(
                                                  color: AppColors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                item.description,
                                                style: const TextStyle(
                                                  color: AppColors.white70,
                                                  fontSize: 13,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                timeStr,
                                                style: const TextStyle(
                                                  color: Colors.white38,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: AppColors.red),
                                          onPressed: () async {
                                            await controller.deleteItem(item.id);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(t.get('deleted')),
                                                  duration: const Duration(seconds: 1),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabButton(String tabKey, String label) {
    final isSelected = _selectedTab == tabKey;
    return Material(
      color: isSelected ? AppColors.primaryButton : AppColors.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = tabKey;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, HistoryController controller, AppTranslations t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(t.get('clear_all'), style: const TextStyle(color: AppColors.white)),
        content: Text(
          '${t.get('clear_all')}؟',
          style: const TextStyle(color: AppColors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.white70)),
          ),
          TextButton(
            onPressed: () {
              controller.clearAll();
              Navigator.pop(context);
            },
            child: Text(t.get('clear_all'), style: const TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}