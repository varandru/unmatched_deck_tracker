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
  final ArsenalAssignments _assignments = ArsenalAssignments();
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
          _draft.nextRound();
          _arsenalState = CurrentArsenalState.roundResult;
          break;
        case CurrentArsenalState.roundResult:
          _arsenalState = _draft.draftEnded
              ? CurrentArsenalState.leaderIsAssigning
              : CurrentArsenalState.leaderIsPicking;
          if (_draft.draftEnded) {
            _assignments.initialize(_draft.leaderChoice, _draft.followerChoice);
          }
          break;
        case CurrentArsenalState.draftResult:
          // We shouldn't get here. If we do, I guess we're restarting the draft?
          _arsenalState = CurrentArsenalState.leaderIsPicking;
          _draft.reset(_decks);
          _assignments.clear();
          break;
        case CurrentArsenalState.leaderIsAssigning:
          _arsenalState = CurrentArsenalState.followerIsAssigning;
          _assignments.leaderIsAssigning = false;
          break;
        case CurrentArsenalState.followerIsAssigning:
          _arsenalState = CurrentArsenalState.draftResult;
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
      case CurrentArsenalState.leaderIsAssigning:
        return "Leader Assignments";
      case CurrentArsenalState.followerIsAssigning:
        return "Follower Assignments";
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
      case CurrentArsenalState.leaderIsAssigning:
      case CurrentArsenalState.followerIsAssigning:
        body = ArsenalAssignmentsBody(
          myFighters: _assignments.myFighters,
          yourFighters: _assignments.yourFighters,
          assignMyAdvantage: (hero) =>
              setState(() => _assignments.assignMyAdvantage(hero)),
          assignNeutral: (hero) =>
              setState(() => _assignments.assignNeutral(hero)),
          assignYourAdvantage: (hero) =>
              setState(() => _assignments.assignYourAdvantage(hero)),
          yourAdvantage: _assignments.yourAdvantage,
          myAdvantage: _assignments.myAdvantage,
          neutralPick: _assignments.neutralPick,
        );
        print("Filled? ${_assignments.filled}");
        bottomNavigationBar = ArsenalAssignmentsBottomBar(_goToNextState,
            active: _assignments.filled,
            leaderIsAssigning: _assignments.leaderIsAssigning);
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
      cardType: DeckChoiceCardType.selectable,
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
    required this.cardType,
  }) : super(key: key);

  final List<String> heroes;
  final Set<String>? currentPicks;
  final bool scrollable;
  final DeckChoiceCardType cardType;
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
        cardType,
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
      child: cardType == DeckChoiceCardType.selectable
          ? Center(
              child: _isSelected
                  ? const Icon(Icons.check_circle, size: 50.0)
                  : null)
          : null,
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
          cardType: DeckChoiceCardType.display,
          scrollable: false,
          cardPerRow: cardsPerRow));
    }
    if (roundPick.leaderPicks.isNotEmpty) {
      children.add(Text("Leader's new picks are",
          textScaleFactor: scaleFactor, textAlign: TextAlign.center));
      children.add(HeroView(
          heroes: roundPick.leaderPicks.toList(),
          cardType: DeckChoiceCardType.display,
          scrollable: false,
          cardPerRow: cardsPerRow));
    }
    if (roundPick.commonPicks.isNotEmpty) {
      children.add(Text("Banned characters are",
          textScaleFactor: scaleFactor, textAlign: TextAlign.center));
      children.add(HeroView(
          heroes: roundPick.commonPicks.toList(),
          cardType: DeckChoiceCardType.display,
          scrollable: false,
          cardPerRow: cardsPerRow));
    }
    if (roundPick.leaderPicks.isNotEmpty) {
      children.add(Text("Follower's new picks are",
          textScaleFactor: scaleFactor, textAlign: TextAlign.center));
      children.add(HeroView(
          heroes: roundPick.followerPicks.toList(),
          cardType: DeckChoiceCardType.display,
          scrollable: false,
          cardPerRow: cardsPerRow));
    }
    if (followerPicks.difference(roundPick.followerPicks).isNotEmpty) {
      children.add(Text("Follower had",
          textScaleFactor: scaleFactor, textAlign: TextAlign.center));
      children.add(HeroView(
          heroes: followerPicks.difference(roundPick.followerPicks).toList(),
          cardType: DeckChoiceCardType.display,
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

class ArsenalAssignmentsBody extends StatelessWidget {
  const ArsenalAssignmentsBody(
      {super.key,
      required this.myFighters,
      required this.yourFighters,
      required this.assignMyAdvantage,
      required this.assignNeutral,
      required this.assignYourAdvantage,
      required this.yourAdvantage,
      required this.myAdvantage,
      required this.neutralPick});

  final Set<String> myFighters;
  final Set<String> yourFighters;
  final void Function(String) assignMyAdvantage;
  final void Function(String) assignNeutral;
  final void Function(String) assignYourAdvantage;

  final String? yourAdvantage;
  final String? myAdvantage;
  final String? neutralPick;

  final double textScale = 1.3;

  final int overviewCardsPerRow = 6;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        // Opponent's fighters
        HeroView(
            heroes: yourFighters.toList(),
            cardType: DeckChoiceCardType.display,
            scrollable: false,
            cardPerRow: overviewCardsPerRow),
        // Opponent's advantage
        Text("Opponent's advantage", textScaleFactor: textScale),
        AssignmentTarget(
            selectedHero: yourAdvantage,
            color: Colors.red,
            onAccept: assignYourAdvantage),
        // Neutral game
        Text("Neutral game", textScaleFactor: textScale),
        AssignmentTarget(
            selectedHero: neutralPick,
            color: Colors.yellow,
            onAccept: assignNeutral),
        // Your advantage
        Text("Your advantage", textScaleFactor: textScale),
        AssignmentTarget(
            selectedHero: myAdvantage,
            color: Colors.green,
            onAccept: assignMyAdvantage),
        // Your fighters
        Text("Drag your fighters into positions", textScaleFactor: textScale),
        HeroView(
            heroes: myFighters.toList(),
            cardType: DeckChoiceCardType.draggable,
            scrollable: false,
            cardPerRow: overviewCardsPerRow)
      ],
    ));
  }
}

class AssignmentTarget extends StatelessWidget {
  const AssignmentTarget({
    Key? key,
    required this.color,
    required this.onAccept,
    this.selectedHero,
  }) : super(key: key);

  final Color color;
  final void Function(String) onAccept;

  final double containerHeight = 120.0;

  final String? selectedHero;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
        onAccept: onAccept,
        builder: (context, candidateData, rejectedData) => Center(
                child: Container(
              height: containerHeight,
              width: containerHeight / 1.5,
              color: color,
              child: selectedHero == null
                  ? null
                  : DeckChoiceCard(selectedHero!, DeckChoiceCardType.draggable,
                      cardWidth: containerHeight / 1.5),
            )));
  }
}

class ArsenalAssignmentsBottomBar extends StatelessWidget {
  const ArsenalAssignmentsBottomBar(this.goToNextState,
      {required this.active, super.key, required this.leaderIsAssigning});

  final bool active;
  final bool leaderIsAssigning;
  final VoidCallback goToNextState;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
        child: TextButton(
      onPressed: active ? goToNextState : null,
      child: Text(
        leaderIsAssigning ? "Go to follower's assignments" : "Go to results",
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
        cardType: DeckChoiceCardType.display,
        scrollable: false,
        cardPerRow: cardsPerRow));

    children.add(Text("Follower has",
        textScaleFactor: scaleFactor, textAlign: TextAlign.center));
    children.add(HeroView(
        heroes: followerPicks.toList(),
        cardType: DeckChoiceCardType.display,
        scrollable: false,
        cardPerRow: cardsPerRow));

    children.add(Text("These heroes don't get to play this time",
        textScaleFactor: scaleFactor, textAlign: TextAlign.center));
    children.add(HeroView(
        heroes: bannedCharacters.toList(),
        cardType: DeckChoiceCardType.display,
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
