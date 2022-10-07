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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(deck.name),
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
                        );
                } else {
                  return TwoDecksView(deck);
                }
              }),
        );
      },
    );
  }
}
