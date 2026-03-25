import 'package:flutter/material.dart';

/// Extension for filtering nulls from iterables.
extension ListFilterExt<T> on Iterable<T?> {
  List<T> get withoutNulls => where((s) => s != null).map((e) => e!).toList();
}

/// Extension for dividing, padding and wrapping widget lists.
extension ListDivideExt<T extends Widget> on Iterable<T> {
  Iterable<MapEntry<int, Widget>> get enumerate => toList().asMap().entries;

  List<Widget> divide(Widget t) => isEmpty
      ? []
      : (enumerate.map((e) => [e.value, t]).expand((i) => i).toList()
        ..removeLast());

  List<Widget> around(Widget t) => addToStart(t).addToEnd(t);

  List<Widget> addToStart(Widget t) =>
      enumerate.map((e) => e.value).toList()..insert(0, t);

  List<Widget> addToEnd(Widget t) =>
      enumerate.map((e) => e.value).toList()..add(t);

  List<Padding> paddingTopEach(double val) =>
      map((w) => Padding(padding: EdgeInsets.only(top: val), child: w))
          .toList();
}

/// Extension for sorting iterables.
extension IterableExt<T> on Iterable<T> {
  List<T> sortedList<S extends Comparable>([S Function(T)? keyOf]) => toList()
    ..sort(keyOf == null ? null : ((a, b) => keyOf(a).compareTo(keyOf(b))));
}

/// Extension for getting the bounding box of a widget.
Rect? getWidgetBoundingBox(BuildContext context) {
  try {
    final renderBox = context.findRenderObject() as RenderBox?;
    return renderBox!.localToGlobal(Offset.zero) & renderBox.size;
  } on Exception catch (_) {
    return null;
  }
}

/// Safe setState — only calls [fn] if the widget is still mounted.
extension StatefulWidgetExtensions on State<StatefulWidget> {
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      // ignore: invalid_use_of_protected_member
      setState(fn);
    }
  }
}

/// Sets the app-wide [ThemeMode] via [AppView].
/// Import app.dart alongside this file when using setDarkModeSetting.
// Note: setDarkModeSetting is kept in app.dart to avoid circular imports.
