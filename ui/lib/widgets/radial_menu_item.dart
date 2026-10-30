import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

const double radialMenuItemLength = 112;
const double radialMenuItemWidth = 38;

const double _itemInset = 8;
const double _itemIconSize = 18;
const double _itemIconGap = 6;
const double _itemLabelSize = 12;
const double _itemLabelHeight = 1.2;

class ExpandMenuItem {
  const ExpandMenuItem({
    required this.icon,
    this.label,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  final bool enabled;
}

/// 沿圆周方向摆放的直角矩形项：长轴沿半径，图标在内端。
class RadialRingItem extends StatelessWidget {
  const RadialRingItem({
    super.key,
    required this.item,
    required this.scheme,
    required this.angle,
    required this.midRadius,
    required this.scale,
    required this.opacity,
    required this.flipped,
    required this.interactive,
    required this.flipDuration,
    required this.onTap,
  });

  final ExpandMenuItem item;
  final ColorScheme scheme;
  final double angle;
  final double midRadius;
  final double scale;
  final double opacity;
  final bool flipped;
  final bool interactive;
  final Duration flipDuration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final direction = Offset(math.cos(angle), math.sin(angle));

    return Transform.translate(
      offset: direction * midRadius,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: flipped ? 1 : 0),
        duration: flipDuration,
        curve: Curves.easeInOut,
        builder: (context, flip, child) {
          return Transform.rotate(angle: angle + flip * math.pi, child: child);
        },
        child: Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: IgnorePointer(ignoring: !interactive, child: _buildButton()),
          ),
        ),
      ),
    );
  }

  Widget _buildButton() {
    final label = item.label;
    final enabled = item.enabled;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      child: SizedBox(
        width: radialMenuItemLength,
        height: radialMenuItemWidth,
        child: FilledButton(
          onPressed: enabled ? onTap : null,
          style: _buttonStyle(enabled),
          child: Row(
            children: [
              Icon(item.icon, size: _itemIconSize),
              if (label != null) ...[
                const SizedBox(width: _itemIconGap),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: _itemLabelSize,
                      height: _itemLabelHeight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle(bool enabled) {
    return ButtonStyle(
      elevation: const WidgetStatePropertyAll(0),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: _itemInset),
      ),
      minimumSize: const WidgetStatePropertyAll(Size.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
      backgroundColor: WidgetStatePropertyAll(
        enabled ? scheme.primary : scheme.onSurface.withValues(alpha: 0.12),
      ),
      foregroundColor: WidgetStatePropertyAll(
        enabled ? scheme.onPrimary : scheme.onSurface.withValues(alpha: 0.38),
      ),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (!enabled) {
          return null;
        }

        if (states.contains(WidgetState.pressed)) {
          return scheme.onPrimary.withValues(alpha: 0.10);
        }

        if (states.contains(WidgetState.hovered)) {
          return scheme.onPrimary.withValues(alpha: 0.08);
        }

        return null;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return BorderSide(
            color: scheme.onPrimary.withValues(alpha: 0.70),
            width: 2,
          );
        }

        return BorderSide.none;
      }),
    );
  }
}
