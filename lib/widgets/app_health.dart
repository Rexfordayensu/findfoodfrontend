import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/providers.dart';
import '../theme.dart';
import '../utils/friendly_error.dart';
import '../utils/time_format.dart';
import 'account_settings.dart' show SheetHeader, showSettingsSheet, showSettingsMessage;
import 'live_refresh.dart';
import 'widgets.dart';

/// Open crash reports from the app and the server, on the admin overview.
/// Hidden while there are none.
class AppHealthPanel extends StatefulWidget {
  const AppHealthPanel({super.key});

  @override
  State<AppHealthPanel> createState() => _AppHealthPanelState();
}

class _AppHealthPanelState extends State<AppHealthPanel> with LiveRefresh<AppHealthPanel> {
  List<Map<String, dynamic>> _errors = [];

  @override
  void initState() {
    super.initState();
    _load();
    startLiveRefresh(_load);
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    try {
      final errors = await ApiService.getErrorReports(token);
      if (mounted) setState(() => _errors = errors);
    } catch (_) {
      // The overview still works without it.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errors.isEmpty) return const SizedBox.shrink();
    final textPri = AppColors.textPrimary(context);
    final occurrences = _errors.fold<int>(0, (sum, e) => sum + ((e['count'] as num?)?.toInt() ?? 0));
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        key: const Key('app-health'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('App health',
                style: TextStyle(color: textPri, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${_errors.length}',
                  style: const TextStyle(
                      color: AppTheme.danger, fontWeight: FontWeight.w800, fontSize: 12)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('$occurrences crash${occurrences == 1 ? '' : 'es'} reported',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.textHint(context), fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 12),
          for (final error in _errors.take(6)) ...[
            _ErrorTile(error: error, onResolved: _load),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

String _when(Map<String, dynamic> error, String key) {
  final at = DateTime.tryParse('${error[key]}');
  return at == null ? '' : relativeTime(at.toLocal(), DateTime.now());
}

class _ErrorTile extends StatelessWidget {
  final Map<String, dynamic> error;
  final Future<void> Function() onResolved;
  const _ErrorTile({required this.error, required this.onResolved});

  @override
  Widget build(BuildContext context) {
    final server = error['source'] == 'server';
    final count = (error['count'] as num?)?.toInt() ?? 1;
    return Material(
      color: AppColors.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.border(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        key: Key('app-error-${error['id']}'),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppTheme.danger.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(server ? Icons.dns_rounded : Icons.phone_android_rounded,
              color: AppTheme.danger, size: 19),
        ),
        title: Text('${error['error_type']}: ${error['message']}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text(
          [
            server ? 'Server' : 'App',
            '$count×',
            'last ${_when(error, 'last_seen')}',
            if (error['route'] != null) error['route'],
          ].join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () async {
          final fixed = await showSettingsSheet<bool>(context, _ErrorDetails(error: error));
          if (fixed == true) await onResolved();
        },
      ),
    );
  }
}

class _ErrorDetails extends StatefulWidget {
  final Map<String, dynamic> error;
  const _ErrorDetails({required this.error});

  @override
  State<_ErrorDetails> createState() => _ErrorDetailsState();
}

class _ErrorDetailsState extends State<_ErrorDetails> {
  bool _busy = false;

  String get _report {
    final e = widget.error;
    return [
      '${e['error_type']}: ${e['message']}',
      'Where: ${e['source']} ${e['route'] ?? ''}',
      'Seen ${e['count']} times, first ${e['first_seen']}, last ${e['last_seen']}',
      if (e['app_version'] != null) 'App version: ${e['app_version']}',
      if (e['role'] != null) 'Signed in as: ${e['role']}',
      if (e['user_agent'] != null) 'Device: ${e['user_agent']}',
      '',
      '${e['stack'] ?? '(no stack trace)'}',
    ].join('\n');
  }

  Future<void> _resolve() async {
    setState(() => _busy = true);
    try {
      await ApiService.resolveErrorReport(
          context.read<AuthProvider>().token!, widget.error['id'] as int);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      showSettingsMessage(context, "Marked as fixed. It'll reopen if it happens again.");
    } catch (e) {
      if (mounted) showSettingsMessage(context, friendlyMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.error;
    final textSec = AppColors.textSecondary(context);
    Widget fact(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, size: 15, color: textSec),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: TextStyle(color: textSec, fontSize: 13))),
          ]),
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SheetHeader(
          title: '${e['error_type']}',
          subtitle: e['source'] == 'server' ? 'Server error' : 'App crash',
        ),
        Text('${e['message']}',
            style: TextStyle(
                color: AppColors.textPrimary(context), fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        fact(Icons.repeat_rounded,
            'Happened ${e['count']} time${e['count'] == 1 ? '' : 's'} · first ${_when(e, 'first_seen')}, '
            'last ${_when(e, 'last_seen')}'),
        if (e['route'] != null) fact(Icons.route_rounded, '${e['route']}'),
        if (e['role'] != null) fact(Icons.person_outline_rounded, 'Last seen by a ${e['role']}'),
        if (e['app_version'] != null) fact(Icons.tag_rounded, 'App version ${e['app_version']}'),
        if (e['user_agent'] != null) fact(Icons.devices_rounded, '${e['user_agent']}'),
        const SizedBox(height: 8),
        Container(
          key: const Key('app-error-stack'),
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 220),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: SingleChildScrollView(
            child: SelectableText('${e['stack'] ?? 'No stack trace was sent.'}',
                style: TextStyle(
                    color: textSec, fontFamily: 'monospace', fontSize: 11.5, height: 1.45)),
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          key: const Key('app-error-resolve'),
          label: 'Mark as fixed',
          isLoading: _busy,
          onPressed: _busy ? null : _resolve,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: _report));
              if (context.mounted) showSettingsMessage(context, 'Copied the error details.');
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy details'),
          ),
        ),
      ],
    );
  }
}

/// Every app and server error, open or fixed; the admin's Reports tab.
class AppErrorsList extends StatefulWidget {
  const AppErrorsList({super.key});

  @override
  State<AppErrorsList> createState() => _AppErrorsListState();
}

class _AppErrorsListState extends State<AppErrorsList> with LiveRefresh<AppErrorsList> {
  String _status = 'open';
  List<Map<String, dynamic>>? _errors;

  @override
  void initState() {
    super.initState();
    _load();
    startLiveRefresh(_load);
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    final status = _status;
    try {
      final errors = await ApiService.getErrorReports(token, status: status);
      if (mounted && status == _status) setState(() => _errors = errors);
    } catch (_) {
      if (mounted) setState(() => _errors ??= const []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final errors = _errors;
    return Column(
      key: const Key('admin-app-errors'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterChips(
          options: const [('open', 'Open'), ('resolved', 'Fixed'), ('all', 'All')],
          selected: _status,
          onSelected: (value) {
            setState(() {
              _status = value;
              _errors = null;
            });
            _load();
          },
        ),
        const SizedBox(height: 14),
        if (errors == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
          )
        else if (errors.isEmpty)
          EmptyState(
            icon: Icons.health_and_safety_outlined,
            title: _status == 'open' ? 'No app errors' : 'Nothing here',
            subtitle: _status == 'open'
                ? 'Crashes in the app or on the server show up here automatically.'
                : 'No errors with this status.',
          )
        else
          for (final error in errors) ...[
            _ErrorTile(error: error, onResolved: _load),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}
