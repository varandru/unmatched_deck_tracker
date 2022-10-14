import 'package:flutter/material.dart';
import 'package:unmatched_deck_tracker/card.dart';
import 'package:unmatched_deck_tracker/settings.dart';
import 'common_defs.dart';
import 'deck.dart';
import 'deck_list_view.dart';
import 'help_dialogs.dart';

class TwoDecksView extends StatefulWidget {
  const TwoDecksView(this.deck, {this.secondDeck, super.key});

  final ShortDeck deck;
  final ShortDeck? secondDeck;

  @override
  State<TwoDecksView> createState() => _TwoDecksViewState();
}

class _TwoDecksViewState extends State<TwoDecksView> {
  CardSortType currentSortType = CardSortType.byName;

  @override
  Widget build(BuildContext context) {
    Deck longDeck = Deck(widget.deck);
    Future<CardSortType> cardSortType = getCardSortType();

    List<Widget> actions = [
      PopupMenuButton<CardSortType>(
          icon: const Icon(Icons.sort),
          itemBuilder: (context) => CardSortType.values
              .map((e) => PopupMenuItem<CardSortType>(
                  value: e, child: Text(cardSortTypeName(e))))
              .toList(growable: false),
          onSelected: ((value) => setState(() {
                setCardSortType(value);
                currentSortType = value;
              }))),
      IconButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => const DeckViewHelpDialog());
          },
          icon: helpIcon),
    ];

    if (widget.secondDeck != null) {
      Deck secondLongDeck = Deck(widget.secondDeck!);
      return FutureBuilder(
        future: Future.wait([
          longDeck.fillDeckFromFile(),
          secondLongDeck.fillDeckFromFile(),
          cardSortType,
        ]),
        builder: (context, snapshot) => snapshot.hasData
            ? DefaultTabController(
                length: 2,
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text("Fight!"),
                    actions: actions,
                    bottom: TabBar(
                      tabs: [
                        Tab(text: longDeck.summary.name),
                        Tab(text: secondLongDeck.summary.name)
                      ],
                      indicatorColor: Colors.grey.shade800,
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      DeckListView(longDeck, snapshot.data![2] as CardSortType),
                      DeckListView(secondLongDeck,
                          currentSortType = snapshot.data![2] as CardSortType),
                    ],
                  ),
                ),
              )
            : const CircularProgressIndicator(),
      );
    } else {
      return FutureBuilder(
        future: Future.wait([longDeck.fillDeckFromFile(), cardSortType]),
        builder: (context, snapshot) => snapshot.hasData
            ? Scaffold(
                appBar: AppBar(
                  title: Text(widget.deck.name),
                  actions: actions,
                ),
                body: DeckListView(longDeck,
                    currentSortType = snapshot.data![1] as CardSortType),
              )
            : const CircularProgressIndicator(),
      );
    }
  }
}
