import 'dart:math' as math;
import 'dart:ui';

/// 一整圈对应的弧度。
const double radialMenuFullTurn = math.pi * 2;

/// 翻转判据的默认迟滞（约 3°）。
const double radialMenuFlipHysteresis = 0.052;

double clampUnit(double value) {
  if (value < 0) {
    return 0;
  }

  if (value > 1) {
    return 1;
  }

  return value;
}

/// 把角度归一化到 `(-π, π]`，避免长时间旋转后累积过大数值。
double normalizeAngle(double angle) {
  final turn = angle % radialMenuFullTurn;
  return turn > math.pi ? turn - radialMenuFullTurn : turn;
}

/// 第 [index] 项的方向角，`rotation` 为环的当前旋转量。
double itemAngle({
  required double rotation,
  required double startAngle,
  required int index,
  required int count,
}) {
  if (count <= 0) {
    return normalizeAngle(rotation + startAngle);
  }

  return normalizeAngle(
    rotation + startAngle + index * radialMenuFullTurn / count,
  );
}

/// 项中心相对圆心的落点。
Offset itemCenter({
  required Offset center,
  required double angle,
  required double midRadius,
}) {
  return center + Offset(math.cos(angle), math.sin(angle)) * midRadius;
}

/// 依据项朝向决定内容是否翻转；处于迟滞区间内时保持原状态。
bool resolveFlipped({
  required double angle,
  required bool currentlyFlipped,
  double hysteresis = radialMenuFlipHysteresis,
}) {
  final cosine = math.cos(angle);
  if (cosine < -hysteresis) {
    return true;
  }

  if (cosine > hysteresis) {
    return false;
  }

  return currentlyFlipped;
}

double angleOf({required Offset center, required Offset pointer}) {
  return math.atan2(pointer.dy - center.dy, pointer.dx - center.dx);
}

/// 从 [from] 转到 [to] 的最短角度差，落在 `(-π, π]`。
double shortestAngleDelta({required double from, required double to}) {
  final delta = (to - from) % radialMenuFullTurn;
  return delta > math.pi ? delta - radialMenuFullTurn : delta;
}

/// 拖拽产生的旋转量；指针距圆心过近（角度奇异区）时忽略。
double dragRotationDelta({
  required Offset center,
  required Offset previousPointer,
  required Offset currentPointer,
  double minPointerRadius = 24,
}) {
  final previousRadius = (previousPointer - center).distance;
  final currentRadius = (currentPointer - center).distance;
  if (previousRadius < minPointerRadius || currentRadius < minPointerRadius) {
    return 0;
  }

  return shortestAngleDelta(
    from: angleOf(center: center, pointer: previousPointer),
    to: angleOf(center: center, pointer: currentPointer),
  );
}

/// 展开后的中心圆直径，按圆心到最近窗口边的距离收敛，避免被裁切。
double radialMenuOpenDiameter({
  required Offset center,
  required Size windowSize,
  double maxDiameter = 62,
  double edgeMargin = 2,
}) {
  final nearestEdge = math.min(
    math.min(center.dx, windowSize.width - center.dx),
    math.min(center.dy, windowSize.height - center.dy),
  );
  final diameter = nearestEdge * 2 - edgeMargin;

  return math.max(2, math.min(maxDiameter, diameter));
}
