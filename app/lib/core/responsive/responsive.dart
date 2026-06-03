import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Responsive {
  const Responsive._();

  static const double _tabletBreakpoint = 600;
  static const double _largeTabletBreakpoint = 1024;
  static const double _maxContentWidth = 980;
  static const double _modalMaxWidth = 650;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= _tabletBreakpoint;

  static bool isPhone(BuildContext context) => !isTablet(context);

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double contentMaxWidth(BuildContext context) {
    final width = screenWidth(context);
    if (width >= _largeTabletBreakpoint) return _maxContentWidth.w;
    return width;
  }

  static double horizontalPadding(BuildContext context) {
    if (isPhone(context)) return isLandscape(context) ? 14.w : 16.w;
    return isLandscape(context) ? 28.w : 24.w;
  }

  static int gridColumns(BuildContext context) {
    final width = screenWidth(context);
    final landscape = isLandscape(context);
    final tablet = isTablet(context);

    if (!tablet) {
      if (landscape && width >= 700) return 4;
      return landscape ? 3 : 2;
    }

    if (width >= 1200) return 6;
    if (width >= 1000) return 5;
    return 4;
  }

  static double modalWidth(BuildContext context) {
    final width = screenWidth(context);
    final rawWidth = isPhone(context) ? width * 0.94 : width * 0.78;
    return rawWidth.clamp(320.w, _modalMaxWidth.w).toDouble();
  }
}
