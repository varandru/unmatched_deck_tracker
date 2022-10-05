import 'package:flutter/material.dart';
import 'card.dart' as um;

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

class CardListTile extends StatefulWidget {
  const CardListTile(this.card,
      {super.key, required this.onPlusTap, required this.onMinusTap});

  final um.Card card;
  final void Function(um.Card) onPlusTap;
  final void Function(um.Card) onMinusTap;

  @override
  State<StatefulWidget> createState() => _CardListTileState();
}

class _CardListTileState extends State<CardListTile> {
  _CardListTileState();

  int count = 0;

  @override
  void initState() {
    count = widget.card.count;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: InkedCallbackButton(
        callback: widget.onMinusTap,
        color: Colors.redAccent,
        icon: Icons.remove,
        card: widget.card,
      ),
      trailing: InkedCallbackButton(
        callback: widget.onPlusTap,
        color: Colors.greenAccent,
        icon: Icons.add,
        card: widget.card,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              widget.card.name,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
          ),
          Text("x${widget.card.count}")
        ],
      ),
      subtitle: Text("Boost: ${widget.card.boost}"),
      children: [Text(widget.card.text)],
    );
  }
}
