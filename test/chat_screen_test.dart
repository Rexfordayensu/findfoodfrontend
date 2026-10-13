import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:findfood_app/screens/chat_screen.dart';
import 'package:findfood_app/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// A WebSocket stand-in the test can push frames into and close.
class FakeSocket extends StreamChannelMixin implements WebSocketChannel {
  final incoming = StreamController<dynamic>();
  final sent = <dynamic>[];
  late final _sink = _FakeSink(this);

  @override
  Stream get stream => incoming.stream;
  @override
  WebSocketSink get sink => _sink;
  @override
  Future<void> get ready => Future.value();
  @override
  String? get protocol => null;
  @override
  int? get closeCode => null;
  @override
  String? get closeReason => null;

  void push(Map<String, dynamic> message) => incoming.add(jsonEncode(message));
  void drop() => incoming.close();
}

class _FakeSink extends DelegatingStreamSink implements WebSocketSink {
  final FakeSocket socket;
  _FakeSink(this.socket) : super(StreamController<dynamic>());
  @override
  void add(dynamic data) => socket.sent.add(data);
  @override
  Future close([int? closeCode, String? closeReason]) async {}
}

Map<String, dynamic> msg(int id, int sender, String role, String text) => {
      'id': id, 'order_id': 3, 'sender_id': sender, 'sender_role': role,
      'message': text, 'content': text,
      'created_at': DateTime.utc(2026, 10, 13, 12, id).toIso8601String(),
    };

void main() {
  late List<FakeSocket> sockets;
  late List<Map<String, dynamic>> history;
  late List<String> requests;

  setUp(() {
    AuthProvider.refreshInterval = null;
    sockets = [];
    history = [msg(1, 20, 'restaurant', 'Your order is being prepared')];
    requests = [];
    ChatScreen.connect = (uri) {
      requests.add('WS ${uri.path}');
      final socket = FakeSocket();
      sockets.add(socket);
      return socket;
    };
  });

  final client = MockClient((request) async {
    requests.add('${request.method} ${request.url.path}');
    if (request.method == 'POST') {
      final text = jsonDecode(request.body)['message'] as String;
      final sent = msg(10, 7, 'customer', text);
      history.add(sent);
      return http.Response(jsonEncode(sent), 201,
          headers: {'content-type': 'application/json'});
    }
    return http.Response(jsonEncode(history), 200,
        headers: {'content-type': 'application/json'});
  });

  Future<void> open(WidgetTester tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final auth = AuthProvider();
    await auth.login(
        token: 'tok', userId: 7, role: 'customer', name: 'Ama',
        email: 'ama@example.com');
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: auth,
      child: const MaterialApp(
          home: ChatScreen(orderId: 3, otherPartyName: "Mama's Kitchen")),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('loads history, then shows new messages live without duplicates',
      (tester) async {
    await http.runWithClient(() async {
      await open(tester);
      expect(find.text('Your order is being prepared'), findsOneWidget);
      expect(find.textContaining('Live'), findsOneWidget);
      expect(requests.first, 'WS /ws/orders/3/chat');

      // The rider writes: it appears straight away, no refresh.
      sockets.single.push(msg(2, 30, 'rider', "I'm on my way"));
      await tester.pumpAndSettle();
      expect(find.text("I'm on my way"), findsOneWidget);
      expect(find.text('Rider'), findsOneWidget);

      // We send; the server also echoes it over the socket. Shown once.
      await tester.enterText(find.byKey(const Key('chat-input')), 'See you soon');
      await tester.tap(find.byKey(const Key('chat-send')));
      await tester.pumpAndSettle();
      sockets.single.push(msg(10, 7, 'customer', 'See you soon'));
      await tester.pumpAndSettle();
      expect(find.text('See you soon'), findsOneWidget);
    }, () => client);
  });

  testWidgets('reconnects after a drop and catches up on missed messages',
      (tester) async {
    await http.runWithClient(() async {
      await open(tester);
      sockets.single.drop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.textContaining('Connecting'), findsOneWidget);

      // Sent while we were offline.
      history.add(msg(3, 20, 'restaurant', 'Your order is ready'));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(sockets, hasLength(2));
      expect(find.textContaining('Live'), findsOneWidget);
      expect(find.text('Your order is ready'), findsOneWidget);
      expect(find.text('Your order is being prepared'), findsOneWidget);
    }, () => client);
  });

  testWidgets('quick replies send straight away', (tester) async {
    await http.runWithClient(() async {
      await open(tester);
      await tester.tap(find.text('Where are you now?'));
      await tester.pumpAndSettle();
      expect(requests, contains('POST /orders/3/messages'));
      expect(find.text('Where are you now?'), findsNWidgets(2)); // chip + bubble
    }, () => client);
  });
}
