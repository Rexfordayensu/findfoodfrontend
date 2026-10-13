import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme.dart';
import '../utils/friendly_error.dart';

/// A full-area error state with plain words and the right next step.
///
/// While the server is waking up it shows a calm progress state and calls
/// [onRetry] by itself every few seconds, so people don't have to.
class ErrorView extends StatefulWidget {
  final Object error;
  final Future<void> Function() onRetry;

  const ErrorView({super.key, required this.error, required this.onRetry});

  /// How often to retry while the server is waking. Tests may shorten it.
  static Duration autoRetryEvery = const Duration(seconds: 6);

  @override
  State<ErrorView> createState() => _ErrorViewState();
}

class _ErrorViewState extends State<ErrorView> {
  Timer? _autoRetry;
  bool _retrying = false;

  FriendlyError get _friendly => friendlyError(widget.error);

  @override
  void initState() {
    super.initState();
    _scheduleAutoRetry();
  }

  @override
  void didUpdateWidget(ErrorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleAutoRetry();
  }

  void _scheduleAutoRetry() {
    _autoRetry?.cancel();
    if (_friendly.isWaking) {
      _autoRetry = Timer(ErrorView.autoRetryEvery, _retry);
    }
  }

  Future<void> _retry() async {
    if (_retrying || !mounted) return;
    setState(() => _retrying = true);
    try {
      await widget.onRetry();
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  void dispose() {
    _autoRetry?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendly = _friendly;
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: friendly.isWaking
                    ? const Padding(
                        padding: EdgeInsets.all(22),
                        child: CircularProgressIndicator(
                            strokeWidth: 3, color: AppTheme.accentDeep),
                      )
                    : Icon(friendly.icon,
                        size: 34, color: AppColors.accentText(context)),
              ),
              const SizedBox(height: 20),
              Text(friendly.title,
                  key: const Key('error-title'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: textPri,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3)),
              const SizedBox(height: 8),
              Text(friendly.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textSec, fontSize: 14.5, height: 1.45)),
              const SizedBox(height: 24),
              if (friendly.needsSignIn)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    key: const Key('error-sign-in'),
                    onPressed: () => context.go('/login'),
                    child: const Text('Sign in'),
                  ),
                )
              else if (friendly.isWaking)
                Text(_retrying ? 'Checking…' : 'Retrying automatically',
                    style: TextStyle(color: textSec, fontSize: 13))
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    key: const Key('error-retry'),
                    onPressed: _retrying ? null : _retry,
                    child: _retrying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.black))
                        : const Text('Try again'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
