import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../models/models.dart';
import 'package:url_launcher/url_launcher_string.dart';


class CartScreen extends StatefulWidget {
  const CartScreen({super.key, this.paymentReference});

  final String? paymentReference;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;
  Timer? _paymentVerificationTimer;
  bool _hasNavigatedToTracking = false;
  bool _isDelivery = true;
  bool _isDetectingLocation = false;
  double? _deliveryLatitude;
  double? _deliveryLongitude;


  final TextEditingController _deliveryAddressController = TextEditingController();
  final TextEditingController _pickupNameController = TextEditingController();
  final TextEditingController _pickupPhoneController = TextEditingController();
  final TextEditingController _kitchenNoteController = TextEditingController();


  final List<PaymentProviderOption> _providers = const [
    PaymentProviderOption(value: 'paystack', label: 'Paystack'),
    PaymentProviderOption(value: 'mtn_momo', label: 'MTN Mobile Money'),
  ];


  @override
  void initState() {
    super.initState();
    _pickupNameController.text =
        context.read<AuthProvider>().name?.trim() ?? '';
    if (widget.paymentReference != null &&
        widget.paymentReference!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _verifyReturnedPayment(widget.paymentReference!.trim());
      });
    }
  }

  @override
  void dispose() {
    _paymentVerificationTimer?.cancel();
    _deliveryAddressController.dispose();
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
    } catch (error) {
      if (!mounted) return;
      _showCheckoutMessage(
        error.toString().replaceAll('Exception: ', ''),
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

  void _startPaymentVerification(
      {required String reference, required Order order}) {
    if (_paymentVerificationTimer != null) return;

    _hasNavigatedToTracking = false;
    _paymentVerificationTimer =
        Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted || _hasNavigatedToTracking) return;

      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (!auth.isLoggedIn || auth.token == null) return;

      try {
        final verification = await ApiService.verifyPayment(
          token: auth.token!,
          reference: reference,
        );

        final status = verification['status']?.toString().toLowerCase();
        if (status == 'success') {
          _paymentVerificationTimer?.cancel();
          _paymentVerificationTimer = null;
          if (!mounted) return;

          setState(() => _hasNavigatedToTracking = true);
          context.go('/order-tracking/${order.id}', extra: order);
        }
      } catch (_) {
        // Keep polling until the backend confirms payment success.
      }
    });

    Future.delayed(const Duration(minutes: 2), () {
      if (!mounted || _hasNavigatedToTracking) return;
      _paymentVerificationTimer?.cancel();
      _paymentVerificationTimer = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Payment verification timed out. Please check your order status.')),
      );
    });
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
      );

      final init = await ApiService.initializePayment(
        token: auth.token!,
        orderId: order.id,
        provider: 'paystack',
      );

      if (!mounted) return;

      final authorizationUrl = init['authorization_url'] as String?;
      final reference = init['reference'] as String?;

      if (authorizationUrl == null || reference == null) {
        throw Exception('Invalid payment initialization response.');
      }

      await launchUrlString(
        authorizationUrl,
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: '_self',
      );

      if (!mounted) return;
      _startPaymentVerification(reference: reference, order: order);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Opening checkout for reference $reference...'),
      ));
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString().replaceAll('Exception: ', '');
        debugPrint('Payment initialization error: $errorMsg | Provider: paystack');
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

    return Scaffold(
      appBar: AppBar(
        title: Text(cart.restaurantName ?? 'Cart'),
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Cart items ─────────────────────────────────────────
          const Text('Your order', style: AppText.heading),
          const SizedBox(height: 14),
          ...cart.items.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.menuItem.name, style: AppText.title),
                          const SizedBox(height: 4),
                          Text(item.displaySubtotal,
                              style: AppText.label
                                  .copyWith(color: AppTheme.accent)),
                        ],
                      ),
                    ),
                    // Qty controls
                    Row(
                      children: [
                        _qtyBtn(
                            Icons.remove,
                            () => Provider.of<CartProvider>(context,
                                    listen: false)
                                .decreaseItem(item.menuItem.id)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text('${item.quantity}', style: AppText.title),
                        ),
                        _qtyBtn(
                            Icons.add,
                            () => Provider.of<CartProvider>(context,
                                    listen: false)
                                .addItem(item.menuItem, cart.restaurantId!,
                              cart.restaurantName!,
                              restaurantAddress: cart.restaurantAddress)),
                      ],
                    ),
                  ],
                ),
              )),

          // ── Summary ────────────────────────────────────────────
          const SizedBox(height: 8),
              _buildFulfillmentSelector(cart),
              const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Column(
              children: [
                _summaryRow('Subtotal', cart.displayTotal),
                const SizedBox(height: 8),
                _summaryRow(_isDelivery ? 'Delivery fee' : 'Pickup fee', 'Free'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: AppTheme.darkBorder),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: AppText.title),
                    Text(cart.displayTotal,
                        style: AppText.title.copyWith(color: AppTheme.accent)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          if (_isDelivery)
            _buildDeliveryDetails()
          else
            _buildPickupDetails(cart.restaurantAddress),

          const SizedBox(height: 24),
          const Text('Payment', style: AppText.heading),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline_rounded, color: AppTheme.accent),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Paystack', style: AppText.title),
                    SizedBox(height: 3),
                    Text('Secure online payment', style: AppText.caption),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (!auth.isLoggedIn)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'You need to sign in before placing an order.',
                style: TextStyle(color: AppTheme.warning, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          PrimaryButton(
            label: auth.isLoggedIn
                ? 'Place order · ${cart.displayTotal}'
                : 'Sign in to order',
            isLoading: _isLoading,
            onPressed: _placeOrderAndInitializePayment,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFulfillmentSelector(CartProvider cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fulfillment', style: AppText.title),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(
                value: true,
                label: Text('Delivery'),
                icon: Icon(Icons.delivery_dining_outlined),
              ),
              ButtonSegment<bool>(
                value: false,
                label: Text('Pickup'),
                icon: Icon(Icons.storefront_outlined),
              ),
            ],
            selected: {_isDelivery},
            showSelectedIcon: false,
            onSelectionChanged: (selection) {
              setState(() => _isDelivery = selection.first);
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              _isDelivery ? Icons.location_on_outlined : Icons.store_outlined,
              size: 17,
              color: AppTheme.textSecond,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _isDelivery
                    ? 'Delivered to your address or current location'
                    : 'Collect from ${cart.restaurantName ?? 'the restaurant'}',
                style: AppText.caption.copyWith(color: AppTheme.textSecond),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: Icon(icon, size: 16, color: AppTheme.textPrimary),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppText.body),
        Text(value, style: AppText.label),
      ],
    );
  }

  Widget _buildDeliveryDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Delivery address', style: AppText.title),
          const SizedBox(height: 6),
          const Text('Use your location or enter the address manually.',
              style: AppText.caption),
          const SizedBox(height: 12),
          TextField(
            controller: _deliveryAddressController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Enter delivery address',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            onChanged: (_) {
              if (_deliveryLatitude != null || _deliveryLongitude != null) {
                setState(() {
                  _deliveryLatitude = null;
                  _deliveryLongitude = null;
                });
              }
            },
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _isDetectingLocation ? null : _detectDeliveryLocation,
            icon: _isDetectingLocation
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_rounded),
            label: Text(_isDetectingLocation
                ? 'Detecting location...'
                : 'Use my current location'),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupDetails(String? restaurantAddress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pickup location', style: AppText.title),
          const SizedBox(height: 6),
          Text(
            restaurantAddress?.trim().isNotEmpty == true
                ? restaurantAddress!
                : 'Restaurant address unavailable',
            style: AppText.body,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pickupNameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Pickup name',
              hintText: 'Name of the person collecting the order',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pickupPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Pickup phone number',
              hintText: 'Phone number for collection updates',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _kitchenNoteController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Kitchen note (optional)',
              hintText: 'Special instructions for the restaurant',
              prefixIcon: Icon(Icons.chat_bubble_outline),
            ),
          ),
        ],
      ),
    );
  }
}
class PaymentProviderOption {
  final String value;
  final String label;

  const PaymentProviderOption({
    required this.value,
    required this.label,
  });
}

