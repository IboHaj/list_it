import 'package:flutter/material.dart';

extension WidgetUtils on Widget {
  Widget paddingAll([double all = 10]) {
    return Padding(padding: EdgeInsetsGeometry.all(all), child: this);
  }

  Widget paddingLTRB([double L = 10, double T = 10, double R = 10, double B = 10]) {
    return Padding(padding: EdgeInsetsGeometry.fromLTRB(L, T, R, B), child: this);
  }

  Widget paddingSymmetric([double horizontal = 10, double vertical = 10]) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: vertical, horizontal: horizontal),
      child: this,
    );
  }

  Widget paddingOnlyB([double bottom = 10]) {
    return Padding(
      padding: EdgeInsetsGeometry.only(bottom: bottom),
      child: this,
    );
  }

  Widget paddingOnlyT([double top = 10]) {
    return Padding(
      padding: EdgeInsetsGeometry.only(top: top),
      child: this,
    );
  }
}

extension ContextUtils on BuildContext {
  ThemeData get appTheme => Theme.of(this);

  ColorScheme get scheme => appTheme.colorScheme;

  Color get primary => scheme.primary;

  Color get primaryContainer => scheme.primaryContainer;

  Color get secondary => scheme.secondary;

  Color get secondaryContainer => scheme.secondaryContainer;

  Color get tertiary => scheme.tertiary;

  Color get tertiaryContainer => scheme.tertiaryContainer;

  Color get onTertiary => scheme.onTertiary;

  Color get onPrimaryContainer => scheme.onPrimaryContainer;

  Color get onSecondaryContainer => scheme.onSecondaryContainer;

  Color get onTertiaryContainer => scheme.onTertiaryContainer;

  Color get primaryFixed => scheme.primaryFixed;

  Color get inversePrimary => scheme.inversePrimary;

  Color get onInverseSurface => scheme.onInverseSurface;

  Color get inverseSurface => scheme.inverseSurface;

  Color get onErrorContainer => scheme.onErrorContainer;

  double get height => MediaQuery.heightOf(this);

  double get width => MediaQuery.widthOf(this);
}
