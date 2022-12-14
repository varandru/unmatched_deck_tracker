import 'package:flutter/material.dart';
import 'package:unmatched_deck_tracker/common_defs.dart';
import 'package:unmatched_deck_tracker/settings.dart';

import 'deck.dart';
import 'deck_list_tile.dart';
import 'help_dialogs.dart';

class ChosenDeck {
  ChosenDeck(this.decks, this.previousChoice);

  List<ShortDeck> decks;
  int previousChoice;
}

class DeckChoiceWidget extends StatefulWidget {
  const DeckChoiceWidget(
      {super.key,
      required this.title,
      this.chosenDeck,
      required this.isTwoPlayerMode});

  final String title;
  final ChosenDeck? chosenDeck;
  final bool isTwoPlayerMode;

  @override
  State<DeckChoiceWidget> createState() => _DeckChoiceWidgetState();
}

class _DeckChoiceWidgetState extends State<DeckChoiceWidget> {
  bool isTwoPlayerMode = false;

  @override
  void initState() {
    super.initState();
    isTwoPlayerMode = widget.isTwoPlayerMode;
    getFirstLaunch().then((value) => value
        ? WidgetsBinding.instance.addPostFrameCallback((_) => showDialog(
              context: context,
              barrierDismissible: false,
              builder: ((context) => WillPopScope(
                  onWillPop: (() => Future.value(false)),
                  child: MainMenuHelpDialog(value))),
            ))
        : null);
  }

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
                  showDialog(
                      context: context,
                      builder: (context) => const MainMenuHelpDialog(false));
                },
                icon: helpIcon),
            IconButton(
                onPressed: () {
                  setState(() {
                    isTwoPlayerMode = !isTwoPlayerMode;
                  });
                  setTwoPlayerMode(isTwoPlayerMode);
                },
                icon: isTwoPlayerMode ? twoPlayerIcon : onePlayerIcon),
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
