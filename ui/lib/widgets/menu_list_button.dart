import 'dart:ui';

import 'package:flutter/cupertino.dart' as cupertino;
import 'package:material_ui/material_ui.dart';

enum MenuLabelPosition { left, right }

class ExpandMenuItem {
  const ExpandMenuItem({required this.icon, this.label, required this.onTap});

  final IconData icon;
  final String? label;
  final VoidCallback onTap;
}

class _SpringCurve extends Curve {
  const _SpringCurve();

  @override
  double transformInternal(double t) {
    if (t < 0.55) {
      final inv = 1 - t / 0.55;
      return 1.05 * (1 - inv * inv * inv);
    }

    if (t < 0.8) {
      final u = (t - 0.55) / 0.25;
      return 1.05 - 0.06 * (u * u * (3 - 2 * u));
    }

    final inv = 1 - (t - 0.8) / 0.2;
    return 0.99 + 0.01 * (1 - inv * inv * inv);
  }
}

class _StaggeredSlide extends StatefulWidget {
  const _StaggeredSlide({required this.controller, required this.index, required this.count, required this.child});

  final AnimationController controller;
  final int index;
  final int count;
  final Widget child;

  @override
  State<_StaggeredSlide> createState() => _StaggeredSlideState();
}

class _StaggeredSlideState extends State<_StaggeredSlide> {
  late CurvedAnimation _curved;

  CurvedAnimation _createCurvedAnimation() {
    const overlap = 0.1;

    final count = widget.count;
    final span = count == 1 ? 1.0 : 1 / (1 + overlap * (count - 1));
    final step = span * overlap;
    final fwdStart = (count - 1 - widget.index) * step;
    final revStart = widget.index * step;

    return CurvedAnimation(
      parent: widget.controller,
      curve: Interval(fwdStart, fwdStart + span, curve: const _SpringCurve()),
      reverseCurve: Interval(revStart, revStart + span, curve: Curves.easeInCubic),
    );
  }

  @override
  void initState() {
    super.initState();
    _curved = _createCurvedAnimation();
  }

  @override
  void didUpdateWidget(covariant _StaggeredSlide oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller ||
        oldWidget.index != widget.index ||
        oldWidget.count != widget.count) {
      _curved.dispose();
      _curved = _createCurvedAnimation();
    }
  }

  @override
  void dispose() {
    _curved.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return AnimatedBuilder(
      animation: _curved,
      child: widget.child,
      builder: (context, child) {
        return Transform.translate(offset: Offset(screenWidth * (1 - _curved.value), 0), child: child);
      },
    );
  }
}

class _AnimatedElevation extends StatelessWidget {
  const _AnimatedElevation({
    required this.controller,
    required this.scheme,
    required this.shape,
    required this.child,
    required this.elevation,
  });

  final AnimationController controller;
  final ColorScheme scheme;
  final ShapeBorder shape;
  final Widget child;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    if (elevation <= 0) return child;

    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        final animatedElevation = elevation * Curves.easeInOutCubic.transform(controller.value);

        return PhysicalShape(
          clipper: ShapeBorderClipper(shape: shape),
          color: scheme.primary,
          shadowColor: scheme.shadow,
          elevation: animatedElevation,
          clipBehavior: Clip.none,
          child: child,
        );
      },
    );
  }
}

ButtonStyle _buttonStyle(ColorScheme scheme, OutlinedBorder shape, EdgeInsets padding) {
  return ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(scheme.primary),
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return Colors.white.withValues(alpha: 0.24);
      }
      if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) {
        return Colors.white.withValues(alpha: 0.16);
      }
      return Colors.transparent;
    }),
    elevation: const WidgetStatePropertyAll(0),
    shadowColor: const WidgetStatePropertyAll(Colors.transparent),
    padding: WidgetStatePropertyAll(padding),
    shape: WidgetStatePropertyAll(shape),
  );
}

class ExpandUpMenuButton extends StatefulWidget {
  const ExpandUpMenuButton({
    super.key,
    required this.items,
    this.icon = Icons.add,
    this.closeIcon = Icons.close,
    this.size = 46,
    this.gap = 2,
    this.labelPosition = MenuLabelPosition.right,
    this.blurSigma = 1,
    this.barrierOpacity = 0.5,
    this.barrierBlur = true,
    this.elevation = 0,
  });

  final List<ExpandMenuItem> items;
  final IconData icon;
  final IconData closeIcon;
  final double size;
  final double gap;
  final MenuLabelPosition labelPosition;
  final double blurSigma;
  final double barrierOpacity;
  final bool barrierBlur;
  final double elevation;

  @override
  State<ExpandUpMenuButton> createState() => _ExpandUpMenuButtonState();
}

class _ExpandUpMenuButtonState extends State<ExpandUpMenuButton> with SingleTickerProviderStateMixin {
  final _link = cupertino.LayerLink();
  OverlayEntry? _entry;

  int _openToken = 0;
  bool _isClosing = false;
  bool _isExpanded = false;

  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 460),
    reverseDuration: const Duration(milliseconds: 260),
  );

  late final CurvedAnimation _fade = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    reverseCurve: const Interval(0.65, 1.0, curve: Curves.easeIn),
  );

  @override
  void didUpdateWidget(covariant ExpandUpMenuButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.elevation != widget.elevation) {
      _entry?.markNeedsBuild();
    }
  }

  @override
  void dispose() {
    ++_openToken;

    final entry = _entry;
    _entry = null;

    if (entry != null) {
      entry.remove();
      entry.dispose();
    }

    _fade.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_entry == null) {
      _open();
    } else if (_isClosing) {
      _reopen();
    } else {
      _close();
    }
  }

  void _open() {
    if (_entry != null) {
      if (_isClosing) _reopen();
      return;
    }

    final overlay = Overlay.of(context, rootOverlay: true);
    final captured = InheritedTheme.capture(from: context, to: overlay.context);
    final entry = OverlayEntry(builder: (_) => captured.wrap(_buildOverlay()));

    ++_openToken;
    setState(() {
      _entry = entry;
      _isClosing = false;
      _isExpanded = false;
    });

    overlay.insert(entry);
    _ctrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !identical(_entry, entry) || _isClosing) return;

      setState(() {
        _isExpanded = true;
      });
      entry.markNeedsBuild();
    });
  }

  void _reopen() {
    if (_entry == null || !_isClosing) return;

    final entry = _entry!;
    ++_openToken;
    setState(() {
      _isClosing = false;
      _isExpanded = true;
    });
    entry.markNeedsBuild();

    _ctrl.forward();
  }

  void _close() {
    final entry = _entry;
    if (entry == null || _isClosing) return;

    final token = ++_openToken;
    setState(() {
      _isClosing = true;
      _isExpanded = false;
    });
    entry.markNeedsBuild();

    _ctrl.reverse().then((_) {
      if (!mounted || _openToken != token || !identical(_entry, entry)) {
        return;
      }

      setState(() {
        _entry = null;
        _isClosing = false;
      });

      entry.remove();
      entry.dispose();
    });
  }

  List<Widget> _buildMenuItems(ColorScheme scheme) {
    final items = widget.items;
    final count = items.length;

    return [for (var i = 0; i < count; i++) _buildMenuItem(item: items[i], index: i, count: count, scheme: scheme)];
  }

  Widget _buildMenuItem({
    required ExpandMenuItem item,
    required int index,
    required int count,
    required ColorScheme scheme,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.gap),
      child: _StaggeredSlide(
        controller: _ctrl,
        index: index,
        count: count,
        child: _AnimatedElevation(
          controller: _ctrl,
          scheme: scheme,
          shape: const StadiumBorder(),
          elevation: widget.elevation,
          child: _MenuItemButton(
            item: item,
            size: widget.size,
            scheme: scheme,
            labelPosition: widget.labelPosition,
            onTap: () {
              _close();
              item.onTap();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: FadeTransition(
              opacity: _fade,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _close,
                child: widget.barrierBlur
                    ? BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: widget.blurSigma, sigmaY: widget.blurSigma),
                        child: Container(color: scheme.surface.withValues(alpha: widget.barrierOpacity)),
                      )
                    : Container(color: scheme.surface.withValues(alpha: widget.barrierOpacity)),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            targetAnchor: Alignment.topRight,
            followerAnchor: Alignment.bottomRight,
            offset: Offset(0, -widget.gap),
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _buildMenuItems(scheme),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.bottomRight,
            child: Material(
              type: MaterialType.transparency,
              child: _AnimatedElevation(
                controller: _ctrl,
                scheme: scheme,
                shape: const CircleBorder(),
                elevation: widget.elevation,
                child: _buildMainButton(isOpen: _isExpanded),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainButton({required bool isOpen}) {
    final scheme = Theme.of(context).colorScheme;
    final shape = isOpen ? const CircleBorder() : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: FilledButton(
        onPressed: _toggle,
        style: _buttonStyle(scheme, shape, EdgeInsets.zero),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) => RotationTransition(
            turns: _kIconTurnTween.animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: Icon(isOpen ? widget.closeIcon : widget.icon, key: ValueKey(isOpen), size: widget.size * 0.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasOverlay = _entry != null;

    return CompositedTransformTarget(
      link: _link,
      child: Opacity(
        opacity: hasOverlay ? 0 : 1,
        child: _buildMainButton(isOpen: _isExpanded),
      ),
    );
  }
}

final _kIconTurnTween = Tween<double>(begin: 0.125, end: 0.0);

class _MenuItemButton extends StatelessWidget {
  const _MenuItemButton({
    required this.item,
    required this.size,
    required this.scheme,
    required this.labelPosition,
    required this.onTap,
  });

  final ExpandMenuItem item;
  final double size;
  final ColorScheme scheme;
  final MenuLabelPosition labelPosition;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(item.icon, size: size * 0.5);
    final label = Text(item.label ?? '');
    final gap = SizedBox(width: size * 0.18);

    return FilledButton(
      onPressed: onTap,
      style: _buttonStyle(
        scheme,
        const StadiumBorder(),
        EdgeInsets.symmetric(horizontal: size * 0.32, vertical: size * 0.24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: labelPosition == MenuLabelPosition.right
            ? [
                icon,
                if (item.label != null) ...[gap, label],
              ]
            : [
                if (item.label != null) ...[label, gap],
                icon,
              ],
      ),
    );
  }
}
