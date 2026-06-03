import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1194, 834)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(834, 1194),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => MaterialApp(home: child),
        child: const AppEntry(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Periodic Quest'), findsWidgets);
  });
}
