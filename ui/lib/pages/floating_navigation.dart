import 'dart:ui';

import 'package:material_ui/material_ui.dart';

class FloatingToolbarItem {
  const FloatingToolbarItem({
    required this.icon,
    this.activeIcon,
    required this.onPressed,
    this.tooltip,
    this.label,
    this.enabled = true,
    this.active = false,
  });

  final IconData icon;
  final IconData? activeIcon;
  final bool Function() onPressed;
  final String? tooltip;
  final String? label;
  final bool enabled;
  final bool active;
}

class FloatingNavigation extends StatefulWidget {
  const FloatingNavigation({
    super.key,
    required this.child,
    required this.items,
    this.customButton,
    this.alignment = Alignment.bottomCenter,
    this.screenOffset = 8,
    this.safeArea = true,
    this.backgroundColor,
    this.foregroundColor,
    this.activeColor,
    this.actionSize = 38,
    this.iconSize = 20,
    this.buttonGap = 4,
    this.elevation = 0,
    this.direction = Axis.horizontal,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
  }) : assert(items.length > 0, '至少需要一个工具栏操作项');

  final Widget child;
  final List<FloatingToolbarItem> items;
  final Widget? customButton;
  final AlignmentGeometry alignment;
  final double screenOffset;
  final bool safeArea;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? activeColor;
  final double actionSize;
  final double iconSize;
  final double buttonGap;
  final double elevation;
  final Axis direction;
  final Duration animationDuration;
  final Curve animationCurve;

  @override
  State<FloatingNavigation> createState() => _FloatingNavigationState();
}

class _FloatingNavigationState extends State<FloatingNavigation> {
  FloatingToolbarItem? _activeItem;

  @override
  void initState() {
    super.initState();
    _assertSingleActive();
    _activeItem = _findInitialActive();
  }

  @override
  void didUpdateWidget(covariant FloatingNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _assertSingleActive();
      _activeItem = _findInitialActive();
    }
  }

  void _assertSingleActive() {
    assert(
      widget.items.where((item) => item.active).length <= 1,
      '只能有一个子项是激活状态',
    );
  }

  FloatingToolbarItem? _findInitialActive() {
    for (final item in widget.items) {
      if (item.active) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final systemPadding = MediaQuery.of(context).padding;
    final isVertical = widget.direction == .vertical;

    final padding = EdgeInsets.only(
      left: widget.screenOffset + (widget.safeArea ? systemPadding.left : 0),
      right: widget.screenOffset + (widget.safeArea ? systemPadding.right : 0),
      top: widget.screenOffset + (widget.safeArea ? systemPadding.top : 0),
      bottom:
          widget.screenOffset + (widget.safeArea ? systemPadding.bottom : 0),
    );

    return Stack(
      fit: .expand,
      children: [
        Positioned.fill(child: widget.child),
        Align(
          alignment: widget.alignment,
          child: Padding(
            padding: padding,
            child: Flex(
              direction: widget.direction,
              mainAxisSize: .min,
              children: [
                _buildToolbar(colorScheme, isVertical),
                if (widget.customButton != null) ...[
                  SizedBox(
                    width: isVertical ? 0 : widget.buttonGap,
                    height: isVertical ? widget.buttonGap : 0,
                  ),
                  widget.customButton!,
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar(ColorScheme colorScheme, bool isVertical) {
    return Material(
      color: widget.backgroundColor ?? colorScheme.onPrimary,
      elevation: widget.elevation,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.50),
      borderRadius: const BorderRadius.all(Radius.circular(0)),
      clipBehavior: .antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Flex(
          spacing: 0,
          direction: isVertical ? .vertical : .horizontal,
          mainAxisSize: .min,
          children: [
            for (final item in widget.items) _buildAction(item, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(FloatingToolbarItem item, ColorScheme colorScheme) {
    final semanticLabel = item.label ?? item.tooltip;
    final isActive = _activeItem == item;

    final iconColor = !item.enabled
        ? colorScheme.onSurface.withValues(alpha: 0.38)
        : isActive
        ? widget.foregroundColor ?? colorScheme.onPrimary
        : widget.foregroundColor ?? colorScheme.onSurface;

    Widget button = Semantics(
      button: true,
      enabled: item.enabled,
      selected: isActive,
      label: semanticLabel,
      child: AnimatedContainer(
        duration: widget.animationDuration,
        curve: widget.animationCurve,
        decoration: BoxDecoration(
          color: isActive
              ? widget.activeColor ?? colorScheme.primary
              : Colors.transparent,
          shape: .rectangle,
        ),
        clipBehavior: .antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.enabled
                ? () {
                    final shouldActivate = item.onPressed();
                    setState(() {
                      if (shouldActivate) {
                        _activeItem = item;
                      } else {
                        if (_activeItem == item) {
                          _activeItem = null;
                        }
                      }
                    });
                  }
                : null,
            child: SizedBox(
              width: widget.actionSize,
              height: widget.actionSize,
              child: Center(child: _buildIcon(item, isActive, iconColor)),
            ),
          ),
        ),
      ),
    );

    if (item.tooltip != null && item.tooltip!.isNotEmpty) {
      button = Tooltip(message: item.tooltip!, child: button);
    }

    return button;
  }

  Widget _buildIcon(FloatingToolbarItem item, bool isActive, Color iconColor) {
    if (item.activeIcon == null) {
      return Icon(item.icon, size: widget.iconSize, color: iconColor);
    }

    final activeDuration = isActive ? widget.animationDuration : Duration.zero;

    return Stack(
      alignment: .center,
      children: [
        AnimatedOpacity(
          opacity: isActive ? 0.0 : 1.0,
          duration: activeDuration,
          curve: widget.animationCurve,
          child: Icon(item.icon, size: widget.iconSize, color: iconColor),
        ),
        AnimatedOpacity(
          opacity: isActive ? 1.0 : 0.0,
          duration: activeDuration,
          curve: widget.animationCurve,
          child: Icon(
            item.activeIcon!,
            size: widget.iconSize,
            color: iconColor,
          ),
        ),
      ],
    );
  }
}
