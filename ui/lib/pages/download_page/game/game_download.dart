import 'package:material_ui/material_ui.dart';

class GameDownload extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GameDownloadState();
}

class _GameDownloadState extends State<GameDownload> {
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          color: color.onPrimary,
          margin: EdgeInsetsGeometry.all(8),
          padding: EdgeInsetsGeometry.all(8),
          child: Row(
            children: [
              Text('最新版本'),
              Spacer(),
              Icon(Icons.keyboard_arrow_up_sharp),
            ],
          ),
        ),
      ],
    );
  }
}
