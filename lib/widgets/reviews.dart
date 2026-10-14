import 'package:flutter/material.dart';

import '../theme.dart';
import '../utils/time_format.dart';

/// "What went wrong?" tags, matching the server's app.ratings.ISSUES.
const restaurantIssueLabels = {
  'wrong_item': 'Wrong item',
  'missing_item': 'Missing item',
  'poor_packaging': 'Poor packaging',
};
const deliveryIssueLabels = {
  'cold_food': 'Arrived cold',
  'late': 'Late delivery',
};

/// A customer review of a restaurant (always from a delivered order).
class Review {
  final int id;
  final int rating;
  final String? comment;
  final List<String> issues;
  final String reviewer;
  final bool verified;
  final DateTime? createdAt;

  const Review({
    required this.id,
    required this.rating,
    required this.reviewer,
    this.comment,
    this.issues = const [],
    this.verified = true,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'],
        rating: json['rating'],
        comment: (json['comment'] as String?)?.trim().isEmpty ?? true
            ? null
            : (json['comment'] as String).trim(),
        issues: [for (final tag in (json['issues'] as List? ?? const [])) '$tag'],
        reviewer: json['reviewer'] ?? 'FindFood customer',
        verified: json['verified'] ?? true,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.tryParse(json['created_at'])?.toLocal(),
      );
}

/// The reviews section on a restaurant's page.
class ReviewsSection extends StatelessWidget {
  final List<Review> reviews;
  final bool loading;

  const ReviewsSection({super.key, required this.reviews, this.loading = false});

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    return Column(
      key: const Key('reviews-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What customers say',
            style: TextStyle(
                color: textPri, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('From people who received an order',
            style: TextStyle(color: textSec, fontSize: 13)),
        const SizedBox(height: 14),
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Column(children: [
              Icon(Icons.rate_review_outlined,
                  color: AppColors.textHint(context), size: 28),
              const SizedBox(height: 8),
              Text('No reviews yet',
                  style: TextStyle(color: textPri, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('Order and be the first to share how it was.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textSec, fontSize: 13)),
            ]),
          )
        else
          for (final review in reviews) ...[
            _ReviewCard(review: review),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    final when = review.createdAt == null
        ? null
        : relativeTime(review.createdAt!, DateTime.now());
    return Container(
      key: Key('review-${review.id}'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.accent.withValues(alpha: 0.16),
              child: Text(review.reviewer[0].toUpperCase(),
                  style: TextStyle(
                      color: AppColors.accentText(context),
                      fontWeight: FontWeight.w800,
                      fontSize: 13)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.reviewer,
                      style: TextStyle(
                          color: textPri,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  if (review.verified)
                    Row(children: [
                      const Icon(Icons.verified_rounded,
                          size: 13, color: AppTheme.success),
                      const SizedBox(width: 4),
                      Text('Verified order',
                          style: TextStyle(color: textSec, fontSize: 12)),
                    ]),
                ],
              ),
            ),
            if (when != null)
              Text(when, style: TextStyle(color: textSec, fontSize: 12)),
          ]),
          const SizedBox(height: 10),
          Semantics(
            label: '${review.rating} out of 5 stars',
            excludeSemantics: true,
            child: Row(children: [
              for (var i = 1; i <= 5; i++)
                Icon(
                  i <= review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 18,
                  color: AppTheme.accent,
                ),
            ]),
          ),
          if (review.comment != null) ...[
            const SizedBox(height: 8),
            Text(review.comment!,
                style: TextStyle(color: textPri, fontSize: 14, height: 1.4)),
          ],
          if (review.issues.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final tag in review.issues)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(restaurantIssueLabels[tag] ?? tag,
                      style: const TextStyle(
                          color: AppTheme.danger,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
            ]),
          ],
        ],
      ),
    );
  }
}
