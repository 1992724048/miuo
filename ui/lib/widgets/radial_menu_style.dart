import 'package:material_ui/material_ui.dart';

/// 中心圆与矩形项共用的扁平填充按钮样式。
ButtonStyle radialMenuButtonStyle({
  required ColorScheme scheme,
  required BorderRadius borderRadius,
}) {
  return ButtonStyle(
    elevation: const WidgetStatePropertyAll(0),
    padding: const WidgetStatePropertyAll(EdgeInsets.zero),
    minimumSize: const WidgetStatePropertyAll(Size.zero),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    backgroundColor: WidgetStatePropertyAll(scheme.primary),
    foregroundColor: WidgetStatePropertyAll(scheme.onPrimary),
    overlayColor: WidgetStateProperty.resolveWith((states) {
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
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: borderRadius),
    ),
  );
}
