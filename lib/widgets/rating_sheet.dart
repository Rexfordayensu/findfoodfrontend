import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../services/providers.dart';
import '../theme.dart';
import 'account_settings.dart';
import 'reviews.dart';
import 'widgets.dart';
import '../utils/friendly_error.dart';

/// Lets the customer rate a completed order. Resolves to true when submitted.
Future<bool> showRateOrderSheet(BuildContext context, Order order) async {
  final submitted =
      await showSettingsSheet<bool>(context, _RateOrderForm(order: order));
  return submitted ?? false;
}

class _RateOrderForm extends StatefulWidget {
  final Order order;
  const _RateOrderForm({required this.order});

  @override
  State<_RateOrderForm> createState() => _RateOrderFormState();
}

class _RateOrderFormState extends State<_RateOrderForm> {
  int _restaurantRating = 0;
  int _riderRating = 0;
  final _commentCtrl = TextEditingController();
  final Set<String> _issues = {};
  bool _saving = false;

  /// Problems are only asked about when the food was rated 3 stars or less.
  bool get _askWhatWentWrong => _restaurantRating > 0 && _restaurantRating <= 3;

  bool get _hasRider => widget.order.fulfillmentMethod == 'delivery';

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_restaurantRating == 0 || (_hasRider && _riderRating == 0)) {
      showSettingsMessage(context, 'Please choose a star rating.', isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await ApiService.submitRating(
        token: context.read<AuthProvider>().token!,
        orderId: widget.order.id,
        restaurantRating: _restaurantRating,
        riderRating: _hasRider ? _riderRating : null,
        comment: _commentCtrl.text.trim().isEmpty ? null : _commentCtrl.text.trim(),
        issues: _askWhatWentWrong ? _issues.toList() : const [],
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      showSettingsMessage(context, 'Thanks for your feedback!');
    } catch (error) {
      if (mounted) {
        showSettingsMessage(context, friendlyMessage(error),
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _stars(String key, String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600)),
        Row(
          children: List.generate(5, (i) {
            final star = i + 1;
            return IconButton(
              key: Key('$key-$star'),
              onPressed: () => onChanged(star),
              icon: Icon(
                star <= value ? Icons.star_rounded : Icons.star_border_rounded,
                color: AppTheme.accent,
                size: 32,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SheetHeader(
          title: 'Rate order #${widget.order.id}',
          subtitle: widget.order.restaurantName,
        ),
        _stars('rate-restaurant', 'How was the food?', _restaurantRating,
            (v) => setState(() => _restaurantRating = v)),
        if (_askWhatWentWrong) ...[
          Text('What went wrong?',
              style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final entry in {
              ...restaurantIssueLabels,
              if (_hasRider) ...deliveryIssueLabels,
            }.entries)
              FilterChip(
                key: Key('issue-${entry.key}'),
                label: Text(entry.value),
                selected: _issues.contains(entry.key),
                onSelected: (on) => setState(
                    () => on ? _issues.add(entry.key) : _issues.remove(entry.key)),
              ),
          ]),
          const SizedBox(height: 16),
        ],
        if (_hasRider)
          _stars('rate-rider', 'How was the delivery?', _riderRating,
              (v) => setState(() => _riderRating = v)),
        AppTextField(
          key: const Key('rate-comment'),
          controller: _commentCtrl,
          hint: 'Add a comment (optional)',
          prefixIcon: Icons.chat_bubble_outline_rounded,
          maxLines: 3,
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          key: const Key('rate-submit'),
          label: 'Submit rating',
          isLoading: _saving,
          onPressed: _saving ? null : _submit,
        ),
      ],
    );
  }
}
