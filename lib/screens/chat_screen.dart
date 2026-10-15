import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../utils/friendly_error.dart';

/// A private chat between the signed-in user and one other person on an
/// order ([withRole]: 'customer', 'restaurant' or 'rider'). New messages
/// arrive over a WebSocket; history is (re)loaded over REST each time the
/// socket connects, so nothing sent while offline is missed.
class ChatScreen extends StatefulWidget {
  final int orderId;
  final String otherPartyName;
  final String withRole;

  const ChatScreen({
    super.key,
    required this.orderId,
    required this.otherPartyName,
    required this.withRole,
  });

  /// Opens the live connection; replaced in tests.
  static WebSocketChannel Function(Uri uri) connect = WebSocketChannel.connect;
  static Duration keepAliveEvery = const Duration(seconds: 25);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final Set<int> _messageIds = {}; // dedupe guard between REST + WebSocket
  bool _loading = true;
  String _error = '';
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _connected = false;
  bool _disposed = false;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  Timer? _keepAlive;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  @override
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _keepAlive?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── History over REST, merged with whatever arrived live ───────────────
  Future<void> _loadHistory() async {
    final auth = context.read<AuthProvider>();
    if (auth.token == null) return;
    try {
      final messages = await ApiService.getChatMessages(
          token: auth.token!, orderId: widget.orderId, withRole: widget.withRole);
      if (!mounted) return;
      setState(() {
        for (final raw in messages) {
          _add(ChatMessage.fromJson(
              {...raw, 'is_mine': raw['sender_id'] == auth.userId}));
        }
        _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        _error = '';
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      if (_messages.isEmpty) {
        setState(() => _error = friendlyMessage(e));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _add(ChatMessage message) {
    if (!_messageIds.add(message.id)) return false;
    _messages.add(message);
    return true;
  }

  // ── Live connection ────────────────────────────────────────────────────
  Future<void> _connect() async {
    final auth = context.read<AuthProvider>();
    if (auth.token == null) {
      setState(() => _loading = false);
      return;
    }
    final wsBase = ApiService.baseUrl.replaceFirst('http', 'ws');
    // The token goes in the first message, not the address: addresses are
    // written to server and proxy logs.
    final uri = Uri.parse(
        '$wsBase/ws/orders/${widget.orderId}/chat?with=${widget.withRole}');

    try {
      final channel = ChatScreen.connect(uri);
      _channel = channel;
      _subscription = channel.stream.listen(
        (raw) => _onFrame(raw, auth.userId),
        onDone: _handleDisconnect,
        onError: (_) => _handleDisconnect(),
      );
      await channel.ready;
      if (_disposed || _channel != channel) return;
      channel.sink.add(jsonEncode({'type': 'auth', 'token': auth.token}));
      _reconnectAttempts = 0;
      setState(() => _connected = true);
      _keepAlive?.cancel();
      _keepAlive = Timer.periodic(ChatScreen.keepAliveEvery, (_) {
        try {
          _channel?.sink.add('ping');
        } catch (_) {}
      });
    } catch (_) {
      _handleDisconnect();
    }
    // Catch up on anything sent before (or while) we were connecting.
    if (!_disposed) await _loadHistory();
  }

  void _onFrame(dynamic raw, int? myUserId) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      final incoming = ChatMessage.fromJson(
          {...data, 'is_mine': data['sender_id'] == myUserId});
      if (!mounted) return;
      var added = false;
      setState(() => added = _add(incoming));
      if (added) _scrollToBottom();
    } catch (_) {
      // Ignore frames that are not chat messages.
    }
  }

  void _handleDisconnect() {
    // A failed attempt reports through both the stream and `ready`.
    if (_disposed || (_reconnectTimer?.isActive ?? false)) return;
    _keepAlive?.cancel();
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    if (mounted) setState(() => _connected = false);
    // Back off 2, 4, 8 … up to 30 seconds between attempts.
    final delay = Duration(
        seconds: (2 << _reconnectAttempts.clamp(0, 4)).clamp(2, 30));
    _reconnectAttempts++;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (!_disposed) _connect();
    });
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _msgCtrl.text).trim();
    if (text.isEmpty || _sending) return;
    final auth = context.read<AuthProvider>();

    setState(() => _sending = true);
    if (preset == null) _msgCtrl.clear();
    try {
      // Sent over REST; the server broadcasts it to everyone's socket.
      final msg = await ApiService.sendChatMessage(
        token: auth.token!,
        orderId: widget.orderId,
        withRole: widget.withRole,
        message: text,
      );
      if (!mounted) return;
      var added = false;
      setState(() => added = _add(ChatMessage.fromJson(
          {...msg, 'is_mine': msg['sender_id'] == auth.userId})));
      if (added) _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      if (preset == null && _msgCtrl.text.isEmpty) _msgCtrl.text = text;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.danger,
        content: Text(friendlyMessage(e),
            style: const TextStyle(color: Colors.white)),
      ));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Suggestions for this particular pair of people.
  List<String> _quickReplies(String? me) => switch ((me, widget.withRole)) {
        ('customer', 'restaurant') => [
            'Is my food ready?',
            'Can I change my order?',
            'Thank you!'
          ],
        ('customer', 'rider') => [
            'Where are you now?',
            'Please call me when you arrive',
            'Thank you!'
          ],
        ('restaurant', 'customer') => [
            'Your order is being prepared',
            'Your order is ready',
            'Thank you!'
          ],
        ('restaurant', 'rider') => [
            'The food is ready for pickup',
            'Please come to the counter',
            'Thanks!'
          ],
        ('rider', 'restaurant') => [
            "I'm on my way to collect",
            "I've arrived for pickup",
            'Is the order ready?'
          ],
        ('rider', 'customer') => [
            "I'm on my way",
            "I've arrived",
            'Please call me'
          ],
        _ => ['Thank you!'],
      };

  @override
  Widget build(BuildContext context) {
    final role = context.read<AuthProvider>().role;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.accentDim,
              child: Text(
                widget.otherPartyName.isNotEmpty
                    ? widget.otherPartyName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                    color: AppColors.accentText(context),
                    fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.otherPartyName,
                      style: const TextStyle(fontSize: 15),
                      overflow: TextOverflow.ellipsis),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _connected
                              ? AppTheme.success
                              : AppColors.textHint(context),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _connected
                            ? 'Order #${widget.orderId} · Live'
                            : 'Order #${widget.orderId} · Connecting…',
                        key: const Key('chat-connection-status'),
                        style: TextStyle(
                          fontSize: 11,
                          color: _connected
                              ? AppTheme.success
                              : AppColors.textHint(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _body()),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              children: [
                for (final reply in _quickReplies(role))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ActionChip(
                      label: Text(reply),
                      onPressed: _sending ? null : () => _send(reply),
                    ),
                  ),
              ],
            ),
          ),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded,
                  size: 48, color: AppColors.textHint(context)),
              const SizedBox(height: 12),
              Text(_error,
                  style: TextStyle(color: AppColors.textSecondary(context)),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: () {
                    setState(() => _loading = true);
                    _loadHistory();
                  },
                  child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded,
                size: 48, color: AppColors.textHint(context)),
            const SizedBox(height: 12),
            Text('No messages yet',
                style: TextStyle(color: AppColors.textSecondary(context))),
            const SizedBox(height: 4),
            Text('Say hello to get started!',
                style:
                    TextStyle(color: AppColors.textHint(context), fontSize: 12)),
          ],
        ),
      );
    }
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (_, i) => _MessageBubble(message: _messages[i]),
    );
  }

  Widget _inputBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          border: Border(top: BorderSide(color: AppColors.border(context))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: TextField(
                  key: const Key('chat-input'),
                  controller: _msgCtrl,
                  minLines: 1,
                  maxLines: 4,
                  style: TextStyle(color: AppColors.textPrimary(context)),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: AppColors.textHint(context)),
                    border: InputBorder.none,
                    filled: false,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onSubmitted: (_) => _send(),
                  textInputAction: TextInputAction.send,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: 'Send',
              child: GestureDetector(
                key: const Key('chat-send'),
                onTap: () => _send(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppTheme.accent,
                    shape: BoxShape.circle,
                  ),
                  child: _sending
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                              color: Colors.black, strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded,
                          color: Colors.black, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    final time = TimeOfDay.fromDateTime(message.createdAt.toLocal());
    final timeStr =
        '${time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}';

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 3),
                child: Text(
                  message.senderRole.isNotEmpty
                      ? message.senderRole[0].toUpperCase() +
                          message.senderRole.substring(1)
                      : '',
                  style:
                      TextStyle(color: AppColors.textHint(context), fontSize: 11),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMine ? AppTheme.accent : AppColors.card(context),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMine ? 16 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 16),
                ),
                border:
                    isMine ? null : Border.all(color: AppColors.border(context)),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isMine ? Colors.black : AppColors.textPrimary(context),
                  fontSize: 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
              child: Text(timeStr,
                  style:
                      TextStyle(color: AppColors.textHint(context), fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }
}
