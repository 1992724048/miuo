import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:material_ui/material_ui.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:ui/pages/main_page.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(860, 600),
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

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: _buildApp);
  }

  static final _subThemeData = const FlexSubThemesData(
    interactionEffects: true,
    tintedDisabledControls: true,
    blendOnColors: true,
    useM2StyleDividerInM3: true,
    inputDecoratorIsFilled: true,
    inputDecoratorBorderType: FlexInputBorderType.outline,
    alignedDropdown: true,
    navigationRailUseIndicator: true,
  );

  static ThemeData light = FlexThemeData.light(
    scheme: FlexScheme.blue,
    subThemesData: _subThemeData,
    fontFamily: 'HarmonyOS Sans SC',
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: cupertino.CupertinoThemeData(applyThemeToAll: true)
        .noDefault(),
  );

  static ThemeData dark = FlexThemeData.dark(
    scheme: FlexScheme.blue,
    subThemesData: _subThemeData,
    fontFamily: 'HarmonyOS Sans SC',
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: cupertino.CupertinoThemeData(applyThemeToAll: true)
        .noDefault(),
  );

  Widget _buildApp(ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      //showPerformanceOverlay: kDebugMode,
      title: 'miuo',
      theme: light,
      darkTheme: dark,
      home: MainPage(),
    );
  }
}
