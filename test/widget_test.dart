import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visionmate/features/home/presentation/widgets/home_action_card.dart';

void main() {
  testWidgets('HomeActionCard renders title and icon successfully', (WidgetTester tester) async {
    bool tapped = false;

    // Build the widget.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeActionCard(
            title: 'Test Card',
            icon: Icons.camera_alt,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    // Verify title is rendered.
    expect(find.text('Test Card'), findsOneWidget);

    // Verify icon is rendered.
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);

    // Tap the card and verify action.
    await tester.tap(find.byType(HomeActionCard));
    expect(tapped, true);
  });
}
