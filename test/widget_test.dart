// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:virtual_try_on/main.dart';

late Directory _hiveTestDir;

Future<void> _initHiveForTests() async {
  _hiveTestDir = await Directory.systemTemp.createTemp('virtual_try_on_test');
  Hive.init(_hiveTestDir.path);
  await Hive.openBox('settings');
  await Hive.openBox('wardrobe');
}

Future<void> _disposeHiveForTests() async {
  await Hive.close();
  if (await _hiveTestDir.exists()) {
    await _hiveTestDir.delete(recursive: true);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _initHiveForTests();
  });

  tearDownAll(() async {
    await _disposeHiveForTests();
  });

  setUp(() async {
    await Hive.box('settings').clear();
    await Hive.box('wardrobe').clear();
  });

  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: VirtualTryOnApp(),
      ),
    );

    // Дожидаемся завершения стартовых анимаций, чтобы избежать таймеров
    await tester.pumpAndSettle();

    // Verify that the app title is displayed
    expect(find.text('Виртуальная примерочная'), findsOneWidget);

    // Verify that the bottom navigation is displayed
    expect(find.text('Главная'), findsOneWidget);
    expect(find.text('Гардероб'), findsOneWidget);
    expect(find.text('Настройки'), findsOneWidget);
  });
}
