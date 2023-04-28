import 'dart:async';

import 'package:flutter/material.dart';

const Icon onePlayerIcon = Icon(Icons.person_rounded);
const Icon twoPlayerIcon = Icon(Icons.people_alt_rounded);
const Icon helpIcon = Icon(Icons.help);
const Icon sortIcon = Icon(Icons.sort);

enum CardSize { small, medium, large, doNoClamp }

const double minSmallCardWidth = 0.0;
const double minMediumCardWidth = 0.0;
const double minLargeCardWidth = 0.0;
const double maxSmallCardWidth = 50.0;
const double maxMediumCardWidth = 200.0;
const double maxLargeCardWidth = 600.0;
const double minSmallCardHeight = 20.0 * 1.5;
const double minMediumCardHeight = 120.0 * 1.5;
const double minLargeCardHeight = 300.0 * 1.5;
const double maxSmallCardHeight = 50.0 * 1.5;
const double maxMediumCardHeight = 200.0 * 1.5;
const double maxLargeCardHeight = 600.0 * 1.5;

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

double getEvenlySpacedWidth(BuildContext context, int cardPerRow, CardSize size,
    {double spacing = 4.0}) {
  final screenWidth = MediaQuery.of(context).size.width - spacing;
  double width = screenWidth / cardPerRow - spacing;
  switch (size) {
    case CardSize.small:
      return width.clamp(minSmallCardWidth, maxSmallCardWidth);
    case CardSize.medium:
      return width.clamp(minMediumCardWidth, maxMediumCardWidth);
    case CardSize.large:
      return width.clamp(minLargeCardWidth, maxLargeCardWidth);
    case CardSize.doNoClamp:
      return width;
  }
}

double getEvenlySpacedHeight(
    BuildContext context, int itemsPerRow, CardSize size,
    {double spacing = 4.0}) {
  final screenHeight = MediaQuery.of(context).size.height - spacing;
  double height = screenHeight / itemsPerRow - spacing;
  switch (size) {
    case CardSize.small:
      return height.clamp(minSmallCardHeight, maxSmallCardHeight);
    case CardSize.medium:
      return height.clamp(minMediumCardHeight, maxMediumCardHeight);
    case CardSize.large:
      return height.clamp(minLargeCardHeight, maxLargeCardHeight);
    case CardSize.doNoClamp:
      return height;
  }
}

class TimeOutButton extends StatefulWidget {
  const TimeOutButton(this.callback, {super.key});

  final VoidCallback callback;

  @override
  State<TimeOutButton> createState() => _TimeOutButtonState();
}

class _TimeOutButtonState extends State<TimeOutButton> {
  bool countDownComplete = false;
  int _counter = 3;

  String buttonText = "OK (3)";

  void tickTimer(Timer timer) {
    if (_counter == 0) {
      setState(() {
        buttonText = "OK";
      });
      timer.cancel();
    } else {
      setState(() {
        buttonText = "OK ($_counter)";
      });
    }
    _counter--;
  }

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), tickTimer);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _timer!.isActive ? null : widget.callback,
      child: Text(buttonText),
    );
  }
}

class ExpandCollapseButton extends StatefulWidget {
  const ExpandCollapseButton(
      {Key? key, required this.expandAll, required this.collapseAll})
      : super(key: key);

  final VoidCallback expandAll;
  final VoidCallback collapseAll;

  @override
  ExpandCollapseButtonState createState() => ExpandCollapseButtonState();
}

class ExpandCollapseButtonState extends State<ExpandCollapseButton> {
  bool _allExpanded = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) => RotationTransition(
                turns: child.key == const ValueKey('expand')
                    ? Tween<double>(begin: 1, end: 0.5).animate(anim)
                    : Tween<double>(begin: 0.5, end: 1).animate(anim),
                child: ScaleTransition(scale: anim, child: child),
              ),
          child: _allExpanded
              ? const Icon(Icons.unfold_less, key: ValueKey('expand'))
              : const Icon(Icons.unfold_more, key: ValueKey('collapse'))),
      onPressed: () {
        setState(() {
          _allExpanded = !_allExpanded;
        });
        _allExpanded ? widget.expandAll() : widget.collapseAll();
      },
    );
  }
}
