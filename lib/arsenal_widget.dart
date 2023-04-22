import 'package:flutter/material.dart';
import 'package:unmatched_deck_tracker/arsenal.dart';
import 'package:unmatched_deck_tracker/deck.dart';
import 'package:unmatched_deck_tracker/sidebar.dart';

import 'deck_choice_widget.dart' show goToDeckChoice;
import 'image_handling.dart';

void goToArsenal(BuildContext context) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const ArsenalBaseWidget()),
  );
}

class ArsenalBaseWidget extends StatefulWidget {
  const ArsenalBaseWidget({super.key});

  @override
  State<ArsenalBaseWidget> createState() => _ArsenalBaseWidgetState();
}

class _ArsenalBaseWidgetState extends State<ArsenalBaseWidget> {
  ArsenalDraft _draft = ArsenalDraft();
  // List<ShortDeck> _decks = [];
  bool _loaded = false;

  @override
  void initState() {
    getDecksFromAssets().then((value) {
      setState(() {
        // _decks = value;
        _draft.init(value);
        _loaded = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Widget> pool = [];
    for (var deckName in _draft.pool) {
      pool.add(DeckChoiceCard(
        deckName,
        () => setState(() {
          _draft.clickedCharacter(deckName);
        }),
        _draft.currentPicks.contains(deckName),
      ));
    }

    int charactersPicked = _draft.currentPicks.length;
    int picksLeft = _draft.picksLeft;
    bool picksMatch = charactersPicked == picksLeft;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Arsenal"),
          // TODO help dialog
          // actions: [
          //   // IconButton(
          //   //     onPressed: () {
          //   //       showDialog(
          //   //           context: context,
          //   //           builder: (context) => const MainMenuHelpDialog(false));
          //   //     },
          //   //     icon: helpIcon),
          // ],
        ),
        drawer: const Sidebar(SidebarPosition.arsenal,
            openDeckChoice: goToDeckChoice, openArsenal: goToArsenal),
        bottomNavigationBar: BottomAppBar(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "$charactersPicked/$picksLeft fighters",
              style: TextStyle(
                color: picksMatch ? Colors.black : Colors.red,
              ),
            ),
            TextButton(
              onPressed: picksMatch
                  ? () {
                      if (_draft.confirmSelection()) {
                        print("Confirm selection");
                      }
                    }
                  : null,
              child: const Text("Confirm selection"),
            )
          ],
        )),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(4.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 4.0,
            runSpacing: 4.0,
            children: pool,
          ),
        ));
  }
}

class DeckChoiceCard extends StatelessWidget {
  const DeckChoiceCard(this.deckName, this.fighterSelected, this.isSelected,
      {super.key});

  final String deckName;
  final VoidCallback fighterSelected;

  final bool isSelected;

  final int cardPerRow = 4;

  final double heightFactor = 1.5;

  final double halfSpacing = 4.0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - 4.0;
    final cardWidth = screenWidth / cardPerRow - halfSpacing;
    final cardHeight = cardWidth * heightFactor;
    return InkWell(
      onTap: fighterSelected,
      child: Container(
        alignment: Alignment.bottomCenter,
        height: cardHeight,
        width: cardWidth,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: getCardbackByName(deckName),
          ),
        ),
        child: Center(
          child: Checkbox(
            value: isSelected,
            onChanged: (value) {},
          ),
        ),
      ),
    );
  }
}
