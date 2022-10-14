import 'package:flutter/material.dart';
import 'package:unmatched_deck_tracker/common_defs.dart';
import 'package:unmatched_deck_tracker/settings.dart';

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

class MainMenuHelpDialog extends StatelessWidget {
  const MainMenuHelpDialog(this.isFirstLaunch, {super.key});

  final isFirstLaunch;

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
            Text(
              "Help",
              style: Theme.of(context).textTheme.headline5,
            ),
            oneOrTwoPlayerHelp,
          ],
        ),
      ),
    );
  }
}
