import 'package:flutter/material.dart';

import 'deck.dart';
import 'deck_list_tile.dart';

class ChosenDeck {
  ChosenDeck(this.decks, this.previousChoice);

  List<ShortDeck> decks;
  int previousChoice;
}

class DeckChoiceWidget extends StatefulWidget {
  const DeckChoiceWidget({super.key, required this.title, this.chosenDeck});

  final String title;
  final ChosenDeck? chosenDeck;

  @override
  State<DeckChoiceWidget> createState() => _DeckChoiceWidgetState();
}

class _DeckChoiceWidgetState extends State<DeckChoiceWidget> {
  // TODO это должно сохраняться в настройки и доставаться оттуда
  bool isTwoPlayerMode = true;

  @override
  Widget build(BuildContext context) {
    bool isChoosingFirstDeck = widget.chosenDeck == null;

    if (isChoosingFirstDeck) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    isTwoPlayerMode = !isTwoPlayerMode;
                  });
                },
                icon: Icon(isTwoPlayerMode
                    ? Icons.people_alt_rounded
                    : Icons.person_rounded))
          ],
        ),
        body: FutureBuilder(
          future: getDecksFromAssets(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error! as String),
              );
            }
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: ((context, index) => DeckListTile(
                        snapshot.data![index],
                        index: index,
                        deckGetter: () => snapshot.data!,
                        previousChoice: () => widget.chosenDeck?.previousChoice,
                        isTwoPlayerMode: isTwoPlayerMode,
                      )));
            }
            return const CircularProgressIndicator();
          },
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView.builder(
            itemCount: widget.chosenDeck!.decks.length,
            itemBuilder: ((context, index) => DeckListTile(
                  widget.chosenDeck!.decks[index],
                  index: index,
                  isChosen: index == widget.chosenDeck!.previousChoice,
                  deckGetter: () => widget.chosenDeck!.decks,
                  previousChoice: () => widget.chosenDeck!.previousChoice,
                  isTwoPlayerMode: isTwoPlayerMode,
                ))),
      );
    }
  }
}
