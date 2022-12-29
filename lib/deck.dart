import 'dart:convert';

import 'package:flutter/services.dart';

import 'card.dart';

enum TileType {
  handCard,
  deckCard,
  discardCard,
  handHeader,
  deckHeader,
  discardHeader
}

class ShortDeck {
  ShortDeck(this.name, this.filePath,
      {required this.heroName,
      required this.hp,
      required this.isRanged,
      required this.move});

  ShortDeck.fromJson(Map<String, dynamic> json, this.filePath)
      : name = json["name"],
        heroName = json["hero"]["name"],
        isRanged = json["hero"]["isRanged"],
        hp = json["hero"]["hp"],
        move = json["hero"]["move"];

  @override
  String toString() {
    return "$name: $filePath";
  }

  String name;
  String heroName;
  bool isRanged;
  int hp;
  int move;

  String filePath;
}

class PileOfCards {
  PileOfCards();
  PileOfCards.fromJson(Map<String, dynamic> json) {
    for (dynamic card in json["cards"]) {
      Card parsedCard = Card.fromJson(card);
      _cards.add(parsedCard);
      _count += parsedCard.count;
    }
  }
  // ignore: prefer_final_fields
  List<Card> _cards = [];
  // Count of all the cards in the deck. Should be 30 for most characters
  int _count = 0;

  List<Card> get cards => _cards;
  // Count of all the cards in the deck. Should be 30 for most characters
  int get count => _count;

  // Count of all *unique* cards in the deck
  int get length => _cards.length;

  void addCard(Card card) {
    int index = _cards.indexWhere((element) => card.name == element.name);
    _count++;
    if (index == -1) {
      // A reference is always passed. Thus, we have to create a copy
      Card newCard = Card.fromOther(card);
      newCard.count = 1;
      _cards.add(newCard);
    } else {
      _cards[index].count++;
    }
  }

  bool removeCard(Card card) {
    int index = _cards.indexWhere((element) => card.name == element.name);
    if (index == -1) {
      // Shouldn't happen. But whatever
      return false;
    } else {
      _count--;
      _cards[index].count--;
      if (_cards[index].count <= 0) {
        _cards.removeAt(index);
      }
      return true;
    }
  }

  void sort(CardSortType sortType) {
    _cards.sort(getCardSort(sortType));
  }

  void setExpanded(bool expanded) {
    for (var card in _cards) {
      card.expanded = expanded;
    }
  }
}

class DeckInformation {
  DeckInformation(ShortDeck shortDeck) : summary = shortDeck;

  Future<bool> fillDeckFromFile() async {
    if (_initialized) {
      return true;
    }
    String encodedJson = await rootBundle.loadString(summary.filePath);
    Map<String, dynamic> json = jsonDecode(encodedJson);
    deck = PileOfCards.fromJson(json);

    _initialized = true;

    return true;
  }

  // How many items in a list the deck takes. The summary size of all the piles
  // of cards + headers for non-empty ones
  int get itemCount {
    // This is possible to one-line. I'd rather not,
    //this is more readable and expandable
    int count = 0;
    if (hand.cards.isNotEmpty) {
      count += hand.length + 1;
    }

    // Deck may be empty, but its header is always present
    count += deck.length + 1;

    if (discard.cards.isNotEmpty) {
      count += discard.length + 1;
    }
    return count;
  }

  // !!!!! INDICES !!!!!!!
  // If present, always first. Otherwise, never in the list
  int get _handHeaderIndex => hand.cards.isEmpty ? -1 : 0;
  // If hand is not present, always first.
  //If not, goes after the hand and its header
  int get _deckHeaderIndex => hand.cards.isEmpty ? 0 : hand.cards.length + 1;
  // Goes after the deck, which always has at least a header
  int get _discardHeaderIndex => _deckHeaderIndex + deck.length + 1;

  int get totalCardCount => hand.count + deck.count + discard.count;

  TileType tileType(int index) {
    if (index == _handHeaderIndex) {
      return TileType.handHeader;
    }
    if (index == _deckHeaderIndex) {
      return TileType.deckHeader;
    }
    if (index == _discardHeaderIndex) {
      return TileType.discardHeader;
    }
    if (index < _deckHeaderIndex) {
      return TileType.handCard;
    }
    if (index < _discardHeaderIndex) {
      return TileType.deckCard;
    }
    return TileType.discardCard;
  }

  Card handCardByIndex(int index) {
    return hand.cards[index];
  }

  Card deckCardByIndex(int index) {
    return deck.cards[index - _deckHeaderIndex - 1];
  }

  Card discardCardByIndex(int index) {
    return discard.cards[index - _discardHeaderIndex - 1];
  }

  void moveFromDeckToDiscard(Card card) {
    if (deck.removeCard(card)) {
      discard.addCard(card);
    }
  }

  void moveFromDeckToHand(Card card) {
    if (deck.removeCard(card)) {
      hand.addCard(card);
    }
  }

  void moveFromDiscardToDeck(Card card) {
    if (discard.removeCard(card)) {
      deck.addCard(card);
    }
  }

  void moveFromDiscardToHand(Card card) {
    if (discard.removeCard(card)) {
      hand.addCard(card);
    }
  }

  void moveFromHandToDeck(Card card) {
    if (hand.removeCard(card)) {
      deck.addCard(card);
    }
  }

  void moveFromHandToDiscard(Card card) {
    if (hand.removeCard(card)) {
      discard.addCard(card);
    }
  }

  void sort(CardSortType sortType) {
    deck.sort(sortType);
    discard.sort(sortType);
    hand.sort(sortType);
  }

  void setExpanded(bool expanded) {
    deck.setExpanded(expanded);
    discard.setExpanded(expanded);
    hand.setExpanded(expanded);
  }

  ShortDeck summary;
  PileOfCards deck = PileOfCards();
  PileOfCards discard = PileOfCards();
  PileOfCards hand = PileOfCards();
  bool _initialized = false;
}

Future<List<ShortDeck>> getDecksFromAssets() async {
  List<ShortDeck> decks = [];
  RegExp isCharacter = RegExp(r'.*assets\/characters\/.*json$');

  final deckFileNames = json
      .decode(await rootBundle.loadString('AssetManifest.json'))
      .keys
      .where((String key) => isCharacter.hasMatch(key))
      .toList();

  for (String deckFileName in deckFileNames) {
    deckFileName = deckFileName.replaceAll("%20", " ");
    ShortDeck deck = ShortDeck.fromJson(
        await json.decode(await rootBundle.loadString(deckFileName)),
        deckFileName);
    decks.add(deck);
  }

  return decks;
}
