import 'package:flutter/widgets.dart';
import '../../core/utils/responsive_utils.dart';

/// Renders a different widget based on the current screen width breakpoint.
///
/// Breakpoints (from [responsive_utils.dart]):
/// - mobile  : width < 479
/// - tablet  : 479 ≤ width < 767
/// - desktop : width ≥ 767
///
/// Falls back to the nearest smaller breakpoint widget when a slot is null.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
  }) : assert(
          mobile != null || tablet != null || desktop != null,
          'At least one layout widget must be provided.',
        );

  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= kBreakpointMedium) {
      return desktop ?? tablet ?? mobile ?? const SizedBox.shrink();
    }
    if (width >= kBreakpointSmall) {
      return tablet ?? mobile ?? desktop ?? const SizedBox.shrink();
    }
    return mobile ?? tablet ?? desktop ?? const SizedBox.shrink();
  }
}
