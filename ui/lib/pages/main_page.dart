import 'package:ui/assets.dart';
import 'package:ui/pages/game_list/game_list.dart';
import 'package:ui/pages/home_page/home_page.dart';
import 'package:ui/widgets/floating_navigation.dart';
import 'package:ui/widgets/menu_list_button.dart';
import 'package:ui/widgets/tag.dart';
import 'package:material_ui/material_ui.dart';
import 'package:window_manager/window_manager.dart';

import '../widgets/rect_style.dart';

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
      appBar: AppBar(
        elevation: 1,
        toolbarHeight: 40,
        centerTitle: true,
        titleSpacing: 0,
        title: DragToMoveArea(
          child: Row(
            children: [
              Image.asset(Assets.assets.imgs.icon.keyName, height: 40),
              const SizedBox(width: 10),
              Text('MiUO', style: TextStyle(fontSize: 18)),
              const Spacer(),
              Tag('赞助版', radius: 0, insets: 6, size: 12),
              SizedBox(height: 20, child: VerticalDivider()),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              _isAlwaysOnTop = !await windowManager.isAlwaysOnTop();
              await windowManager.setAlwaysOnTop(_isAlwaysOnTop);
              setState(() {});
            },
            icon: Icon(
              _isAlwaysOnTop ? Icons.push_pin : Icons.push_pin_outlined,
            ),
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
        ],
      ),
      body: FloatingNavigation(
        items: [
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
        ],
        alignment: .bottomEnd,
        direction: .horizontal,
        customButton: ExpandUpMenuButton(
          icon: Icons.add_outlined,
          items: [
            ExpandMenuItem(
              icon: Icons.lightbulb_outline_sharp,
              label: '添加光影包',
              onTap: () {},
            ),
            ExpandMenuItem(
              icon: Icons.text_fields_sharp,
              label: '添加材质包',
              onTap: () {},
            ),
            ExpandMenuItem(
              icon: Icons.important_devices_sharp,
              label: '导入整合包',
              onTap: () {},
            ),
            ExpandMenuItem(
              icon: Icons.videogame_asset_sharp,
              label: '添加游戏版本',
              onTap: () {},
            ),
          ],
        ),
        child: HomePage(),
      ),
    );
  }
}
