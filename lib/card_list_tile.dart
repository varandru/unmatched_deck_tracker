import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'card.dart' as um;
import 'card.dart';
import 'common_defs.dart';

const iconContainerSize = 75.0;
const iconSize = 32.0;

class InkedCallbackButtonInfo {
  final IconData icon;
  final Color color;

  InkedCallbackButtonInfo(this.icon, this.color);
}

class InkedCallbackButton extends StatelessWidget {
  InkedCallbackButton(
      {super.key,
      required this.card,
      required InkedCallbackButtonInfo info,
      required this.callback})
      : icon = info.icon,
        color = info.color;

  final IconData icon;
  final Color color;
  final void Function(um.Card) callback;
  final um.Card card;

  @override
  Widget build(BuildContext context) => Ink(
        decoration: ShapeDecoration(
          color: color,
          shape: const CircleBorder(),
        ),
        child: IconButton(
          icon: Icon(icon),
          onPressed: () => callback(card),
        ),
      );
}

class TypeIcon extends StatelessWidget {
  const TypeIcon(this.type, {super.key, this.value});

  final CardType type;
  final int? value;

  String assetPath() {
    switch (type) {
      case CardType.attack:
        return "unmatched_deck_tracker_assets/images/type_markers/attack.svg";
      case CardType.defence:
        return "unmatched_deck_tracker_assets/images/type_markers/defence.svg";
      case CardType.versatile:
        return "unmatched_deck_tracker_assets/images/type_markers/versatile.svg";
      case CardType.scheme:
        return "unmatched_deck_tracker_assets/images/type_markers/scheme.svg";
    }
  }

  Color backgroundColor() {
    switch (type) {
      case CardType.attack:
        return const Color(0xffdc3034);
      case CardType.defence:
        return const Color(0xff2c76ac);
      case CardType.versatile:
        return const Color(0xff6c4e8d);
      case CardType.scheme:
        return const Color(0xfffcbd71);
    }
  }

  @override
  Widget build(BuildContext context) {
    {
      return Container(
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            color: backgroundColor()),
        height: iconContainerSize,
        width: iconContainerSize,
        child: value == null
            ? SizedBox(
                height: iconSize,
                width: iconSize,
                child: SvgPicture.asset(
                  assetPath(),
                  fit: BoxFit.scaleDown,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: iconSize,
                    width: iconSize,
                    child: SvgPicture.asset(assetPath()),
                  ),
                  Text(
                    "$value",
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge!
                        .copyWith(color: Colors.white),
                  ),
                ],
              ),
      );
    }
  }
}

class CardListTile extends StatelessWidget {
  const CardListTile(this.card,
      {super.key,
      required this.rightInfo,
      required this.onRightTap,
      required this.leftInfo,
      required this.onLeftTap});

  final um.Card card;
  final InkedCallbackButtonInfo rightInfo;
  final void Function(um.Card) onRightTap;
  final InkedCallbackButtonInfo leftInfo;
  final void Function(um.Card) onLeftTap;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: card.expanded,
      leading: TypeIcon(
        card.type,
        value: card.value,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkedCallbackButton(
            info: leftInfo,
            callback: onLeftTap,
            card: card,
          ),
          const SizedBox(width: 3.0),
          InkedCallbackButton(
            info: rightInfo,
            callback: onRightTap,
            card: card,
          ),
        ],
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              card.name,
              softWrap: true,
              overflow: TextOverflow.fade,
            ),
          ),
          Text("x${card.count}")
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Boost: ${card.boost}"),
          Text(card.characterName.toCapitalized()),
        ],
      ),
      children: [
        Container(
          margin: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 20.0,
          ),
          child: Text(
            card.text,
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ),
      ],
    );
  }
}
