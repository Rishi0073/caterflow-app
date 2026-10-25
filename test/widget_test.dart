// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
  testWidgets('CaterFlow app loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CaterFlowApp());

    // Verify that our app title appears
    expect(find.text('CATERFLOW ELITE'), findsOneWidget);

    // Verify that the navigation items are present
    expect(find.text('JOBS'), findsOneWidget);
    expect(find.text('EARNINGS'), findsOneWidget);
    expect(find.text('PROFILE'), findsOneWidget);
  });
}
