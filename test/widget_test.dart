import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/screens/onboardscreen.dart';
import 'package:expense_tracker/screens/mainscreen.dart';

void main() {
  // Mocking SharedPreferences to test different scenarios
  setUp(() async {
    // Clear any existing preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  testWidgets('Navigates to OnboardingScreen if not logged in', (WidgetTester tester) async {
    // Simulate that the user is not logged in
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', false);

    // Build our app and trigger a frame
    await tester.pumpWidget(const MyApp(loggedIn: false));

    // Verify that the OnboardingScreen is displayed
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(MainScreen), findsNothing);
  });

  testWidgets('Navigates to MainScreen if logged in', (WidgetTester tester) async {
    // Simulate that the user is logged in
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', true);

    // Build our app and trigger a frame
    await tester.pumpWidget(const MyApp(loggedIn: true));

    // Verify that the MainScreen is displayed
    expect(find.byType(MainScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
  });
}
