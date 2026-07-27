import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../core/design_system/app_radius.dart';
import '../../core/design_system/app_spacing.dart';
import '../../shared/widgets/app_empty_widget.dart';
import '../../shared/widgets/app_error_widget.dart';
import '../../shared/widgets/app_image.dart';
import '../../shared/widgets/app_loading_widget.dart';
import '../../shared/widgets/app_shimmer.dart';
import '../../shared/widgets/gap.dart';

const _invalidImageUrl = 'https://example.invalid/image.jpg';

@widgetbook.UseCase(name: 'Spinner', type: AppLoadingWidget)
Widget appLoadingSpinnerUseCase(BuildContext context) {
  return AppLoadingWidget(
    message: context.knobs.string(
      label: 'Message',
      initialValue: 'Loading content…',
    ),
  );
}

@widgetbook.UseCase(name: 'Shimmer', type: AppLoadingWidget)
Widget appLoadingShimmerUseCase(BuildContext context) {
  return const Padding(
    padding: EdgeInsets.all(AppSpacing.md),
    child: AppLoadingWidget(type: LoadingType.shimmer),
  );
}

@widgetbook.UseCase(name: 'Custom block', type: AppShimmer)
Widget appShimmerCustomUseCase(BuildContext context) {
  return Center(
    child: AppShimmer(
      width: context.knobs.double.slider(
        label: 'Width',
        initialValue: 240,
        min: 80,
        max: 480,
      ),
      height: context.knobs.double.slider(
        label: 'Height',
        initialValue: 120,
        min: 40,
        max: 320,
      ),
      borderRadius: BorderRadius.circular(
        context.knobs.double.slider(
          label: 'Corner radius',
          initialValue: AppRadius.sm,
          min: 0,
          max: AppRadius.xl,
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Card', type: AppShimmer)
Widget appShimmerCardUseCase(BuildContext context) {
  return const Padding(
    padding: EdgeInsets.all(AppSpacing.md),
    child: AppShimmer.card(),
  );
}

@widgetbook.UseCase(name: 'List', type: AppShimmer)
Widget appShimmerListUseCase(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(AppSpacing.md),
    child: AppShimmer.list(
      itemCount: context.knobs.int.slider(
        label: 'Item count',
        initialValue: 5,
        min: 1,
        max: 10,
      ),
      itemHeight: context.knobs.double.slider(
        label: 'Item height',
        initialValue: 72,
        min: 40,
        max: 160,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Default', type: AppEmptyWidget)
Widget appEmptyDefaultUseCase(BuildContext context) {
  return AppEmptyWidget(
    message: context.knobs.string(
      label: 'Message',
      initialValue: 'No items yet',
    ),
  );
}

@widgetbook.UseCase(name: 'With action', type: AppEmptyWidget)
Widget appEmptyActionUseCase(BuildContext context) {
  return AppEmptyWidget(
    message: context.knobs.string(
      label: 'Message',
      initialValue: 'Your collection is empty',
    ),
    actionLabel: context.knobs.string(
      label: 'Action label',
      initialValue: 'Add item',
    ),
    onAction: () {},
  );
}

@widgetbook.UseCase(name: 'Without retry', type: AppErrorWidget)
Widget appErrorWithoutRetryUseCase(BuildContext context) {
  return AppErrorWidget(
    message: context.knobs.string(
      label: 'Message',
      initialValue: 'Something went wrong',
    ),
  );
}

@widgetbook.UseCase(name: 'With retry', type: AppErrorWidget)
Widget appErrorWithRetryUseCase(BuildContext context) {
  return AppErrorWidget(
    message: context.knobs.string(
      label: 'Message',
      initialValue: 'Could not load this content',
    ),
    onRetry: () {},
  );
}

@widgetbook.UseCase(name: 'Editable URL', type: AppImage)
Widget appImageEditableUrlUseCase(BuildContext context) {
  return Center(
    child: AppImage(
      url: context.knobs.string(
        label: 'Image URL',
        initialValue: _invalidImageUrl,
      ),
      width: context.knobs.double.slider(
        label: 'Width',
        initialValue: 280,
        min: 80,
        max: 560,
      ),
      height: context.knobs.double.slider(
        label: 'Height',
        initialValue: 180,
        min: 80,
        max: 400,
      ),
      borderRadius: AppRadius.borderMd,
    ),
  );
}

@widgetbook.UseCase(name: 'Error fallback', type: AppImage)
Widget appImageErrorUseCase(BuildContext context) {
  return const Center(
    child: AppImage(
      url: _invalidImageUrl,
      width: 280,
      height: 180,
      borderRadius: AppRadius.borderMd,
      errorWidget: _ImageErrorFallback(),
    ),
  );
}

@widgetbook.UseCase(name: 'Editable URL', type: AppAvatarImage)
Widget appAvatarImageUseCase(BuildContext context) {
  return Center(
    child: AppAvatarImage(
      url: context.knobs.string(
        label: 'Image URL',
        initialValue: _invalidImageUrl,
      ),
      size: context.knobs.double.slider(
        label: 'Size',
        initialValue: 64,
        min: 24,
        max: 160,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Token sizes', type: Gap)
Widget gapTokenSizesUseCase(BuildContext context) {
  return const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GapTokenRow(label: 'xs · 4', gap: Gap.xs()),
        _GapTokenRow(label: 'sm · 8', gap: Gap.sm()),
        _GapTokenRow(label: 'md · 16', gap: Gap.md()),
        _GapTokenRow(label: 'lg · 24', gap: Gap.lg()),
        _GapTokenRow(label: 'xl · 32', gap: Gap.xl()),
      ],
    ),
  );
}

class _ImageErrorFallback extends StatelessWidget {
  const _ImageErrorFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.broken_image_outlined, size: 40)),
    );
  }
}

class _GapTokenRow extends StatelessWidget {
  const _GapTokenRow({required this.label, required this.gap});

  final String label;
  final Gap gap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 72, child: Text(label)),
          const ColoredBox(
            color: Colors.blue,
            child: SizedBox(width: AppSpacing.sm, height: AppSpacing.sm),
          ),
          gap,
          const ColoredBox(
            color: Colors.blue,
            child: SizedBox(width: AppSpacing.sm, height: AppSpacing.sm),
          ),
        ],
      ),
    );
  }
}
