import 'package:flutter/material.dart';

/// Wraps [child] in a [RefreshIndicator] for pull-to-refresh support.
///
/// [onRefresh] must return a [Future] that completes when the refresh is done.
class PullToRefreshWrapper extends StatelessWidget {
  const PullToRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: onRefresh,
      child: child,
    );
  }
}
