import 'package:flutter/material.dart';
import 'card_list_tile.dart';
import 'deck.dart';
import 'card.dart' as um;

class DeckListView extends StatefulWidget {
  const DeckListView(Deck deck, {super.key}) : _deck = deck;

  final Deck _deck;

  @override
  State<StatefulWidget> createState() => _DeckListViewState();
}

class _DeckListViewState extends State<DeckListView> {
  late Deck deck;
  late Deck discardPile;

  @override
  void initState() {
    super.initState();
    deck = widget._deck;
    discardPile = Deck(ShortDeck("placeholder", ""));
    discardPile.cards.clear();
  }

  void moveCardToDiscardPile(um.Card card) {
    setState(() {
      int cardInDeckIndex =
          deck.cards.indexWhere((element) => card.name == element.name);
      if (cardInDeckIndex == -1) {
        return;
      } else {
        deck.cards[cardInDeckIndex].count--;
        deck.deckCount--;
        if (deck.cards[cardInDeckIndex].count <= 0) {
          deck.cards.removeAt(cardInDeckIndex);
        }
      }
      int cardInDiscardIndex =
          discardPile.cards.indexWhere((element) => card.name == element.name);
      discardPile.deckCount++;
      if (cardInDiscardIndex == -1) {
        um.Card newCard = um.Card.fromOther(card);
        newCard.count = 1;
        discardPile.cards.add(newCard);
      } else {
        discardPile.cards[cardInDiscardIndex].count += 1;
      }

      deck.cards.sort(((a, b) => a.name.compareTo(b.name)));
      discardPile.cards.sort(((a, b) => a.name.compareTo(b.name)));
    });
  }

  void moveCardToDeck(um.Card card) {
    setState(() {
      int cardInDiscardIndex =
          discardPile.cards.indexWhere((element) => card.name == element.name);
      if (cardInDiscardIndex == -1) {
        return;
      } else {
        discardPile.cards[cardInDiscardIndex].count--;
        discardPile.deckCount--;
        if (discardPile.cards[cardInDiscardIndex].count <= 0) {
          discardPile.cards.removeAt(cardInDiscardIndex);
        }
      }
      int cardInDeckIndex =
          deck.cards.indexWhere((element) => card.name == element.name);
      deck.deckCount++;
      if (cardInDeckIndex == -1) {
        um.Card newCard = um.Card.fromOther(card);
        newCard.count = 1;
        deck.cards.add(newCard);
      } else {
        deck.cards[cardInDeckIndex].count++;
      }

      deck.cards.sort(((a, b) => a.name.compareTo(b.name)));
      discardPile.cards.sort(((a, b) => a.name.compareTo(b.name)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text(
              "deck count = ${deck.deckCount}, discard count = ${discardPile.deckCount}"),
        ),
        ExpansionTile(
          title: const Text("Deck"),
          children: List<CardListTile>.generate(
              deck.cards.length,
              (index) => CardListTile(
                    deck.cards[index],
                    onMinusTap: moveCardToDiscardPile,
                    onPlusTap: moveCardToDeck,
                  ),
              growable: false),
        ),
        ExpansionTile(
          title: const Text("Discard Pile"),
          children: List<CardListTile>.generate(
              discardPile.cards.length,
              (index) => CardListTile(
                    discardPile.cards[index],
                    onMinusTap: moveCardToDeck,
                    onPlusTap: moveCardToDiscardPile,
                  ),
              growable: false),
        ),
      ],
    );
  }
}
