import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/providers.dart';
import '../theme.dart';
import '../utils/friendly_error.dart';
import '../widgets/account_settings.dart' show SheetHeader, showSettingsSheet, showSettingsMessage;
import '../widgets/widgets.dart';

String supportTime(Object? iso) {
  final at = DateTime.tryParse('$iso')?.toLocal();
  if (at == null) return '';
  final now = DateTime.now();
  final hm = '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
  if (at.year == now.year && at.month == now.month && at.day == now.day) return hm;
  return '${at.day}/${at.month} $hm';
}

/// Your conversations with FindFood support.
class SupportInboxScreen extends StatefulWidget {
  const SupportInboxScreen({super.key});

  @override
  State<SupportInboxScreen> createState() => _SupportInboxScreenState();
}

class _SupportInboxScreenState extends State<SupportInboxScreen> {
  List<Map<String, dynamic>>? _threads;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final threads = await ApiService.getMySupportThreads(context.read<AuthProvider>().token!);
      if (mounted) {
        setState(() {
          _threads = threads;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = friendlyMessage(e));
    }
  }

  Future<void> _new() async {
    final thread = await showSettingsSheet<Map<String, dynamic>>(context, const _NewConversation());
    if (thread == null || !mounted) return;
    await context.push('/support/${thread['id']}');
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final threads = _threads;
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(title: const Text('Support')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('support-new'),
        onPressed: _new,
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.edit_rounded),
        label: const Text('New message'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.accent,
        child: _error != null && threads == null
            ? ListView(children: [
                EmptyState(icon: Icons.wifi_off_rounded, title: "Couldn't load your messages",
                    subtitle: _error!, actionLabel: 'Retry', onAction: _load),
              ])
            : threads == null
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                : threads.isEmpty
                    ? ListView(children: const [
                        EmptyState(
                          icon: Icons.support_agent_rounded,
                          title: 'How can we help?',
                          subtitle: 'Send us a message about an order, a payment, or anything else. '
                              'We reply here and let you know.',
                        ),
                      ])
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        children: [
                          for (final t in threads)
                            Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                key: Key('support-thread-${t['id']}'),
                                onTap: () async {
                                  await context.push('/support/${t['id']}');
                                  await _load();
                                },
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.accent.withValues(alpha: 0.18),
                                  child: Icon(t['status'] == 'closed'
                                      ? Icons.check_rounded : Icons.support_agent_rounded,
                                      color: AppColors.accentText(context)),
                                ),
                                title: Text('${t['subject']}',
                                    style: TextStyle(color: textPri,
                                        fontWeight: (t['unread'] as num) > 0 ? FontWeight.w800 : FontWeight.w600)),
                                subtitle: Text(
                                  '${t['last_from_staff'] == true ? 'FindFood: ' : 'You: '}${t['last_message'] ?? ''}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: textSec),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(supportTime(t['updated_at']), style: TextStyle(color: textSec, fontSize: 11.5)),
                                    if ((t['unread'] as num) > 0)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(color: AppTheme.danger, shape: BoxShape.circle),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
      ),
    );
  }
}

class _NewConversation extends StatefulWidget {
  const _NewConversation();

  @override
  State<_NewConversation> createState() => _NewConversationState();
}

class _NewConversationState extends State<_NewConversation> {
  final _subject = TextEditingController();
  final _body = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_subject.text.trim().length < 3 || _body.text.trim().isEmpty) {
      showSettingsMessage(context, 'Add a topic and your message.', isError: true);
      return;
    }
    setState(() => _sending = true);
    try {
      final thread = await ApiService.startSupportThread(context.read<AuthProvider>().token!,
          subject: _subject.text.trim(), body: _body.text.trim());
      if (mounted) Navigator.of(context).pop(thread);
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SheetHeader(title: 'Message FindFood support', subtitle: "We'll reply here and send you a notification."),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final s in ['My order', 'A payment or refund', 'My account', 'Something else'])
          ActionChip(label: Text(s), onPressed: () => setState(() => _subject.text = s)),
      ]),
      const SizedBox(height: 12),
      AppTextField(key: const Key('support-subject'), controller: _subject, hint: 'Topic',
          prefixIcon: Icons.topic_outlined),
      const SizedBox(height: 10),
      TextField(
        key: const Key('support-body'),
        controller: _body,
        maxLines: 4,
        maxLength: 2000,
        decoration: const InputDecoration(hintText: 'Tell us what happened (include the order number if you can)'),
      ),
      const SizedBox(height: 8),
      PrimaryButton(key: const Key('support-send'), label: 'Send', isLoading: _sending,
          onPressed: _sending ? null : _send),
    ]);
  }
}

/// One conversation: the messages and a reply box. Also used by admins
/// (with [admin]), who see the person's details and can close it.
class SupportThreadScreen extends StatefulWidget {
  final int threadId;
  final bool admin;
  const SupportThreadScreen({super.key, required this.threadId, this.admin = false});

  @override
  State<SupportThreadScreen> createState() => _SupportThreadScreenState();
}

class _SupportThreadScreenState extends State<SupportThreadScreen> {
  Map<String, dynamic>? _thread;
  String? _error;
  final _reply = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token!;
    try {
      final thread = widget.admin
          ? await ApiService.getAdminSupportThread(token, widget.threadId)
          : await ApiService.getMySupportThread(token, widget.threadId);
      if (mounted) {
        setState(() {
          _thread = thread;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = friendlyMessage(e));
    }
  }

  Future<void> _send() async {
    final text = _reply.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      final token = context.read<AuthProvider>().token!;
      if (widget.admin) {
        await ApiService.replyAsSupport(token, widget.threadId, text);
      } else {
        await ApiService.replyToSupport(token, widget.threadId, text);
      }
      _reply.clear();
      await _load();
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _setClosed(bool close) async {
    try {
      await ApiService.setSupportThreadStatus(context.read<AuthProvider>().token!, widget.threadId, close: close);
      await _load();
      if (mounted) showSettingsMessage(context, close ? 'Marked as sorted.' : 'Reopened.');
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final thread = _thread;
    final messages = ((thread?['messages'] as List?) ?? const []).cast<Map<String, dynamic>>();
    final user = thread?['user'] as Map?;
    final closed = thread?['status'] == 'closed';
    final textSec = AppColors.textSecondary(context);
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text('${thread?['subject'] ?? 'Support'}'),
        actions: [
          if (widget.admin && thread != null)
            TextButton(
              key: const Key('support-toggle-status'),
              onPressed: () => _setClosed(!closed),
              child: Text(closed ? 'Reopen' : 'Mark sorted'),
            ),
        ],
      ),
      body: Column(children: [
        if (widget.admin && user != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            color: AppColors.surface(context),
            child: Text(
              [user['name'], thread?['user_role'], user['phone'], user['email'],
                if (thread?['order_id'] != null) 'order #${thread!['order_id']}']
                  .whereType<Object>().join(' · '),
              style: TextStyle(color: textSec, fontSize: 12.5),
            ),
          ),
        Expanded(
          child: _error != null && thread == null
              ? Center(child: Text(_error!, style: TextStyle(color: textSec)))
              : thread == null
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppTheme.accent,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          for (final m in messages) _Bubble(message: m, mine: (m['from_staff'] == true) == widget.admin,
                              admin: widget.admin),
                          if (closed)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Center(
                                child: Text(
                                  widget.admin
                                      ? 'Marked as sorted. A new message from them reopens it.'
                                      : 'This conversation is sorted. Reply if you still need help.',
                                  style: TextStyle(color: textSec, fontSize: 12.5),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: Row(children: [
              Expanded(
                child: TextField(
                  key: const Key('support-reply'),
                  controller: _reply,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(hintText: widget.admin ? 'Reply as FindFood support' : 'Write a message'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                key: const Key('support-reply-send'),
                onPressed: _sending ? null : _send,
                style: IconButton.styleFrom(backgroundColor: AppTheme.accent, foregroundColor: Colors.black),
                icon: _sending
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send_rounded),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool mine, admin;
  const _Bubble({required this.message, required this.mine, required this.admin});

  @override
  Widget build(BuildContext context) {
    final staff = message['from_staff'] == true;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: mine ? AppTheme.accent : AppColors.card(context),
          borderRadius: BorderRadius.circular(16),
          border: mine ? null : Border.all(color: AppColors.border(context)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!mine || (admin && staff))
            Text(staff ? (admin ? '${message['sender_name'] ?? 'Support'}' : 'FindFood support')
                : '${message['sender_name'] ?? ''}',
                style: TextStyle(
                    color: mine ? Colors.black87 : AppColors.accentText(context),
                    fontSize: 11.5, fontWeight: FontWeight.w800)),
          Text('${message['body']}',
              style: TextStyle(color: mine ? Colors.black : AppColors.textPrimary(context), height: 1.35)),
          const SizedBox(height: 2),
          Text(supportTime(message['created_at']),
              style: TextStyle(color: mine ? Colors.black54 : AppColors.textSecondary(context), fontSize: 10.5)),
        ]),
      ),
    );
  }
}
