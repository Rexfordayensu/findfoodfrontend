import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';
import '../theme.dart';
import '../utils/friendly_error.dart';

/// Shows a handover code to the person who holds it (the customer's delivery
/// code, the rider's pickup code), with what to do with it.
class HandoffCodeCard extends StatelessWidget {
  final String title;
  final String code;
  final String instructions;
  final IconData icon;

  const HandoffCodeCard({
    super.key,
    required this.title,
    required this.code,
    required this.instructions,
    this.icon = Icons.lock_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    return Semantics(
      label: '$title ${code.split('').join(' ')}. $instructions',
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 18, color: AppColors.textSecondary(context)),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 12),
            Row(
              key: const Key('handoff-code-digits'),
              children: [
                for (final digit in code.split(''))
                  Container(
                    width: 48,
                    height: 56,
                    margin: const EdgeInsets.only(right: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _fill(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(digit,
                        style: TextStyle(
                            color: textPri,
                            fontSize: 28,
                            fontWeight: FontWeight.w800)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(instructions,
                style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 13,
                    height: 1.4)),
          ],
        ),
      ),
    );
  }
}

Color _fill(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? const Color(0x14FFFFFF)
        : AppTheme.lightBg;

/// Asks for a 4-digit handover code and submits it. Returns true once
/// [submit] succeeds; a failure's message (e.g. "1 attempt left") is shown
/// in the sheet so the person can try again.
Future<bool> showHandoffCodeEntry(
  BuildContext context, {
  required String title,
  required String instructions,
  required String actionLabel,
  required Future<void> Function(String code) submit,
  Widget? details,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.sheet(context),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _CodeEntrySheet(
      title: title,
      instructions: instructions,
      actionLabel: actionLabel,
      submit: submit,
      details: details,
    ),
  );
  return result ?? false;
}

class _CodeEntrySheet extends StatefulWidget {
  final String title;
  final String instructions;
  final String actionLabel;
  final Future<void> Function(String code) submit;
  final Widget? details;

  const _CodeEntrySheet({
    required this.title,
    required this.instructions,
    required this.actionLabel,
    required this.submit,
    this.details,
  });

  @override
  State<_CodeEntrySheet> createState() => _CodeEntrySheetState();
}

class _CodeEntrySheetState extends State<_CodeEntrySheet> {
  final _controller = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _controller.text.trim();
    if (code.length != 4) {
      setState(() => _error = 'Enter all 4 digits.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.submit(code);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = friendlyMessage(e);
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          24, 12, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(widget.title,
              style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(widget.instructions,
              style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 14,
                  height: 1.4)),
          if (widget.details != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _fill(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: widget.details,
            ),
          ],
          const SizedBox(height: 20),
          TextField(
            key: const Key('handoff-code-input'),
            controller: _controller,
            autofocus: true,
            enabled: !_busy,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 4,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: 18),
            decoration: InputDecoration(
              counterText: '',
              hintText: '••••',
              errorText: _error,
              errorMaxLines: 3,
            ),
            onChanged: (value) {
              if (_error != null) setState(() => _error = null);
              if (value.length == 4) _submit();
            },
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              key: const Key('handoff-code-submit'),
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.black, strokeWidth: 2.5))
                  : Text(widget.actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

/// What should be in the bag: each dish with its quantity, plus the kitchen
/// note. Shown to the restaurant and the rider so both can check the bag
/// before the pickup code is given.
class PackingList extends StatelessWidget {
  final Order order;
  final bool dense;

  const PackingList({super.key, required this.order, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    final note = order.kitchenNote?.trim();
    final size = dense ? 13.0 : 14.0;
    return Column(
      key: Key('packing-list-${order.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (order.items.isEmpty)
          Text('Items not available', style: TextStyle(color: textSec, fontSize: size))
        else
          for (final line in order.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 30,
                    child: Text('${line.quantity}×',
                        style: TextStyle(
                            color: textPri,
                            fontSize: size,
                            fontWeight: FontWeight.w700)),
                  ),
                  Expanded(
                    child: Text(line.name ?? 'Item #${line.menuItemId}',
                        style: TextStyle(color: textPri, fontSize: size)),
                  ),
                ],
              ),
            ),
        if (note != null && note.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.edit_note_rounded, size: 18, color: textSec),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(note,
                      style: TextStyle(
                          color: textSec,
                          fontSize: size - 1,
                          fontStyle: FontStyle.italic)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
