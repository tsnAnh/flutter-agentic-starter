import 'dart:io';
import 'package:flutter/widgets.dart';

/// Renders [cupertino] on iOS/macOS, [material] on all other platforms.
///
/// Useful for rendering platform-native UI without manual `Platform.isIOS`
/// checks at every call site.
class PlatformWidget extends StatelessWidget {
  const PlatformWidget({
    super.key,
    required this.material,
    required this.cupertino,
  });

  final Widget material;
  final Widget cupertino;

  @override
  Widget build(BuildContext context) {
    return (Platform.isIOS || Platform.isMacOS) ? cupertino : material;
  }
}
