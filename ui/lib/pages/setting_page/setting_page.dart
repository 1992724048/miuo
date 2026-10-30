import 'package:material_ui/material_ui.dart';

import '../floating_navigation.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return _buildBottomBar();
  }

  Widget _buildBottomBar() {
    return FloatingNavigation(
      alignment: .bottomLeft,
      direction: .horizontal,
      items: [
        FloatingToolbarItem(
          icon: Icons.games_outlined,
          activeIcon: Icons.games,
          active: true,
          tooltip: '游戏',
          onPressed: () => true,
        ),
        FloatingToolbarItem(
          icon: Icons.send_time_extension_outlined,
          activeIcon: Icons.send_time_extension_sharp,
          tooltip: '启动器',
          onPressed: () => true,
        ),
        FloatingToolbarItem(
          icon: Icons.checkroom_sharp,
          tooltip: '个性化',
          onPressed: () => true,
        ),
      ],
      child: Padding(
        padding: const EdgeInsetsGeometry.only(bottom: 80),
        child: Text('data'),
      ),
    );
  }
}
