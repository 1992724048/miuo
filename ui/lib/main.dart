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

  Widget _buildApp(ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
    final light = ThemeData(
      fontFamily: 'HarmonyOS Sans SC',
      colorSchemeSeed: lightDynamic?.primary,
      brightness: .light,
    );

    final dark = ThemeData(
      fontFamily: 'HarmonyOS Sans SC',
      colorSchemeSeed: darkDynamic?.primary,
      brightness: .dark,
    );

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
