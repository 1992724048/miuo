import 'package:material_ui/material_ui.dart';
import 'package:ui/pages/download_page/download_page.dart';
import 'package:ui/pages/other_page/other_page.dart';
import 'package:ui/pages/setting_page/setting_page.dart';

import 'dart:ui';

import '../assets.dart';
import 'floating_navigation.dart';
import 'home_page/home_page.dart';

class BottomControl extends StatefulWidget {
  const BottomControl({super.key});

  @override
  State<StatefulWidget> createState() => _BottomControlState();
}

class _BottomControlState extends State<BottomControl> {
  int _pageIndex = 0;
  late final PageController _pageController = PageController();
  final List<Widget> _pages = [
    HomePage(),
    DownloadPage(),
    SettingPage(),
    OtherPage(),
  ];

  static const _pageActions = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, tooltip: '首页'),
    (icon: Icons.download_outlined, activeIcon: Icons.download, tooltip: '下载'),
    (icon: Icons.settings_outlined, activeIcon: Icons.settings, tooltip: '设置'),
    (icon: Icons.apps, activeIcon: Icons.apps_outage, tooltip: '更多'),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return FloatingNavigation(
      items: _buildToolBarActions(),
      alignment: .bottomEnd,
      direction: .horizontal,
      customButton: _buildMenuButton(),
      child: Stack(
        fit: .expand,
        children: [
          Positioned.fill(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _pageIndex = i),
              children: _pages,
            ),
          ),
          Align(
            alignment: .bottomEnd,
            child: Padding(
              padding: const EdgeInsetsGeometry.fromLTRB(0, 0, 8, 50),
              child: _buildCard(color),
            ),
          ),
        ],
      ),
    );
  }

  List<FloatingToolbarItem> _buildToolBarActions() {
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

  Widget _buildMenuButton() {
    return SizedBox(
      width: 38,
      height: 38,
      child: IconButton.filled(
        icon: const Icon(Icons.arrow_right),
        padding: .zero,
        iconSize: 32,
        tooltip: '启动游戏',
        onPressed: () => {},
        style: IconButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
    );
  }

  Widget _buildCard(ColorScheme color) {
    return SizedBox(
      width: 194,
      height: 76,
      child: Column(
        children: [
          _buildCharacterCard(color),
          Divider(
            height: 0,
            color: color.surfaceContainerHighest,
            thickness: 1,
            radius: BorderRadius.circular(0),
          ),
          _buildGameCard(color),
        ],
      ),
    );
  }

  Widget _buildCharacterCard(ColorScheme color) {
    return _buildCardWidget(
      color,
      'Alex',
      '编辑账户',
      Assets.assets.imgs.alex.keyName,
      const Icon(Icons.edit_outlined, size: 20),
      false,
      () => {},
    );
  }

  Widget _buildGameCard(ColorScheme color) {
    return _buildCardWidget(
      color,
      '26.3 NeoForge',
      '选择版本',
      Assets.assets.imgs.neoforged.keyName,
      const Icon(Icons.chevron_right_sharp),
      null,
      () => {},
    );
  }

  Widget _buildCardWidget(
    ColorScheme color,
    String title,
    String tooltip,
    String img,
    Icon icon,
    bool? offline,
    VoidCallback onPressed,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 156,
          height: 38,
          child: Stack(
            children: [
              Container(
                height: 38,
                padding: const EdgeInsets.all(5),
                color: color.onPrimary,
                child: Row(
                  children: [
                    Image.asset(img, height: 40),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (offline != null)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 5,
                    height: 5,
                    color: offline ? Colors.grey : Colors.green,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 38,
          width: 38,
          child: IconButton.filled(
            onPressed: onPressed,
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            tooltip: tooltip,
            icon: icon,
          ),
        ),
      ],
    );
  }
}
