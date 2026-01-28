// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:athlete_ai/main.dart';
import 'package:athlete_ai/screens/splash_screen.dart';

void main() {
  testWidgets('App builds without error', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // You might need to override providers if necessary
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the app builds and shows the splash screen
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
