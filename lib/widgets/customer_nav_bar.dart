import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/providers.dart';
import 'glass.dart';

/// The customer's bottom bar: Home, Search, Orders, Profile and the cart in
/// the middle. Slot indexes: 0 Home, 1 Search, 2 Orders, 3 Profile.
class CustomerNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCartTap;

  const CustomerNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassNavBar(
      currentIndex: currentIndex,
      onTap: onTap,
      centerIcon: Icons.shopping_bag_rounded,
      centerTooltip: 'Cart',
      centerBadge: context.watch<CartProvider>().itemCount,
      onCenterTap: onCartTap,
      items: const [
        GlassNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Home'),
        GlassNavItem(
            icon: Icons.search_rounded,
            activeIcon: Icons.search_rounded,
            label: 'Search'),
        GlassNavItem(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            label: 'Orders'),
        GlassNavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Profile'),
      ],
    );
  }
}
