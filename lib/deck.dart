import 'dart:convert';

import 'package:flutter/services.dart';

import 'card.dart';

class ShortDeck {
  ShortDeck(this.name, this.filePath);
  ShortDeck.fromJson(Map<String, dynamic> json, this.filePath)
      : name = json["name"];

  @override
  String toString() {
    return "$name: $filePath";
  }

  String name;
  String filePath;
}

class Deck {
  Deck(ShortDeck shortDeck) : summary = shortDeck;

  Future<bool> fillDeckFromFile() async {
    String encodedJson = await rootBundle.loadString(summary.filePath);
    Map<String, dynamic> json = jsonDecode(encodedJson);
    cards.clear();
    for (dynamic card in json["cards"]) {
      Card parsedCard = Card.fromJson(card);
      cards.add(parsedCard);
      deckCount += parsedCard.count;
    }

    cards.sort(((a, b) => a.name.compareTo(b.name)));

    return true;
  }

  ShortDeck summary;
  List<Card> cards = [];
  int deckCount = 0;
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
