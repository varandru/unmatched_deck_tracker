import 'package:flutter/material.dart';
import 'package:unmatched_deck_tracker/deck.dart';

import 'deck_list_tile.dart';
import 'set.dart';

class SetWidget extends StatelessWidget {
  const SetWidget(
    this.set, {
    required this.isTwoPlayerMode,
    this.previousChoice,
    required this.deckGetter,
    super.key,
  });

  final ReleaseSet set;
  final ShortDeck? previousChoice;
  final bool isTwoPlayerMode;
  final ValueGetter<List<ReleaseSet>> deckGetter;

  @override
  Widget build(BuildContext context) =>
      ExpansionTile(title: Text(set.name), initiallyExpanded: true, children: [
        ListView.builder(
            itemCount: set.characters.length,
            shrinkWrap: true,
            primary: false,
            itemBuilder: ((context, index) => DeckListTile(
                  set.characters[index],
                  index: index,
                  deckGetter: deckGetter,
                  previousChoice: () => previousChoice,
                  isTwoPlayerMode: isTwoPlayerMode,
                  isChosen: previousChoice != null
                      ? set.characters[index] == previousChoice!
                      : false,
                )))
      ]);
}
