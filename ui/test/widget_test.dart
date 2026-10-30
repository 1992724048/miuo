import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui/widgets/menu_list_button.dart';

const _labels = <String>['添加光影包', '添加材质包', '导入整合包', '添加游戏版本'];

List<ExpandMenuItem> _buildItems() {
  return [
    for (final label in _labels)
      ExpandMenuItem(icon: Icons.add, label: label, onTap: () {}),
  ];
}

Widget _buildApp({List<ExpandMenuItem>? items}) {
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          Positioned(
            right: 20,
            bottom: 20,
            child: ExpandUpMenuButton(
              icon: Icons.add,
              items: items ?? _buildItems(),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> _pumpApp(
  WidgetTester tester, {
  List<ExpandMenuItem>? items,
}) async {
  tester.view.physicalSize = const Size(800, 600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(_buildApp(items: items));
}

Future<void> _openMenu(WidgetTester tester) async {
  await tester.tap(find.byType(ExpandUpMenuButton));
  await tester.pumpAndSettle();
}

Offset _itemCenter(WidgetTester tester, String label) {
  return tester.getCenter(find.text(label));
}

void main() {
  testWidgets('收起态不显示任何菜单文字', (tester) async {
    await _pumpApp(tester);

    for (final label in _labels) {
      expect(find.text(label), findsNothing);
    }
  });

  testWidgets('点击中心圆展开后显示全部标签', (tester) async {
    await _pumpApp(tester);
    await _openMenu(tester);

    for (final label in _labels) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('点击遮罩空白处收起菜单', (tester) async {
    await _pumpApp(tester);
    await _openMenu(tester);

    await tester.tapAt(const Offset(80, 80));
    await tester.pumpAndSettle();

    for (final label in _labels) {
      expect(find.text(label), findsNothing);
    }
  });

  testWidgets('再次点击中心圆收起菜单', (tester) async {
    await _pumpApp(tester);
    await _openMenu(tester);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    for (final label in _labels) {
      expect(find.text(label), findsNothing);
    }
  });

  testWidgets('拖拽使矩形环旋转', (tester) async {
    await _pumpApp(tester);
    await _openMenu(tester);
    final before = _itemCenter(tester, _labels.first);

    final gesture = await tester.startGesture(const Offset(700, 480));
    for (var step = 0; step < 4; step++) {
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();
    }
    final after = _itemCenter(tester, _labels.first);
    expect(after, isNot(before));

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('鼠标滚轮使矩形环旋转', (tester) async {
    await _pumpApp(tester);
    await _openMenu(tester);
    final before = _itemCenter(tester, _labels.first);

    await tester.sendEventToBinding(
      PointerScrollEvent(
        viewId: tester.view.viewId,
        position: const Offset(400, 300),
        scrollDelta: const Offset(0, 120),
      ),
    );
    await tester.pump();
    final after = _itemCenter(tester, _labels.first);
    expect(after, isNot(before));
  });

  testWidgets('没有菜单项时仍可开合', (tester) async {
    await _pumpApp(tester, items: []);
    await _openMenu(tester);

    expect(tester.takeException(), isNull);
    expect(find.text(_labels.first), findsNothing);

    await tester.tapAt(const Offset(80, 80));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
