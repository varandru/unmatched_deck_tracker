import 'dart:convert';

import 'package:flutter/services.dart';

import 'deck.dart';

class ReleaseSet {
  String tag;
  String name;
  String releaseDate;
  List<String> characterNames;
  List<ShortDeck> characters = [];

  ReleaseSet(
      {required this.tag,
      required this.name,
      required this.releaseDate,
      required this.characterNames});

  ReleaseSet.fromJson(Map<String, dynamic> json)
      : tag = json['tag'],
        name = json['name'],
        releaseDate = json['release_date'],
        characterNames = json['characters'].cast<String>();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['tag'] = tag;
    data['name'] = name;
    data['release_date'] = releaseDate;
    data['characters'] = characterNames;
    return data;
  }

  bool loadCharacters(List<ShortDeck> decks) {
    characters.clear();
    for (var characterName in characterNames) {
      int index = decks.indexWhere((element) => element.name == characterName);
      if (index == -1) {
        // print("Deck $characterName not found!");
        return false;
      } else {
        characters.add(decks[index]);
      }
    }

    return true;
  }
}

Future<List<ReleaseSet>> getReleaseSets() async {
  List<ReleaseSet> sets = [];
  List<dynamic> json = await jsonDecode(await rootBundle
      .loadString('unmatched_deck_tracker_assets/other/sets.json'));

  for (var set in json) {
    ReleaseSet releaseSet = ReleaseSet.fromJson(set);
    sets.add(releaseSet);
  }

  return sets;
}
