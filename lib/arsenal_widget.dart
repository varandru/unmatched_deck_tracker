import 'package:flutter/material.dart';
import 'package:unmatched_deck_tracker/arsenal.dart';
import 'package:unmatched_deck_tracker/deck.dart';
import 'package:unmatched_deck_tracker/sidebar.dart';

import 'deck_choice_widget.dart' show goToDeckChoice;
import 'image_handling.dart';

void goToArsenal(BuildContext context) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const ArsenalBaseWidget()),
  );
}

class ArsenalBaseWidget extends StatefulWidget {
  const ArsenalBaseWidget({super.key});

  @override
  State<ArsenalBaseWidget> createState() => _ArsenalBaseWidgetState();
}

class _ArsenalBaseWidgetState extends State<ArsenalBaseWidget> {
  final ArsenalDraft _draft = ArsenalDraft();
  List<ShortDeck> _decks = [];
  bool _loaded = false;
  CurrentArsenalState _arsenalState = CurrentArsenalState.leaderIsPicking;

  void _goToNextState() {
    setState(() {
      switch (_arsenalState) {
        case CurrentArsenalState.leaderIsPicking:
          _arsenalState = CurrentArsenalState.leaderPassesPhone;
          break;
        case CurrentArsenalState.leaderPassesPhone:
          _arsenalState = CurrentArsenalState.followerIsPicking;
          break;
        case CurrentArsenalState.followerIsPicking:
          bool draftEnded = _draft.nextRound();
          _arsenalState = draftEnded
              ? CurrentArsenalState.draftResult
              : CurrentArsenalState.roundResult;
          break;
        case CurrentArsenalState.roundResult:
          _arsenalState = CurrentArsenalState.leaderIsPicking;
          break;
        case CurrentArsenalState.draftResult:
          // We shouldn't get here. If we do, I guess we're restarting the draft?
          _arsenalState = CurrentArsenalState.leaderIsPicking;
          _draft.reset(_decks);
          break;
      }
    });
  }

  String getHeaderByState() {
    switch (_arsenalState) {
      case CurrentArsenalState.leaderIsPicking:
        return "Leader is picking characters";
      case CurrentArsenalState.leaderPassesPhone:
        return "Intermission";
      case CurrentArsenalState.followerIsPicking:
        return "Follower is picking characters";
      case CurrentArsenalState.roundResult:
        return "Round result";
      case CurrentArsenalState.draftResult:
        return "Draft Result";
    }
  }

  @override
  void initState() {
    getDecksFromAssets().then((value) {
      setState(() {
        _decks = value;
        _draft.reset(value);
        _loaded = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_draft.sanityCheck(_arsenalState)) {
      return ErrorWidget("Unexpected arsenal state!");
    }

    Widget? body;
    Widget? bottomNavigationBar;
    List<Widget>? actions;

    switch (_arsenalState) {
      case CurrentArsenalState.leaderIsPicking:
      case CurrentArsenalState.followerIsPicking:
        body = PickView(_draft,
            clickedCharacter: (name) =>
                setState(() => _draft.clickedCharacter(name)));
        bottomNavigationBar = HeroBottomBar(_draft, _goToNextState);
        actions = [
          IconButton(
              onPressed: () {
                setState(() {
                  _draft.pool.shuffle();
                });
              },
              icon: const Icon(Icons.casino))
        ];
        break;
      case CurrentArsenalState.leaderPassesPhone:
        body = SplashScreenBetweenPicks(_goToNextState);
        break;
      case CurrentArsenalState.roundResult:
        body = RoundResult(
          roundPick: _draft.roundHistory.last,
          leaderPicks: _draft.leaderChoice,
          followerPicks: _draft.followerChoice,
          toContinue: _goToNextState,
        );
        break;
      case CurrentArsenalState.draftResult:
        body = DraftResult(
          leaderPicks: _draft.leaderChoice,
          followerPicks: _draft.followerChoice,
          bannedCharacters: _draft.bannedCharacters,
        );
        bottomNavigationBar = DraftResultBottomBar(_goToNextState);
        break;
    }

    return Scaffold(
      appBar: AppBar(title: Text(getHeaderByState()), actions: actions),
      drawer: const Sidebar(SidebarPosition.arsenal,
          openDeckChoice: goToDeckChoice, openArsenal: goToArsenal),
      bottomNavigationBar: bottomNavigationBar,
      body: body,
    );
  }
}

class HeroBottomBar extends StatelessWidget {
  const HeroBottomBar(this._draft, this._goToNextStep, {super.key});

  final ArsenalDraft _draft;
  final VoidCallback _goToNextStep;

  @override
  Widget build(BuildContext context) {
    int charactersPicked = _draft.currentPicks.length;
    int picksLeft = _draft.picksLeft;
    bool picksMatch = charactersPicked == picksLeft;

    return BottomAppBar(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "$charactersPicked/$picksLeft fighters",
          style: TextStyle(
            color: picksMatch ? Colors.black : Colors.red,
          ),
        ),
        TextButton(
          onPressed: picksMatch
              ? () {
                  if (_draft.confirmSelection()) {
                    _goToNextStep();
                  }
                }
              : null,
          child: const Text("Confirm selection"),
        )
      ],
    ));
  }
}

class PickView extends StatelessWidget {
  const PickView(this.draft, {required this.clickedCharacter, super.key});

  final ArsenalDraft draft;
  final void Function(String) clickedCharacter;

  @override
  Widget build(BuildContext context) {
    return HeroView(
      heroes: draft.pool,
      scrollable: true,
      currentPicks: draft.currentPicks,
      clickedCharacter: clickedCharacter,
    );
  }
}

class HeroView extends StatelessWidget {
  const HeroView({
    Key? key,
    required this.heroes,
    this.currentPicks,
    this.clickedCharacter,
    required this.scrollable,
    this.cardPerRow = 4,
    this.spacing = 4.0,
  }) : super(key: key);

  final List<String> heroes;
  final Set<String>? currentPicks;
  final bool scrollable;
  final void Function(String)? clickedCharacter;

  final int cardPerRow;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - 4.0;
    final cardWidth = screenWidth / cardPerRow - spacing;

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
        fighterSelected: fighterSelected,
        isSelected: selected,
        cardWidth: cardWidth,
      ));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(4.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: spacing,
        runSpacing: spacing,
        children: cardbacks,
      ),
    );
  }
}

class DeckChoiceCard extends StatelessWidget {
  const DeckChoiceCard(
    this.deckName, {
    this.fighterSelected,
    bool? isSelected,
    required this.cardWidth,
    super.key,
  })  : _isSelected = isSelected ?? false,
        _isClickable = fighterSelected != null;

  final String deckName;
  final VoidCallback? fighterSelected;
  final double cardWidth;
  final double heightFactor = 1.5;

  final bool _isSelected;
  final bool _isClickable;

  @override
  Widget build(BuildContext context) {
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
      child: _isClickable
          ? Center(
              child: _isSelected
                  ? const Icon(Icons.check_circle, size: 50.0)
                  : null)
          : null,
    );
    return _isClickable
        ? InkWell(
            onTap: fighterSelected,
            child: card,
          )
        : card;
  }
}

class SplashScreenBetweenPicks extends StatelessWidget {
  const SplashScreenBetweenPicks(this.toContinue, {super.key});

  final VoidCallback toContinue;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Pass the device \nto the other player",
          textAlign: TextAlign.center,
          textScaleFactor: 2.0,
        ),
        TextButton(
            autofocus: true,
            onPressed: toContinue,
            child: const Text(
              "Continue",
              textScaleFactor: 1.5,
            )),
      ],
    ));
  }
}

class RoundResult extends StatelessWidget {
  const RoundResult(
      {super.key,
      required this.roundPick,
      required this.leaderPicks,
      required this.followerPicks,
      required this.toContinue});

  final RoundPick roundPick;
  final Set<String> leaderPicks;
  final Set<String> followerPicks;
  final VoidCallback toContinue;

  final double scaleFactor = 1.2;
  final int cardsPerRow = 6;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (leaderPicks.difference(roundPick.leaderPicks).isNotEmpty) {
      children.add(Text("Leader had",
          textScaleFactor: scaleFactor, textAlign: TextAlign.center));
      children.add(HeroView(
          heroes: leaderPicks.difference(roundPick.leaderPicks).toList(),
          scrollable: false,
          cardPerRow: cardsPerRow));
    }
    if (roundPick.leaderPicks.isNotEmpty) {
      children.add(Text("Leader's new picks are",
          textScaleFactor: scaleFactor, textAlign: TextAlign.center));
      children.add(HeroView(
          heroes: roundPick.leaderPicks.toList(),
          scrollable: false,
          cardPerRow: cardsPerRow));
    }
    if (roundPick.leaderPicks.isNotEmpty) {
      children.add(Text("Banned characters are",
          textScaleFactor: scaleFactor, textAlign: TextAlign.center));
      children.add(HeroView(
          heroes: roundPick.commonPicks.toList(),
          scrollable: false,
          cardPerRow: cardsPerRow));
    }
    if (roundPick.leaderPicks.isNotEmpty) {
      children.add(Text("Follower's new picks are",
          textScaleFactor: scaleFactor, textAlign: TextAlign.center));
      children.add(HeroView(
          heroes: roundPick.followerPicks.toList(),
          scrollable: false,
          cardPerRow: cardsPerRow));
    }
    if (followerPicks.difference(roundPick.followerPicks).isNotEmpty) {
      children.add(Text("Follower had",
          textScaleFactor: scaleFactor, textAlign: TextAlign.center));
      children.add(HeroView(
          heroes: followerPicks.difference(roundPick.leaderPicks).toList(),
          scrollable: false,
          cardPerRow: cardsPerRow));
    }

    children.add(TextButton(
        onPressed: toContinue,
        child: const Text("Pass the phone to leader and press to continue")));

    return Center(
        child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    ));
  }
}

class DraftResult extends StatelessWidget {
  const DraftResult({
    super.key,
    required this.leaderPicks,
    required this.followerPicks,
    required this.bannedCharacters,
  });

  final Set<String> leaderPicks;
  final Set<String> followerPicks;
  final Set<String> bannedCharacters;

  final double scaleFactor = 1.2;
  final int cardsPerRow = 6;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(Text("Leader has",
        textScaleFactor: scaleFactor, textAlign: TextAlign.center));
    children.add(HeroView(
        heroes: leaderPicks.toList(),
        scrollable: false,
        cardPerRow: cardsPerRow));

    children.add(Text("Follower has",
        textScaleFactor: scaleFactor, textAlign: TextAlign.center));
    children.add(HeroView(
        heroes: followerPicks.toList(),
        scrollable: false,
        cardPerRow: cardsPerRow));

    children.add(Text("These heroes don't get to play this time",
        textScaleFactor: scaleFactor, textAlign: TextAlign.center));
    children.add(HeroView(
        heroes: bannedCharacters.toList(),
        scrollable: false,
        cardPerRow: cardsPerRow));

    return Center(
        child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    ));
  }
}

class DraftResultBottomBar extends StatelessWidget {
  const DraftResultBottomBar(this._goToNextStep, {super.key});

  final VoidCallback _goToNextStep;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
        child: TextButton(
      onPressed: _goToNextStep,
      child: const Text("Restart?"),
    ));
  }
}
