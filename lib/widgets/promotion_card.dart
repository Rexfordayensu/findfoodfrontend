import 'dart:async';

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
                  ApiService.sizedImage(url, width: 900),
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

/// Promotion cards that slide to the next offer on their own.
///
/// Auto-advance pauses while the user touches or swipes the carousel, and is
/// off when there is a single promotion or the device asks for reduced motion.
class PromotionCarousel extends StatefulWidget {
  /// Time each promotion stays on screen. Tests may set this to null.
  static Duration? autoAdvanceEvery = const Duration(seconds: 4);

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
  State<PromotionCarousel> createState() => _PromotionCarouselState();
}

class _PromotionCarouselState extends State<PromotionCarousel> {
  static const _slideDuration = Duration(milliseconds: 600);
  static const _resumeAfterTouch = Duration(seconds: 6);

  PageController? _controller;
  double? _viewportFraction;
  Timer? _timer;
  Timer? _resumeTimer;
  int _page = 0;
  bool _showingEnd = false;

  int get _count => widget.promotions.length;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant PromotionCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_page >= _count) _page = 0;
    _restartTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _resumeTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  bool get _canAutoAdvance =>
      _count > 1 &&
      PromotionCarousel.autoAdvanceEvery != null &&
      !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);

  void _restartTimer() {
    _timer?.cancel();
    if (!_canAutoAdvance) return;
    _timer = Timer.periodic(PromotionCarousel.autoAdvanceEvery!, (_) => _next());
  }

  bool _atEnd(PageController controller) {
    final position = controller.position;
    return position.pixels >= position.maxScrollExtent - 1;
  }

  void _next() {
    final controller = _controller;
    if (!mounted || controller == null || !controller.hasClients) return;
    final position = controller.position;
    if (position.maxScrollExtent <= 0) return; // every offer is already visible
    // On wide screens several cards fit at once, so the last pages cannot
    // scroll to the front; loop back once the end is reached.
    final target = _atEnd(controller) ? 0 : (_page + 1) % _count;
    controller.animateToPage(target,
        duration: _slideDuration, curve: Curves.easeInOutCubic);
  }

  void _onScroll() {
    final controller = _controller;
    if (controller == null || !controller.hasClients) return;
    final atEnd = _atEnd(controller) && controller.position.maxScrollExtent > 0;
    if (atEnd != _showingEnd) setState(() => _showingEnd = atEnd);
  }

  /// Stop auto-advancing while the user is interacting, then resume.
  void _pauseForUser() {
    _timer?.cancel();
    _resumeTimer?.cancel();
    _resumeTimer = Timer(_resumeAfterTouch, () {
      if (mounted) _restartTimer();
    });
  }

  PageController _controllerFor(double fraction) {
    if (_controller == null || _viewportFraction != fraction) {
      _controller?.dispose();
      _viewportFraction = fraction;
      _controller = PageController(viewportFraction: fraction, initialPage: _page)
        ..addListener(_onScroll);
    }
    return _controller!;
  }

  @override
  Widget build(BuildContext context) {
    if (_count == 0) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: widget.padding,
          child: Row(children: [
            const Icon(Icons.local_offer_rounded,
                color: AppTheme.accent, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(widget.title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 17,
                      fontWeight: FontWeight.w800)),
            ),
            if (_count > 1)
              _PageDots(count: _count, active: _showingEnd ? _count - 1 : _page),
          ]),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: LayoutBuilder(builder: (context, constraints) {
            final available = constraints.maxWidth - widget.padding.horizontal;
            final cardWidth =
                _count == 1 ? available : (available * 0.86).clamp(240.0, 420.0);
            final fraction = ((cardWidth + 12) / constraints.maxWidth).clamp(0.1, 1.0);
            return Listener(
              onPointerDown: (_) => _pauseForUser(),
              child: PageView.builder(
                key: const Key('promotion-carousel'),
                controller: _controllerFor(fraction),
                padEnds: false,
                itemCount: _count,
                onPageChanged: (page) => setState(() => _page = page),
                itemBuilder: (_, i) => Padding(
                  padding: EdgeInsets.only(
                    left: i == 0 ? widget.padding.left : 0,
                    right: 12,
                  ),
                  child: PromotionCard(
                    key: Key('promotion-${widget.promotions[i].id}'),
                    promotion: widget.promotions[i],
                    showRestaurant: widget.showRestaurant,
                    onTap: widget.onTap == null
                        ? null
                        : () => widget.onTap!(widget.promotions[i]),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  final int count;
  final int active;
  const _PageDots({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count.clamp(0, 8), (i) {
        final selected = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(left: 4),
          width: selected ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: selected ? AppTheme.accent : AppColors.border(context),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
