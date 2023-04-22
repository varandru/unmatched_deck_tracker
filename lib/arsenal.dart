import 'package:unmatched_deck_tracker/deck.dart';

const int ARSENAL_SIZE = 4;

class RoundPick {
  Set<String> leaderPicks = Set.identity();
  Set<String> commonPicks = Set.identity();
  Set<String> followerPicks = Set.identity();
}

class ArsenalDraft {
  ArsenalDraft();

  Set<String> pool = Set.identity();

  Set<String> leaderChoice = Set.identity();
  Set<String> leaderHiddenPicks = Set.identity();
  Set<String> followerChoice = Set.identity();
  Set<String> followerHiddenPicks = Set.identity();

  Set<String> currentPicks = Set.identity();

  bool leaderIsPicking = true;

  List<RoundPick> roundHistory = [];

  void init(List<ShortDeck> decks) {
    pool = Set.from(decks.map((e) => e.name).toSet());
  }

  void _movePoolToLeader() {
    pool.removeAll(currentPicks);
    leaderHiddenPicks.addAll(currentPicks);
    currentPicks.clear();
  }

  void _movePoolToFollower() {
    pool.removeAll(currentPicks);
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

  bool nextRound() {
    RoundPick pick = RoundPick();
    pick.commonPicks = leaderHiddenPicks.intersection(followerHiddenPicks);
    pick.leaderPicks = leaderHiddenPicks.difference(followerHiddenPicks);
    pick.followerPicks = followerHiddenPicks.difference(leaderHiddenPicks);

    leaderChoice.addAll(pick.leaderPicks);
    followerChoice.addAll(pick.followerPicks);

    roundHistory.add(pick);

    leaderHiddenPicks.clear();
    followerHiddenPicks.clear();

    if (leaderChoice.length != followerChoice.length) {
      throw Exception("Somehow different amount of picks. "
          "Leader: ${leaderChoice.toString()}. "
          "Follower: ${followerChoice.toString()}");
    }

    leaderIsPicking = true;

    return leaderChoice.length == ARSENAL_SIZE;
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
