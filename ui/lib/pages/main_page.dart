import 'dart:ui';

import 'package:ui/assets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui/pages/tag.dart';
import 'package:window_manager/window_manager.dart';

import 'bottom_control.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  _MainPageState();

  var _isAlwaysOnTop = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildTitleBar(),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: BottomControl(),
    );
  }

  List<Widget> _buildTopBarActions() {
    return [
      IconButton(
        onPressed: () async {
          _isAlwaysOnTop = !await windowManager.isAlwaysOnTop();
          await windowManager.setAlwaysOnTop(_isAlwaysOnTop);
          setState(() {});
        },
        icon: Icon(_isAlwaysOnTop ? Icons.push_pin : Icons.push_pin_outlined),
        style: IconButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      IconButton(
        onPressed: () async {
          await windowManager.minimize();
        },
        icon: Icon(Icons.horizontal_rule),
        style: IconButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      IconButton(
        onPressed: () async {
          await windowManager.close();
        },
        icon: Icon(Icons.close),
        style: IconButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
    ];
  }

  Widget _buildTopBarTitle() {
    return DragToMoveArea(
      child: Row(
        children: [
          Image.asset(Assets.assets.imgs.icon.keyName, height: 40),
          const SizedBox(width: 10),
          const Text('MiUO Launcher', style: TextStyle(fontSize: 18)),
          const Spacer(),
          const Tag('26.1R', radius: 0, insets: 6, size: 12),
          const SizedBox(height: 20, child: VerticalDivider()),
        ],
      ),
    );
  }

  AppBar _buildTitleBar() {
    return AppBar(
      elevation: 0,
      toolbarHeight: 40,
      centerTitle: true,
      titleSpacing: 0,
      title: _buildTopBarTitle(),
      actions: _buildTopBarActions(),
    );
  }
}
