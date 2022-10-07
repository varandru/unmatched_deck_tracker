import 'package:flutter/material.dart';
import 'deck.dart';
import 'deck_list_view.dart';

class TwoDecksView extends StatelessWidget {
  const TwoDecksView(this.deck, {this.secondDeck, super.key});

  final ShortDeck deck;
  final ShortDeck? secondDeck;

  @override
  Widget build(BuildContext context) {
    Deck longDeck = Deck(deck);

    if (secondDeck != null) {
      Deck secondLongDeck = Deck(secondDeck!);
      return FutureBuilder(
        future: Future.wait([
          longDeck.fillDeckFromFile(),
          secondLongDeck.fillDeckFromFile(),
        ]),
        builder: (context, snapshot) => DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Fight!"),
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
                DeckListView(longDeck),
                DeckListView(secondLongDeck),
              ],
            ),
          ),
        ),
      );
    } else {
      return FutureBuilder(
        future: longDeck.fillDeckFromFile(),
        builder: (context, snapshot) => Scaffold(
          appBar: AppBar(
            title: Text(deck.name),
          ),
          body: DeckListView(longDeck),
        ),
      );
    }
  }
}
