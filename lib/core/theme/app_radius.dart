import 'package:flutter/material.dart';

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double round = 999.0;

  static final BorderRadius small = BorderRadius.circular(sm);
  static final BorderRadius medium = BorderRadius.circular(md);
  static final BorderRadius large = BorderRadius.circular(lg);
  static final BorderRadius extraLarge = BorderRadius.circular(xl);
  static final BorderRadius circular = BorderRadius.circular(round);
  static final BorderRadius card = BorderRadius.circular(xl);
  static final BorderRadius control = BorderRadius.circular(lg);
  static final BorderRadius chip = BorderRadius.circular(round);

  static const Radius bubbleTail = Radius.circular(6);
}
