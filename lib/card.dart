enum CardType { attack, versatile, defence, scheme }

enum CardSortType { byName, byValue, byType }

CardType typeFromScheme(String type) {
  if (type == "attack") {
    return CardType.attack;
  } else if (type == "defence") {
    return CardType.defence;
  } else if (type == "versatile") {
    return CardType.versatile;
  } else if (type == "scheme") {
    return CardType.scheme;
  } else {
    throw UnsupportedError("Wrong card type: $type");
  }
}

String combineCardText(String? basicText, String? immediateText,
    String? duringText, String? afterText) {
  String combinedText = "";
  if (basicText != null) {
    combinedText += basicText;
  }
  if (immediateText != null) {
    if (combinedText.isNotEmpty) {
      combinedText += '\n';
    }
    combinedText += "Immediately: $immediateText";
  }
  if (duringText != null) {
    if (combinedText.isNotEmpty) {
      combinedText += '\n';
    }
    combinedText += "During Combat: $duringText";
  }
  if (afterText != null) {
    if (combinedText.isNotEmpty) {
      combinedText += '\n';
    }
    combinedText += "After Combat: $afterText";
  }
  return combinedText;
}

int cardSortTypeToInt(CardSortType type) {
  switch (type) {
    case CardSortType.byName:
      return 0;
    case CardSortType.byType:
      return 1;
    case CardSortType.byValue:
      return 2;
  }
}

String cardSortTypeName(CardSortType type) {
  switch (type) {
    case CardSortType.byName:
      return "By Name";
    case CardSortType.byType:
      return "By Type";
    case CardSortType.byValue:
      return "By Value";
  }
}

CardSortType intToCardSortType(int type) {
  switch (type) {
    case 0:
      return CardSortType.byName;
    case 1:
      return CardSortType.byType;
    default:
      return CardSortType.byValue;
  }
}

int sortCardsByName(Card a, Card b) => a.name.compareTo(b.name);

int sortCardsByType(Card a, Card b) {
  return Enum.compareByIndex(a.type, b.type);
}

int sortCardsByValue(Card a, Card b) {
  if (a.value == b.value) {
    return 0;
  }
  if (a.value == null && b.value != null) {
    return 1;
  }
  if (a.value != null && b.value == null) {
    return -1;
  }
  if (a.value! < b.value!) {
    return -1;
  }
  return 1;
}

int sortCardByTypeFull(Card a, Card b) {
  int res = 0;
  if ((res = sortCardsByType(a, b)) == 0) {
    if ((res = sortCardsByValue(a, b)) == 0) {
      return sortCardsByName(a, b);
    }
  }
  return res;
}

int sortCardByValueFull(Card a, Card b) {
  int res = 0;
  if ((res = sortCardsByValue(a, b)) == 0) {
    return sortCardsByName(a, b);
  }
  return res;
}

int Function(Card, Card) getCardSort(CardSortType cardSortType) {
  switch (cardSortType) {
    case CardSortType.byName:
      return sortCardsByName;
    case CardSortType.byType:
      return sortCardByTypeFull;
    case CardSortType.byValue:
      return sortCardByValueFull;
  }
}

class Card {
  Card(
      {required this.name,
      required this.characterName,
      required this.type,
      required this.count,
      required this.text,
      this.value,
      required this.boost});

  Card.fromOther(Card other)
      : name = other.name,
        characterName = other.characterName,
        value = other.value,
        boost = other.boost,
        type = other.type,
        text = other.text,
        count = other.count;

  Card.fromJson(Map<String, dynamic> json)
      : name = json["title"],
        type = typeFromScheme(json["type"]),
        characterName = json["characterName"],
        value = json["value"],
        boost = json["boost"],
        text = combineCardText(json["basicText"], json["immediateText"],
            json["duringText"], json["afterText"]),
        count = json["quantity"];

  String name;
  String characterName;
  int? value;
  int boost;
  CardType type;
  String text;
  int count;
  bool expanded = false;
}
