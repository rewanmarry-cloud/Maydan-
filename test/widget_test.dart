import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:maydan/core/localization/app_strings.dart';
import 'package:maydan/core/state/app_controller.dart';
import 'package:maydan/data/repositories/maydan_repository.dart';
import 'package:maydan/features/shell/app_shell.dart';

class _TestRepository extends MaydanRepository {
  @override
  Future<List<Map<String, dynamic>>> list(String table) async => [];
}

Future<AppController> _controller() async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final controller = AppController(_TestRepository(), preferences);
  await controller.initialize();
  return controller;
}

void main() {
  for (final locale in ['ar', 'fr', 'en']) {
    test('$locale has stable RTL/LTR localization strings', () {
      final strings = AppStrings(locale);
      expect(strings.get('dashboard'), isNotEmpty);
      expect(strings.get('save'), isNotEmpty);
      expect(westernDigits('١٢٣٤٥٦٧٨٩٠'), '1234567890');
    });
  }

  testWidgets('Arabic app shell renders dashboard', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = await _controller();
    await controller.setManualLocale('ar');
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(locale: Locale('ar'), home: AppShell()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dashboard-page')), findsOneWidget);
    expect(find.byKey(const Key('app-shell-title')), findsOneWidget);
  });

  testWidgets('system back returns from a section without duplicate pages', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = await _controller();
    await controller.setManualLocale('en');
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(locale: Locale('en'), home: AppShell()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-section-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('projects-page')), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dashboard-page')), findsOneWidget);
  });

  testWidgets('root system Back asks before exiting', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = await _controller();
    await controller.setManualLocale('fr');
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(locale: Locale('fr'), home: AppShell()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('exit-confirmation')), findsOneWidget);
  });

  testWidgets('dialog remains the first Back target', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = await _controller();
    await controller.setManualLocale('en');
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(locale: Locale('en'), home: AppShell()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-section-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-project-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('project-dialog')), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('project-dialog')), findsNothing);
    expect(find.byKey(const Key('projects-page')), findsOneWidget);
  });
}
