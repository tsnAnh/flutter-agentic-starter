import 'package:flutter/material.dart';

/// Renders [cupertino] on iOS/macOS, [material] on all other platforms.
///
/// Uses the inherited theme platform so previews and tests can override it.
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
    final platform = Theme.of(context).platform;
    return (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS)
        ? cupertino
        : material;
  }
}
