import 'package:flutter/material.dart';
import 'deck_list_view.dart';

import 'deck.dart';

class DeckListTile extends StatelessWidget {
  const DeckListTile(this.deck, {super.key});

  final ShortDeck deck;

  @override
  Widget build(BuildContext context) {
    Deck longDeck = Deck(deck);
    return ListTile(
      title: Text(deck.name),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            maintainState: false,
            builder: (context) => FutureBuilder(
              future: longDeck.fillDeckFromFile(),
              builder: ((context, snapshot) => Scaffold(
                    appBar: AppBar(
                      title: Text(deck.name),
                    ),
                    body: DeckListView(longDeck),
                  )),
            ),
          ),
        );
      },
    );
  }
}
