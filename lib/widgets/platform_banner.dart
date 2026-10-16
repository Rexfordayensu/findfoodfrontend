import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme.dart';

/// Shows why customers can't order right now (paused, closed, pickup
/// only); shows nothing while FindFood is open. [onStatus] gets the status.
class PlatformStatusBanner extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>>? onStatus;
  final EdgeInsets padding;
  const PlatformStatusBanner({super.key, this.onStatus, this.padding = EdgeInsets.zero});

  @override
  State<PlatformStatusBanner> createState() => _PlatformStatusBannerState();
}

class _PlatformStatusBannerState extends State<PlatformStatusBanner> {
  Map<String, dynamic>? _status;

  @override
  void initState() {
    super.initState();
    ApiService.getPlatformStatus().then((status) {
      if (!mounted) return;
      setState(() => _status = status);
      widget.onStatus?.call(status);
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    if (status == null || status['message'] == null) return const SizedBox.shrink();
    final closed = status['ordering_open'] != true;
    final color = closed ? AppTheme.danger : AppTheme.warning;
    return Padding(
      padding: widget.padding,
      child: Container(
        key: const Key('platform-banner'),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(closed ? Icons.pause_circle_rounded : Icons.storefront_rounded, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text('${status['message']}',
                style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w600, height: 1.35)),
          ),
        ]),
      ),
    );
  }
}
