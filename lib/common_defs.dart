import 'package:flutter/material.dart';

const Icon onePlayerIcon = Icon(Icons.person_rounded);
const Icon twoPlayerIcon = Icon(Icons.people_alt_rounded);
const Icon helpIcon = Icon(Icons.info);

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}
