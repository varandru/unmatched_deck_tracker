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

  void _moveFromHandToDiscard(um.Card card) {
    setState(() => deckInfo.moveFromHandToDiscard(card));
  }

  void _moveFromHandToDeck(um.Card card) {
    setState(() => deckInfo.moveFromHandToDeck(card));
  }

  void _moveFromDeckToDiscard(um.Card card) {
    setState(() => deckInfo.moveFromDeckToDiscard(card));
  }

  void _moveFromDeckToHand(um.Card card) {
    setState(() => deckInfo.moveFromDeckToHand(card));
  }

  void _moveFromDiscardToDeck(um.Card card) {
    setState(() => deckInfo.moveFromDiscardToDeck(card));
  }

  void _moveFromDiscardToHand(um.Card card) {
    setState(() => deckInfo.moveFromDiscardToHand(card));
  }

  InkedCallbackButtonInfo toDiscardInfo =
      InkedCallbackButtonInfo(Icons.delete, Colors.red);

  InkedCallbackButtonInfo toDeckInfo =
      InkedCallbackButtonInfo(Icons.restore_from_trash, Colors.yellow.shade900);

  InkedCallbackButtonInfo toHandInfo =
      InkedCallbackButtonInfo(Icons.visibility, Colors.green.shade700);

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
                "Revealed cards count = ${deckInfo.hand.count}",
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
                onRightTap: _moveFromHandToDiscard,
                rightInfo: toDiscardInfo,
                onLeftTap: _moveFromHandToDeck,
                leftInfo: toDeckInfo);
          case TileType.deckCard:
            return CardListTile(deckInfo.deckCardByIndex(index),
                onRightTap: _moveFromDeckToDiscard,
                rightInfo: toDiscardInfo,
                onLeftTap: _moveFromDeckToHand,
                leftInfo: toHandInfo);
          case TileType.discardCard:
            return CardListTile(deckInfo.discardCardByIndex(index),
                onRightTap: _moveFromDiscardToDeck,
                rightInfo: toDeckInfo,
                onLeftTap: _moveFromDiscardToHand,
                leftInfo: toHandInfo);
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
