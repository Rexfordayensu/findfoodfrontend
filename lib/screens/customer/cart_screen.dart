import 'dart:async';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../services/order_payment.dart';
import '../../utils/friendly_error.dart';
import '../../widgets/platform_banner.dart';


class CartScreen extends StatefulWidget {
  const CartScreen({super.key, this.paymentReference});

  final String? paymentReference;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  /// FindFood credit, taken off what the customer pays.
  int _credit = 0;

  Future<void> _loadCredit() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    final credit = await OrderPayment.creditBalance(token);
    if (mounted && credit != _credit) setState(() => _credit = credit);
  }

  /// The delivery fee quoted for this restaurant and address (null while
  /// loading or if it couldn't be fetched).
  int? _deliveryFee;
  double? _deliveryKm;
  String? _quoteMode;
  int _quoteRequest = 0;

  Future<void> _loadDeliveryQuote() async {
    final restaurantId = context.read<CartProvider>().restaurantId;
    if (restaurantId == null) return;
    final request = ++_quoteRequest;
    try {
      final quote = await ApiService.getDeliveryQuote(restaurantId,
          latitude: _deliveryLatitude, longitude: _deliveryLongitude);
      if (!mounted || request != _quoteRequest) return;
      setState(() {
        _deliveryFee = (quote['fee'] as num?)?.toInt() ?? 0;
        _deliveryKm = (quote['distance_km'] as num?)?.toDouble();
        _quoteMode = quote['mode']?.toString();
      });
      if (_promoCode != null) _applyPromo(quiet: true);
    } catch (_) {
      // The order is priced on the server either way; the total shown then
      // just leaves the fee out.
    }
  }

  /// The restaurant, for its address and map location at pickup (a cart
  /// refilled with "Order again" doesn't carry them).
  Restaurant? _shop;

  Future<void> _loadShop() async {
    final id = context.read<CartProvider>().restaurantId;
    if (id == null) return;
    try {
      final shops = await ApiService.getRestaurants();
      final shop = shops.where((r) => r.id == id).firstOrNull;
      if (mounted && shop != null) setState(() => _shop = shop);
    } catch (_) {}
  }

  /// The phone number from the customer's profile, if they saved one.
  Future<void> _prefillPhone() async {
    final token = context.read<AuthProvider>().token;
    if (token == null || _pickupPhoneController.text.isNotEmpty) return;
    try {
      final me = await ApiService.getCurrentUser(token);
      final phone = me['phone']?.toString() ?? '';
      if (mounted && phone.isNotEmpty && _pickupPhoneController.text.isEmpty) {
        _pickupPhoneController.text = phone;
      }
    } catch (_) {}
  }

  Future<void> _openDirections(String? address) async {
    final shop = _shop;
    final query = shop?.latitude != null && shop?.longitude != null
        ? '${shop!.latitude},${shop.longitude}'
        : '${shop?.name ?? context.read<CartProvider>().restaurantName ?? ''} ${address ?? ''}'.trim();
    await launchUrlString(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
      mode: LaunchMode.externalApplication,
    );
  }

  int get _fee => _isDelivery ? (_deliveryFee ?? 0) : 0;
  int _total(CartProvider cart) => cart.totalAmount + _fee;
  int _toPay(CartProvider cart) =>
      (_total(cart) - _discount - _credit).clamp(0, _total(cart));

  // ── Promo code ──
  final _promoController = TextEditingController();
  bool _promoOpen = false, _checkingPromo = false;
  String? _promoCode, _promoMessage, _promoError;
  int _discount = 0;

  Future<void> _applyPromo({bool quiet = false}) async {
    final cart = context.read<CartProvider>();
    final token = context.read<AuthProvider>().token;
    final code = (_promoCode ?? _promoController.text).trim();
    if (code.isEmpty || cart.restaurantId == null) return;
    if (token == null) {
      setState(() => _promoError = 'Sign in to use a promo code.');
      return;
    }
    setState(() => _checkingPromo = true);
    try {
      final result = await ApiService.checkPromo(token,
          code: code, restaurantId: cart.restaurantId!, subtotal: cart.totalAmount,
          deliveryFee: _fee, delivery: _isDelivery);
      if (!mounted) return;
      setState(() {
        if (result['valid'] == true) {
          _promoCode = '${result['code']}';
          _discount = (result['discount'] as num).toInt();
          _promoMessage = '${result['message']}';
          _promoError = null;
        } else {
          _promoCode = null;
          _discount = 0;
          _promoMessage = null;
          _promoError = quiet ? '$code no longer applies: ${result['message']}' : '${result['message']}';
        }
      });
    } catch (e) {
      if (mounted) setState(() => _promoError = friendlyMessage(e));
    } finally {
      if (mounted) setState(() => _checkingPromo = false);
    }
  }

  void _removePromo() => setState(() {
        _promoCode = null;
        _discount = 0;
        _promoMessage = null;
        _promoError = null;
        _promoController.clear();
      });

  Widget _promoSection() {
    final textSec = AppColors.textSecondary(context);
    if (_promoCode != null) {
      return Container(
        key: const Key('promo-applied'),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.success.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.success.withValues(alpha: 0.35)),
        ),
        child: Row(children: [
          const Icon(Icons.local_offer_rounded, color: AppTheme.success, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$_promoCode applied',
                  style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w800)),
              Text('${_promoMessage ?? ''} · you save ${formatCedis(_discount)}',
                  style: TextStyle(color: textSec, fontSize: 12.5)),
            ]),
          ),
          TextButton(key: const Key('promo-remove'), onPressed: _removePromo, child: const Text('Remove')),
        ]),
      );
    }
    if (!_promoOpen) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          key: const Key('promo-open'),
          onPressed: () => setState(() => _promoOpen = true),
          icon: const Icon(Icons.local_offer_outlined, size: 18),
          label: const Text('Have a promo code?'),
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: TextField(
            key: const Key('promo-field'),
            controller: _promoController,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _applyPromo(),
            decoration: const InputDecoration(
              hintText: 'Promo code',
              prefixIcon: Icon(Icons.local_offer_outlined),
            ),
          ),
        ),
        const SizedBox(width: 10),
        FilledButton(
          key: const Key('promo-apply'),
          onPressed: _checkingPromo ? null : () => _applyPromo(),
          child: _checkingPromo
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Apply'),
        ),
      ]),
      if (_promoError != null)
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 4),
          child: Text(_promoError!, key: const Key('promo-error'),
              style: const TextStyle(color: AppTheme.danger, fontSize: 12.5)),
        ),
    ]);
  }
  bool _isDelivery = true;
  bool _isDetectingLocation = false;
  double? _deliveryLatitude;
  double? _deliveryLongitude;


  final TextEditingController _deliveryAddressController = TextEditingController();
  final TextEditingController _pickupNameController = TextEditingController();
  final TextEditingController _pickupPhoneController = TextEditingController();
  final TextEditingController _kitchenNoteController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _pickupNameController.text =
        context.read<AuthProvider>().name?.trim() ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCredit();
      _loadDeliveryQuote();
      _loadShop();
      _prefillPhone();
    });
    if (widget.paymentReference != null &&
        widget.paymentReference!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _verifyReturnedPayment(widget.paymentReference!.trim());
      });
    }
  }

  @override
  void dispose() {
    _deliveryAddressController.dispose();
    _promoController.dispose();
    _pickupNameController.dispose();
    _pickupPhoneController.dispose();
    _kitchenNoteController.dispose();
    super.dispose();
  }

  Future<void> _detectDeliveryLocation() async {
    setState(() => _isDetectingLocation = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Please enable location services and try again.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission was not granted.');
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _deliveryLatitude = position.latitude;
        _deliveryLongitude = position.longitude;
        _deliveryAddressController.text =
            'Current location (${position.latitude.toStringAsFixed(6)}, '
            '${position.longitude.toStringAsFixed(6)})';
      });
      _showCheckoutMessage('Current location added as your delivery address.');
      _loadDeliveryQuote();
    } catch (error) {
      if (!mounted) return;
      _showCheckoutMessage(
        friendlyMessage(error),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isDetectingLocation = false);
    }
  }

  void _showCheckoutMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppTheme.danger : null,
    ));
  }

  Future<void> _verifyReturnedPayment(String reference) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn || auth.token == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verifying your payment...')));

    for (var attempt = 0; attempt < 12; attempt++) {
      try {
        final verification = await ApiService.verifyPayment(
          token: auth.token!,
          reference: reference,
        );
        final status = verification['status']?.toString().toLowerCase();
        if (status == 'success' || status == 'paid' || status == 'completed') {
          final orderId = verification['order_id'];
          final orders = await ApiService.getMyOrders(auth.token!);
          final order = orderId == null
              ? (orders.isNotEmpty ? orders.first : null)
              : orders
                  .where((item) => item.id.toString() == orderId.toString())
                  .firstOrNull;
          if (!mounted) return;
          if (order == null) {
            _showCheckoutMessage(
                'Payment succeeded, but the order was not found.',
                isError: true);
            return;
          }
          context.read<CartProvider>().clearCart();
          context.go('/order-tracking/${order.id}', extra: order);
          return;
        }
      } catch (_) {
        // Retry briefly while Paystack finishes updating the backend.
      }
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return;
    }

    if (mounted) {
      _showCheckoutMessage(
          'Payment is still being confirmed. Please check your orders shortly.',
          isError: true);
    }
  }

  Future<void> _placeOrderAndInitializePayment() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final cart = Provider.of<CartProvider>(context, listen: false);

    if (!auth.isLoggedIn) {
      context.go(Uri(
        path: '/login',
        queryParameters: {'returnTo': Uri(path: '/cart').toString()},
      ).toString());
      return;
    }

    if (cart.restaurantId == null || cart.orderPayload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: AppTheme.danger,
        content: Text('Your cart is empty. Please add items before checkout.',
            style: TextStyle(color: Colors.white)),
      ));
      return;
    }

    final hasDeliveryCoordinates =
        _deliveryLatitude != null && _deliveryLongitude != null;
    if (_isDelivery &&
        _deliveryAddressController.text.trim().isEmpty &&
        !hasDeliveryCoordinates) {
      _showCheckoutMessage(
          'Enter a delivery address or use your current location.',
          isError: true);
      return;
    }
    if (!_isDelivery && _pickupNameController.text.trim().isEmpty) {
      _showCheckoutMessage('Enter the pickup name.', isError: true);
      return;
    }
    if (!_isDelivery && _pickupPhoneController.text.trim().isEmpty) {
      _showCheckoutMessage('Enter a phone number for pickup.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final order = await ApiService.placeOrder(
        token: auth.token!,
        restaurantId: cart.restaurantId!,
        items: cart.orderPayload,
        fulfillmentMethod: _isDelivery ? 'delivery' : 'pickup',


        deliveryAddress: _isDelivery ? _deliveryAddressController.text.trim() : null,
        deliveryLatitude: _isDelivery ? _deliveryLatitude : null,
        deliveryLongitude: _isDelivery ? _deliveryLongitude : null,
        pickupName: !_isDelivery ? _pickupNameController.text.trim() : null,
        pickupPhone: !_isDelivery ? _pickupPhoneController.text.trim() : null,
        kitchenNote: _kitchenNoteController.text.trim().isNotEmpty ? _kitchenNoteController.text.trim() : null,
        promoCode: _promoCode,
      );

      // The order now exists (awaiting payment), so the cart is done with;
      // an unfinished payment can be completed later from Orders.
      cart.clearCart();
      if (!mounted) return;
      final paid = await OrderPayment.start(context, order);
      if (!mounted) return;
      if (paid) {
        context.go('/order-tracking/${order.id}',
            extra: order.copyWith(status: 'pending'));
      } else {
        _showCheckoutMessage(
            'Payment not completed. Your order is saved under Orders - tap "Pay now" to finish.');
        context.go('/orders');
      }
    } catch (e) {
      if (!mounted) return;
      final errorMsg = friendlyMessage(e);
      debugPrint('Checkout error: $errorMsg');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.danger,
        content: Text(errorMsg, style: const TextStyle(color: Colors.white)),
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cart')),
        body: const EmptyState(
          icon: Icons.shopping_bag_outlined,
          title: 'Your cart is empty',
          subtitle: 'Add items from a restaurant to get started.',
        ),
      );
    }

    final itemCount = cart.items.fold<int>(0, (sum, item) => sum + item.quantity);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Checkout'),
            if (cart.restaurantName != null)
              Text(
                cart.restaurantName!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary(context),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _buildCheckoutBar(cart, auth),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Paused, closed, or pickup only: say so, and switch to pickup.
          PlatformStatusBanner(
            padding: const EdgeInsets.only(top: 8),
            onStatus: (status) {
              if (status['delivery_open'] != true && status['ordering_open'] == true && _isDelivery) {
                setState(() => _isDelivery = false);
              }
            },
          ),
          _section(
            'Your order',
            trailing: '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
            child: _card(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < cart.items.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: AppColors.border(context)),
                    _itemRow(cart, cart.items[i]),
                  ],
                ],
              ),
            ),
          ),
          _section(
            "How you'll get it",
            child: _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ModeToggle(
                    isDelivery: _isDelivery,
                    onChanged: (value) {
                      setState(() => _isDelivery = value);
                      if (_promoCode != null) _applyPromo(quiet: true);
                    },
                  ),
                  const SizedBox(height: 18),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: _isDelivery
                        ? _buildDeliveryDetails()
                        : _buildPickupDetails(cart),
                  ),
                ],
              ),
            ),
          ),
          _section(
            'Note for the kitchen',
            child: _card(
              child: TextField(
                controller: _kitchenNoteController,
                maxLines: 2,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Kitchen note (optional)',
                  hintText: 'Allergies, less pepper, extra shito…',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
              ),
            ),
          ),
          _section(
            'Payment',
            child: _card(
              child: Row(
                children: [
                  _iconTile(Icons.lock_outline_rounded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Paystack', style: _strong(15)),
                        const SizedBox(height: 2),
                        Text('Card or mobile money, paid securely',
                            style: _muted(13)),
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle_rounded,
                      size: 20, color: AppColors.textPrimary(context)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: _promoSection(),
          ),
          _section(
            'Summary',
            child: _card(
              child: Column(
                children: [
                  _summaryRow('Subtotal', cart.displayTotal),
                  const SizedBox(height: 10),
                  KeyedSubtree(
                    key: const Key('checkout-delivery-fee'),
                    child: _summaryRow(
                      _isDelivery && _deliveryKm != null
                          ? 'Delivery fee · ${_deliveryKm!.toStringAsFixed(1)} km'
                          : _isDelivery
                              ? 'Delivery fee'
                              : 'Pickup fee',
                      !_isDelivery || _deliveryFee == 0
                          ? 'Free'
                          : _deliveryFee == null
                              ? '…'
                              : formatCedis(_deliveryFee!),
                    ),
                  ),
                  // Distance pricing without the customer's location charges
                  // the highest fee; sharing it gives the real one.
                  if (_isDelivery && _quoteMode == 'no_location') ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tap "Use my current location" above for the exact fee. '
                        "It's usually less.",
                        key: const Key('checkout-location-hint'),
                        style: _muted(12),
                      ),
                    ),
                  ],
                  if (_discount > 0) ...[
                    const SizedBox(height: 10),
                    Row(
                      key: const Key('checkout-discount'),
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Promo $_promoCode', style: _muted(14)),
                        Text('−${formatCedis(_discount)}',
                            style: const TextStyle(
                                color: AppTheme.success, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                  if (_credit > 0) ...[
                    const SizedBox(height: 10),
                    Row(
                      key: const Key('checkout-credit'),
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('FindFood credit', style: _muted(14)),
                        Text('−${formatCedis(_credit.clamp(0, _total(cart) - _discount))}',
                            style: const TextStyle(
                                color: AppTheme.success, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1, color: AppColors.border(context)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_credit > 0 ? 'To pay' : 'Total', style: _strong(16)),
                      Text(formatCedis(_toPay(cart)), style: _strong(16)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Building blocks ────────────────────────────────────────────────

  TextStyle _strong(double size) => TextStyle(
        color: AppColors.textPrimary(context),
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      );

  TextStyle _muted(double size) =>
      TextStyle(color: AppColors.textSecondary(context), fontSize: size, height: 1.35);

  Widget _section(String title, {String? trailing, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
            child: Row(
              children: [
                Expanded(child: Text(title, style: _strong(16))),
                if (trailing != null) Text(trailing, style: _muted(13)),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _card({required Widget child, EdgeInsets padding = const EdgeInsets.all(16)}) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: child,
    );
  }

  Widget _iconTile(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _softFill(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: AppColors.textPrimary(context)),
    );
  }

  Widget _itemRow(CartProvider cart, CartItem item) {
    final provider = context.read<CartProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.menuItem.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _strong(15)),
                const SizedBox(height: 3),
                Text('${item.menuItem.displayPrice} each', style: _muted(13)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _QuantityStepper(
            quantity: item.quantity,
            onDecrease: () => provider.decreaseItem(item.menuItem.id),
            onIncrease: () => provider.addItem(
              item.menuItem,
              cart.restaurantId!,
              cart.restaurantName!,
              restaurantAddress: cart.restaurantAddress,
            ),
          ),
          SizedBox(
            width: 84,
            child: Text(item.displaySubtotal,
                textAlign: TextAlign.right, style: _strong(14)),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: _muted(14)),
        Text(value,
            style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildCheckoutBar(CartProvider cart, AuthProvider auth) {
    final inset = MediaQuery.viewPaddingOf(context).bottom;
    final bottom = inset > 0
        ? inset
        : (kIsWeb && defaultTargetPlatform == TargetPlatform.iOS ? 24.0 : 12.0);
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 16, bottom),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        border: Border(top: BorderSide(color: AppColors.border(context))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!auth.isLoggedIn)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text('Sign in to place your order.', style: _muted(13)),
            ),
          Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_credit > 0 ? 'To pay' : 'Total', style: _muted(12)),
                  const SizedBox(height: 1),
                  Text(formatCedis(_toPay(cart)), style: _strong(19)),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: PrimaryButton(
                  label: auth.isLoggedIn ? 'Place order' : 'Sign in to order',
                  isLoading: _isLoading,
                  onPressed: _placeOrderAndInitializePayment,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetails() {
    return Column(
      key: const ValueKey('delivery'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Delivery address', style: _strong(15)),
        const SizedBox(height: 2),
        Text('Type your address or use where you are now.', style: _muted(13)),
        const SizedBox(height: 12),
        TextField(
          controller: _deliveryAddressController,
          maxLines: 2,
          minLines: 1,
          decoration: const InputDecoration(
            hintText: 'House number, street, landmark',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          onChanged: (_) {
            if (_deliveryLatitude != null || _deliveryLongitude != null) {
              setState(() {
                _deliveryLatitude = null;
                _deliveryLongitude = null;
              });
              _loadDeliveryQuote();
            }
          },
        ),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: _isDetectingLocation ? null : _detectDeliveryLocation,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textPrimary(context),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          ),
          icon: _isDetectingLocation
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location_rounded, size: 18),
          label: Text(
            _isDetectingLocation
                ? 'Finding your location…'
                : 'Use my current location',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildPickupDetails(CartProvider cart) {
    final saved = cart.restaurantAddress?.trim();
    final address = saved?.isNotEmpty == true ? saved : _shop?.address.trim();
    final name = cart.restaurantName ?? _shop?.name ?? 'the restaurant';
    final banner = ApiService.imageUrl(_shop?.bannerUrl);
    final textPri = AppColors.textPrimary(context);
    return Column(
      key: const ValueKey('pickup'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pickup location', style: _strong(15)),
        const SizedBox(height: 10),
        Container(
          key: const Key('pickup-card'),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _softFill(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: banner == null
                      ? Container(
                          color: AppTheme.accent.withValues(alpha: 0.18),
                          child: Icon(Icons.storefront_rounded, color: AppColors.accentText(context)),
                        )
                      : Image.network(ApiService.sizedImage(banner, width: 240), fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                                color: AppTheme.accent.withValues(alpha: 0.18),
                                child: Icon(Icons.storefront_rounded, color: AppColors.accentText(context)),
                              )),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: textPri, fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Row(children: [
                    Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary(context)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        address?.isNotEmpty == true ? address! : 'Finding the address…',
                        key: const Key('pickup-address'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _muted(13),
                      ),
                    ),
                  ]),
                ]),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('pickup-directions'),
                  onPressed: address == null && _shop?.latitude == null
                      ? null
                      : () => _openDirections(address),
                  icon: const Icon(Icons.directions_rounded, size: 18),
                  label: const Text('Directions'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textPri,
                    side: BorderSide(color: AppColors.border(context)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.notifications_active_outlined, size: 16, color: AppTheme.success),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "We'll let you know the moment your order is ready to collect. "
                  'Show your collection code at the counter.',
                  style: _muted(12.5),
                ),
              ),
            ]),
          ]),
        ),
        const SizedBox(height: 18),
        Text("Who's collecting?", style: _strong(15)),
        const SizedBox(height: 10),
        TextField(
          controller: _pickupNameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Pickup name',
            hintText: 'Who is collecting the order',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _pickupPhoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Pickup phone number',
            hintText: 'For collection updates',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
      ],
    );
  }
}

/// Quiet fill for controls that sit inside a card.
Color _softFill(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? const Color(0x12FFFFFF)
        : AppTheme.lightBg;

/// Delivery / pickup switch: a sliding white thumb on a quiet track.
class _ModeToggle extends StatelessWidget {
  final bool isDelivery;
  final ValueChanged<bool> onChanged;

  const _ModeToggle({required this.isDelivery, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _softFill(context),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: isDelivery ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF2B2F3A) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: dark ? 0.3 : 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              _option(context, 'Delivery', Icons.delivery_dining_outlined, true),
              _option(context, 'Pickup', Icons.storefront_outlined, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _option(BuildContext context, String label, IconData icon, bool value) {
    final selected = isDelivery == value;
    final color = selected
        ? AppColors.textPrimary(context)
        : AppColors.textSecondary(context);
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(value),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QuantityStepper({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.textPrimary(context);
    Widget button(IconData icon, String tooltip, VoidCallback onTap) => SizedBox(
          width: 32,
          height: 32,
          child: IconButton(
            tooltip: tooltip,
            padding: EdgeInsets.zero,
            iconSize: 17,
            color: color,
            onPressed: onTap,
            icon: Icon(icon),
          ),
        );
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: _softFill(context),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(quantity == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
              quantity == 1 ? 'Remove' : 'Decrease', onDecrease),
          SizedBox(
            width: 22,
            child: Text('$quantity',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: color, fontSize: 14, fontWeight: FontWeight.w700)),
          ),
          button(Icons.add_rounded, 'Increase', onIncrease),
        ],
      ),
    );
  }
}
