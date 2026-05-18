import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppMotion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 420);
  static const Duration page = Duration(milliseconds: 360);
  static const Curve curve = Curves.easeOutCubic;

  static Duration stagger(int index) =>
      Duration(milliseconds: 80 + (index * 45));
}

extension AppMotionX on Widget {
  Widget appEntrance({Duration delay = Duration.zero}) {
    return animate()
        .fadeIn(
          duration: AppMotion.normal,
          delay: delay,
          curve: AppMotion.curve,
        )
        .slideY(
          begin: 0.08,
          end: 0,
          duration: AppMotion.normal,
          curve: AppMotion.curve,
        );
  }

  Widget appScaleIn({Duration delay = Duration.zero}) {
    return animate()
        .fadeIn(
          duration: AppMotion.normal,
          delay: delay,
          curve: AppMotion.curve,
        )
        .scale(
          begin: const Offset(0.94, 0.94),
          end: const Offset(1, 1),
          duration: AppMotion.normal,
          curve: AppMotion.curve,
        );
  }
}
