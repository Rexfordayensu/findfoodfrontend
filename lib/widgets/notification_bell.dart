import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/notifications_provider.dart';
import '../theme.dart';

/// The bell in every header: a round button with the unread count on it.
/// Opens the notification centre. Hidden when there is no signed-in session.
class NotificationBell extends StatelessWidget {
  final double size;
  const NotificationBell({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NotificationsProvider?>();
    if (notes == null) return const SizedBox.shrink();
    final unread = notes.unread;
    final label = unread == 0
        ? 'Notifications'
        : 'Notifications, $unread unread';
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: 'Notifications',
        // The badge sits outside the button so the button's shape and ink
        // never clip or tint it.
        child: Stack(key: const Key('notification-bell'), clipBehavior: Clip.none, children: [
          Material(
            // Solid, even on glass screens, so the bell never looks faded.
            color: AppColors.sheet(context),
            elevation: 0,
            shape: CircleBorder(side: BorderSide(color: AppColors.border(context))),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => context.push('/notifications'),
              child: SizedBox(
                width: size,
                height: size,
                child: Center(
                  child: Icon(
                    unread > 0 ? Icons.notifications_rounded : Icons.notifications_none_rounded,
                    size: size * 0.52,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -4,
            right: -4,
            child: IgnorePointer(child: CountBadge(count: unread)),
          ),
        ]),
      ),
    );
  }
}

/// A red count pill ("3", "99+") that pops in when the number changes.
class CountBadge extends StatelessWidget {
  final int count;
  const CountBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutBack,
      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
      child: count <= 0
          ? const SizedBox.shrink(key: ValueKey(0))
          : Container(
              key: ValueKey(count),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.danger,
                borderRadius: BorderRadius.circular(10),
                // A solid ring (never the see-through page colour of glass
                // screens) keeps it crisp on any background.
                border: Border.all(color: AppColors.sheet(context), width: 2),
                boxShadow: const [
                  BoxShadow(color: Color(0x40EF4444), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                key: const Key('notification-count'),
                textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false, applyHeightToLastDescent: false),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  height: 1.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
    );
  }
}
