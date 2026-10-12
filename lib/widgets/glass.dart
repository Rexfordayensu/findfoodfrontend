import 'dart:ui' show ImageFilter;

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

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding,
    this.blur = 22,
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
              border: Border.all(color: AppColors.glassBorder(context)),
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

/// Floating frosted bottom navigation, optionally with a raised centre
/// action button (e.g. the customer's cart).
class GlassNavBar extends StatelessWidget {
  final List<GlassNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final IconData? centerIcon;
  final String? centerTooltip;
  final VoidCallback? onCenterTap;
  final int centerBadge;

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

  @override
  Widget build(BuildContext context) {
    final hasCenter = centerIcon != null;
    final half = (items.length / 2).ceil();
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (hasCenter && i == half) {
        children.add(_CenterAction(
          icon: centerIcon!,
          tooltip: centerTooltip,
          badge: centerBadge,
          onTap: onCenterTap,
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

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
        child: SizedBox(
          height: 70,
          child: GlassPanel(
            borderRadius: BorderRadius.circular(26),
            blur: 28,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(children: children),
          ),
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
    final activeColor = dark ? AppTheme.accent : const Color(0xFF0F172A);
    final color = selected ? activeColor : AppColors.textHint(context);
    final icon = Icon(selected ? item.activeIcon : item.icon, color: color, size: 23);
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkResponse(
        onTap: onTap,
        radius: 34,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.accent.withValues(alpha: dark ? 0.16 : 0.28)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: item.badge > 0
                  ? Badge(
                      label: Text('${item.badge}'),
                      backgroundColor: AppTheme.danger,
                      child: icon,
                    )
                  : icon,
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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
    Widget button = Container(
      width: 54,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: AppTheme.brandGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentDeep.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Icon(icon, color: Colors.black, size: 24),
        ),
      ),
    );
    if (badge > 0) {
      button = Badge(
        label: Text('$badge'),
        backgroundColor: AppTheme.danger,
        offset: const Offset(-2, 2),
        child: button,
      );
    }
    return Semantics(
      button: true,
      label: tooltip,
      child: tooltip == null ? button : Tooltip(message: tooltip!, child: button),
    );
  }
}
