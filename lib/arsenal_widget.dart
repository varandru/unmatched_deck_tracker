import 'package:flutter/material.dart';
import 'package:unmatched_deck_tracker/arsenal.dart';
import 'package:unmatched_deck_tracker/deck.dart';
import 'package:unmatched_deck_tracker/help_dialogs.dart';
import 'package:unmatched_deck_tracker/sidebar.dart';

import 'deck_choice_widget.dart' show goToDeckChoice;
import 'image_handling.dart';

void goToArsenal(BuildContext context) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const ArsenalSettings()),
  );
}

class ArsenalBaseWidget extends StatefulWidget {
  const ArsenalBaseWidget(
      {super.key,
      required this.hasNeutralGame,
      required this.bannedCharacters});

  final bool hasNeutralGame;
  final Set<String> bannedCharacters;

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
            _assignments.initialize(_draft.leaderChoice, _draft.followerChoice,
                widget.hasNeutralGame);
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
        _decks.removeWhere(
            (element) => widget.bannedCharacters.contains(element.name));
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
        return DraftResult(
          leaderPicks: _draft.leaderChoice,
          followerPicks: _draft.followerChoice,
          bannedCharacters: _draft.bannedCharacters,
          leaderAdvantage: _assignments.leaderAdvantage,
          followerAdvantage: _assignments.followerAdvantage,
          neutralGame: _assignments.neutralGame,
          history: _draft.roundHistory,
          hasNeutralGame: widget.hasNeutralGame,
        );
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
          hasNeutralGame: widget.hasNeutralGame,
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
              ? () async {
                  if (_draft.checkSelection()) {
                    showDialog<bool>(
                            context: context,
                            builder: (context) =>
                                ConfirmingChoiceDialog(_draft.currentPicks))
                        .then((value) {
                      if (value ?? false) {
                        _draft.confirmSelection();
                        _goToNextStep();
                      }
                    });
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
    List<Widget> children = [];

    double width = getEvenlySpacedWidth(context, 3);

    if (draft.myCharacters.isNotEmpty) {
      children.add(Row(children: [
        SizedBox(
            width: width, child: const Center(child: Text("Your fighters"))),
        SizedBox(
            width: width,
            child: HeroView(
                heroes: draft.myCharacters,
                scrollable: false,
                cardType: DeckChoiceCardType.display,
                cardPerRow: 10)),
        SizedBox(width: width),
      ]));
    }

    if (draft.opponentCharacters.isNotEmpty) {
      children.add(Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(width: width),
          SizedBox(
              width: width,
              child: HeroView(
                  heroes: draft.opponentCharacters,
                  scrollable: false,
                  cardType: DeckChoiceCardType.display,
                  cardPerRow: 10)),
          SizedBox(
              width: width,
              child: const Center(child: Text("Opponent's fighters"))),
        ],
      ));
    }

    children.add(HeroView(
      heroes: draft.pool,
      cardType: DeckChoiceCardType.selectable,
      scrollable: true,
      currentPicks: draft.currentPicks,
      clickedCharacter: clickedCharacter,
    ));

    return ListView(children: children);
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
    double cardWidth =
        getEvenlySpacedWidth(context, cardPerRow, spacing: spacing);

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

double getEvenlySpacedWidth(BuildContext context, int cardPerRow,
    {double spacing = 4.0}) {
  final screenWidth = MediaQuery.of(context).size.width - spacing;
  return screenWidth / cardPerRow - spacing;
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
                  ? const Icon(Icons.check_circle,
                      size: 50.0, color: Colors.white)
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
      required this.neutralPick,
      required this.hasNeutralGame});

  final Set<String> myFighters;
  final Set<String> yourFighters;
  final bool hasNeutralGame;
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
    List<Widget> children = [];

    children.addAll([
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
    ]);

    if (hasNeutralGame) {
      children.addAll([
        // Neutral game
        Text("Neutral game", textScaleFactor: textScale),
        AssignmentTarget(
            selectedHero: neutralPick,
            color: Colors.yellow,
            onAccept: assignNeutral),
      ]);
    }

    children.addAll([
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
    ]);

    return Center(
        child: ListView(
      shrinkWrap: true,
      children: children,
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
    required this.leaderAdvantage,
    required this.followerAdvantage,
    required this.neutralGame,
    required this.history,
    required this.hasNeutralGame,
  });

  final Set<String> leaderPicks;
  final Set<String> followerPicks;
  final Set<String> bannedCharacters;

  final PositionPick leaderAdvantage;
  final PositionPick followerAdvantage;
  final bool hasNeutralGame;
  final PositionPick neutralGame;

  final List<RoundPick> history;

  final double scaleFactor = 1.2;
  final int cardsPerRow = 6;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          drawer: const Sidebar(SidebarPosition.arsenal,
              openDeckChoice: goToDeckChoice, openArsenal: goToArsenal),
          appBar: AppBar(
              title: const Text("Draft Results"),
              bottom: const TabBar(tabs: [
                Tab(text: "Assignments"),
                Tab(text: "Overview"),
                Tab(text: "History"),
              ])),
          body: TabBarView(children: [
            _createAssignmentsView(context, hasNeutralGame),
            _createHeroOverview(),
            _createHistoryView(context),
          ]),
          bottomNavigationBar: const DraftResultBottomBar(),
        ));
  }

  Widget _createHistoryView(BuildContext context) {
    int maxLeaderPicks = 0;
    int maxCommonPicks = 0;
    int maxFollowerPicks = 0;

    for (var pick in history) {
      if (pick.leaderPicks.length > maxLeaderPicks) {
        maxLeaderPicks = pick.leaderPicks.length;
      }
      if (pick.commonPicks.length > maxCommonPicks) {
        maxCommonPicks = pick.commonPicks.length;
      }
      if (pick.followerPicks.length > maxFollowerPicks) {
        maxFollowerPicks = pick.followerPicks.length;
      }
    }

    int cardsPerRow = maxLeaderPicks + maxCommonPicks + maxFollowerPicks + 3;
    double cardWidth = getEvenlySpacedWidth(context, cardsPerRow);
    double cardHeight = cardWidth * 1.5;

    return Center(
        child: SizedBox(
      width: double.infinity,
      child: DataTable(
        horizontalMargin: 4.0,
        columnSpacing: 0.0,
        dataRowHeight: cardHeight + 8.0,
        border: TableBorder.symmetric(inside: const BorderSide()),
        columns: const [
          DataColumn(label: Expanded(child: Center(child: Text("Leader")))),
          DataColumn(label: Expanded(child: Center(child: Text("Banned")))),
          DataColumn(label: Expanded(child: Center(child: Text("Follower")))),
        ],
        rows: List<DataRow>.generate(
          history.length,
          (index) => DataRow(
            cells: [
              DataCell(Center(
                  child: HeroView(
                      heroes: history[index].leaderPicks.toList(),
                      scrollable: false,
                      cardType: DeckChoiceCardType.display,
                      cardPerRow: cardsPerRow))),
              DataCell(Center(
                  child: HeroView(
                      heroes: history[index].commonPicks.toList(),
                      scrollable: false,
                      cardType: DeckChoiceCardType.display,
                      cardPerRow: cardsPerRow))),
              DataCell(Center(
                  child: HeroView(
                      heroes: history[index].followerPicks.toList(),
                      scrollable: false,
                      cardType: DeckChoiceCardType.display,
                      cardPerRow: cardsPerRow))),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _createAssignmentsView(BuildContext context, bool hasNeutralGame) {
    List<Widget> children = [];
    children.add(_createAssignmentsHeader(context));
    children.add(Text("Leader advanatage: ",
        textScaleFactor: scaleFactor, textAlign: TextAlign.center));
    children.add(MatchWidget(leaderAdvantage));
    children.add(Text("Follower advanatage: ",
        textScaleFactor: scaleFactor, textAlign: TextAlign.center));
    children.add(MatchWidget(followerAdvantage));
    if (hasNeutralGame) {
      children.add(Text("Neutral game: ",
          textScaleFactor: scaleFactor, textAlign: TextAlign.center));
      children.add(MatchWidget(neutralGame));
    }
    return Center(child: ListView(shrinkWrap: true, children: children));
  }

  Widget _createAssignmentsHeader(BuildContext context) {
    double width = getEvenlySpacedWidth(context, 4);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
            width: width,
            child: const Text("Leader",
                textScaleFactor: 1.3, textAlign: TextAlign.center)),
        SizedBox(width: width),
        SizedBox(
            width: width,
            child: const Text("Follower",
                textScaleFactor: 1.3, textAlign: TextAlign.center)),
      ],
    );
  }

  Widget _createHeroOverview() {
    List<Widget> children = [];
    children.add(Text("Leader's fighters are:",
        textScaleFactor: scaleFactor, textAlign: TextAlign.center));
    children.add(HeroView(
        heroes: leaderPicks.toList(),
        cardType: DeckChoiceCardType.display,
        scrollable: false,
        cardPerRow: cardsPerRow));

    children.add(Text("Follower's fighters are:",
        textScaleFactor: scaleFactor, textAlign: TextAlign.center));
    children.add(HeroView(
        heroes: followerPicks.toList(),
        cardType: DeckChoiceCardType.display,
        scrollable: false,
        cardPerRow: cardsPerRow));

    if (bannedCharacters.isNotEmpty) {
      children.add(Text("These heroes don't get to play this time",
          textScaleFactor: scaleFactor, textAlign: TextAlign.center));
      children.add(HeroView(
          heroes: bannedCharacters.toList(),
          cardType: DeckChoiceCardType.display,
          scrollable: false,
          cardPerRow: cardsPerRow));
    }
    return Center(child: ListView(shrinkWrap: true, children: children));
  }
}

class MatchWidget extends StatelessWidget {
  const MatchWidget(this.positionPick, {super.key});

  final PositionPick positionPick;
  final int cardsPerRow = 4;

  @override
  Widget build(BuildContext context) {
    double width = getEvenlySpacedWidth(context, cardsPerRow);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        DeckChoiceCard(positionPick.leaderPick, DeckChoiceCardType.display,
            cardWidth: width),
        SizedBox(
            width: width,
            child: const Center(child: Text("VS", textScaleFactor: 4.0))),
        DeckChoiceCard(positionPick.followerPick, DeckChoiceCardType.display,
            cardWidth: width),
      ],
    );
  }
}

class DraftResultBottomBar extends StatelessWidget {
  const DraftResultBottomBar({super.key});
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
        child: TextButton(
      onPressed: () {
        goToArsenal(context);
      },
      child: const Text("Restart?"),
    ));
  }
}

class ArsenalSettings extends StatefulWidget {
  const ArsenalSettings({super.key});

  @override
  State<ArsenalSettings> createState() => _ArsenalSettingsState();
}

class _ArsenalSettingsState extends State<ArsenalSettings> {
  bool hasNeutralGame = true;
  bool isExpanded = false;
  Set<String> bannedCharacters = Set.identity();

  @override
  void initState() {
    bannedCharacters.add('Deadpool');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getDecksFromAssets(),
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return ErrorWidget(snapshot.error!);
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<ShortDeck> decks = snapshot.data!;

          return Scaffold(
            appBar: AppBar(title: const Text("Arsenal Setup")),
            drawer: const Sidebar(SidebarPosition.arsenal,
                openDeckChoice: goToDeckChoice, openArsenal: goToArsenal),
            // bottomNavigationBar: bottomNavigationBar,
            body: ListView(
              children: [
                SwitchListTile(
                    value: hasNeutralGame,
                    title: const Text("Has neutral game"),
                    subtitle: const Text("Configures whether a third game"
                        " with split advantage is set up"),
                    onChanged: ((value) {
                      setState(() {
                        hasNeutralGame = value;
                      });
                    })),
                ExpansionTile(
                  title: isExpanded
                      ? const Text("Banned characters")
                      : const Text("Checked characters will be banned"),
                  initiallyExpanded: isExpanded,
                  onExpansionChanged: (value) => setState(() {
                    isExpanded = value;
                  }),
                  children: [
                    ListView.builder(
                        itemCount: decks.length,
                        shrinkWrap: true,
                        itemBuilder: ((context, index) => CheckboxListTile(
                            title: Text(decks[index].name),
                            value: bannedCharacters.contains(decks[index].name),
                            onChanged: ((value) {
                              if (value == null) {
                                return;
                              }

                              setState(() {
                                if (value) {
                                  bannedCharacters.add(decks[index].name);
                                } else {
                                  bannedCharacters.remove(decks[index].name);
                                }
                              });
                            }))))
                  ],
                )
              ],
            ),
            bottomNavigationBar: BottomAppBar(
                child: TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: ((context) => ArsenalBaseWidget(
                        hasNeutralGame: hasNeutralGame,
                        bannedCharacters: bannedCharacters))));
              },
              child: const Text("Play Arsenal"),
            )),
          );
        }));
  }
}
