import 'package:material_ui/material_ui.dart';
import 'package:ui/pages/game_list/game_card.dart';

class GameList extends StatefulWidget {
  const GameList({super.key});

  @override
  State<StatefulWidget> createState() => _GameListState();
}

const List<GameCardData> _testData = [
  GameCardData("26.3 NeoForge", version: "26.3", modLoader: "NeoForge"),
  GameCardData("26.2 NeoForge", version: "26.2", modLoader: "NeoForge"),
  GameCardData("26.1 NeoForge", version: "26.1", modLoader: "NeoForge"),
  GameCardData("1.21.1 NeoForge", version: "1.21.1", modLoader: "NeoForge"),
];

class _GameListState extends State<GameList> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.all(4),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 280,
          mainAxisExtent: 160,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemBuilder: (context, index) => GameCard(_testData[index]),
        itemCount: _testData.length,
      ),
    );
  }
}
