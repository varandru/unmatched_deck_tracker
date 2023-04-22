import 'package:flutter/material.dart';

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
        const DrawerHeader(child: Text("Menu")),
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
