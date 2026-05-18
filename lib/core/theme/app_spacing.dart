import 'package:flutter/material.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Reusable SizedBoxes for vertical spacing
  static const Widget vXs = SizedBox(height: xs);
  static const Widget vSm = SizedBox(height: sm);
  static const Widget vMd = SizedBox(height: md);
  static const Widget vLg = SizedBox(height: lg);
  static const Widget vXl = SizedBox(height: xl);
  static const Widget vXxl = SizedBox(height: xxl);

  // Reusable SizedBoxes for horizontal spacing
  static const Widget hXs = SizedBox(width: xs);
  static const Widget hSm = SizedBox(width: sm);
  static const Widget hMd = SizedBox(width: md);
  static const Widget hLg = SizedBox(width: lg);
  static const Widget hXl = SizedBox(width: xl);
  static const Widget hXxl = SizedBox(width: xxl);

  // Padding presets
  static const EdgeInsets pagePadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(md);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: md,
  );
}
