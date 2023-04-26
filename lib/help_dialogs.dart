import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:unmatched_deck_tracker/common_defs.dart';
import 'package:unmatched_deck_tracker/settings.dart';
import 'package:url_launcher/url_launcher.dart';

const Text legalDisclaimer = Text(
    "This app is not published by or affiliated with Restoration Games."
    " The card text is a copyright of Restoration Games, LLC. "
    "The look and design of the cards is a trademark of Restoration "
    "Games, LLC. They are used with permission.",
    style: TextStyle(fontWeight: FontWeight.bold));

const Text oneOrTwoPlayerHelp = Text.rich(
  TextSpan(
    children: <InlineSpan>[
      TextSpan(
          text: "Currently the app supports tracking the deck for one or two "
              "players, as indicated by the icon on top. "),
      WidgetSpan(child: onePlayerIcon),
      TextSpan(
          text: " means that only one deck will be selected and "
              "tracked. To select it, tap on it. "),
      WidgetSpan(child: twoPlayerIcon),
      TextSpan(
          text: " means that two deck will be selected and tracked. "
              "First, select your deck by tapping on it. After that you will "
              "be brought to a similar screen with your selection grayed out. "
              "Unless you are playing a mirror match, choose another deck. "),
      TextSpan(text: "If you are in need of additional help, tap "),
      WidgetSpan(child: helpIcon),
      TextSpan(
          text: " on the tracking screen. It will explain the elements there."),
    ],
  ),
);

const Text deckViewHelp =
    Text("This screen is the tracker itself. It shows the descriptions "
        "of cards in the deck and discard pile, along with the button "
        "to move the cards to discard and back.");

const Text tapOnCardText =
    Text("\u2022 Tap on the card to expand it and read " "the card text.");
const Text moveCardButtonText = Text.rich(TextSpan(children: <InlineSpan>[
  TextSpan(text: "\u2022 Tap on the "),
  WidgetSpan(child: Icon(Icons.remove)),
  TextSpan(
      text: " button to move the card from deck to discard pile and back."),
]));
const Text expandCollapseText = Text.rich(TextSpan(children: <InlineSpan>[
  TextSpan(text: "\u2022 Tap on the "),
  WidgetSpan(child: Icon(Icons.unfold_less)),
  TextSpan(text: " or "),
  WidgetSpan(child: Icon(Icons.unfold_more)),
  TextSpan(text: " to expand or collapse all decks."),
]));

const Text leavingDeckView = Text("You are leaving deck view. "
    "If you do, all tracking progress will be lost. Are you sure?");

const Text confirmingChoiceView =
    Text("Are you sure in your selection? Once you click \"Yes\", "
        "there's no going back.");

const Text arsenalPickHelp = Text("This is the hero picking view. "
    "Click on the characters you're choosing for this round. Chosen fighters "
    "are marked with a checkmark, and the bottom bar shows how many characters"
    " you have left to pick.");

const Text arsenalAssignmentHelp = Text("This is the hero assignment view. "
    "Drag the chosen heroes into their positions from the list at the bottom, "
    "or from another position if you happen to change your mind. "
    "Click the button at the bottom to continue when you're done. ");

Text arsenalLink = Text.rich(
    TextSpan(text: "See official rules for the Arsenal format ", children: [
  TextSpan(
    text: "here",
    style: const TextStyle(
        decoration: TextDecoration.underline, color: Colors.blue),
    recognizer: TapGestureRecognizer()
      ..onTap = () => launchUrl(Uri.parse(
          'https://docs.google.com/document/d/1dNOztTCMpSiRhwNqNqla9xKMb5nqtPSfLuPDwHfYLjU')),
  ),
]));

Text getFighterList(Set<String> fighters) {
  return Text("Your selection is $fighters");
}

class BackingOutOfDeckDialog extends StatelessWidget {
  const BackingOutOfDeckDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Exiting deck view"),
      content: leavingDeckView,
      actions: [
        TextButton(
            onPressed: (() => Navigator.of(context).pop(true)),
            child: const Text("Yes")),
        TextButton(
            onPressed: (() => Navigator.of(context).pop(false)),
            child: const Text("No")),
      ],
    );
  }
}

class ConfirmingChoiceDialog extends StatelessWidget {
  const ConfirmingChoiceDialog(this.fighters, {super.key});

  final Set<String> fighters;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirm?"),
      content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            confirmingChoiceView,
            getFighterList(fighters),
          ]),
      actions: [
        TextButton(
            onPressed: (() => Navigator.of(context).pop(true)),
            child: const Text("Yes")),
        TextButton(
            onPressed: (() => Navigator.of(context).pop(false)),
            child: const Text("No")),
      ],
    );
  }
}

class MainMenuHelpDialog extends StatelessWidget {
  const MainMenuHelpDialog(this.isFirstLaunch, {super.key});

  final bool isFirstLaunch;

  void onPressed(BuildContext context) {
    setFirstLaunch().then((value) => value
        ? ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("This won't show up on start anymore.")),
          )
        : null);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        isFirstLaunch
            ? TimeOutButton(() => onPressed(context))
            : TextButton(
                onPressed: (() => onPressed(context)), child: const Text("OK")),
      ],
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            legalDisclaimer,
            const SizedBox(height: 30.0),
            Text(
              "Help",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            oneOrTwoPlayerHelp,
          ],
        ),
      ),
    );
  }
}

class DeckViewHelpDialog extends StatelessWidget {
  const DeckViewHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
            onPressed: (() => Navigator.pop(context)), child: const Text("OK")),
      ],
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            legalDisclaimer,
            const SizedBox(height: 30.0),
            Text(
              "Help",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            deckViewHelp,
            tapOnCardText,
            moveCardButtonText,
            expandCollapseText,
          ],
        ),
      ),
    );
  }
}

class ArsenalPickViewHelpDialog extends StatelessWidget {
  const ArsenalPickViewHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
            onPressed: (() => Navigator.pop(context)), child: const Text("OK")),
      ],
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            legalDisclaimer,
            const SizedBox(height: 30.0),
            Text(
              "Help",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            arsenalPickHelp,
            arsenalLink,
          ],
        ),
      ),
    );
  }
}

class ArsenalAssignmentViewHelpDialog extends StatelessWidget {
  const ArsenalAssignmentViewHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
            onPressed: (() => Navigator.pop(context)), child: const Text("OK")),
      ],
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            legalDisclaimer,
            const SizedBox(height: 30.0),
            Text(
              "Help",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            arsenalAssignmentHelp,
            arsenalLink,
          ],
        ),
      ),
    );
  }
}
