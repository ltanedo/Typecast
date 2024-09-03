import 'package:flutter/material.dart';

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor)!);
  }

  // @override
  // SpringDescription get spring => const SpringDescription(
  //       mass: 100,
  //       stiffness: 10,
  //       damping: 101,
  //     );

  @override
  double get dragStartDistanceMotionThreshold => 100;
  @override
  double get minFlingDistance => 200;

  // @override
  // Simulation createBallisticSimulation(
  //     ScrollMetrics position, double velocity) {
  //   return CustomSimulation(
  //     // initPosition: position.pixels,
  //     velocity: velocity,
  //   );
  // }
}
