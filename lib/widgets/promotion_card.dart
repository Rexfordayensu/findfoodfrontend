import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import '../theme.dart';

/// A banner-style card for a restaurant promotion: the uploaded image with a
/// dark gradient, the discount badge, title and restaurant/description.
/// Falls back to a branded gradient when the image is missing.
class PromotionCard extends StatelessWidget {
  final Promotion promotion;
  final VoidCallback? onTap;
  final Widget? trailing;
  final double height;
  final bool showRestaurant;

  const PromotionCard({
    super.key,
    required this.promotion,
    this.onTap,
    this.trailing,
    this.height = 150,
    this.showRestaurant = true,
  });

  @override
  Widget build(BuildContext context) {
    final url = ApiService.imageUrl(promotion.imageUrl);
    final subtitle = showRestaurant && promotion.restaurantName != null
        ? promotion.restaurantName!
        : promotion.description;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (url == null)
                const _PromotionFallback()
              else
                Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : Container(color: AppColors.surface(context)),
                  errorBuilder: (_, __, ___) => const _PromotionFallback(),
                ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x10000000), Color(0xCC000000)],
                  ),
                ),
              ),
              if (promotion.discountPercent != null &&
                  promotion.discountPercent! > 0)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${promotion.discountPercent}% OFF',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              if (trailing != null)
                Positioned(top: 4, right: 4, child: trailing!),
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(promotion.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800)),
                    if (subtitle != null && subtitle.isNotEmpty)
                      Text(subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xDDFFFFFF), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromotionFallback extends StatelessWidget {
  const _PromotionFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
        ),
      ),
      child: Align(
        alignment: Alignment(0.85, -0.4),
        child: Icon(Icons.local_offer_rounded, color: Color(0x55FFFFFF), size: 64),
      ),
    );
  }
}

/// Horizontally scrolling row of promotion cards with a section title.
class PromotionCarousel extends StatelessWidget {
  final String title;
  final List<Promotion> promotions;
  final ValueChanged<Promotion>? onTap;
  final bool showRestaurant;
  final EdgeInsets padding;

  const PromotionCarousel({
    super.key,
    required this.title,
    required this.promotions,
    this.onTap,
    this.showRestaurant = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    if (promotions.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding,
          child: Row(children: [
            const Icon(Icons.local_offer_rounded,
                color: AppTheme.accent, size: 18),
            const SizedBox(width: 6),
            Text(title,
                style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w800)),
          ]),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: LayoutBuilder(builder: (context, constraints) {
            final width = promotions.length == 1
                ? constraints.maxWidth - padding.horizontal
                : (constraints.maxWidth * 0.82).clamp(240.0, 420.0);
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: padding,
              itemCount: promotions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => SizedBox(
                width: width,
                child: PromotionCard(
                  key: Key('promotion-${promotions[i].id}'),
                  promotion: promotions[i],
                  showRestaurant: showRestaurant,
                  onTap: onTap == null ? null : () => onTap!(promotions[i]),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
