import 'dart:developer';

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
        if (deck.cards[cardInDeckIndex].count <= 0) {
          deck.cards.removeAt(cardInDeckIndex);
        }
      }
      int cardInDiscardIndex =
          discardPile.cards.indexWhere((element) => card.name == element.name);
      if (cardInDiscardIndex == -1) {
        card.count = 1;
        discardPile.cards.add(card);
        print("Added ${discardPile.cards.last.count} copies");
      } else {
        print("Card is ${discardPile.cards[cardInDiscardIndex].name}");
        print("Before: ${discardPile.cards[cardInDiscardIndex].count}");
        discardPile.cards[cardInDiscardIndex].count += 1;
        print(
            "Got one more ${discardPile.cards[cardInDiscardIndex].name}. Now have ${discardPile.cards[cardInDiscardIndex].count}");
      }

      deck.cards.sort(((a, b) => a.name.compareTo(b.name)));
      discardPile.cards.sort(((a, b) => a.name.compareTo(b.name)));

      for (um.Card card in discardPile.cards) {
        print("${card.name} : ${card.count}");
      }
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
        if (discardPile.cards[cardInDiscardIndex].count <= 0) {
          discardPile.cards.removeAt(cardInDiscardIndex);
        }
      }
      int cardInDeckIndex =
          deck.cards.indexWhere((element) => card.name == element.name);
      if (cardInDeckIndex == -1) {
        card.count = 1;
        deck.cards.add(card);
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
              "deck count = ${deck.cards.length}, discard count = ${discardPile.cards.length}"),
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
