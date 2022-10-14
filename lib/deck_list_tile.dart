import 'package:flutter/material.dart';
import 'package:unmatched_deck_tracker/deck_choice_widget.dart';

import 'deck.dart';
import 'two_deck_view.dart';

class DeckListTile extends StatelessWidget {
  const DeckListTile(this.deck,
      {super.key,
      required this.index,
      required this.deckGetter,
      required this.previousChoice,
      required this.isTwoPlayerMode,
      this.isChosen = false});

  final ShortDeck deck;
  final int index;
  final ValueGetter<List<ShortDeck>> deckGetter;
  final ValueGetter<int?> previousChoice;
  final bool isChosen;
  final bool isTwoPlayerMode;

  String getCardbackPath() => "assets/images/cardbacks/${deck.name}.jpg";

  @override
  Widget build(BuildContext context) {
    Color textColor = isChosen ? Colors.grey : Colors.white;

    TextStyle style = TextStyle(
        inherit: true,
        fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
        color: textColor,
        shadows: const [
          Shadow(
              // bottomLeft
              offset: Offset(-1.0, -1.0),
              color: Colors.black),
          Shadow(
              // bottomRight
              offset: Offset(1.0, -1.0),
              color: Colors.black),
          Shadow(
              // topRight
              offset: Offset(1.0, 1.0),
              color: Colors.black),
          Shadow(
              // topLeft
              offset: Offset(-1.0, 1.0),
              color: Colors.black),
        ]);

    return Card(
      child: Container(
        alignment: Alignment.bottomCenter,
        height: 120.0,
        decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover, image: AssetImage(getCardbackPath())),
        ),
        child: ListTile(
          title: Text(deck.name,
              style: style.copyWith(
                  fontSize: Theme.of(context).textTheme.titleLarge?.fontSize)),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(deck.heroName, style: style),
              Text("${deck.hp} HP", style: style),
              Text("${deck.move} move", style: style)
            ],
          ),
          selected: isChosen,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  maintainState: false,
                  builder: (context) {
                    if (isTwoPlayerMode) {
                      return previousChoice() != null
                          ? TwoDecksView(
                              deckGetter()[previousChoice()!],
                              secondDeck: deck,
                            )
                          : DeckChoiceWidget(
                              title: "Choose a second deck",
                              chosenDeck: ChosenDeck(deckGetter(), index),
                              isTwoPlayerMode: isTwoPlayerMode,
                            );
                    } else {
                      return TwoDecksView(deck);
                    }
                  }),
            );
          },
        ),
      ),
    );
  }
}
