import 'package:material_ui/material_ui.dart';
import 'package:ui/pages/download_page/game/game_download.dart';
import 'package:ui/pages/floating_navigation.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<StatefulWidget> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  int _pageIndex = 0;
  late final PageController _pageController = PageController();
  final List<Widget> _pages = [
    GameDownload(),
    GameDownload(),
    GameDownload(),
    GameDownload(),
    GameDownload(),
  ];

  static const _pageActions = [
    (icon: Icons.games_outlined, activeIcon: Icons.games, tooltip: '游戏'),
    (
      icon: Icons.extension_outlined,
      activeIcon: Icons.extension,
      tooltip: '模组',
    ),
    (
      icon: Icons.view_in_ar_sharp,
      activeIcon: Icons.view_in_ar_sharp,
      tooltip: '整合包',
    ),
    (
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_sharp,
      tooltip: '数据包',
    ),
    (icon: Icons.image_outlined, activeIcon: Icons.image_sharp, tooltip: '资源包'),
    (
      icon: Icons.wb_sunny_outlined,
      activeIcon: Icons.wb_sunny_sharp,
      tooltip: '光影包',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _buildBottomBar();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildBottomBar() {
    return FloatingNavigation(
      alignment: .bottomLeft,
      direction: .horizontal,
      items: _buildBottomBarActions(),
      child: Padding(
        padding: const EdgeInsetsGeometry.only(bottom: 80),
        child: PageView(
          controller: _pageController,
          onPageChanged: (i) => setState(() => _pageIndex = i),
          children: _pages,
        ),
      ),
    );
  }

  List<FloatingToolbarItem> _buildBottomBarActions() {
    return _pageActions.indexed.map((entry) {
      final (index, action) = entry;
      return FloatingToolbarItem(
        icon: action.icon,
        activeIcon: action.activeIcon,
        active: _pageIndex == index,
        tooltip: action.tooltip,
        onPressed: () {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
          return true;
        },
      );
    }).toList();
  }
}
