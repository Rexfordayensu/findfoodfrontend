import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme.dart';

/// The one way into an order's chat, so every entry point looks the same.
///
/// [ChatButton] is a compact "Chat" pill for order cards;
/// [ChatButton.wide] is a full-width row for detail screens.
class ChatButton extends StatelessWidget {
  final VoidCallback onPressed;

  /// Who the chat is with, read out by screen readers and shown by
  /// [ChatButton.wide] (e.g. "Mama's Kitchen & your rider").
  final String withWhom;
  final String title;
  final bool _wide;

  const ChatButton({super.key, required this.onPressed, required this.withWhom})
      : title = 'Chat',
        _wide = false;

  const ChatButton.wide({
    super.key,
    required this.onPressed,
    required this.withWhom,
    this.title = 'Chat about this order',
  }) : _wide = true;

  @override
  Widget build(BuildContext context) {
    final fg = AppColors.textPrimary(context);
    final border = BorderSide(color: AppColors.border(context));
    final fill = Theme.of(context).brightness == Brightness.dark
        ? const Color(0x14FFFFFF)
        : AppColors.card(context);

    if (!_wide) {
      return Semantics(
        button: true,
        label: 'Chat with $withWhom',
        excludeSemantics: true,
        child: Material(
          color: fill,
          shape: StadiumBorder(side: border),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 16, color: fg),
                  const SizedBox(width: 6),
                  Text('Chat',
                      style: TextStyle(
                          color: fg, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      label: '$title, $withWhom',
      excludeSemantics: true,
      child: Material(
        color: AppColors.card(context),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), side: border),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.chat_bubble_outline_rounded,
                      size: 20, color: AppColors.accentText(context)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              color: fg,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(withWhom,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Someone the signed-in user can chat with about an order.
class ChatContact {
  final String role; // 'customer', 'restaurant' or 'rider'
  final String name;
  final String description;

  const ChatContact(this.role, this.name, this.description);
}

String chatLocation(int orderId, ChatContact contact) => Uri(
      path: '/chat/$orderId',
      queryParameters: {'with': contact.role, 'name': contact.name},
    ).toString();

/// Opens the private chat with [contacts] (straight away when there is only
/// one person to talk to, otherwise after picking who).
Future<void> openOrderChat(
    BuildContext context, int orderId, List<ChatContact> contacts) async {
  if (contacts.isEmpty) return;
  if (contacts.length == 1) {
    context.push(chatLocation(orderId, contacts.single));
    return;
  }
  final picked = await showModalBottomSheet<ChatContact>(
    context: context,
    backgroundColor: AppColors.card(context),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border(sheetContext),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Chat about order #$orderId',
                style: TextStyle(
                    color: AppColors.textPrimary(sheetContext),
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Each conversation is private between the two of you.',
                style: TextStyle(
                    color: AppColors.textSecondary(sheetContext), fontSize: 13)),
            const SizedBox(height: 12),
            for (final contact in contacts)
              ListTile(
                key: Key('chat-with-${contact.role}'),
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppTheme.accent.withValues(alpha: 0.16),
                  child: Icon(
                    switch (contact.role) {
                      'restaurant' => Icons.storefront_outlined,
                      'rider' => Icons.electric_bike_outlined,
                      _ => Icons.person_outline_rounded,
                    },
                    color: AppColors.accentText(sheetContext),
                    size: 20,
                  ),
                ),
                title: Text(contact.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(contact.description),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(sheetContext).pop(contact),
              ),
          ],
        ),
      ),
    ),
  );
  if (picked != null && context.mounted) {
    context.push(chatLocation(orderId, picked));
  }
}
