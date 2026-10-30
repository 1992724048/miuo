import 'package:material_ui/material_ui.dart';

import '../../rect_style.dart';

class GameCardData {
  const GameCardData(
    this.name, {
    required,
    required this.version,
    required this.modLoader,
    this.icon,
  });

  final Icon? icon;
  final String name;

  final String version;

  final String modLoader;
}

class GameCard extends StatefulWidget {
  const GameCard(this.data, {super.key});

  final GameCardData data;

  @override
  State<StatefulWidget> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0,
      shape: const LinearBorder(),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Padding(
            padding: const EdgeInsetsGeometry.all(4),
            child: Row(
              crossAxisAlignment: .center,
              children: [
                data.icon ?? Icon(Icons.games),
                const SizedBox(width: 8),
                Text(data.name),
              ],
            ),
          ),
          const Spacer(),
          Container(
            color: theme.colorScheme.surfaceContainerHigh,
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      style: RectStyle.iconButton,
                      iconSize: 16,
                      icon: Icon(Icons.folder_copy_sharp),
                      onPressed: () => {},
                    ),
                    IconButton(
                      style: RectStyle.iconButton,
                      iconSize: 20,
                      icon: Icon(Icons.delete_sharp),
                      onPressed: () => {},
                    ),
                  ],
                ),
                IconButton.filled(
                  style: RectStyle.iconButton,
                  onPressed: () => {},
                  padding: const EdgeInsetsGeometry.all(0),
                  iconSize: 32,
                  icon: const Icon(Icons.arrow_right),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
