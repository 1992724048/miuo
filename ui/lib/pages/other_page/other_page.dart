import 'package:material_ui/material_ui.dart';

import '../floating_navigation.dart';

class OtherPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OtherPageState();
}

class _OtherPageState extends State<OtherPage> {
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
          icon: Icons.help_center_outlined,
          activeIcon: Icons.help_center_sharp,
          active: true,
          tooltip: '帮助',
          onPressed: () => true,
        ),
        FloatingToolbarItem(
          icon: Icons.info_outline,
          activeIcon: Icons.info_sharp,
          tooltip: '关于',
          onPressed: () => true,
        ),
        FloatingToolbarItem(
          icon: Icons.email_outlined,
          activeIcon: Icons.email_sharp,
          tooltip: '反馈',
          onPressed: () => true,
        ),
        FloatingToolbarItem(
          icon: Icons.inbox_sharp,
          activeIcon: Icons.all_inbox_sharp,
          tooltip: '小工具',
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
