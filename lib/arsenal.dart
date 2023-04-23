import 'package:unmatched_deck_tracker/deck.dart';

const int ARSENAL_SIZE = 4;

enum CurrentArsenalState {
  leaderIsPicking,
  leaderPassesPhone,
  followerIsPicking,
  roundResult,
  draftResult,
  leaderIsAssigning,
  followerIsAssigning
}

class RoundPick {
  Set<String> leaderPicks = Set.identity();
  Set<String> commonPicks = Set.identity();
  Set<String> followerPicks = Set.identity();
}

class ArsenalDraft {
  ArsenalDraft();

  List<String> pool = [];

  Set<String> leaderChoice = Set.identity();
  Set<String> followerChoice = Set.identity();
  Set<String> bannedCharacters = Set.identity();

  Set<String> leaderHiddenPicks = Set.identity();
  Set<String> followerHiddenPicks = Set.identity();
  Set<String> currentPicks = Set.identity();

  bool leaderIsPicking = true;

  List<RoundPick> roundHistory = [];

  void reset(List<ShortDeck> decks) {
    pool = List.from(decks.map((e) => e.name).toList());
    leaderChoice.clear();
    followerChoice.clear();
    bannedCharacters.clear();
    leaderHiddenPicks.clear();
    followerHiddenPicks.clear();
    currentPicks.clear();
  }

  bool sanityCheck(CurrentArsenalState state) {
    switch (state) {
      case CurrentArsenalState.leaderIsPicking:
        return leaderIsPicking == true;
      case CurrentArsenalState.followerIsPicking:
        return leaderIsPicking == false;
      case CurrentArsenalState.leaderPassesPhone:
      case CurrentArsenalState.roundResult:
      case CurrentArsenalState.draftResult:
      case CurrentArsenalState.leaderIsAssigning:
      case CurrentArsenalState.followerIsAssigning:
        return true;
    }
  }

  void _movePoolToLeader() {
    leaderHiddenPicks.addAll(currentPicks);
    currentPicks.clear();
  }

  void _movePoolToFollower() {
    followerHiddenPicks.addAll(currentPicks);
    currentPicks.clear();
  }

  bool clickedCharacter(String name) {
    if (currentPicks.contains(name)) {
      currentPicks.remove(name);
      return false;
    } else {
      currentPicks.add(name);
      return true;
    }
  }

  bool get draftEnded => leaderChoice.length == ARSENAL_SIZE;

  void nextRound() {
    RoundPick pick = RoundPick();

    pick.commonPicks = leaderHiddenPicks.intersection(followerHiddenPicks);
    pick.leaderPicks = leaderHiddenPicks.difference(followerHiddenPicks);
    pick.followerPicks = followerHiddenPicks.difference(leaderHiddenPicks);

    leaderChoice.addAll(pick.leaderPicks);
    followerChoice.addAll(pick.followerPicks);
    bannedCharacters.addAll(pick.commonPicks);

    roundHistory.add(pick);

    leaderHiddenPicks.clear();
    followerHiddenPicks.clear();
    pool.removeWhere((element) => pick.commonPicks.contains(element));
    pool.removeWhere((element) => pick.leaderPicks.contains(element));
    pool.removeWhere((element) => pick.followerPicks.contains(element));

    if (pool.isEmpty) {
      pool.addAll(bannedCharacters);
    }

    if (leaderChoice.length != followerChoice.length) {
      throw Exception("Somehow different amount of picks. "
          "Leader: ${leaderChoice.toString()}. "
          "Follower: ${followerChoice.toString()}");
    }

    leaderIsPicking = true;
  }

  bool confirmSelection() {
    return leaderIsPicking
        ? _confirmSelectionLeader()
        : _confirmSelectionFollower();
  }

  bool _confirmSelectionLeader() {
    if (currentPicks.length + leaderChoice.length != ARSENAL_SIZE) {
      print("Select the neccessary fighters");
      return false;
    }

    if (currentPicks.intersection(leaderChoice).isNotEmpty) {
      print("How the fuck? Combined fighters are"
          " ${currentPicks.intersection(leaderChoice).toString()}");
    }

    _movePoolToLeader();

    leaderIsPicking = false;

    return true;
  }

  bool _confirmSelectionFollower() {
    if (currentPicks.length + followerChoice.length != ARSENAL_SIZE) {
      print("Select the neccessary fighters");
      return false;
    }

    if (currentPicks.intersection(followerChoice).isNotEmpty) {
      print("How the fuck? Combined fighters are"
          " ${currentPicks.intersection(followerChoice).toString()}");
      return false;
    }

    _movePoolToFollower();

    return true;
  }

  int get picksLeft {
    if (leaderIsPicking) {
      return ARSENAL_SIZE - leaderChoice.length;
    } else {
      return ARSENAL_SIZE - followerChoice.length;
    }
  }

  Set<String> get picks => leaderIsPicking ? leaderChoice : followerChoice;
}

enum ArsenalAssignment {
  leaderAdvantage,
  followerAdvantage,
  neutral,
}

String getPickNameFromEnum(ArsenalAssignment assignment) {
  switch (assignment) {
    case ArsenalAssignment.leaderAdvantage:
      return "Leader Advantage";
    case ArsenalAssignment.followerAdvantage:
      return "Follower Advantage";
    case ArsenalAssignment.neutral:
      return "Neutral game";
  }
}

bool getMapPickFromEnum(ArsenalAssignment assignment) {
  switch (assignment) {
    case ArsenalAssignment.leaderAdvantage:
      return true;
    case ArsenalAssignment.followerAdvantage:
      return false;
    case ArsenalAssignment.neutral:
      return true;
  }
}

bool getPositionPickFromEnum(ArsenalAssignment assignment) {
  switch (assignment) {
    case ArsenalAssignment.leaderAdvantage:
      return true;
    case ArsenalAssignment.followerAdvantage:
      return false;
    case ArsenalAssignment.neutral:
      return false;
  }
}

class PositionPick {
  PositionPick(ArsenalAssignment assignment)
      : leaderHasMapPick = getMapPickFromEnum(assignment),
        leaderHasPositionPick = getPositionPickFromEnum(assignment);

  String leaderPick = "";
  String followerPick = "";

  final bool leaderHasMapPick;
  final bool leaderHasPositionPick;

  bool filled(bool isLeaderPicking) =>
      isLeaderPicking ? leaderPick.isNotEmpty : followerPick.isNotEmpty;

  bool leaderFighterAvailable(String fighter) =>
      leaderPick.isEmpty ? true : leaderPick == fighter;
  bool followerFighterAvailable(String fighter) =>
      followerPick.isEmpty ? true : followerPick == fighter;

  void removeLeaderFighter(String fighter) {
    if (leaderPick == fighter) {
      leaderPick = "";
    }
  }

  void removeFollowerFighter(String fighter) {
    if (followerPick == fighter) {
      followerPick = "";
    }
  }

  void clear() {
    leaderPick = followerPick = "";
  }
}

class ArsenalAssignments {
  ArsenalAssignments();

  PositionPick leaderAdvantage =
      PositionPick(ArsenalAssignment.leaderAdvantage);
  PositionPick followerAdvantage =
      PositionPick(ArsenalAssignment.followerAdvantage);
  PositionPick neutralGame = PositionPick(ArsenalAssignment.neutral);

  Set<String> leaderFighters = Set.identity();
  Set<String> followerFighters = Set.identity();

  bool get inited => leaderFighters.isNotEmpty && followerFighters.isNotEmpty;

  bool leaderIsAssigning = true;

  bool _leaderFighterAvailable(String fighter) =>
      leaderAdvantage.leaderFighterAvailable(fighter) &&
      followerAdvantage.leaderFighterAvailable(fighter) &&
      neutralGame.leaderFighterAvailable(fighter);

  bool _followerFighterAvailable(String fighter) =>
      leaderAdvantage.followerFighterAvailable(fighter) &&
      followerAdvantage.followerFighterAvailable(fighter) &&
      neutralGame.followerFighterAvailable(fighter);

  void initialize(Set<String> leaderPicks, Set<String> followerPicks) {
    leaderFighters = leaderPicks;
    followerFighters = followerPicks;
    print('Leader has $leaderFighters');
    print('Follower has $followerFighters');
  }

  void assignMyAdvantage(String fighter) {
    if (leaderIsAssigning) {
      _clearLeader(fighter);
      leaderAdvantage.leaderPick = fighter;
    } else {
      _clearFollower(fighter);
      followerAdvantage.followerPick = fighter;
    }
  }

  void assignYourAdvantage(String fighter) {
    if (leaderIsAssigning) {
      _clearLeader(fighter);
      followerAdvantage.leaderPick = fighter;
    } else {
      _clearFollower(fighter);
      leaderAdvantage.followerPick = fighter;
    }
  }

  void assignNeutral(String fighter) {
    if (leaderIsAssigning) {
      _clearLeader(fighter);
      neutralGame.leaderPick = fighter;
    } else {
      _clearFollower(fighter);
      neutralGame.followerPick = fighter;
    }
  }

  bool get filled =>
      leaderAdvantage.filled(leaderIsAssigning) &&
      followerAdvantage.filled(leaderIsAssigning) &&
      neutralGame.filled(leaderIsAssigning);

  Set<String> get myFighters =>
      leaderIsAssigning ? leaderFighters : followerFighters;

  Set<String> get yourFighters =>
      leaderIsAssigning ? followerFighters : leaderFighters;

  String? get myAdvantage => leaderIsAssigning
      ? (leaderAdvantage.leaderPick.isEmpty ? null : leaderAdvantage.leaderPick)
      : (followerAdvantage.followerPick.isEmpty
          ? null
          : followerAdvantage.followerPick);

  String? get yourAdvantage => leaderIsAssigning
      ? (followerAdvantage.leaderPick.isEmpty
          ? null
          : followerAdvantage.leaderPick)
      : (leaderAdvantage.followerPick.isEmpty
          ? null
          : leaderAdvantage.followerPick);

  String? get neutralPick => leaderIsAssigning
      ? (neutralGame.leaderPick.isEmpty ? null : neutralGame.leaderPick)
      : (neutralGame.followerPick.isEmpty ? null : neutralGame.followerPick);

  void clear() {
    leaderAdvantage.clear();
    followerAdvantage.clear();
    neutralGame.clear();
    leaderIsAssigning = true;
    leaderFighters.clear();
    followerFighters.clear();
  }

  void _clearLeader(String fighter) {
    if (!_leaderFighterAvailable(fighter)) {
      leaderAdvantage.removeLeaderFighter(fighter);
      followerAdvantage.removeLeaderFighter(fighter);
      neutralGame.removeLeaderFighter(fighter);
    }
  }

  void _clearFollower(String fighter) {
    if (!_followerFighterAvailable(fighter)) {
      leaderAdvantage.removeFollowerFighter(fighter);
      followerAdvantage.removeFollowerFighter(fighter);
      neutralGame.removeFollowerFighter(fighter);
    }
  }
}