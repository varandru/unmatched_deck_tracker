import 'dart:convert';

import 'package:flutter/services.dart';

import 'card.dart';

class ShortDeck {
  ShortDeck(this.name, this.filePath);
  ShortDeck.fromJson(Map<String, dynamic> json, this.filePath)
      : name = json["hero"]["name"];

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
      cards.add(Card.fromJson(card));
    }
    return true;
  }

  ShortDeck summary;
  List<Card> cards = [];
}
