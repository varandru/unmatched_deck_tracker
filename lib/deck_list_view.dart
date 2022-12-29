import 'package:flutter/material.dart';
import 'card_list_tile.dart';
import 'deck.dart';
import 'card.dart' as um;

class DeckListView extends StatefulWidget {
  const DeckListView(DeckInformation deck, this.cardSortType, {super.key})
      : _deck = deck;

  final DeckInformation _deck;
  final um.CardSortType cardSortType;

  @override
  State<StatefulWidget> createState() => _DeckListViewState();
}

class _DeckListViewState extends State<DeckListView>
    with AutomaticKeepAliveClientMixin {
  _DeckListViewState();
  late DeckInformation deckInfo;

  @override
  void initState() {
    super.initState();
    deckInfo = widget._deck;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    deckInfo.sort(widget.cardSortType);
    return ListView.builder(
      itemCount: deckInfo.itemCount,
      itemBuilder: (context, index) {
        switch (deckInfo.tileType(index)) {
          case TileType.handHeader:
            // TODO Section Header class
            return ListTile(
              title: Text(
                "Deck count = ${deckInfo.hand.count}",
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
            );
          case TileType.deckHeader:
            return ListTile(
              title: Text(
                "Deck count = ${deckInfo.deck.count}/${deckInfo.totalCardCount}",
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
            );
          case TileType.discardHeader:
            return Text(
              "Discard pile has ${deckInfo.discard.count} cards.",
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            );
          case TileType.handCard:
            return CardListTile(deckInfo.handCardByIndex(index),
                onMinusTap: deckInfo.moveFromHandToDiscard);
          case TileType.deckCard:
            return CardListTile(deckInfo.deckCardByIndex(index),
                onMinusTap: deckInfo.moveFromDeckToDiscard);
          case TileType.discardCard:
            return CardListTile(deckInfo.discardCardByIndex(index),
                onMinusTap: deckInfo.moveFromDiscardToDeck);
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
