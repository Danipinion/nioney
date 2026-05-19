// This is a basic Flutter widget test for Nioney App.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nioney/main.dart';
import 'package:nioney/providers/app_provider.dart';

void main() {
  testWidgets('Nioney landing smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => AppProvider(),
        child: const NioneyApp(),
      ),
    );

    // Verify that the greeting cards are rendered properly
    expect(find.text('Welcome back,'), findsOneWidget);
  });
}
