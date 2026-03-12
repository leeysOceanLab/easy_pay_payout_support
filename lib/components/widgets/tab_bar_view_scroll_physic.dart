import 'package:flutter/material.dart';

class TabBarViewScrollPhysics extends ScrollPhysics {
  const TabBarViewScrollPhysics({ScrollPhysics? parent})
    : super(parent: parent ?? const ClampingScrollPhysics());

  @override
  TabBarViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return TabBarViewScrollPhysics(
      parent: buildParent(ancestor) ?? const ClampingScrollPhysics(),
    );
  }

  @override
  SpringDescription get spring =>
      const SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0);
}
