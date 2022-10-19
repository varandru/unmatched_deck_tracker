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

  late Deck deck;
  Deck? secondDeck;

  void _expandAll() {
    setState(() {
      for (var card in deck.cards) {
        card.expanded = true;
      }

      if (secondDeck != null) {
        for (var card in secondDeck!.cards) {
          card.expanded = true;
        }
      }
    });
  }

  void _collapseAll() {
    setState(() {
      for (var card in deck.cards) {
        card.expanded = false;
      }

      if (secondDeck != null) {
        for (var card in secondDeck!.cards) {
          card.expanded = false;
        }
      }
    });
  }

  @override
  void initState() {
    deck = Deck(widget.deck);
    if (widget.secondDeck != null) {
      secondDeck = Deck(widget.secondDeck!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<CardSortType> cardSortType = getCardSortType();

    List<Widget> actions = [
      ExpandCollapseButton(
        expandAll: _expandAll,
        collapseAll: _collapseAll,
      ),
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
      return FutureBuilder(
        future: Future.wait([
          deck.fillDeckFromFile(),
          secondDeck!.fillDeckFromFile(),
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
                        Tab(text: deck.summary.name),
                        Tab(text: secondDeck!.summary.name)
                      ],
                      indicatorColor: Colors.grey.shade800,
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      DeckListView(deck, snapshot.data![2] as CardSortType),
                      DeckListView(secondDeck!,
                          currentSortType = snapshot.data![2] as CardSortType),
                    ],
                  ),
                ),
              )
            : const CircularProgressIndicator(),
      );
    } else {
      return FutureBuilder(
        future: Future.wait([deck.fillDeckFromFile(), cardSortType]),
        builder: (context, snapshot) => snapshot.hasData
            ? Scaffold(
                appBar: AppBar(
                  title: Text(widget.deck.name),
                  actions: actions,
                ),
                body: DeckListView(
                    deck, currentSortType = snapshot.data![1] as CardSortType),
              )
            : const CircularProgressIndicator(),
      );
    }
  }
}
