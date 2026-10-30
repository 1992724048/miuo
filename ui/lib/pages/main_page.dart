import 'package:ui/assets.dart';
import 'package:ui/pages/home_page/home_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ui/pages/tag.dart';
import 'package:window_manager/window_manager.dart';

import '../rect_style.dart';
import 'floating_navigation.dart';

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
      body: FloatingNavigation(
        items: _buildToolBarActions(),
        alignment: .bottomEnd,
        direction: .horizontal,
        child: HomePage(),
      ),
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
        style: RectStyle.iconButton,
      ),
      IconButton(
        onPressed: () async {
          await windowManager.minimize();
        },
        icon: Icon(Icons.horizontal_rule),
        style: RectStyle.iconButton,
      ),
      IconButton(
        onPressed: () async {
          await windowManager.close();
        },
        icon: Icon(Icons.close),
        style: RectStyle.iconButton,
      ),
    ];
  }

  Widget _buildTopBarTitle() {
    return DragToMoveArea(
      child: Row(
        children: [
          Image.asset(Assets.assets.imgs.icon.keyName, height: 40),
          const SizedBox(width: 10),
          const Text('MiUO', style: TextStyle(fontSize: 18)),
          const Spacer(),
          const Tag('赞助版', radius: 0, insets: 6, size: 12),
          const SizedBox(height: 20, child: VerticalDivider()),
        ],
      ),
    );
  }

  AppBar _buildTitleBar() {
    return AppBar(
      elevation: 2,
      toolbarHeight: 40,
      centerTitle: true,
      titleSpacing: 0,
      title: _buildTopBarTitle(),
      actions: _buildTopBarActions(),
    );
  }

  List<FloatingToolbarItem> _buildToolBarActions() {
    return [
      FloatingToolbarItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        active: true,
        tooltip: '首页',
        onPressed: () => true,
      ),
      FloatingToolbarItem(
        icon: Icons.games_outlined,
        activeIcon: Icons.games_sharp,
        tooltip: '游戏',
        onPressed: () => true,
      ),
      FloatingToolbarItem(
        icon: Icons.download_outlined,
        activeIcon: Icons.download,
        tooltip: '下载',
        onPressed: () => true,
      ),
      FloatingToolbarItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        tooltip: '设置',
        onPressed: () => true,
      ),
    ];
  }
}
