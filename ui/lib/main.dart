import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:material_ui/material_ui.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:ui/widgets/floating_navigation.dart';
import 'package:ui/widgets/menu_list_button.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const UI());
}

class UI extends StatelessWidget {
  const UI({super.key});

  static ThemeData light = FlexThemeData.light(
    scheme: FlexScheme.blue,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
    ),
    fontFamily: 'HarmonyOS Sans SC',
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: cupertino.CupertinoThemeData(applyThemeToAll: true).noDefault(),
  );

  static ThemeData dark = FlexThemeData.dark(
    scheme: FlexScheme.blue,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
    ),
    fontFamily: 'HarmonyOS Sans SC',
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: cupertino.CupertinoThemeData(applyThemeToAll: true).noDefault(),
  );

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: _buildApp);
  }

  Widget _buildApp(ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
    return MaterialApp(themeMode: ThemeMode.system, theme: light, darkTheme: dark, home: _AppPage());
  }
}

class _AppPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppPageState();
}

class _AppPageState extends State<_AppPage> {
  _AppPageState();

  var _isAlwaysOnTop = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        toolbarHeight: 40,
        centerTitle: true,
        title: DragToMoveArea(child: Row(children: [Text('miuo'), const Spacer()])),
        actions: [
          IconButton(
            onPressed: () async {
              _isAlwaysOnTop = !await windowManager.isAlwaysOnTop();
              await windowManager.setAlwaysOnTop(_isAlwaysOnTop);
              setState(() {});
            },
            icon: Icon(_isAlwaysOnTop ? Icons.push_pin_rounded : Icons.push_pin_outlined),
          ),
          IconButton(
            onPressed: () async {
              await windowManager.minimize();
            },
            icon: Icon(Icons.horizontal_rule),
          ),
        ],
      ),
      body: FloatingNavigation(
        items: [
          FloatingToolbarItem(
            icon: Icons.home_outlined,
            active: true,
            activeIcon: Icons.home,
            tooltip: '首页',
            onPressed: () => true,
          ),
          FloatingToolbarItem(icon: Icons.search_outlined, tooltip: '搜索', onPressed: () => false),
          FloatingToolbarItem(
            icon: Icons.chat_bubble_outline_outlined,
            activeIcon: Icons.chat_bubble,
            tooltip: '消息',
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
            ExpandMenuItem(icon: Icons.eighteen_mp, label: '菜单菜单', onTap: () {}),
            ExpandMenuItem(icon: Icons.one_k_plus, label: '菜单菜单菜单', onTap: () {}),
            ExpandMenuItem(icon: Icons.home_rounded, label: '菜单菜单菜单菜单', onTap: () {}),
            ExpandMenuItem(icon: Icons.home_rounded, label: '菜单菜单菜单', onTap: () {}),
            ExpandMenuItem(icon: Icons.home_rounded, label: '菜单菜单', onTap: () {}),
            ExpandMenuItem(icon: Icons.home_rounded, label: '菜单', onTap: () {}),
            ExpandMenuItem(icon: Icons.home_rounded, onTap: () {}),
          ],
        ),
        child: Center(
          child: ElevatedButton(child: const Text('data'), onPressed: () {}),
        ),
      ),
    );
  }
}
