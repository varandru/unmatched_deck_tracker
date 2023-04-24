import 'package:flutter/material.dart';
import 'package:unmatched_deck_tracker/image_handling.dart';

enum SidebarPosition { deckChoice, arsenal }

class Sidebar extends StatelessWidget {
  const Sidebar(this.position,
      {required this.openDeckChoice, required this.openArsenal, super.key});

  final SidebarPosition position;
  final void Function(BuildContext) openDeckChoice;
  final void Function(BuildContext) openArsenal;

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        DrawerHeader(
            child: Container(
                decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: getLogo(),
          ),
        ))),
        ListTile(
          title: const Text("Decks choice"),
          selected: position == SidebarPosition.deckChoice,
          onTap: () {
            if (position != SidebarPosition.deckChoice) {
              openDeckChoice(context);
            }
          },
        ),
        ListTile(
            title: const Text("Arsenal"),
            selected: position == SidebarPosition.arsenal,
            onTap: () {
              if (position != SidebarPosition.arsenal) {
                openArsenal(context);
              }
            }),
      ],
    ));
  }
}
