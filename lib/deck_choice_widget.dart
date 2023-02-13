import 'package:flutter/material.dart';
import 'package:unmatched_deck_tracker/common_defs.dart';
import 'package:unmatched_deck_tracker/set.dart';
import 'package:unmatched_deck_tracker/settings.dart';

import 'deck.dart';
import 'help_dialogs.dart';
import 'set_widget.dart';

class ChosenDeck {
  ChosenDeck(this.sets, this.previousChoice);

  List<ReleaseSet> sets;
  ShortDeck previousChoice;
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
  final PageStorageBucket _bucket = PageStorageBucket();

  Future<List<ReleaseSet>> loadFromMemory() async {
    var decks = await getDecksFromAssets();
    var sets = await getReleaseSets();

    for (var set in sets) {
      if (!set.loadCharacters(decks)) {
        throw Exception("Couldn't load set ${set.name}");
      }
    }

    return sets;
  }

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

  Widget buildSetWidgets(
      List<ReleaseSet> releaseSets, ShortDeck? previousChoice) {
    List<Widget> sets = [];
    for (var set in releaseSets) {
      sets.add(SetWidget(
        set,
        isTwoPlayerMode: isTwoPlayerMode,
        deckGetter: () => releaseSets,
        previousChoice: previousChoice,
        key: PageStorageKey<String>(set.name),
      ));
    }

    return PageStorage(
      bucket: _bucket,
      child: ListView(
        primary: true,
        children: sets,
      ),
    );
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
          future: loadFromMemory(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error! as String),
              );
            }
            if (snapshot.hasData) {
              return PageStorage(
                bucket: _bucket,
                child: buildSetWidgets(
                  snapshot.data!,
                  null,
                ),
              );
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
        body: buildSetWidgets(
          widget.chosenDeck!.sets,
          widget.chosenDeck!.previousChoice,
        ),
      );
    }
  }
}
