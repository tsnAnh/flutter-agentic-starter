// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_agentic_starter/widgetbook/use_cases/collection_layout_use_cases.dart'
    as _flutter_agentic_starter_widgetbook_use_cases_collection_layout_use_cases;
import 'package:flutter_agentic_starter/widgetbook/use_cases/feedback_media_use_cases.dart'
    as _flutter_agentic_starter_widgetbook_use_cases_feedback_media_use_cases;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'shared',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'widgets',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'AppAvatarImage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Editable URL',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_feedback_media_use_cases
                        .appAvatarImageUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'AppEmptyWidget',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_feedback_media_use_cases
                        .appEmptyDefaultUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'With action',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_feedback_media_use_cases
                        .appEmptyActionUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'AppErrorWidget',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'With retry',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_feedback_media_use_cases
                        .appErrorWithRetryUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Without retry',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_feedback_media_use_cases
                        .appErrorWithoutRetryUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'AppImage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Editable URL',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_feedback_media_use_cases
                        .appImageEditableUrlUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Error fallback',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_feedback_media_use_cases
                        .appImageErrorUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'AppLoadingWidget',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Shimmer',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_feedback_media_use_cases
                        .appLoadingShimmerUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Spinner',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_feedback_media_use_cases
                        .appLoadingSpinnerUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'AppShimmer',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Card',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_feedback_media_use_cases
                        .appShimmerCardUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Custom block',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_feedback_media_use_cases
                        .appShimmerCustomUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'List',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_feedback_media_use_cases
                        .appShimmerListUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'Gap',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Token sizes',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_feedback_media_use_cases
                        .gapTokenSizesUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'PaginatedGridView',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Empty',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_collection_layout_use_cases
                        .paginatedGridEmptyUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Failure',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_collection_layout_use_cases
                        .paginatedGridFailureUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Success',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_collection_layout_use_cases
                        .paginatedGridSuccessUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'PaginatedListView',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Empty',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_collection_layout_use_cases
                        .paginatedListEmptyUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Failure',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_collection_layout_use_cases
                        .paginatedListFailureUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Success',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_collection_layout_use_cases
                        .paginatedListSuccessUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'PlatformWidget',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Cupertino',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_collection_layout_use_cases
                        .platformWidgetCupertinoUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Material',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_collection_layout_use_cases
                        .platformWidgetMaterialUseCase,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Selected viewport',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_collection_layout_use_cases
                        .platformWidgetViewportUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'PullToRefreshWrapper',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Pull to refresh',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_collection_layout_use_cases
                        .pullToRefreshUseCase,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'ResponsiveBuilder',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Breakpoint variants',
                builder:
                    _flutter_agentic_starter_widgetbook_use_cases_collection_layout_use_cases
                        .responsiveBuilderUseCase,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
