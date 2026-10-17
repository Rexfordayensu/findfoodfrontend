import 'dart:convert';

import 'package:findfood_app/services/providers.dart';
import 'package:findfood_app/widgets/share_restaurant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

http.Response json(Object body, [int status = 200]) => http.Response(
    jsonEncode(body), status, headers: {'content-type': 'application/json'});

// A 1x1 JPEG, so the preview has a real picture to show.
final _jpeg = base64Decode(
    '/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////wgALCAABAAEBAREA/8QAFBABAAAAAAAAAAAAAAAAAAAAAP/aAAgBAQABPxA=');

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(() => AuthProvider.refreshInterval = null);

  Future<List<String>> open(WidgetTester tester, {Map<String, dynamic>? share, int status = 200}) async {
    final requested = <String>[];
    final client = MockClient((request) async {
      requested.add(request.url.path + (request.url.query.isEmpty ? '' : '?${request.url.query}'));
      if (request.url.path == '/restaurants/mine/share') {
        return status == 200
            ? json(share ??
                {
                  'url': 'https://findfood-nu.vercel.app/r/3',
                  'story_image': '/share/restaurants/3/card.jpg?size=story&v=abc',
                  'wide_image': '/share/restaurants/3/card.jpg?size=wide&v=abc',
                  'text': "Order from Mama Yaa's on FindFood",
                  'has_photo': true,
                  'dish_count': 2,
                })
            : json({'detail': 'You can share your restaurant once FindFood has approved it.'}, status);
      }
      return http.Response.bytes(Uint8List.fromList(_jpeg), 200, headers: {'content-type': 'image/jpeg'});
    });
    await http.runWithClient(() async {
      FlutterSecureStorage.setMockInitialValues({});
      tester.view.physicalSize = const Size(430, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final auth = AuthProvider();
      await auth.login(token: 't', userId: 3, role: 'restaurant', name: 'Ama');
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(home: Scaffold(body: Center(child: ShareRestaurantCard()))),
      ));
      await tester.tap(find.byKey(const Key('share-restaurant-card')));
      await settle(tester);
    }, () => client);
    return requested;
  }

  testWidgets('the share sheet previews the Status banner and the link preview', (tester) async {
    final requested = await open(tester);
    expect(requested, containsAll([
      '/restaurants/mine/share',
      '/share/restaurants/3/card.jpg?size=story&v=abc',
      '/share/restaurants/3/card.jpg?size=wide&v=abc',
    ]));
    expect(find.text('Share your restaurant'), findsWidgets);
    expect(find.byKey(const Key('share-preview-story')), findsOneWidget);
    expect(find.text('Share to Status'), findsOneWidget);
    expect(find.text('For WhatsApp Status: tap Share, choose WhatsApp, then My status.'), findsOneWidget);
    expect(find.byKey(const Key('share-photo-tip')), findsNothing);

    await tester.tap(find.byKey(const Key('share-format-wide')));
    await settle(tester);
    expect(find.byKey(const Key('share-preview-wide')), findsOneWidget);
    expect(find.byKey(const Key('share-link-primary')), findsOneWidget);
    expect(find.byKey(const Key('share-link')), findsNothing, reason: 'the main button shares the link');
    expect(find.text('https://findfood-nu.vercel.app/r/3'), findsOneWidget);
  });

  testWidgets('copy link puts the link on the clipboard', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
      return null;
    });
    await open(tester);
    await tester.tap(find.byKey(const Key('share-copy')));
    await settle(tester);
    expect(copied, 'https://findfood-nu.vercel.app/r/3');
    expect(find.text('Link copied. Paste it anywhere.'), findsOneWidget);
  });

  testWidgets('without photos the sheet suggests adding them', (tester) async {
    await open(tester, share: {
      'url': 'https://findfood-nu.vercel.app/r/1',
      'story_image': '/share/restaurants/1/card.jpg?size=story&v=x',
      'wide_image': '/share/restaurants/1/card.jpg?size=wide&v=x',
      'text': 'Order from Daavi on FindFood',
      'has_photo': false,
      'dish_count': 1,
    });
    expect(find.byKey(const Key('share-photo-tip')), findsOneWidget);
  });

  testWidgets('a restaurant waiting for approval is told why it cannot share yet', (tester) async {
    await open(tester, status: 409);
    expect(find.text('You can share your restaurant once FindFood has approved it.'), findsOneWidget);
  });

  testWidgets('anyone can share a restaurant from its page, signed in or not', (tester) async {
    final requested = <String>[];
    final client = MockClient((request) async {
      requested.add('${request.url.path}?${request.url.query}');
      expect(request.headers.containsKey('Authorization'), isFalse);
      return http.Response.bytes(Uint8List.fromList(_jpeg), 200, headers: {'content-type': 'image/jpeg'});
    });
    await http.runWithClient(() async {
      FlutterSecureStorage.setMockInitialValues({});
      tester.view.physicalSize = const Size(430, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: AuthProvider(),
        child: const MaterialApp(
          home: Scaffold(body: Center(child: ShareRestaurantButton(restaurantId: 7, name: 'Auntie Ama'))),
        ),
      ));
      await tester.tap(find.byKey(const Key('menu-share')));
      await settle(tester);
    }, () => client);
    expect(requested, containsAll([
      '/share/restaurants/7/card.jpg?size=story',
      '/share/restaurants/7/card.jpg?size=wide',
    ]));
    expect(find.text('Share Auntie Ama'), findsOneWidget);
    expect(find.text('Send it to friends or post it on your Status. They can tap it to order.'), findsOneWidget);
    // Friends get a link first; the Status banner is one tap away.
    expect(find.byKey(const Key('share-preview-wide')), findsOneWidget);
    expect(find.byKey(const Key('share-link-primary')), findsOneWidget);
    expect(find.text('https://findfood-nu.vercel.app/r/7'), findsOneWidget);
    expect(find.byKey(const Key('share-photo-tip')), findsNothing);
    await tester.tap(find.byKey(const Key('share-format-story')));
    await settle(tester);
    expect(find.text('Share to Status'), findsOneWidget);
  });
}
