import 'package:flutter/widgets.dart';
import '../../core/design_system/app_spacing.dart';

/// Spacing widget backed by design-system tokens.
///
/// Renders as a [SizedBox] with equal width and height, suitable for both
/// [Row] and [Column] children. Use named constructors for token-aligned gaps.
///
/// ```dart
/// Column(children: [
///   Text('Hello'),
///   Gap.md(),
///   Text('World'),
/// ])
/// ```
class Gap extends StatelessWidget {
  const Gap(this.size, {super.key});

  /// 4 dp
  const Gap.xs({super.key}) : size = AppSpacing.xs;

  /// 8 dp
  const Gap.sm({super.key}) : size = AppSpacing.sm;

  /// 16 dp
  const Gap.md({super.key}) : size = AppSpacing.md;

  /// 24 dp
  const Gap.lg({super.key}) : size = AppSpacing.lg;

  /// 32 dp
  const Gap.xl({super.key}) : size = AppSpacing.xl;

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size);
}
