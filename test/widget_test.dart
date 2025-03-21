import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmanager/main.dart'; // Siguraduhin na tama ang import path

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const MyApp());

    // Hanapin ang + button
    final Finder fab = find.byIcon(Icons.add);

    // Siguraduhin na may isa lang
    expect(fab, findsOneWidget);

    // I-tap ang button
    await tester.tap(fab);
    await tester.pump();

    // Hanapin kung nag-increment ang counter
    expect(find.text('1'), findsOneWidget);
  });
}
