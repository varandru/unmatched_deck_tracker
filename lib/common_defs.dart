import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const Icon onePlayerIcon = Icon(Icons.person_rounded);
const Icon twoPlayerIcon = Icon(Icons.people_alt_rounded);
const Icon helpIcon = Icon(Icons.help);
const Icon sortIcon = Icon(Icons.sort);

enum CardSize { small, medium, large, doNoClamp }

const double standardSpacing = 4.0;

const int cardsPerRowHorizontal = 6;
const int cardsPerRowVertical = 4;

const double maxSmallCardWidth = 60.0;
const double maxMediumCardWidth = 120.0;
const double maxLargeCardWidth = 600.0;
const double maxSmallCardHeight = maxSmallCardWidth * 1.5;
const double maxMediumCardHeight = maxMediumCardWidth * 1.5;
const double maxLargeCardHeight = maxLargeCardWidth * 1.5;

const double maxWideColumnWidth =
    (maxMediumCardWidth + standardSpacing * 2) * cardsPerRowHorizontal;
const double maxNarrowColumnWidth =
    (maxMediumCardWidth + standardSpacing * 2) * cardsPerRowVertical;
const double maxDrawerColumnWidth = 250.0;

bool checkMobile(BuildContext context) {
  if (kIsWeb) {
    return Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.fuchsia;
  } else {
    if (Platform.isAndroid || Platform.isIOS) {
      return true;
    }
  }
  return false;
}

bool checkDrawer(BuildContext context) {
  bool isMobile = checkMobile(context);
  return isMobile ||
      (MediaQuery.of(context).size.width <= maxDrawerColumnWidth * 2.5);
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

double getScaffoldOffset(BuildContext context) {
  if (checkDrawer(context)) {
    return 0.0;
  } else {
    return maxDrawerColumnWidth;
  }
}

double getEvenlySpacedWidth(BuildContext context, int cardPerRow, CardSize size,
    {double spacing = 4.0}) {
  final screenWidth =
      MediaQuery.of(context).size.width - spacing - getScaffoldOffset(context);
  double width = screenWidth / cardPerRow - spacing;
  switch (size) {
    case CardSize.small:
      return width.clamp(0.0, maxSmallCardWidth);
    case CardSize.medium:
      return width.clamp(0.0, maxMediumCardWidth);
    case CardSize.large:
      return width.clamp(0.0, maxLargeCardWidth);
    case CardSize.doNoClamp:
      return width;
  }
}

double getEvenlySpacedHeight(
    BuildContext context, int itemsPerRow, CardSize size,
    {double spacing = 4.0, bool hasBottomBar = false}) {
  final screenHeight = MediaQuery.of(context).size.height -
      spacing -
      (Scaffold.of(context).appBarMaxHeight ?? 0);

  double height = screenHeight / itemsPerRow - spacing;
  switch (size) {
    case CardSize.small:
      return height.clamp(0.0, maxSmallCardHeight);
    case CardSize.medium:
      return height.clamp(0.0, maxMediumCardHeight);
    case CardSize.large:
      return height.clamp(0.0, maxLargeCardHeight);
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

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold(
      {super.key,
      this.appBar,
      required this.body,
      this.drawer,
      this.bottomNavigationBar});

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? drawer;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    if (checkDrawer(context)) {
      return Scaffold(
        appBar: appBar,
        body: body,
        drawer: drawer,
        bottomNavigationBar: bottomNavigationBar,
        resizeToAvoidBottomInset: true,
      );
    } else {
      late Widget stackedBody;
      if (drawer == null) {
        stackedBody = body;
      } else {
        stackedBody = Flex(
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.min,
            children: [
              drawer!,
              Expanded(child: body),
            ]);
      }

      return Scaffold(
        appBar: appBar,
        body: stackedBody,
        bottomNavigationBar: bottomNavigationBar,
        resizeToAvoidBottomInset: true,
      );
    }
  }
}
