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

/// Floating pill-shaped bottom navigation in a light, line-icon style. The
/// selected tab sits on a raised pill that slides between tabs; an optional
/// round centre action (e.g. the customer's cart) sits in the middle.
class GlassNavBar extends StatelessWidget {
  final List<GlassNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final IconData? centerIcon;
  final String? centerTooltip;
  final VoidCallback? onCenterTap;
  final int centerBadge;

  static const double _height = 72;

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
    final slots = items.length + (hasCenter ? 1 : 0);
    int slotOf(int i) => hasCenter && i >= half ? i + 1 : i;

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

    final hasSelection = currentIndex >= 0 && currentIndex < items.length;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
        child: SizedBox(
          height: _height,
          child: GlassPanel(
            borderRadius: BorderRadius.circular(_height / 2),
            blur: 28,
            borderColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0x24FFFFFF)
                : const Color(0x14101828),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: LayoutBuilder(builder: (context, constraints) {
              final slotWidth = constraints.maxWidth / slots;
              return Stack(
                children: [
                  if (hasSelection)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      left: slotOf(currentIndex) * slotWidth + 3,
                      width: slotWidth - 6,
                      top: 8,
                      bottom: 8,
                      child: const _SelectionPill(),
                    ),
                  Row(children: children),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// The raised pill behind the selected tab: a bright surface with a soft
/// brand-coloured glow, like a pressed-out key.
class _SelectionPill extends StatelessWidget {
  const _SelectionPill();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF2B2F3A) : Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: AppTheme.accent.withValues(alpha: dark ? 0.30 : 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: dark ? 0.16 : 0.30),
            blurRadius: 16,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.30 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
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
    final color = selected
        ? AppColors.textPrimary(context)
        : AppColors.textSecondary(context);
    final icon = Icon(
      item.icon,
      color: selected ? AppColors.accentText(context) : color,
      size: 23,
    );
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkResponse(
        onTap: onTap,
        radius: 30,
        highlightShape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            item.badge > 0
                ? Badge(
                    label: Text('${item.badge}'),
                    backgroundColor: AppTheme.danger,
                    child: icon,
                  )
                : icon,
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: color,
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: -0.1,
              ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.brandGradient,
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
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Icon(icon, color: const Color(0xFF111111), size: 25),
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
