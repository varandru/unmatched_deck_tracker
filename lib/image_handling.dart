import 'package:flutter/material.dart';

String getCardbackPath(String deckName) =>
    "unmatched_deck_tracker_assets/images/cardbacks/$deckName.jpg";

AssetImage getCardbackByName(String deckName) =>
    AssetImage(getCardbackPath(deckName));

AssetImage getLogo() =>
    const AssetImage('unmatched_deck_tracker_assets/images/logo.jpg');
