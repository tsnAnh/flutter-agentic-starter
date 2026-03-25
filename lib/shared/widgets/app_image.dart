import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/design_system/app_radius.dart';
import 'app_shimmer.dart';

/// Network image with shimmer placeholder and error fallback.
///
/// Wraps [CachedNetworkImage] so call-sites remain decoupled from
/// the caching implementation.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Custom placeholder shown while loading. Defaults to [AppShimmer].
  final Widget? placeholder;

  /// Custom widget shown on error. Defaults to a grey error icon.
  final Widget? errorWidget;

  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ??
          AppShimmer(
            width: width ?? double.infinity,
            height: height ?? 120,
            borderRadius: borderRadius,
          ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            width: width,
            height: height,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
          ),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}

/// Circular avatar variant of [AppImage].
class AppAvatarImage extends StatelessWidget {
  const AppAvatarImage({
    super.key,
    required this.url,
    this.size = 40,
  });

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AppImage(
      url: url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: AppRadius.borderFull,
    );
  }
}
