import 'package:flutter/material.dart';

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
  final bool _wide;

  const ChatButton({super.key, required this.onPressed, required this.withWhom})
      : _wide = false;

  const ChatButton.wide(
      {super.key, required this.onPressed, required this.withWhom})
      : _wide = true;

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
      label: 'Chat about this order with $withWhom',
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
                      Text('Chat about this order',
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
