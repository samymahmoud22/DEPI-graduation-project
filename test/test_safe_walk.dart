import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/core/providers/safe_walk_provider.dart';
import 'package:visionmate/features/navigation_feature/presentation/controller/navigation_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('safeWalkProvider manages and persists Safe Walk setting', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Default should be true
    expect(container.read(safeWalkProvider), true);

    // Set to false
    await container.read(safeWalkProvider.notifier).setSafeWalk(false);
    expect(container.read(safeWalkProvider), false);

    // Set to true
    await container.read(safeWalkProvider.notifier).setSafeWalk(true);
    expect(container.read(safeWalkProvider), true);
  });

  test('NavigationController reads safeWalkProvider correctly', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(navigationControllerProvider);
    expect(controller.isSafeWalkEnabled, true);

    // Toggle via controller
    await controller.toggleSafeWalk();
    expect(controller.isSafeWalkEnabled, false);
    expect(container.read(safeWalkProvider), false);

    await controller.toggleSafeWalk();
    expect(controller.isSafeWalkEnabled, true);
    expect(container.read(safeWalkProvider), true);
  });
}
