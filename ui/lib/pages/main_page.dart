import 'package:ui/widgets/floating_navigation.dart';
import 'package:ui/widgets/menu_list_button.dart';
import 'package:ui/widgets/tag.dart';
import 'package:material_ui/material_ui.dart';
import 'package:window_manager/window_manager.dart';

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
              const SizedBox(width: 10),
              Text('MiUO', style: TextStyle(fontSize: 22)),
              const Spacer(),
              Tag('赞助版', radius: 5, insets: 6, size: 12),
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
              _isAlwaysOnTop ? Icons.push_pin_rounded : Icons.push_pin_outlined,
            ),
          ),
          IconButton(
            onPressed: () async {
              await windowManager.minimize();
            },
            icon: Icon(Icons.horizontal_rule_rounded),
          ),
          IconButton(
            onPressed: () async {
              await windowManager.close();
            },
            icon: Icon(Icons.close_rounded),
          ),
        ],
      ),
      body: FloatingNavigation(
        items: [
          FloatingToolbarItem(
            icon: Icons.featured_play_list_outlined,
            activeIcon: Icons.featured_play_list_rounded,
            active: true,
            tooltip: '功能',
            onPressed: () => true,
          ),
          FloatingToolbarItem(
            icon: Icons.info_outline,
            activeIcon: Icons.info_rounded,
            tooltip: '关于',
            onPressed: () => true,
          ),
          FloatingToolbarItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            tooltip: '设置',
            onPressed: () => true,
          ),
        ],
        alignment: .bottomRight,
        direction: .horizontal,
        customButton: ExpandUpMenuButton(
          icon: Icons.menu,
          items: [
            ExpandMenuItem(icon: Icons.home_rounded, label: '菜单', onTap: () {}),
            ExpandMenuItem(
              icon: Icons.eighteen_mp,
              label: '菜单菜单',
              onTap: () {},
            ),
            ExpandMenuItem(
              icon: Icons.one_k_plus,
              label: '菜单菜单菜单',
              onTap: () {},
            ),
            ExpandMenuItem(
              icon: Icons.home_rounded,
              label: '菜单菜单菜单菜单',
              onTap: () {},
            ),
            ExpandMenuItem(
              icon: Icons.home_rounded,
              label: '菜单菜单菜单',
              onTap: () {},
            ),
            ExpandMenuItem(
              icon: Icons.home_rounded,
              label: '菜单菜单',
              onTap: () {},
            ),
            ExpandMenuItem(icon: Icons.home_rounded, label: '菜单', onTap: () {}),
            ExpandMenuItem(icon: Icons.home_rounded, onTap: () {}),
          ],
        ),
        child: Center(
          child: FilledButton(child: const Text('data'), onPressed: () {}),
        ),
      ),
    );
  }
}
