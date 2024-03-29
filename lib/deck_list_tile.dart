import 'package:flutter/material.dart';
import 'package:unmatched_deck_tracker/common_defs.dart';
import 'package:unmatched_deck_tracker/deck_choice_widget.dart';
import 'package:unmatched_deck_tracker/set.dart';

import 'deck.dart';
import 'image_handling.dart';
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
  final ValueGetter<List<ReleaseSet>> deckGetter;
  final ValueGetter<ShortDeck?> previousChoice;
  final bool isChosen;
  final bool isTwoPlayerMode;

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(
        inherit: true,
        fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
        color: Colors.white,
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

    Widget finalNonShadedWidget = Container(
      alignment: Alignment.bottomCenter,
      height: 120.0,
      decoration: BoxDecoration(
        image: DecorationImage(
            fit: BoxFit.cover, image: getCardbackByName(deck.name)),
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
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                maintainState: false,
                builder: (context) {
                  if (isTwoPlayerMode) {
                    return previousChoice() != null
                        ? TwoDecksView(
                            previousChoice()!,
                            secondDeck: deck,
                          )
                        : DeckChoiceWidget(
                            title: "Choose a second deck",
                            chosenDeck: ChosenDeck(deckGetter(), deck),
                            isTwoPlayerMode: isTwoPlayerMode,
                          );
                  } else {
                    return TwoDecksView(deck);
                  }
                }),
          );
        },
      ),
    );

    return Container(
      constraints: const BoxConstraints(maxWidth: maxWideColumnWidth / 2 - 8.0),
      child: isChosen
          ? Card(
              child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.saturation,
                  ),
                  child: finalNonShadedWidget))
          : Card(child: finalNonShadedWidget),
    );
  }
}
