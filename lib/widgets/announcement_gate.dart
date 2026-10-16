import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/notifications_provider.dart';
import '../services/providers.dart';
import '../theme.dart';

String _when(Object? iso) {
  final at = DateTime.tryParse('$iso')?.toLocal();
  if (at == null) return '';
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${at.day} ${months[at.month - 1]} · ${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
}

/// Shows FindFood announcements nobody can miss: an unseen announcement
/// pops up as a banner over whatever page is open, until "Got it" is tapped.
/// After that it's a normal notification in the list.
class AnnouncementGate extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  const AnnouncementGate({super.key, required this.child, required this.navigatorKey});

  @override
  State<AnnouncementGate> createState() => _AnnouncementGateState();
}

class _AnnouncementGateState extends State<AnnouncementGate> {
  AuthProvider? _auth;
  NotificationsProvider? _notes;
  bool _checking = false, _showing = false;
  int _lastUnread = -1;
  String? _lastToken;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthProvider>();
    final notes = context.read<NotificationsProvider?>();
    if (!identical(auth, _auth)) {
      _auth?.removeListener(_changed);
      _auth = auth..addListener(_changed);
    }
    if (!identical(notes, _notes)) {
      _notes?.removeListener(_changed);
      _notes = notes?..addListener(_changed);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _changed());
  }

  @override
  void dispose() {
    _auth?.removeListener(_changed);
    _notes?.removeListener(_changed);
    super.dispose();
  }

  /// Check on sign-in, and whenever something new arrives.
  void _changed() {
    final auth = _auth;
    if (auth == null || !auth.isLoggedIn || auth.isAdmin || auth.token == null) {
      _lastToken = null;
      return;
    }
    final unread = _notes?.unread ?? 0;
    if (auth.token == _lastToken && unread <= _lastUnread) {
      _lastUnread = unread;
      return;
    }
    _lastToken = auth.token;
    _lastUnread = unread;
    _check();
  }

  Future<void> _check() async {
    if (_checking || _showing) return;
    final token = _auth?.token;
    if (token == null) return;
    _checking = true;
    try {
      final unseen = await ApiService.getUnseenAnnouncements(token);
      if (unseen.isNotEmpty) await _show(unseen.first, token);
    } catch (_) {
      // Not urgent: it's still in the notifications list.
    } finally {
      _checking = false;
    }
  }

  Future<void> _show(Map<String, dynamic> announcement, String token) async {
    final navContext = widget.navigatorKey.currentContext;
    if (navContext == null || !mounted) return;
    _showing = true;
    await showGeneralDialog<void>(
      context: navContext,
      barrierDismissible: false,
      barrierLabel: 'Announcement',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (dialogContext, _, __) => AnnouncementBanner(
        announcement: announcement,
        onDone: () => Navigator.of(dialogContext).pop(),
      ),
      transitionBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween(begin: const Offset(0, -0.25), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: FadeTransition(opacity: animation, child: child),
      ),
    );
    _showing = false;
    try {
      await ApiService.openAnnouncement(token, announcement['id'] as int); // marks it seen
      await _notes?.refresh();
    } catch (_) {}
    // Another one waiting?
    if (mounted) await _check();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// The pop-up banner for one announcement.
class AnnouncementBanner extends StatelessWidget {
  final Map<String, dynamic> announcement;
  final VoidCallback onDone;
  const AnnouncementBanner({super.key, required this.announcement, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final important = announcement['kind'] == 'important';
    final accent = important ? AppTheme.danger : AppTheme.accentDeep;
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Material(
              key: const Key('announcement-banner'),
              color: AppColors.sheet(context),
              elevation: 12,
              shadowColor: Colors.black38,
              borderRadius: BorderRadius.circular(22),
              clipBehavior: Clip.antiAlias,
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                  decoration: BoxDecoration(
                    gradient: important
                        ? const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFF97316)])
                        : AppTheme.brandGradient,
                  ),
                  child: Row(children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(12)),
                      child: Icon(important ? Icons.priority_high_rounded : Icons.campaign_rounded,
                          color: accent, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(important ? 'IMPORTANT · FROM FINDFOOD' : 'FROM FINDFOOD',
                            style: TextStyle(
                                color: important ? Colors.white : Colors.black87,
                                fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                        Text(_when(announcement['created_at']),
                            style: TextStyle(color: important ? Colors.white70 : Colors.black54, fontSize: 12)),
                      ]),
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
                  child: Text('${announcement['title']}',
                      style: TextStyle(color: AppColors.textPrimary(context), fontSize: 20,
                          fontWeight: FontWeight.w800, height: 1.25)),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                    child: Text('${announcement['body']}',
                        style: TextStyle(color: AppColors.textSecondary(context), fontSize: 15, height: 1.5)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: FilledButton(
                    key: const Key('announcement-got-it'),
                    onPressed: onDone,
                    style: FilledButton.styleFrom(
                      backgroundColor: important ? AppTheme.danger : AppTheme.accent,
                      foregroundColor: important ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// /announcements/:id: the whole announcement (from a notification or a push).
class AnnouncementScreen extends StatefulWidget {
  final int announcementId;
  const AnnouncementScreen({super.key, required this.announcementId});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  Map<String, dynamic>? _announcement;
  String? _error;

  @override
  void initState() {
    super.initState();
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    ApiService.openAnnouncement(token, widget.announcementId).then((a) {
      if (!mounted) return;
      setState(() => _announcement = a);
      context.read<NotificationsProvider?>()?.refresh();
    }).catchError((Object e) {
      if (mounted) setState(() => _error = "This announcement isn't available.");
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = _announcement;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/notifications'),
        ),
        title: const Text('Announcement'),
      ),
      body: a == null
          ? Center(
              child: _error != null
                  ? Text(_error!, style: TextStyle(color: AppColors.textSecondary(context)))
                  : const CircularProgressIndicator(color: AppTheme.accent))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(children: [
                  Icon(a['kind'] == 'important' ? Icons.priority_high_rounded : Icons.campaign_rounded,
                      color: a['kind'] == 'important' ? AppTheme.danger : AppColors.accentText(context)),
                  const SizedBox(width: 8),
                  Text(a['kind'] == 'important' ? 'Important · from FindFood' : 'From FindFood',
                      style: TextStyle(color: AppColors.textSecondary(context), fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text(_when(a['created_at']), style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12)),
                ]),
                const SizedBox(height: 14),
                Text('${a['title']}',
                    key: const Key('announcement-title'),
                    style: TextStyle(color: AppColors.textPrimary(context), fontSize: 26,
                        fontWeight: FontWeight.w800, height: 1.2)),
                const SizedBox(height: 12),
                Text('${a['body']}',
                    style: TextStyle(color: AppColors.textPrimary(context), fontSize: 16, height: 1.55)),
              ],
            ),
    );
  }
}

/// An older announcement (sent before announcements had their own page):
/// shown in full from the notification itself.
Future<void> showAnnouncementFromNotification(BuildContext context, AppNotification note) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Announcement',
    barrierColor: Colors.black54,
    pageBuilder: (dialogContext, _, __) => AnnouncementBanner(
      announcement: {
        'title': note.title,
        'body': note.body ?? '',
        'kind': 'news',
        'created_at': note.createdAt.toUtc().toIso8601String(),
      },
      onDone: () => Navigator.of(dialogContext).pop(),
    ),
  );
}
