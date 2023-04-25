import 'dart:async';

import 'package:flutter/material.dart';

const Icon onePlayerIcon = Icon(Icons.person_rounded);
const Icon twoPlayerIcon = Icon(Icons.people_alt_rounded);
const Icon helpIcon = Icon(Icons.help);
const Icon sortIcon = Icon(Icons.sort);

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
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
