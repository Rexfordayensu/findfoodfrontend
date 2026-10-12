import 'package:findfood_app/models/models.dart';
import 'package:findfood_app/widgets/promotion_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

List<Promotion> promos(int n) => [
      for (var i = 1; i <= n; i++)
        Promotion(
          id: i,
          restaurantId: 1,
          restaurantName: 'Shop',
          title: 'Deal $i',
          discountPercent: 10 * i,
          isActive: true,
        ),
    ];

Widget host(List<Promotion> promotions, {bool reduceMotion = false}) =>
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
            size: const Size(430, 900), disableAnimations: reduceMotion),
        child: Scaffold(
          body:
              PromotionCarousel(title: 'Deals for you', promotions: promotions),
        ),
      ),
    );

Future<void> phone(WidgetTester tester) async {
  tester.view.physicalSize = const Size(430, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

int currentPage(WidgetTester tester) => tester
    .widget<PageView>(find.byKey(const Key('promotion-carousel')))
    .controller!
    .page!
    .round();

void main() {
  setUp(() => PromotionCarousel.autoAdvanceEvery = const Duration(seconds: 4));

  testWidgets('slides to the next promotion on its own and loops',
      (tester) async {
    await phone(tester);
    await tester.pumpWidget(host(promos(3)));
    expect(currentPage(tester), 0);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(currentPage(tester), 1);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(currentPage(tester), 2);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(currentPage(tester), 0, reason: 'wraps back to the first offer');

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('pauses while the user is touching it', (tester) async {
    await phone(tester);
    await tester.pumpWidget(host(promos(3)));
    final gesture = await tester
        .startGesture(tester.getCenter(find.byKey(const Key('promotion-1'))));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(currentPage(tester), 0, reason: 'no auto-advance under a finger');
    await gesture.up();

    // Resumes a few seconds after the user lets go.
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(currentPage(tester), 1);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('stays still for a single promotion or reduced motion',
      (tester) async {
    await phone(tester);
    await tester.pumpWidget(host(promos(1)));
    await tester.pump(const Duration(seconds: 9));
    expect(currentPage(tester), 0);

    await tester.pumpWidget(host(promos(3), reduceMotion: true));
    await tester.pump(const Duration(seconds: 9));
    await tester.pumpAndSettle();
    expect(currentPage(tester), 0);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('loops on wide screens where several offers fit at once',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(promos(4)));
    final controller = tester
        .widget<PageView>(find.byKey(const Key('promotion-carousel')))
        .controller!;

    var reachedEnd = false;
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      final position = controller.position;
      if (position.pixels >= position.maxScrollExtent - 1) reachedEnd = true;
      if (reachedEnd && position.pixels == 0) break;
    }
    expect(reachedEnd, isTrue);
    expect(controller.position.pixels, 0, reason: 'came back to the start');

    await tester.pumpWidget(const SizedBox());
  });
}
