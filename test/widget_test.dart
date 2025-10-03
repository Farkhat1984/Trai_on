// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virtual_try_on/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: VirtualTryOnApp(),
      ),
    );

    // Verify that the app title is displayed
    expect(find.text('Виртуальная примерочная'), findsOneWidget);

    // Verify that the bottom navigation is displayed
    expect(find.text('Главная'), findsOneWidget);
    expect(find.text('Гардероб'), findsOneWidget);
    expect(find.text('Настройки'), findsOneWidget);
  });
}
