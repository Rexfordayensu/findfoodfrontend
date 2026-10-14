import 'package:findfood_app/legal/legal_documents.dart';
import 'package:findfood_app/screens/legal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('terms and privacy switch, and contents jump to a section', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: LegalScreen()));

    expect(find.text('Terms of Service'), findsWidgets);
    expect(find.text('The short version'), findsOneWidget);
    expect(find.textContaining('Last updated $legalUpdated'), findsOneWidget);

    await tester.tap(find.byKey(const Key('legal-contents')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('For riders').first);
    await tester.pumpAndSettle();
    expect(find.text('For riders'), findsWidgets);

    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, 100000));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('legal-tab-privacy')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('legal-title')), findsOneWidget);
    expect((tester.widget(find.byKey(const Key('legal-title'))) as Text).data, 'Privacy Policy');
  });

  test('every document mentions how to reach support and Ghanaian law', () {
    for (final doc in [termsOfService, privacyPolicy]) {
      final text = doc.sections.expand((s) => s.paragraphs).join(' ');
      expect(text, contains(supportEmail));
      expect(doc.sections.map((s) => s.id).toSet().length, doc.sections.length,
          reason: 'section ids must be unique for the contents links');
    }
    expect(privacyPolicy.intro, contains('Act 843'));
  });
}
