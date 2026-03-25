import 'package:flutter/material.dart';

/// Widget convenience extensions for common layout wrappers.
extension WidgetExtensions on Widget {
  /// Wraps the widget in symmetric [Padding] with [value] on all sides.
  Widget padAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  /// Wraps the widget in horizontal/vertical [Padding].
  Widget padSymmetric({double horizontal = 0, double vertical = 0}) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: this,
      );

  /// Wraps the widget in a [Center].
  Widget get center => Center(child: this);

  /// Wraps the widget in [Expanded] with the given [flex] factor.
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);

  /// Wraps the widget in [SliverToBoxAdapter] for use in slivers.
  Widget get sliver => SliverToBoxAdapter(child: this);

  /// Wraps the widget in [Opacity].
  Widget withOpacity(double opacity) =>
      Opacity(opacity: opacity, child: this);

  /// Wraps the widget in a [Visibility] toggle.
  Widget visible(bool isVisible) =>
      Visibility(visible: isVisible, child: this);
}
