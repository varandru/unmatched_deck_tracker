import 'package:flutter/material.dart';
import 'package:unmatched_deck_tracker/deck.dart';

import 'deck_list_tile.dart';
import 'set.dart';

class SetWidget extends StatefulWidget {
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
  State<SetWidget> createState() => _SetWidgetState();
}

class _SetWidgetState extends State<SetWidget> {
  @override
  Widget build(BuildContext context) => ExpansionTile(
        title: Text(widget.set.name),
        key: widget.key,
        initiallyExpanded: true,
        children: List<Widget>.generate(
            widget.set.characters.length,
            (index) => DeckListTile(
                  widget.set.characters[index],
                  index: index,
                  deckGetter: widget.deckGetter,
                  previousChoice: () => widget.previousChoice,
                  isTwoPlayerMode: widget.isTwoPlayerMode,
                  isChosen: widget.previousChoice != null
                      ? widget.set.characters[index] == widget.previousChoice!
                      : false,
                )),
      );
}
