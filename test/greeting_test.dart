import 'package:findfood_app/widgets/greeting_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the greeting follows the time of day', () {
    expect(DayMoment.of(DateTime(2026, 10, 16, 3)).greeting, 'Up late');
    expect(DayMoment.of(DateTime(2026, 10, 16, 8)).greeting, 'Good morning');
    expect(DayMoment.of(DateTime(2026, 10, 16, 13)).greeting, 'Good afternoon');
    expect(DayMoment.of(DateTime(2026, 10, 16, 19)).greeting, 'Good evening');
    // Never "Good night" (that's a goodbye).
    expect(DayMoment.of(DateTime(2026, 10, 16, 23)).greeting, 'Good evening');
  });

  test('each role gets its own message, which changes from day to day', () {
    final monday = DateTime(2026, 10, 12, 8);
    final roles = ['customer', 'restaurant', 'rider', 'admin'];
    final messages = {for (final r in roles) greetingMessage(r, monday)};
    expect(messages.length, 4);
    final week = {
      for (var d = 0; d < 7; d++) greetingMessage('customer', monday.add(Duration(days: d)))
    };
    expect(week.length, greaterThan(1));
    // Stable within one part of the day.
    expect(greetingMessage('rider', DateTime(2026, 10, 12, 8)),
        greetingMessage('rider', DateTime(2026, 10, 12, 11, 59)));
  });

  testWidgets('shows the first name and a live status when given', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GreetingHeader(
          name: 'Rexford Ayensu',
          role: 'restaurant',
          status: '2 new orders are waiting for you.',
          now: DateTime(2026, 10, 16, 23, 24),
        ),
      ),
    ));
    expect(find.text('Good evening'), findsOneWidget);
    expect(find.text('Rexford'), findsOneWidget);
    expect(find.text('2 new orders are waiting for you.'), findsOneWidget);
    expect(find.textContaining('👋'), findsNothing);
  });
}
