import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../theme.dart';
import '../../utils/friendly_error.dart';
import '../../widgets/account_settings.dart' show SheetHeader, showSettingsSheet, showSettingsMessage;
import '../../widgets/live_refresh.dart';
import '../../widgets/widgets.dart';
import '../support_screen.dart';

Widget _pageTitle(BuildContext context, String title, String subtitle) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(color: AppColors.textPrimary(context), fontSize: 28,
                fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13.5, height: 1.4)),
      ],
    );

// ── Support inbox ────────────────────────────────────────────────────────────

class SupportInboxPage extends StatefulWidget {
  final VoidCallback? onChanged;
  const SupportInboxPage({super.key, this.onChanged});

  @override
  State<SupportInboxPage> createState() => _SupportInboxPageState();
}

class _SupportInboxPageState extends State<SupportInboxPage> with LiveRefresh<SupportInboxPage> {
  String _status = 'open';
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    startLiveRefresh(_load);
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getSupportInbox(context.read<AuthProvider>().token!, _status);
      if (mounted) {
        setState(() {
          _data = data;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = friendlyMessage(e));
    }
  }

  Future<void> _open(Map<String, dynamic> thread) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => SupportThreadScreen(threadId: thread['id'] as int, admin: true)));
    await _load();
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final threads = ((data?['threads'] as List?) ?? const []).cast<Map<String, dynamic>>();
    final counts = (data?['counts'] as Map?) ?? const {};
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.accent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          _pageTitle(context, 'Support inbox',
              'Messages from customers, riders and restaurants. Reply here; they get a notification.'),
          const SizedBox(height: 14),
          Wrap(spacing: 8, children: [
            for (final (value, label) in [
              ('open', 'Open (${counts['open'] ?? 0})'), ('closed', 'Sorted'), ('all', 'All'),
            ])
              ChoiceChip(key: Key('inbox-$value'), label: Text(label), selected: _status == value,
                  onSelected: (_) {
                    setState(() {
                      _status = value;
                      _data = null;
                    });
                    _load();
                  }),
          ]),
          const SizedBox(height: 12),
          if (_error != null && data == null)
            EmptyState(icon: Icons.wifi_off_rounded, title: "Couldn't load the inbox",
                subtitle: _error!, actionLabel: 'Retry', onAction: _load)
          else if (data == null)
            const Padding(padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator(color: AppTheme.accent)))
          else if (threads.isEmpty)
            EmptyState(icon: Icons.mark_email_read_outlined,
                title: _status == 'open' ? 'All caught up' : 'Nothing here',
                subtitle: _status == 'open' ? 'New messages from people will appear here.' : '')
          else
            for (final t in threads)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  key: Key('inbox-thread-${t['id']}'),
                  onTap: () => _open(t),
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.accent.withValues(alpha: 0.18),
                    child: Icon(
                      switch (t['user_role']) {
                        'rider' => Icons.delivery_dining_rounded,
                        'restaurant' => Icons.storefront_rounded,
                        _ => Icons.person_rounded,
                      },
                      color: AppColors.accentText(context),
                    ),
                  ),
                  title: Text('${t['user_name'] ?? 'Someone'} · ${t['subject']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: textPri,
                          fontWeight: (t['unread'] as num) > 0 ? FontWeight.w800 : FontWeight.w600)),
                  subtitle: Text(
                    '${t['last_from_staff'] == true ? 'You: ' : ''}${t['last_message'] ?? ''}',
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
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(color: AppTheme.danger, borderRadius: BorderRadius.circular(10)),
                          child: Text('${t['unread']}',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                        ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

// ── Reviews ──────────────────────────────────────────────────────────────────

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  String _show = 'recent';
  List<Map<String, dynamic>>? _reviews;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final reviews = await ApiService.getAdminReviews(context.read<AuthProvider>().token!, _show);
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = friendlyMessage(e));
    }
  }

  Future<void> _hide(Map<String, dynamic> review) async {
    final reason = await showSettingsSheet<String>(context, const _HideForm());
    if (reason == null || !mounted) return;
    try {
      await ApiService.hideReview(context.read<AuthProvider>().token!, review['id'] as int, reason);
      if (mounted) showSettingsMessage(context, 'Hidden from the restaurant page.');
      await _load();
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    }
  }

  Future<void> _showAgain(Map<String, dynamic> review) async {
    try {
      await ApiService.showReview(context.read<AuthProvider>().token!, review['id'] as int);
      if (mounted) showSettingsMessage(context, 'The review is visible again.');
      await _load();
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _reviews;
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.accent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          _pageTitle(context, 'Reviews',
              'Hide abusive or fake reviews. Honest bad reviews should stay: they help restaurants improve.'),
          const SizedBox(height: 14),
          Wrap(spacing: 8, children: [
            for (final (value, label) in [('recent', 'Latest'), ('low', '1–2 stars'), ('hidden', 'Hidden')])
              ChoiceChip(key: Key('reviews-$value'), label: Text(label), selected: _show == value,
                  onSelected: (_) {
                    setState(() {
                      _show = value;
                      _reviews = null;
                    });
                    _load();
                  }),
          ]),
          const SizedBox(height: 12),
          if (_error != null && reviews == null)
            EmptyState(icon: Icons.wifi_off_rounded, title: "Couldn't load reviews",
                subtitle: _error!, actionLabel: 'Retry', onAction: _load)
          else if (reviews == null)
            const Padding(padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator(color: AppTheme.accent)))
          else if (reviews.isEmpty)
            const EmptyState(icon: Icons.star_outline_rounded, title: 'No reviews here', subtitle: '')
          else
            for (final r in reviews)
              Container(
                key: Key('review-${r['id']}'),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    for (var i = 1; i <= 5; i++)
                      Icon(i <= (r['rating'] as num) ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 18, color: AppTheme.accentDeep),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('${r['restaurant_name']}',
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: textPri, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                  if ((r['comment'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text('"${r['comment']}"', style: TextStyle(color: textPri, height: 1.35)),
                  ],
                  const SizedBox(height: 6),
                  Text('${r['customer_name']} · order #${r['order_id']} · ${supportTime(r['created_at'])}'
                      '${r['hidden'] == true ? ' · hidden: ${r['hidden_reason']}' : ''}',
                      style: TextStyle(color: textSec, fontSize: 12)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: r['hidden'] == true
                        ? TextButton(key: Key('review-show-${r['id']}'), onPressed: () => _showAgain(r),
                            child: const Text('Show again'))
                        : TextButton(key: Key('review-hide-${r['id']}'), onPressed: () => _hide(r),
                            child: const Text('Hide', style: TextStyle(color: AppTheme.danger))),
                  ),
                ]),
              ),
        ],
      ),
    );
  }
}

class _HideForm extends StatefulWidget {
  const _HideForm();

  @override
  State<_HideForm> createState() => _HideFormState();
}

class _HideFormState extends State<_HideForm> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SheetHeader(title: 'Hide this review?',
          subtitle: "It disappears from the restaurant's page and doesn't count in its rating."),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final s in ['Abusive language', 'Fake review', 'Personal information', 'Not about the food'])
          ActionChip(label: Text(s), onPressed: () => setState(() => _reason.text = s)),
      ]),
      const SizedBox(height: 12),
      AppTextField(key: const Key('hide-reason'), controller: _reason, hint: 'Reason',
          prefixIcon: Icons.edit_note_rounded),
      const SizedBox(height: 14),
      PrimaryButton(
        key: const Key('hide-confirm'),
        label: 'Hide review',
        onPressed: () {
          if (_reason.text.trim().length < 3) {
            showSettingsMessage(context, 'Add a short reason.', isError: true);
            return;
          }
          Navigator.of(context).pop(_reason.text.trim());
        },
      ),
    ]);
  }
}
