import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_spacing.dart';
import '../../core/design_system/app_radius.dart';

/// Shimmer placeholder widget wrapping the [shimmer] package.
///
/// Named constructors:
/// - [AppShimmer.list] — vertical list of shimmer rows.
/// - [AppShimmer.card] — card-shaped shimmer block.
class AppShimmer extends StatelessWidget {
  /// Custom-size shimmer block.
  const AppShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  })  : _type = _ShimmerType.custom,
        _itemCount = 6,
        _itemHeight = 72;

  /// Vertical list shimmer with [itemCount] rows of [itemHeight].
  const AppShimmer.list({
    super.key,
    int itemCount = 6,
    double itemHeight = 72,
  })  : _type = _ShimmerType.list,
        _itemCount = itemCount,
        _itemHeight = itemHeight,
        width = double.infinity,
        height = double.infinity,
        borderRadius = null;

  /// Card-shaped shimmer block (full-width, 120px tall).
  const AppShimmer.card({super.key})
      : _type = _ShimmerType.card,
        _itemCount = 1,
        _itemHeight = 120,
        width = double.infinity,
        height = 120,
        borderRadius = null;

  final _ShimmerType _type;
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final int _itemCount;
  final double _itemHeight;

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark.surface
        : AppColors.background;
    final highlightColor = Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark.surfaceVariant
        : AppColors.surface;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: switch (_type) {
        _ShimmerType.list => _ListShimmer(
            itemCount: _itemCount,
            itemHeight: _itemHeight,
          ),
        _ShimmerType.card => _BlockShimmer(
            width: double.infinity,
            height: _itemHeight,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        _ShimmerType.custom => _BlockShimmer(
            width: width,
            height: height,
            borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.sm),
          ),
      },
    );
  }
}

enum _ShimmerType { list, card, custom }

class _BlockShimmer extends StatelessWidget {
  const _BlockShimmer({
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
      ),
    );
  }
}

class _ListShimmer extends StatelessWidget {
  const _ListShimmer({required this.itemCount, required this.itemHeight});

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (context, i) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) => Container(
        height: itemHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }
}
