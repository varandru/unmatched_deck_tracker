import 'package:flutter/material.dart';
import 'package:unmatched_deck_tracker/arsenal.dart';
import 'package:unmatched_deck_tracker/arsenal_widget.dart';

class TestDisplay extends StatelessWidget {
  const TestDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    var leaderPicks = {'Alice', 'Medusa', 'King Arthur', 'Sinbad'};
    var followerPicks = {'Achilles', 'Sun Wukong', 'Bloody Mary', 'Yennenga'};
    var bannedCharacters = Set<String>.identity();

    PositionPick leaderAdvantage =
        PositionPick(ArsenalAssignment.leaderAdvantage);
    leaderAdvantage.leaderPick = 'Alice';
    leaderAdvantage.followerPick = 'Achilles';

    PositionPick followerAdvantage =
        PositionPick(ArsenalAssignment.followerAdvantage);
    followerAdvantage.leaderPick = 'Medusa';
    followerAdvantage.followerPick = 'Sun Wukong';

    PositionPick neutralGame = PositionPick(ArsenalAssignment.neutral);
    neutralGame.leaderPick = 'King Arthur';
    neutralGame.followerPick = 'Bloody Mary';

    List<RoundPick> history = [];

    history.add(RoundPick.fromSets(
        leaderPicks: Set.identity(),
        commonPicks: {'Bigfoot', 'Dracula', 'Bruce Lee', 'Daredevil'},
        followerPicks: Set.identity()));

    history.add(RoundPick.fromSets(
        leaderPicks: {'Alice', 'Medusa'},
        commonPicks: {'Sherlock Holmes', 'Beowulf'},
        followerPicks: {'Achilles', 'Sun Wukong'}));

    history.add(RoundPick.fromSets(
        leaderPicks: {'King Arthur', 'Sinbad'},
        commonPicks: {},
        followerPicks: {'Bloody Mary', 'Yennenga'}));

    return DraftResult(
        leaderPicks: leaderPicks,
        followerPicks: followerPicks,
        bannedCharacters: bannedCharacters,
        leaderAdvantage: leaderAdvantage,
        followerAdvantage: followerAdvantage,
        neutralGame: neutralGame,
        history: history,
        hasNeutralGame: true);
  }
}
