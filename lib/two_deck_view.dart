import 'package:flutter/material.dart';
import 'package:unmatched_deck_tracker/card.dart';
import 'package:unmatched_deck_tracker/settings.dart';
import 'common_defs.dart';
import 'deck.dart';
import 'deck_choice_widget.dart';
import 'deck_list_view.dart';
import 'help_dialogs.dart';

class TwoDecksView extends StatefulWidget {
  const TwoDecksView(this.deck, {this.secondDeck, super.key});

  final ShortDeck deck;
  final ShortDeck? secondDeck;

  @override
  State<TwoDecksView> createState() => _TwoDecksViewState();
}

class _TwoDecksViewState extends State<TwoDecksView> {
  CardSortType currentSortType = CardSortType.byName;

  late DeckInformation deck;
  DeckInformation? secondDeck;

  void _expandAll() {
    setState(() {
      deck.setExpanded(true);
      secondDeck?.setExpanded(true);
    });
  }

  void _collapseAll() {
    setState(() {
      deck.setExpanded(false);
      secondDeck?.setExpanded(false);
    });
  }

  @override
  void initState() {
    deck = DeckInformation(widget.deck);
    if (widget.secondDeck != null) {
      secondDeck = DeckInformation(widget.secondDeck!);
    }
    super.initState();
  }

  Future<bool> willPopHelper() async {
    bool? canReturn = await showDialog<bool>(
        context: context,
        builder: ((context) => const BackingOutOfDeckDialog()));
    if (canReturn ?? false) {
      if (!mounted) {
        return false;
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        maintainState: false,
        builder: (context) {
          return FutureBuilder(
            future: getTwoPlayerMode(),
            builder: ((context, snapshot) => snapshot.hasData
                ? DeckChoiceWidget(
                    title: 'Unmatched Deck Tracker',
                    isTwoPlayerMode: snapshot.data!,
                  )
                : const CircularProgressIndicator()),
          );
        },
      ));
    }
    return canReturn ?? false;
  }

  @override
  Widget build(BuildContext context) {
    Future<CardSortType> cardSortType = getCardSortType();

    List<Widget> actions = [
      ExpandCollapseButton(
        expandAll: _expandAll,
        collapseAll: _collapseAll,
      ),
      PopupMenuButton<CardSortType>(
          icon: const Icon(Icons.sort),
          itemBuilder: (context) => CardSortType.values
              .map((e) => PopupMenuItem<CardSortType>(
                  value: e, child: Text(cardSortTypeName(e))))
              .toList(growable: false),
          onSelected: ((value) => setState(() {
                setCardSortType(value);
                currentSortType = value;
              }))),
      IconButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => const DeckViewHelpDialog());
          },
          icon: helpIcon),
    ];

    if (widget.secondDeck != null) {
      bool isHorizontal = MediaQuery.of(context).size.width >
          MediaQuery.of(context).size.height;
      bool twoViewsFit =
          MediaQuery.of(context).size.width > 2 * (maxNarrowColumnWidth + 8.0);

      bool isWide = isHorizontal && twoViewsFit;

      return FutureBuilder(
          future: Future.wait([
            deck.fillDeckFromFile(),
            secondDeck!.fillDeckFromFile(),
            cardSortType,
          ]),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Widget> children = [
                DeckListView(deck, snapshot.data![2] as CardSortType),
                DeckListView(secondDeck!, snapshot.data![2] as CardSortType),
              ];

              return WillPopScope(
                onWillPop: willPopHelper,
                child: isWide
                    ? rowScaffold(actions, children)
                    : tabScaffold(actions, children),
              );
            }
            return const CircularProgressIndicator();
          });
    } else {
      return FutureBuilder(
        future: Future.wait([deck.fillDeckFromFile(), cardSortType]),
        builder: (context, snapshot) => snapshot.hasData
            ? WillPopScope(
                onWillPop: willPopHelper,
                child: singleDeckView(actions, snapshot),
              )
            : const CircularProgressIndicator(),
      );
    }
  }

  AdaptiveScaffold singleDeckView(
      List<Widget> actions, AsyncSnapshot<List<Object>> snapshot) {
    return AdaptiveScaffold(
      appBar: AppBar(
        title: Text(widget.deck.name),
        actions: actions,
      ),
      body: DeckListView(
          deck, currentSortType = snapshot.data![1] as CardSortType),
    );
  }

  DefaultTabController tabScaffold(
      List<Widget> actions, List<Widget> children) {
    return DefaultTabController(
      length: 2,
      child: AdaptiveScaffold(
        appBar: AppBar(
          title: const Text("Fight!"),
          actions: actions,
          bottom: TabBar(
            tabs: [
              Tab(text: deck.summary.name),
              Tab(text: secondDeck!.summary.name)
            ],
            indicatorColor: Colors.grey.shade800,
          ),
        ),
        body: TabBarView(children: children),
      ),
    );
  }

  AdaptiveScaffold rowScaffold(List<Widget> actions, List<Widget> children) {
    return AdaptiveScaffold(
      appBar: AppBar(
        title: const Text("Fight!"),
        actions: actions,
      ),
      body: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: children),
    );
  }
}
