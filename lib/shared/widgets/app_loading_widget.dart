import 'package:flutter/material.dart';
import 'app_shimmer.dart';

/// Determines the visual style of [AppLoadingWidget].
enum LoadingType { spinner, shimmer }

/// Centered loading indicator — spinner or shimmer list placeholder.
class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({
    super.key,
    this.type = LoadingType.spinner,
    this.message,
  });

  final LoadingType type;

  /// Optional label shown beneath the spinner.
  final String? message;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      LoadingType.spinner => _SpinnerLoading(message: message),
      LoadingType.shimmer => const AppShimmer.list(),
    };
  }
}

class _SpinnerLoading extends StatelessWidget {
  const _SpinnerLoading({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator.adaptive(),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
