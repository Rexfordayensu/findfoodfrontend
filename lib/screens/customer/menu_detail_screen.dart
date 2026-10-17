import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../widgets/share_restaurant.dart';
import '../../widgets/glass.dart';
import '../../widgets/promotion_card.dart';
import '../../widgets/reviews.dart';
import '../../utils/friendly_error.dart';
import '../../widgets/error_view.dart';

String? _uploadedImageUrl(String? imageUrl) {
  if (imageUrl == null || imageUrl.trim().isEmpty) return null;
  final url = imageUrl.trim();
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  final baseUrl = ApiService.baseUrl.endsWith('/')
      ? ApiService.baseUrl.substring(0, ApiService.baseUrl.length - 1)
      : ApiService.baseUrl;
  final imagePath = url.startsWith('/') ? url : '/$url';
  return '$baseUrl$imagePath';
}

class MenuDetailScreen extends StatefulWidget {
  final Restaurant restaurant;
  const MenuDetailScreen({super.key, required this.restaurant});

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  List<MenuItem> _menu = [];
  List<Promotion> _promotions = [];
  List<Review> _reviews = [];
  bool _reviewsLoading = true;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    _loadPromotions();
    _loadReviews();
    try {
      final items = await ApiService.getMenu(widget.restaurant.id);
      if (!mounted) return;
      setState(() => _menu = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await ApiService.getRestaurantReviews(widget.restaurant.id);
      if (mounted) setState(() => _reviews = reviews);
    } catch (_) {
      // Reviews are extra; the menu still works without them.
    } finally {
      if (mounted) setState(() => _reviewsLoading = false);
    }
  }

  Future<void> _loadPromotions() async {
    try {
      final promotions = await ApiService.getPromotions(widget.restaurant.id);
      if (mounted) setState(() => _promotions = promotions);
    } catch (_) {
      // Promotions are optional; the menu still works without them.
    }
  }

  void _addToCart(MenuItem item) {
    if (!widget.restaurant.isOpen) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.danger,
        content: Text('${widget.restaurant.name} is closed right now.',
            style: const TextStyle(color: Colors.white)),
      ));
      return;
    }
    final cart = Provider.of<CartProvider>(context, listen: false);
    if (cart.restaurantId != null &&
        cart.restaurantId != widget.restaurant.id &&
        cart.items.isNotEmpty) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.card(dialogContext),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Start new cart?',
              style: TextStyle(
                  color: AppColors.textPrimary(dialogContext),
                  fontWeight: FontWeight.w700)),
          content: Text(
            'Your cart has items from ${cart.restaurantName}. '
            'Adding from ${widget.restaurant.name} will clear it.',
            style: TextStyle(color: AppColors.textSecondary(dialogContext)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel',
                  style: TextStyle(color: AppColors.textHint(dialogContext))),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                cart.addItem(
                  item,
                  widget.restaurant.id,
                  widget.restaurant.name,
                  restaurantAddress: widget.restaurant.address,
                );
                _showAddedSnack(item.name);
              },
              child: Text('Clear & add',
                  style: TextStyle(color: AppColors.accentText(dialogContext), fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
      return;
    }
    cart.addItem(
      item,
      widget.restaurant.id,
      widget.restaurant.name,
      restaurantAddress: widget.restaurant.address,
    );
    _showAddedSnack(item.name);
  }

  void _showAddedSnack(String name) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppTheme.success,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 1),
      content: Row(
        children: [
          const Icon(Icons.shopping_basket_rounded,
              color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text('$name added to basket',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final r = widget.restaurant;
    final bg = AppColors.bg(context);
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    final textHint = AppColors.textHint(context);
    final border = AppColors.border(context);
    final restaurantImageUrl = _uploadedImageUrl(r.bannerUrl ?? r.imageUrl);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // ── Hero image app bar ─────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.bg(context),
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
            actions: [
              ShareRestaurantButton(restaurantId: widget.restaurant.id, name: widget.restaurant.name),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => context.go('/cart'),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shopping_basket_rounded,
                            color: Colors.white, size: 20),
                      ),
                      if (cart.itemCount > 0)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                                color: AppTheme.accent, shape: BoxShape.circle),
                            child: Center(
                              child: Text('${cart.itemCount}',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (restaurantImageUrl != null)
                    Image.network(
                      ApiService.sizedImage(restaurantImageUrl, width: 1200),
                      fit: BoxFit.cover,
                      key: ValueKey(r.id),
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surface(context),
                        child: const Icon(
                          Icons.restaurant_rounded,
                          size: 64,
                          color: AppTheme.accent,
                        ),
                      ),
                    )
                  else
                    Container(
                      color: AppColors.surface(context),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        size: 64,
                        color: AppTheme.accent,
                      ),
                    ),
                  // Gradient overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Restaurant info ────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: bg,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(r.name,
                            style: TextStyle(
                                color: textPri,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: r.isActive
                              ? AppTheme.success.withValues(alpha: 0.12)
                              : AppColors.surface(context),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: r.isActive
                                ? AppTheme.success.withValues(alpha: 0.4)
                                : border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: r.isActive ? AppTheme.success : textHint,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              r.isActive ? 'Open now' : 'Closed',
                              style: TextStyle(
                                color: r.isActive ? AppTheme.success : textHint,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(r.cuisineType,
                      style: TextStyle(color: textSec, fontSize: 14)),
                  if (!r.isOpen) ...[
                    const SizedBox(height: 10),
                    Container(
                      key: const Key('restaurant-closed-banner'),
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                          'Closed right now — you can browse the menu, but ordering is paused.',
                          style: TextStyle(
                              color: AppTheme.danger,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Stats row
                  Row(
                    children: [
                      _statChip(Icons.star_rounded,
                          widget.restaurant.ratingLabel, AppTheme.accent),
                      const SizedBox(width: 10),
                      _statChip(
                          Icons.access_time_rounded, '25–35 min', textHint),
                      const SizedBox(width: 10),
                      // A long address shortens with "…" instead of overflowing.
                      Flexible(
                        child: _statChip(Icons.location_on_outlined, r.address,
                            textHint,
                            shrink: true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (widget.restaurant.deliveryLabel != null)
                        _tag(
                            widget.restaurant.deliveryLabel!,
                            widget.restaurant.deliveryFeeFrom == 0
                                ? AppTheme.success
                                : AppTheme.accentDeep),
                      _tag('Avg 25 min', AppTheme.accent),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_promotions.isNotEmpty) ...[
                    PromotionCarousel(
                      title: 'Current offers',
                      promotions: _promotions,
                      showRestaurant: false,
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Divider(color: border, height: 1),
                  const SizedBox(height: 4),

                  // Menu title
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Menu',
                            style: TextStyle(
                                color: textPri,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.touch_app_rounded,
                              size: 16, color: AppTheme.accentDeep),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text('Tap a dish or "Add" to put it in your basket',
                                key: const Key('menu-add-hint'),
                                style: TextStyle(
                                    color: AppColors.textSecondary(context),
                                    fontSize: 13)),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Menu items ────────────────────────────────────
          if (_loading)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppTheme.accent),
                    const SizedBox(height: 14),
                    Text('Loading menu...', style: TextStyle(color: textSec)),
                  ],
                ),
              ),
            )
          else if (_error.isNotEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: ErrorView(error: _error, onRetry: _load),
            )
          else if (_menu.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.no_food_outlined, size: 56, color: textHint),
                    const SizedBox(height: 16),
                    Text('No items yet',
                        style: TextStyle(
                            color: textPri,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text("This restaurant hasn't added menu items.",
                        style: TextStyle(color: textSec)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _MenuItemCard(
                    item: _menu[i],
                    onAdd: () => _addToCart(_menu[i]),
                  ),
                  childCount: _menu.length,
                ),
              ),
            ),
          if (!_loading && _error.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              sliver: SliverToBoxAdapter(
                child: ReviewsSection(
                    reviews: _reviews, loading: _reviewsLoading),
              ),
            ),
        ],
      ),

      // ── Floating basket bar ────────────────────────────────
      bottomNavigationBar: cart.items.isNotEmpty
          ? Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 8, 16, GlassNavBar.bottomGap(context)),
              child: Material(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(18),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  key: const Key('view-basket'),
                  onTap: () => context.push('/cart'),
                  child: SizedBox(
                    height: 58,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Text('${cart.itemCount}',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('View basket',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16)),
                          ),
                          Text(cart.displayTotal,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _statChip(IconData icon, String label, Color color,
      {bool shrink = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        shrink
            ? Flexible(
                child: Text(label,
                    style: TextStyle(color: color, fontSize: 12),
                    overflow: TextOverflow.ellipsis))
            : Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

// ─── MENU ITEM CARD ──────────────────────────────────────────────────────────
/// Text on the left, photo on the right with the add control resting on its
/// corner. The quantity comes from the cart, so it stays right after visiting
/// the basket or when an add is refused.
class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onAdd;
  const _MenuItemCard({required this.item, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final qty = cart.restaurantId == item.restaurantId
        ? cart.items
                .where((line) => line.menuItem.id == item.id)
                .firstOrNull
                ?.quantity ??
            0
        : 0;
    final textPri = AppColors.textPrimary(context);
    final textSec = AppColors.textSecondary(context);
    final soldOut = !item.isAvailable;
    final inBasket = qty > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.card(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: inBasket
                ? AppTheme.accent.withValues(alpha: 0.7)
                : AppColors.border(context),
            width: inBasket ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('menu-item-${item.id}'),
          // Tapping anywhere on the dish adds it.
          onTap: soldOut ? null : onAdd,
          child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2, right: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_capitalised(item.name),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: soldOut ? textSec : textPri,
                          fontSize: 16,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2)),
                  if (item.description?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(item.description!.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textSec, fontSize: 13, height: 1.4)),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(item.displayPrice,
                          style: TextStyle(
                              color: soldOut ? textSec : textPri,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                      if (soldOut) ...[
                        const SizedBox(width: 8),
                        Text('· Sold out',
                            style: TextStyle(
                                color: textSec,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                  if (inBasket) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 15, color: AppTheme.success),
                      const SizedBox(width: 5),
                      Text('$qty in your basket',
                          style: const TextStyle(
                              color: AppTheme.success,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700)),
                    ]),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(
            width: 112,
            height: 112 + _AddControl.height / 2,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 112,
                    height: 112,
                    child: Opacity(
                      opacity: soldOut ? 0.45 : 1,
                      child: _MenuPhoto(url: _uploadedImageUrl(item.imageUrl)),
                    ),
                  ),
                ),
                if (!soldOut)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Center(
                      child: _AddControl(
                      quantity: qty,
                      onAdd: onAdd,
                      onRemove: () => context.read<CartProvider>().decreaseItem(item.id),
                      itemName: item.name,
                    ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
          ),
        ),
      ),
    );
  }

  /// Menus are typed by restaurants; show "waakye and salad" as
  /// "Waakye and salad" without changing the rest.
  static String _capitalised(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }
}

class _MenuPhoto extends StatelessWidget {
  final String? url;
  const _MenuPhoto({required this.url});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColors.surface(context),
      alignment: Alignment.center,
      child: Icon(Icons.restaurant_rounded,
          size: 28, color: AppColors.textHint(context)),
    );
    if (url == null) return placeholder;
    // Fill the square and crop, whatever shape the restaurant's photo is.
    return SizedBox.expand(
      child: Image.network(
        ApiService.sizedImage(url!, width: 400),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => placeholder,
        frameBuilder: (_, child, frame, sync) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          layoutBuilder: (current, previous) => Stack(
            fit: StackFit.expand,
            children: [...previous, if (current != null) current],
          ),
          child: sync || frame != null ? child : placeholder,
        ),
      ),
    );
  }
}

/// One yellow pill, the same size either way: "+ Add", then "− 1 +" once
/// the dish is in the basket.
class _AddControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final String itemName;

  static const width = 100.0;
  static const height = 38.0;

  const _AddControl({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    required this.itemName,
  });

  @override
  Widget build(BuildContext context) {
    Widget tapArea(IconData icon, String label, VoidCallback onTap, {Key? key}) => Tooltip(
          message: label,
          child: InkResponse(
            key: key,
            onTap: onTap,
            radius: 18,
            child: SizedBox(
              width: 34,
              height: height,
              child: Icon(icon, size: 19, color: Colors.black),
            ),
          ),
        );

    return Material(
      color: AppTheme.accent,
      shape: StadiumBorder(
        side: BorderSide(color: AppColors.card(context), width: 2),
      ),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: width,
        height: height,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: quantity == 0
              ? InkWell(
                  key: Key('menu-add-$itemName'),
                  onTap: onAdd,
                  child: Semantics(
                    button: true,
                    label: 'Add $itemName',
                    excludeSemantics: true,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded, size: 19, color: Colors.black),
                        SizedBox(width: 4),
                        Text('Add',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                )
              : Row(
                  key: const ValueKey('stepper'),
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    tapArea(
                        quantity == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
                        quantity == 1 ? 'Remove $itemName' : 'One less',
                        onRemove),
                    Text('$quantity',
                        style: const TextStyle(
                            color: Colors.black, fontSize: 15, fontWeight: FontWeight.w800)),
                    tapArea(Icons.add_rounded, 'One more', onAdd),
                  ],
                ),
        ),
      ),
    );
  }
}
