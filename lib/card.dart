enum CardType { attack, defence, versatile, scheme }

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
    String? duringText, String? afterText, String? boostTrick) {
  String combinedText = "";
  if (boostTrick != null) {
    combinedText += "Boost Trick: $boostTrick";
  }
  if (basicText != null) {
    if (combinedText.isNotEmpty) {
      combinedText += '\n';
    }
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
            json["duringText"], json["afterText"], json["boostTrick"]),
        count = json["quantity"];

  String name;
  String characterName;
  int? value;
  int boost;
  CardType type;
  String text;
  int count;
}
