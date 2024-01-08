import 'package:flutter/material.dart';

import 'common_defs.dart';
import 'image_handling.dart';

class HeroView extends StatelessWidget {
  const HeroView({
    super.key,
    required this.heroes,
    this.currentPicks,
    this.clickedCharacter,
    required this.scrollable,
    this.cardPerRow = 4,
    this.spacing = 4.0,
    required this.cardType,
    this.cardSize = CardSize.medium,
  });

  final List<String> heroes;
  final Set<String>? currentPicks;
  final bool scrollable;
  final DeckChoiceCardType cardType;
  final CardSize cardSize;
  final void Function(String)? clickedCharacter;

  final int cardPerRow;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    double cardWidth =
        getEvenlySpacedWidth(context, cardPerRow, cardSize, spacing: spacing);

    List<Widget> cardbacks = [];
    for (var heroName in heroes) {
      bool selected = false;
      if (currentPicks != null) {
        if (currentPicks!.contains(heroName)) {
          selected = true;
        }
      }

      void Function()? fighterSelected;
      if (clickedCharacter != null) {
        fighterSelected = () => clickedCharacter!(heroName);
      }

      cardbacks.add(DeckChoiceCard(
        heroName,
        cardType,
        fighterSelected: fighterSelected,
        isSelected: selected,
        cardWidth: cardWidth,
      ));
    }

    if (scrollable) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(standardSpacing),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: spacing,
          runSpacing: spacing,
          children: cardbacks,
        ),
      );
    } else {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: spacing,
        runSpacing: spacing,
        children: cardbacks,
      );
    }
  }
}

enum DeckChoiceCardType { display, selectable, draggable }

class DeckChoiceCard extends StatelessWidget {
  const DeckChoiceCard(
    this.deckName,
    this.cardType, {
    this.fighterSelected,
    bool? isSelected,
    required this.cardWidth,
    super.key,
  }) : _isSelected = isSelected ?? false;

  final String deckName;
  final VoidCallback? fighterSelected;
  final double cardWidth;
  final double heightFactor = 1.5;

  final DeckChoiceCardType cardType;

  final bool _isSelected;

  @override
  Widget build(BuildContext context) {
    Widget stack;

    Text cardName = cardWidth < maxSmallCardWidth + 1.0
        ? const Text("")
        : Text(deckName,
            softWrap: false,
            style: const TextStyle(
                backgroundColor: Colors.black,
                color: Colors.white,
                overflow: TextOverflow.fade));

    if (cardType == DeckChoiceCardType.selectable) {
      stack = Stack(
        children: [
          Center(
              child: _isSelected
                  ? const Icon(Icons.check_circle,
                      size: 50.0, color: Colors.white)
                  : null),
          cardName,
        ],
      );
    } else {
      stack = cardName;
    }

    var card = Container(
      alignment: Alignment.bottomCenter,
      height: cardWidth * heightFactor,
      width: cardWidth,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: getCardbackByName(deckName),
        ),
      ),
      child: stack,
    );

    switch (cardType) {
      case DeckChoiceCardType.display:
        return card;
      case DeckChoiceCardType.selectable:
        return InkWell(
          onTap: fighterSelected,
          child: card,
        );
      case DeckChoiceCardType.draggable:
        return Draggable<String>(feedback: card, data: deckName, child: card);
    }
  }
}
