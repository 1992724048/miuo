import 'package:material_ui/material_ui.dart';

import '../floating_navigation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
          icon: Icons.skip_next,
          active: false,
          tooltip: '下一个背景',
          onPressed: () => false,
        ),
      ],
      child: Center(child: Text('背景图片')),
    );
  }
}
