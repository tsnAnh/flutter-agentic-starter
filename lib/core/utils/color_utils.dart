import 'package:flutter/material.dart';
import 'package:from_css_color/from_css_color.dart';

/// Parses a CSS color string into a Flutter [Color].
/// Returns [defaultColor] (or black) if parsing fails.
Color colorFromCssString(String color, {Color? defaultColor}) {
  try {
    return fromCssColor(color);
  } on Exception catch (_) {}
  return defaultColor ?? Colors.black;
}
