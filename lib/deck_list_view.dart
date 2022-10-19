import 'package:flutter/material.dart';
import 'card_list_tile.dart';
import 'deck.dart';
import 'card.dart' as um;

class DeckListView extends StatefulWidget {
  const DeckListView(Deck deck, this.cardSortType, {super.key}) : _deck = deck;

  final Deck _deck;
  final um.CardSortType cardSortType;

  @override
  State<StatefulWidget> createState() => _DeckListViewState();
}

class _DeckListViewState extends State<DeckListView>
    with AutomaticKeepAliveClientMixin {
  _DeckListViewState() : discardPile = Deck.empty();
  late Deck deck;
  Deck discardPile;

  @override
  void initState() {
    super.initState();
    deck = widget._deck;
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
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    deck.cards.sort(um.getCardSort(widget.cardSortType));
    discardPile.cards.sort(um.getCardSort(widget.cardSortType));
    return ListView.builder(
      itemCount: deck.cards.length + discardPile.cards.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return ListTile(
            title: Text(
              "Deck count = ${deck.deckCount}/${deck.deckCount + discardPile.deckCount}",
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
          );
        }
        if (index < deck.cards.length + 1) {
          return CardListTile(
            deck.cards[index - 1],
            onMinusTap: moveCardToDiscardPile,
            key: ValueKey(deck.cards[index - 1].expanded),
          );
        }
        if (index == deck.cards.length + 1) {
          return Text(
            "Discard pile has ${discardPile.deckCount} cards.",
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          );
        }
        return CardListTile(
          discardPile.cards[index - deck.cards.length - 2],
          key: ValueKey(deck.cards[index - deck.cards.length - 2].expanded),
          onMinusTap: moveCardToDeck,
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
