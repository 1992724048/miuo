import 'package:flutter/animation.dart';

import 'radial_menu_geometry.dart';

const int radialMenuItemOpenMs = 240;
const int radialMenuItemOpenStaggerMs = 35;
const int radialMenuItemCloseMs = 160;
const int radialMenuItemCloseStaggerMs = 20;
const int radialMenuCenterOpenMs = 200;
const int radialMenuCenterCloseDelayMs = 40;
const int radialMenuCenterCloseMs = 200;

int _staggerSpan(int count, int stepMs) {
  final spanCount = count > 1 ? count - 1 : 0;
  return spanCount * stepMs;
}

int _maxOf(int left, int right) => left > right ? left : right;

int radialMenuOpenDurationMs(int count) {
  return _maxOf(
    radialMenuCenterOpenMs,
    radialMenuItemOpenMs + _staggerSpan(count, radialMenuItemOpenStaggerMs),
  );
}

int radialMenuCloseDurationMs(int count) {
  return _maxOf(
    radialMenuCenterCloseDelayMs + radialMenuCenterCloseMs,
    radialMenuItemCloseMs + _staggerSpan(count, radialMenuItemCloseStaggerMs),
  );
}

double radialMenuItemOpenProgress(
  double controllerValue,
  int index,
  int count,
) {
  final elapsed = controllerValue * radialMenuOpenDurationMs(count);
  final local = clampUnit(
    (elapsed - index * radialMenuItemOpenStaggerMs) / radialMenuItemOpenMs,
  );
  return Curves.easeOutCubic.transform(local);
}

double radialMenuItemCloseProgress(
  double controllerValue,
  int index,
  int count,
) {
  final elapsed = (1 - controllerValue) * radialMenuCloseDurationMs(count);
  final delay = (count - 1 - index) * radialMenuItemCloseStaggerMs;
  final local = clampUnit((elapsed - delay) / radialMenuItemCloseMs);
  return 1 - Curves.easeInCubic.transform(local);
}

double radialMenuCenterProgress(
  double controllerValue,
  int count, {
  required bool closing,
}) {
  if (closing) {
    final elapsed = (1 - controllerValue) * radialMenuCloseDurationMs(count);
    final local = clampUnit(
      (elapsed - radialMenuCenterCloseDelayMs) / radialMenuCenterCloseMs,
    );
    return 1 - Curves.easeInCubic.transform(local);
  }

  final elapsed = controllerValue * radialMenuOpenDurationMs(count);
  final local = clampUnit(elapsed / radialMenuCenterOpenMs);
  return Curves.easeOutCubic.transform(local);
}
