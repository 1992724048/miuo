import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'radial_menu_geometry.dart';
import 'radial_menu_item.dart';
import 'radial_menu_style.dart';
import 'radial_menu_timing.dart';

export 'radial_menu_item.dart';

const double _centerIconClosedSize = 20;
const double _centerIconOpenSize = 28;
const double _ringMargin = 24;
const double _maxOpenDiameter = 62;
const double _scrollSensitivity = 0.010;
const double _minDragRadius = 24;
const double _inertiaDecay = 3.2;
const double _maxInertiaVelocity = 8;
const double _minInertiaVelocity = 0.04;

const int _barrierInMs = 160;
const int _barrierOutMs = 120;
const int _barrierOutDelayMs = 100;
const int _flipMs = 140;
const int _iconSwapMs = 160;

class ExpandUpMenuButton extends StatefulWidget {
  const ExpandUpMenuButton({
    super.key,
    required this.items,
    this.icon = Icons.add,
    this.closeIcon = Icons.close,
    this.size = 39,
    this.gap = 6,
    this.startAngle = math.pi,
    this.blurSigma = 2,
    this.barrierOpacity = 0.5,
    this.barrierBlur = true,
  });

  final List<ExpandMenuItem> items;
  final IconData icon;
  final IconData closeIcon;
  final double size;

  /// 中心圆到矩形内端的间隙。
  final double gap;

  /// 第一项的方向角，默认朝向窗口左侧。
  final double startAngle;

  final double blurSigma;
  final double barrierOpacity;
  final bool barrierBlur;

  @override
  State<ExpandUpMenuButton> createState() => _ExpandUpMenuButtonState();
}

class _ExpandUpMenuButtonState extends State<ExpandUpMenuButton>
    with TickerProviderStateMixin {
  final ValueNotifier<double> _rotation = ValueNotifier<double>(0);
  final ValueNotifier<bool> _dragging = ValueNotifier<bool>(false);
  final List<bool> _flipped = <bool>[];

  late final AnimationController _expand = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: radialMenuItemOpenMs),
  );

  late final AnimationController _barrier = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _barrierInMs),
    reverseDuration: const Duration(milliseconds: _barrierOutMs),
  );

  late final CurvedAnimation _barrierFade = CurvedAnimation(
    parent: _barrier,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeIn,
  );

  OverlayEntry? _entry;
  Offset? _center;
  Offset? _dragPointer;
  Ticker? _inertiaTicker;
  double _angularVelocity = 0;
  Duration _lastInertiaTick = Duration.zero;

  int _openToken = 0;
  bool _isClosing = false;

  @override
  void didUpdateWidget(covariant ExpandUpMenuButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    final entry = _entry;
    if (entry == null) {
      return;
    }

    _applyDurations(widget.items.length);
    entry.markNeedsBuild();
  }

  @override
  void dispose() {
    ++_openToken;
    _stopInertia();

    final entry = _entry;
    _entry = null;
    if (entry != null) {
      entry.remove();
      entry.dispose();
    }

    _barrierFade.dispose();
    _barrier.dispose();
    _expand.dispose();
    _rotation.dispose();
    _dragging.dispose();
    super.dispose();
  }

  Duration _timing(int milliseconds) {
    final disabled = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return Duration(milliseconds: disabled ? 1 : milliseconds);
  }

  void _applyDurations(int count) {
    _expand.duration = _timing(radialMenuOpenDurationMs(count));
    _expand.reverseDuration = _timing(radialMenuCloseDurationMs(count));
    _barrier.duration = _timing(_barrierInMs);
    _barrier.reverseDuration = _timing(_barrierOutMs);
  }

  Offset _resolveCenter() {
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      return renderObject.localToGlobal(renderObject.size.center(Offset.zero));
    }

    return MediaQuery.sizeOf(context).center(Offset.zero);
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
      if (_isClosing) {
        _reopen();
      }
      return;
    }

    final overlay = Overlay.of(context, rootOverlay: true);
    final captured = InheritedTheme.capture(from: context, to: overlay.context);
    final entry = OverlayEntry(
      builder: (overlayContext) =>
          captured.wrap(Builder(builder: _buildOverlay)),
    );

    _center = _resolveCenter();
    _flipped.clear();
    _applyDurations(widget.items.length);

    ++_openToken;
    setState(() {
      _entry = entry;
      _isClosing = false;
    });

    overlay.insert(entry);
    _expand.forward(from: 0);
    _barrier.forward(from: 0);
  }

  void _reopen() {
    final entry = _entry;
    if (entry == null || !_isClosing) {
      return;
    }

    ++_openToken;
    setState(() => _isClosing = false);
    _applyDurations(widget.items.length);
    entry.markNeedsBuild();

    _expand.forward();
    _barrier.forward();
  }

  void _close() {
    final entry = _entry;
    if (entry == null || _isClosing) {
      return;
    }

    _stopInertia();

    final token = ++_openToken;
    setState(() => _isClosing = true);
    _applyDurations(widget.items.length);
    entry.markNeedsBuild();

    _expand.reverse().then((_) {
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

    unawaited(_fadeBarrierOut(token));
  }

  Future<void> _fadeBarrierOut(int token) async {
    await Future<void>.delayed(_timing(_barrierOutDelayMs));
    if (!mounted || _openToken != token) {
      return;
    }

    await _barrier.reverse();
  }

  void _rotateBy(double delta) {
    if (delta == 0) {
      return;
    }

    _rotation.value = normalizeAngle(_rotation.value + delta);
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) {
      return;
    }

    _stopInertia();
    final scroll = event.scrollDelta;
    _rotateBy((scroll.dy + scroll.dx) * _scrollSensitivity);
  }

  void _handlePanStart(DragStartDetails details) {
    _stopInertia();
    _dragPointer = details.globalPosition;
    _dragging.value = true;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final center = _center;
    final previous = _dragPointer;
    if (center == null || previous == null) {
      return;
    }

    final current = details.globalPosition;
    _dragPointer = current;
    _rotateBy(
      dragRotationDelta(
        center: center,
        previousPointer: previous,
        currentPointer: current,
        minPointerRadius: _minDragRadius,
      ),
    );
  }

  void _handlePanEnd(DragEndDetails details) {
    final pointer = _dragPointer;
    _dragPointer = null;
    _dragging.value = false;

    final center = _center;
    if (center == null || pointer == null) {
      return;
    }

    final radial = pointer - center;
    final radius = radial.distance;
    if (radius < _minDragRadius) {
      return;
    }

    final tangent = Offset(-radial.dy, radial.dx) / radius;
    final velocity = details.velocity.pixelsPerSecond;
    final tangential = velocity.dx * tangent.dx + velocity.dy * tangent.dy;
    _startInertia(tangential / radius);
  }

  void _handlePanCancel() {
    _dragPointer = null;
    _dragging.value = false;
  }

  void _startInertia(double velocity) {
    _stopInertia();

    final clamped = velocity
        .clamp(-_maxInertiaVelocity, _maxInertiaVelocity)
        .toDouble();
    if (clamped.abs() < _minInertiaVelocity) {
      return;
    }

    _angularVelocity = clamped;
    _lastInertiaTick = Duration.zero;
    _inertiaTicker = createTicker(_handleInertiaTick)..start();
  }

  void _handleInertiaTick(Duration elapsed) {
    final deltaSeconds =
        (elapsed - _lastInertiaTick).inMicroseconds /
        Duration.microsecondsPerSecond;
    _lastInertiaTick = elapsed;

    if (deltaSeconds <= 0) {
      return;
    }

    _angularVelocity *= math.exp(-_inertiaDecay * deltaSeconds);
    if (_angularVelocity.abs() < _minInertiaVelocity) {
      _stopInertia();
      return;
    }

    _rotateBy(_angularVelocity * deltaSeconds);
  }

  void _stopInertia() {
    final ticker = _inertiaTicker;
    _inertiaTicker = null;
    _angularVelocity = 0;

    if (ticker == null) {
      return;
    }

    ticker.stop();
    ticker.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      _close();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _syncFlipCount(int count) {
    while (_flipped.length < count) {
      _flipped.add(false);
    }

    if (_flipped.length > count) {
      _flipped.length = count;
    }
  }

  bool _resolveFlip(int index, double angle) {
    final flipped = resolveFlipped(
      angle: angle,
      currentlyFlipped: _flipped[index],
    );
    _flipped[index] = flipped;
    return flipped;
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: _entry == null ? 1 : 0, child: _buildTrigger());
  }

  Widget _buildTrigger() {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: FilledButton(
        onPressed: _toggle,
        style: radialMenuButtonStyle(
          scheme: scheme,
          borderRadius: BorderRadius.zero,
        ),
        child: Icon(widget.icon, size: _centerIconClosedSize),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final windowSize = MediaQuery.sizeOf(context);
    final center = _center ?? windowSize.center(Offset.zero);
    final openDiameter = radialMenuOpenDiameter(
      center: center,
      windowSize: windowSize,
      maxDiameter: _maxOpenDiameter,
    );
    final animationsDisabled =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: Focus(
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildBarrier(scheme),
            _buildRing(
              scheme: scheme,
              center: center,
              openDiameter: openDiameter,
            ),
            _buildCenter(
              scheme: scheme,
              center: center,
              openDiameter: openDiameter,
              iconSwapDuration: Duration(
                milliseconds: animationsDisabled ? 1 : _iconSwapMs,
              ),
            ),
            _buildDragLayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildBarrier(ColorScheme scheme) {
    final color = scheme.surface.withValues(alpha: widget.barrierOpacity);
    final barrier = widget.barrierBlur
        ? BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: widget.blurSigma,
              sigmaY: widget.blurSigma,
            ),
            child: ColoredBox(color: color),
          )
        : ColoredBox(color: color);

    return Positioned.fill(
      child: RepaintBoundary(
        child: FadeTransition(
          opacity: _barrierFade,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
            child: barrier,
          ),
        ),
      ),
    );
  }

  Widget _buildRing({
    required ColorScheme scheme,
    required Offset center,
    required double openDiameter,
  }) {
    final innerRadius = openDiameter / 2 + math.max(0, widget.gap);
    final extent = innerRadius + radialMenuItemLength + _ringMargin;

    return Positioned(
      left: center.dx - extent,
      top: center.dy - extent,
      width: extent * 2,
      height: extent * 2,
      child: RepaintBoundary(
        child: ValueListenableBuilder<double>(
          valueListenable: _rotation,
          builder: (context, rotation, _) {
            return AnimatedBuilder(
              animation: _expand,
              builder: (context, _) {
                final count = widget.items.length;
                _syncFlipCount(count);

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (var index = 0; index < count; index++)
                      _buildRingItem(
                        scheme: scheme,
                        index: index,
                        count: count,
                        rotation: rotation,
                        innerRadius: innerRadius,
                        extent: extent,
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildRingItem({
    required ColorScheme scheme,
    required int index,
    required int count,
    required double rotation,
    required double innerRadius,
    required double extent,
  }) {
    final item = widget.items[index];
    final angle = itemAngle(
      rotation: rotation,
      startAngle: widget.startAngle,
      index: index,
      count: count,
    );
    final progress = _isClosing
        ? radialMenuItemCloseProgress(_expand.value, index, count)
        : radialMenuItemOpenProgress(_expand.value, index, count);
    final flipped = _resolveFlip(index, angle);
    final scale = 0.6 + 0.4 * progress;
    final midRadius = innerRadius * progress + radialMenuItemLength * scale / 2;
    final interactive = !_isClosing && item.enabled && progress >= 0.85;

    return Positioned(
      left: extent - radialMenuItemLength / 2,
      top: extent - radialMenuItemWidth / 2,
      child: RadialRingItem(
        item: item,
        scheme: scheme,
        angle: angle,
        midRadius: midRadius,
        scale: scale,
        opacity: clampUnit(progress / 0.4),
        flipped: flipped,
        interactive: interactive,
        flipDuration: _timing(_flipMs),
        onTap: () {
          _close();
          item.onTap();
        },
      ),
    );
  }

  Widget _buildCenter({
    required ColorScheme scheme,
    required Offset center,
    required double openDiameter,
    required Duration iconSwapDuration,
  }) {
    final closedRadius = math.max(1, widget.size) / 2;
    final openRadius = openDiameter / 2;

    return AnimatedBuilder(
      animation: _expand,
      builder: (context, _) {
        final progress = radialMenuCenterProgress(
          _expand.value,
          widget.items.length,
          closing: _isClosing,
        );
        final radius = closedRadius + (openRadius - closedRadius) * progress;
        final isOpen = !_isClosing;

        return Positioned(
          left: center.dx - radius,
          top: center.dy - radius,
          width: radius * 2,
          height: radius * 2,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: FilledButton(
              onPressed: _toggle,
              style: radialMenuButtonStyle(
                scheme: scheme,
                borderRadius: BorderRadius.circular(radius),
              ),
              child: AnimatedSwitcher(
                duration: iconSwapDuration,
                child: Icon(
                  isOpen ? widget.closeIcon : widget.icon,
                  key: ValueKey<bool>(isOpen),
                  size:
                      _centerIconClosedSize +
                      (_centerIconOpenSize - _centerIconClosedSize) * progress,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDragLayer() {
    return Positioned.fill(
      child: ValueListenableBuilder<bool>(
        valueListenable: _dragging,
        builder: (context, dragging, _) {
          return MouseRegion(
            opaque: false,
            cursor: dragging ? SystemMouseCursors.grabbing : MouseCursor.defer,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: _handlePanStart,
              onPanUpdate: _handlePanUpdate,
              onPanEnd: _handlePanEnd,
              onPanCancel: _handlePanCancel,
            ),
          );
        },
      ),
    );
  }
}
