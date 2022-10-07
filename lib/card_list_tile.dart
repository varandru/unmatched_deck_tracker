import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'card.dart' as um;
import 'card.dart';
import 'common_defs.dart';

const iconContainerSize = 75.0;
const iconSize = 32.0;

class InkedCallbackButton extends StatelessWidget {
  const InkedCallbackButton(
      {super.key,
      required this.callback,
      required this.color,
      required this.icon,
      required this.card});

  final IconData icon;
  final void Function(um.Card) callback;
  final Color color;
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
        return "assets/images/type_markers/attack.svg";
      case CardType.defence:
        return "assets/images/type_markers/defence.svg";
      case CardType.versatile:
        return "assets/images/type_markers/versatile.svg";
      case CardType.scheme:
        return "assets/images/type_markers/scheme.svg";
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
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
              ),
      );
    }
  }
}

class CardListTile extends StatelessWidget {
  const CardListTile(this.card, {super.key, required this.onMinusTap});

  final um.Card card;
  final void Function(um.Card) onMinusTap;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: TypeIcon(
        card.type,
        value: card.value,
      ),
      trailing: InkedCallbackButton(
        callback: onMinusTap,
        color: Colors.redAccent,
        icon: Icons.remove,
        card: card,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              card.name,
              softWrap: false,
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
      children: [Text(card.text)],
    );
  }
}
