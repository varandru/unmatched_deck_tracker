import 'package:flutter/material.dart';
import 'card.dart' as um;

class CardListTile extends StatefulWidget {
  const CardListTile(this.card,
      {super.key, required this.onPlusTap, required this.onMinusTap});

  final um.Card card;
  final Function(um.Card) onPlusTap;
  final Function(um.Card) onMinusTap;

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
    return ListTile(
      leading: IconButton(
        icon: const Icon(Icons.remove),
        onPressed: () => widget.onMinusTap(widget.card),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () => widget.onPlusTap(widget.card),
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
    );
  }
}
