import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';

import '../theme.dart';

/// Marks a subtree (a dashboard's tab pages) as drawn over a [GlassBackdrop]:
/// page backgrounds become transparent and cards slightly translucent.
class GlassScope extends InheritedWidget {
  const GlassScope({super.key, required super.child});

  static bool isActive(BuildContext context) =>
      context.getInheritedWidgetOfExactType<GlassScope>() != null;

  @override
  bool updateShouldNotify(GlassScope oldWidget) => false;
}

/// Body for a dashboard [Scaffold] that uses `extendBody: true` with a
/// [GlassNavBar]: the backdrop runs behind the floating bar while the content
/// stops above it.
class GlassBody extends StatelessWidget {
  final Widget child;
  const GlassBody({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final theme = Theme.of(context);
    return GlassBackdrop(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: Theme(
            data: theme.copyWith(scaffoldBackgroundColor: Colors.transparent),
            child: GlassScope(child: child),
          ),
        ),
      ),
    );
  }
}

/// Calm backdrop for the main screens: the base colour with two soft,
/// blurred colour glows so frosted panels have something to refract.
class GlassBackdrop extends StatelessWidget {
  final Widget child;
  const GlassBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.baseBg(context)),
      child: Stack(
        children: [
          Positioned(
            top: -140,
            right: -120,
            child: _Glow(
              size: 360,
              color: AppTheme.accent.withValues(alpha: dark ? 0.10 : 0.22),
            ),
          ),
          Positioned(
            top: 260,
            left: -160,
            child: _Glow(
              size: 380,
              color: (dark ? const Color(0xFF6366F1) : const Color(0xFF7DD3FC))
                  .withValues(alpha: dark ? 0.10 : 0.20),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  const _Glow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

/// A frosted-glass surface: blurred backdrop, translucent fill, hairline
/// highlight border and a soft shadow.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final Color? borderColor;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding,
    this.blur = 22,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: AppColors.softShadow(context),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppColors.glass(context),
              borderRadius: borderRadius,
              border: Border.all(color: borderColor ?? AppColors.glassBorder(context)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlassNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badge;

  const GlassNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge = 0,
  });
}

/// Floating pill-shaped bottom navigation with line icons. The selected tab
/// gets a small tinted capsule behind its icon; an optional round centre
/// action (e.g. the customer's cart) sits in the middle.
class GlassNavBar extends StatelessWidget {
  final List<GlassNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final IconData? centerIcon;
  final String? centerTooltip;
  final VoidCallback? onCenterTap;
  final int centerBadge;

  static const double _height = 66;

  const GlassNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.centerIcon,
    this.centerTooltip,
    this.onCenterTap,
    this.centerBadge = 0,
  });

  /// Space below the bar. Flutter web is not told about the iPhone home
  /// indicator (the inset is 0), so leave room for it there explicitly.
  static double bottomGap(BuildContext context) {
    final inset = MediaQuery.viewPaddingOf(context).bottom;
    if (inset > 0) return inset + 4;
    if (kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) return 28;
    return 16;
  }

  @override
  Widget build(BuildContext context) {
    final hasCenter = centerIcon != null;
    final half = (items.length / 2).ceil();

    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (hasCenter && i == half) {
        children.add(Expanded(
          child: Center(
            child: _CenterAction(
              icon: centerIcon!,
              tooltip: centerTooltip,
              badge: centerBadge,
              onTap: onCenterTap,
            ),
          ),
        ));
      }
      children.add(Expanded(
        child: _NavButton(
          item: items[i],
          selected: i == currentIndex,
          onTap: () => onTap(i),
        ),
      ));
    }

    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 6, 16, bottomGap(context)),
      child: SizedBox(
        height: _height,
        child: GlassPanel(
          borderRadius: BorderRadius.circular(_height / 2),
          blur: 28,
          borderColor: dark ? const Color(0x24FFFFFF) : const Color(0x14101828),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(children: children),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final GlassNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = selected
        ? AppColors.textPrimary(context)
        : AppColors.textSecondary(context);
    Widget icon = Icon(
      item.icon,
      color: selected ? AppColors.accentText(context) : color,
      size: 22,
    );
    if (item.badge > 0) {
      icon = Badge(
        label: Text('${item.badge}'),
        backgroundColor: AppTheme.danger,
        child: icon,
      );
    }
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkResponse(
        onTap: onTap,
        radius: 28,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: selected ? 48 : 32,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.accent.withValues(alpha: dark ? 0.16 : 0.22)
                    : AppTheme.accent.withValues(alpha: 0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: icon,
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterAction extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final int badge;
  final VoidCallback? onTap;

  const _CenterAction({required this.icon, this.tooltip, this.badge = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    // A yellow pill like the app's other buttons: the basket icon, and the
    // number of items inside it once there are any.
    final filled = badge > 0;
    final label = tooltip == null
        ? null
        : filled
            ? '$tooltip, $badge item${badge == 1 ? '' : 's'}'
            : tooltip;
    final button = AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      height: 44,
      constraints: BoxConstraints(minWidth: filled ? 72 : 56),
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentDeep.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: const Key('nav-basket'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: const Color(0xFF111111), size: 22),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: filled
                      ? Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(badge > 99 ? '99+' : '$badge',
                              key: const Key('nav-basket-count'),
                              style: const TextStyle(
                                  color: Color(0xFF111111),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800)),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: label == null ? button : Tooltip(message: label, child: button),
    );
  }
}
