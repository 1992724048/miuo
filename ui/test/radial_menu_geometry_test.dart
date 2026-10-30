import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:ui/widgets/radial_menu_geometry.dart';

void expectOffset(Offset actual, Offset expected) {
  expect(actual.dx, closeTo(expected.dx, 1e-6));
  expect(actual.dy, closeTo(expected.dy, 1e-6));
}

void main() {
  group('itemAngle', () {
    test('四项沿圆周均匀分布', () {
      final angles = [
        for (var index = 0; index < 4; index++)
          itemAngle(rotation: 0.3, startAngle: math.pi, index: index, count: 4),
      ];

      for (var index = 0; index < 4; index++) {
        final delta = shortestAngleDelta(
          from: angles[index],
          to: angles[(index + 1) % 4],
        );
        expect(delta, closeTo(math.pi / 2, 1e-9));
      }
    });

    test('旋转量整体偏移所有项', () {
      final base = itemAngle(rotation: 0, startAngle: 0, index: 1, count: 3);
      final rotated = itemAngle(
        rotation: 0.4,
        startAngle: 0,
        index: 1,
        count: 3,
      );
      expect(shortestAngleDelta(from: base, to: rotated), closeTo(0.4, 1e-9));
    });

    test('没有菜单项时返回起始方向', () {
      expect(
        itemAngle(rotation: 0.2, startAngle: math.pi, index: 0, count: 0),
        closeTo(normalizeAngle(0.2 + math.pi), 1e-9),
      );
    });
  });

  group('resolveFlipped', () {
    test('朝右解除翻转、朝左触发翻转', () {
      expect(resolveFlipped(angle: 0, currentlyFlipped: true), isFalse);
      expect(resolveFlipped(angle: math.pi, currentlyFlipped: false), isTrue);
    });

    test('迟滞区间内保持原状态', () {
      final angle = math.pi / 2 + 0.02;
      expect(resolveFlipped(angle: angle, currentlyFlipped: true), isTrue);
      expect(resolveFlipped(angle: angle, currentlyFlipped: false), isFalse);
    });

    test('越过迟滞阈值后切换', () {
      expect(
        resolveFlipped(angle: math.pi / 2 + 0.1, currentlyFlipped: false),
        isTrue,
      );
      expect(
        resolveFlipped(angle: math.pi / 2 - 0.1, currentlyFlipped: true),
        isFalse,
      );
    });
  });

  group('itemCenter', () {
    test('0°、90°、180° 基准落点', () {
      const center = Offset(100, 100);

      expectOffset(
        itemCenter(center: center, angle: 0, midRadius: 50),
        const Offset(150, 100),
      );
      expectOffset(
        itemCenter(center: center, angle: math.pi / 2, midRadius: 50),
        const Offset(100, 150),
      );
      expectOffset(
        itemCenter(center: center, angle: math.pi, midRadius: 50),
        const Offset(50, 100),
      );
    });
  });

  group('dragRotationDelta', () {
    test('四分之一圈对应 π/2', () {
      final delta = dragRotationDelta(
        center: Offset.zero,
        previousPointer: const Offset(100, 0),
        currentPointer: const Offset(0, 100),
      );
      expect(delta, closeTo(math.pi / 2, 1e-9));
    });

    test('跨越 ±π 时取最短角度', () {
      const center = Offset(100, 100);
      final previous = center + Offset.fromDirection(math.pi - 0.1, 50);
      final current = center + Offset.fromDirection(-math.pi + 0.1, 50);

      final delta = dragRotationDelta(
        center: center,
        previousPointer: previous,
        currentPointer: current,
      );
      expect(delta, closeTo(0.2, 1e-9));
    });

    test('指针靠近圆心时忽略旋转', () {
      expect(
        dragRotationDelta(
          center: Offset.zero,
          previousPointer: const Offset(10, 0),
          currentPointer: const Offset(0, 100),
        ),
        0,
      );
    });
  });

  group('radialMenuOpenDiameter', () {
    test('远离窗口边缘时收敛到最大值', () {
      expect(
        radialMenuOpenDiameter(
          center: const Offset(400, 300),
          windowSize: const Size(800, 600),
        ),
        62,
      );
    });

    test('靠近窗口边缘时按最近边收缩', () {
      expect(
        radialMenuOpenDiameter(
          center: const Offset(20, 300),
          windowSize: const Size(800, 600),
        ),
        38,
      );
    });
  });
}
