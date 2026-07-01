import '/../app/router.dart';

class CommandRouterService {
  String resolveRoute(String command) {
    final text = command.toLowerCase().trim();

    // Back 
    if (text.contains('go back') ||
        text.contains('back') ||
        text.contains('return') ||
        text.contains('ارجع') ||
        text.contains('رجوع') ||
        text.contains('عودة') ||
        text.contains('الخلف') ||
        text.contains('السابق')) {
      return 'back';
    }

    // Read Text
    if (text.contains('read text') ||
        text.contains('read') ||
        text.contains('text') ||
        text.contains('ocr') ||
        text.contains('document') ||
        text.contains('اقرأ') ||
        text.contains('اقرا') ||
        text.contains('قراءة النصوص') ||
        text.contains('قارئ النصوص') ||
        text.contains('قراءة') ||
        text.contains('نص')) {
      return AppRoutes.readText;
    }

    // Scan Object
    if (text.contains('scan object') ||
        text.contains('scan') ||
        text.contains('object') ||
        text.contains('camera') ||
        text.contains('detect object') ||
        text.contains('تعرف على الأشياء') ||
        text.contains('تعرف على الاشياء') ||
        text.contains('التعرف على الأشياء') ||
        text.contains('التعرف على الاشياء') ||
        text.contains('كشف الأشياء') ||
        text.contains('كشف الاشياء') ||
        text.contains('الأشياء') ||
        text.contains('الاشياء') ||
        text.contains('تعرف') ||
        text.contains('حاجة') ||
        text.contains('شيء') ||
        text.contains('جسم')) {
      return AppRoutes.scanObject;
    }

    // Person Recognition
    if (text.contains('person') ||
        text.contains('face') ||
        text.contains('people') ||
        text.contains('recognize person') ||
        text.contains('التعرف على الأشخاص') ||
        text.contains('التعرف على الاشخاص') ||
        text.contains('التعرف على الوجوه') ||
        text.contains('الأشخاص') ||
        text.contains('الاشخاص') ||
        text.contains('شخص') ||
        text.contains('وجه') ||
        text.contains('مين')) {
      return AppRoutes.person;
    }

    // Navigation
    if (text.contains('location') ||
        text.contains('navigation') ||
        text.contains('navigate') ||
        text.contains('go to') ||
        text.contains('map') ||
        text.contains('مكان') ||
        text.contains('لوكيشن') ||
        text.contains('اروح') ||
        text.contains('روح') ||
        text.contains('التنقل والموقع') ||
        text.contains('الموقع') ||
        text.contains('خرائط') ||
        text.contains('التنقل') ||
        text.contains('جي بي اس')) {
      return AppRoutes.navigation;
    }

    // History
    if (text.contains('history') ||
        text.contains('سجل') ||
        text.contains('السجل') ||
        text.contains('التاريخ') ||
        text.contains('الهيستوري') ||
        text.contains('الهيستورى')) {
      return AppRoutes.history;
    }

    // Settings
    if (text.contains('settings') ||
        text.contains('setting') ||
        text.contains('اعدادات') ||
        text.contains('الإعدادات') ||
        text.contains('الاعدادات') ||
        text.contains('ضبط')) {
      return AppRoutes.settings;
    }

    return AppRoutes.home;
  }
}